# Desain Basis Data: Drift SQLite & Supabase PostgreSQL

> **Implementasi ROOTIN-M009 (#8, 25 Oktober 2026):** DDL dan RPC yang berlaku ada di
> `supabase/migrations/20261025000000_mobile_backend.sql`; contoh SQL lama di bawah
> adalah rancangan historis, bukan kode yang dapat dijalankan. Test lokal:
> `npx supabase db reset --local` dan `npx supabase test db --local`.
> Tabel server: `items`, `reminders`, `reminder_logs`, `progress_events`,
> `user_preferences`, `processed_operations`. Foto disimpan di bucket privat
> `item-photos` dengan batas 2 MiB, MIME jpeg/png/webp dan path
> `{user_id}/{item_id}/{file_uuid}.{ext}`; baca/unggah/hapus memerlukan item milik pengguna.
> Semua tabel mempunyai RLS baca berdasarkan `auth.uid() = user_id`; authenticated
> tidak memperoleh grant tulis tabel. Penulisan hanya melalui RPC dengan pemeriksaan
> pemilik dan relasi komposit `(id,user_id)`. Riwayat tidak dapat diedit/hapus,
> termasuk ketika item diarsipkan atau ditombstone; penghapusan akun oleh auth
> tetap menghapus data melalui FK cascade. Tidak ada endpoint hard-delete item.
> `operation_id` unik global dan dipartisi secara logis menurut pemilik; retry
> identik mengembalikan **hasil asli**, bukan status `duplicate_ignored`.
> Mencoba ID dari akun lain atau mengubah payload retry ditolak. Konflik versi
> menolak tulis dan mengembalikan `server_version`; **bukan LWW**. Urutan lock
> item lalu reminder, termasuk completion/progress, dan advisory lock operasi
> mencegah retry konkuren menggandakan event.
> Pull menggunakan kursor keyset `(changed_at, rank, id)`, bukan timestamp tunggal;
> pengambilan satu halaman secara berulang dapat kehilangan perubahan yang
> ditulis mundur ke timestamp lebih awal hanya bila jam server dimanipulasi.
> Data pending outbox lokal tidak dihapus saat konflik sampai client menyelesaikannya.

* **Status**: Accepted
* **Tanggal**: 2026-10-24
* **Tiket Referensi**: ROOTIN-M003 (GitHub Issue [#2](https://github.com/andresanjaya/rootin/issues/2))
* **Target Implementasi**: ROOTIN-M004 (Drift SQLite Persistence) & ROOTIN-M005 (Supabase Backend)

---

## 1. Prinsip & Konvensi Desain Basis Data

Desain basis data Rootin Mobile mengusung prinsip **offline-first reaktif** yang memadukan penyimpanan lokal berbasis SQLite (melalui ORM Drift) dan penyimpanan awan terdistribusi berbasis PostgreSQL (melalui Supabase).

### 1.1 Konvensi Kunci & Kolom Audit
1. **Primary Key (Kunci Utama)**:
   - Dibuat secara mandiri di sisi klien menggunakan format **UUIDv4** string 36-karakter (misal: `550e8400-e29b-41d4-a716-446655440000`).
   - Memungkinkan pembentukan relasi induk-anak (*parent-child relationship*) seketika tanpa membutuhkan konfirmasi atau putaran komunikasi (*round-trip*) ke server.
2. **Kolom Wajib Multi-Tenant & Audit**:
   - `user_id`: UUID pemilik data untuk isolasi multi-tenant.
   - `created_at`: Timestamp ISO 8601 UTC saat baris pertama kali dibuat.
   - `updated_at`: Timestamp ISO 8601 UTC saat pembaruan terakhir terjadi.
   - `deleted_at`: Timestamp ISO 8601 UTC penanda penghapusan lunak (*soft delete*). Nilai `NULL` menandakan rekaman aktif.
   - `version`: Integer berurutan (*revision counter*) dimulai dari `1`, dinaikkan setiap kali terjadi mutasi untuk mendukung resolusi konflik *Last-Write-Wins* (LWW).
3. **Pemisahan Format Tanggal vs Waktu**:
   - Tanggal kalender kalender murni menggunakan representasi `YYYY-MM-DD` (tipe `TEXT` di Drift, tipe `DATE` di PostgreSQL).
   - Waktu jam pengingat menggunakan representasi `HH:mm:ss` (tipe `TEXT` di Drift, tipe `TIME` di PostgreSQL).
   - Titik waktu audit dan riwayat instan menggunakan representasi ISO 8601 UTC (tipe `TEXT` di Drift, tipe `TIMESTAMPTZ` di PostgreSQL).

---

## 2. Skema Database Lokal Drift (SQLite)

Penyimpanan lokal menggunakan SQLite dengan mode WAL (*Write-Ahead Logging*) untuk mendukung pembacaan konkuren dan performa penulisan tinggi (< 15 ms).

```
┌─────────────────────────┐         ┌─────────────────────────┐
│          items          │ 1     N │        reminders        │
├─────────────────────────┤─────────┼─────────────────────────┤
│ id (PK, TEXT/UUID)      │         │ id (PK, TEXT/UUID)      │
│ user_id (TEXT/UUID)     │         │ item_id (FK, TEXT/UUID) │
│ name (TEXT)             │         │ user_id (TEXT/UUID)     │
│ category (TEXT)         │         │ engine_type (TEXT)      │
│ has_odometer (INT/BOOL) │         │ target_date (TEXT/DATE) │
│ current_odometer (INT)  │         │ target_time (TEXT/TIME) │
│ photo_local_path (TEXT) │         │ usage_counter (INT)     │
│ photo_remote_path (TEXT)│         │ interval_km (INT)       │
│ is_archived (INT/BOOL)  │         │ snooze_until (TEXT/UTC) │
│ deleted_at (TEXT/UTC)   │         │ deleted_at (TEXT/UTC)   │
│ version (INT)           │         │ version (INT)           │
└───────────┬─────────────┘         └───────────┬─────────────┘
            │                                   │
            │ 1                                 │ 1
            │                                   │
            │           N ┌─────────────────────┴───┐
            └─────────────┤      reminder_logs      │
                          ├─────────────────────────┤
                          │ id (PK, TEXT/UUID)      │
                          │ item_id (FK, TEXT/UUID) │
                          │ reminder_id (FK, TEXT)  │
                          │ completed_at (TEXT/UTC) │
                          │ completion_date (DATE)  │
                          │ cost (REAL)             │
                          │ performed_by (TEXT)     │
                          │ version (INT)           │
                          └─────────────────────────┘
```

### 2.1 Definisi Tabel Drift (Dart DDL)

#### A. Tabel `items`
Menyimpan profil aset, peralatan rumah tangga, atau kendaraan.

```sql
CREATE TABLE items (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('vehicle', 'appliance', 'furniture', 'facility', 'other')),
    brand TEXT,
    model_number TEXT,
    serial_or_plate_number TEXT,
    purchase_date TEXT, -- Format YYYY-MM-DD
    has_odometer INTEGER NOT NULL DEFAULT 0 CHECK (has_odometer IN (0, 1)),
    current_odometer INTEGER DEFAULT 0,
    photo_local_path TEXT,
    photo_remote_path TEXT,
    notes TEXT,
    is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1)),
    created_at TEXT NOT NULL, -- ISO 8601 UTC
    updated_at TEXT NOT NULL, -- ISO 8601 UTC
    deleted_at TEXT,         -- ISO 8601 UTC (NULL = aktif, NOT NULL = tombstone)
    version INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_items_user_active ON items (user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_items_user_archived ON items (user_id, is_archived) WHERE deleted_at IS NULL;
```

#### B. Tabel `reminders`
Menyimpan konfigurasi pengingat adaptif (Waktu, Pemakaian, Jarak).

```sql
CREATE TABLE reminders (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL,
    item_id TEXT NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    engine_type TEXT NOT NULL CHECK (engine_type IN ('time', 'usage', 'mileage')),

    -- Atribut Khusus Mesin Waktu (Time-Based)
    interval_unit TEXT CHECK (interval_unit IN ('days', 'weeks', 'months', 'years')),
    interval_value INTEGER CHECK (interval_value > 0),
    baseline_mode TEXT DEFAULT 'actual_completion' CHECK (baseline_mode IN ('actual_completion', 'strict_schedule')),
    anchor_day INTEGER CHECK (anchor_day BETWEEN 1 AND 31),
    target_date TEXT, -- Tanggal jatuh tempo kalender: YYYY-MM-DD
    target_time TEXT, -- Jam notifikasi: HH:mm:ss

    -- Atribut Khusus Mesin Pemakaian (Usage-Based)
    usage_counter INTEGER DEFAULT 0 CHECK (usage_counter >= 0),
    usage_threshold INTEGER CHECK (usage_threshold > 0),
    usage_unit TEXT, -- Misal: 'siklus', 'kali seduh', 'jam'

    -- Atribut Khusus Mesin Jarak (Mileage-Based)
    last_service_odometer INTEGER CHECK (last_service_odometer >= 0),
    interval_km INTEGER CHECK (interval_km > 0),

    -- Status & Siklus Penundaan (Snooze)
    snooze_until TEXT, -- ISO 8601 UTC titik waktu bangun alarm tunda
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),

    -- Kolom Audit & Sinkronisasi
    created_at TEXT NOT NULL, -- ISO 8601 UTC
    updated_at TEXT NOT NULL, -- ISO 8601 UTC
    deleted_at TEXT,         -- ISO 8601 UTC (tombstone)
    version INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_reminders_item ON reminders (item_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_reminders_user_active ON reminders (user_id, is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_reminders_target_date ON reminders (user_id, target_date) WHERE deleted_at IS NULL;
```

#### C. Tabel `reminder_logs`
Menyimpan riwayat pemeliharaan permanen (*immutable audit trail*).

```sql
CREATE TABLE reminder_logs (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL,
    item_id TEXT NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    reminder_id TEXT NOT NULL REFERENCES reminders(id) ON DELETE CASCADE,
    completed_at TEXT NOT NULL,   -- ISO 8601 UTC stempel waktu aktual selesai
    completion_date TEXT NOT NULL, -- YYYY-MM-DD tanggal servis kalender
    odometer_at_completion INTEGER,
    cost REAL,                   -- Nilai nominal biaya servis
    performed_by TEXT,           -- 'Mandiri', nama bengkel, atau teknisi
    notes TEXT,
    created_at TEXT NOT NULL,    -- ISO 8601 UTC
    version INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_logs_item ON reminder_logs (item_id);
CREATE INDEX idx_logs_reminder ON reminder_logs (reminder_id);
CREATE INDEX idx_logs_completed_date ON reminder_logs (user_id, completion_date DESC);
```

#### D. Tabel `sync_outbox`
Antrean mutasi lokal persisten yang mengimplementasikan pola Durable Outbox.

```sql
CREATE TABLE sync_outbox (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    operation_id TEXT NOT NULL UNIQUE, -- UUIDv4 client idempotency key
    user_id TEXT NOT NULL,
    entity_type TEXT NOT NULL CHECK (entity_type IN ('item', 'reminder', 'reminder_log')),
    record_id TEXT NOT NULL,
    operation_type TEXT NOT NULL CHECK (operation_type IN ('insert', 'update', 'delete')),
    payload_json TEXT NOT NULL,
    created_at TEXT NOT NULL, -- ISO 8601 UTC
    retry_count INTEGER NOT NULL DEFAULT 0,
    last_attempt_at TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'failed')),
    error_message TEXT
);

CREATE INDEX idx_outbox_queue ON sync_outbox (user_id, id ASC) WHERE status != 'failed';
```

#### E. Tabel `sync_metadata`
Menyimpan penanda posisi sinkronisasi (*sync checkpoint / cursor*) per pengguna.

```sql
CREATE TABLE sync_metadata (
    key TEXT PRIMARY KEY NOT NULL, -- Misal: 'checkpoint_all'
    user_id TEXT NOT NULL,
    last_synced_at TEXT,          -- ISO 8601 UTC kursor pull terakhir
    last_server_version INTEGER DEFAULT 0,
    updated_at TEXT NOT NULL
);
```

---

## 3. Skema Database PostgreSQL Supabase Mobile

Skema PostgreSQL di backend Supabase Mobile merefleksikan model data klien dengan penguatan tipe data relasional, integritas referensial, dan penegakan **Row-Level Security (RLS)** mutlak.

```sql
-- Ekstensi UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. TABEL ITEMS
CREATE TABLE public.items (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(30) NOT NULL CHECK (category IN ('vehicle', 'appliance', 'furniture', 'facility', 'other')),
    brand VARCHAR(100),
    model_number VARCHAR(100),
    serial_or_plate_number VARCHAR(50),
    purchase_date DATE,
    has_odometer BOOLEAN NOT NULL DEFAULT FALSE,
    current_odometer BIGINT DEFAULT 0,
    photo_remote_path TEXT,
    notes TEXT,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    deleted_at TIMESTAMPTZ,
    version INTEGER NOT NULL DEFAULT 1
);

-- 2. TABEL REMINDERS
CREATE TABLE public.reminders (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    engine_type VARCHAR(20) NOT NULL CHECK (engine_type IN ('time', 'usage', 'mileage')),
    interval_unit VARCHAR(20) CHECK (interval_unit IN ('days', 'weeks', 'months', 'years')),
    interval_value INTEGER CHECK (interval_value > 0),
    baseline_mode VARCHAR(30) DEFAULT 'actual_completion' CHECK (baseline_mode IN ('actual_completion', 'strict_schedule')),
    anchor_day SMALLINT CHECK (anchor_day BETWEEN 1 AND 31),
    target_date DATE,
    target_time TIME,
    usage_counter INTEGER DEFAULT 0 CHECK (usage_counter >= 0),
    usage_threshold INTEGER CHECK (usage_threshold > 0),
    usage_unit VARCHAR(50),
    last_service_odometer BIGINT CHECK (last_service_odometer >= 0),
    interval_km INTEGER CHECK (interval_km > 0),
    snooze_until TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    deleted_at TIMESTAMPTZ,
    version INTEGER NOT NULL DEFAULT 1
);

-- 3. TABEL REMINDER_LOGS (IMMUTABLE AUDIT TRAIL)
CREATE TABLE public.reminder_logs (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    reminder_id UUID NOT NULL REFERENCES public.reminders(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ NOT NULL,
    completion_date DATE NOT NULL,
    odometer_at_completion BIGINT,
    cost NUMERIC(12, 2),
    performed_by VARCHAR(150),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    version INTEGER NOT NULL DEFAULT 1
);

-- 4. TABEL PROCESSED_OPERATIONS (IDEMPOTENCY TRACKER SERVER)
CREATE TABLE public.processed_operations (
    operation_id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    entity_type VARCHAR(30) NOT NULL,
    record_id UUID NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- INDEKS PERFORMA
CREATE INDEX idx_pg_items_user ON public.items (user_id, updated_at);
CREATE INDEX idx_pg_reminders_user ON public.reminders (user_id, updated_at);
CREATE INDEX idx_pg_logs_user ON public.reminder_logs (user_id, completed_at);
CREATE INDEX idx_pg_op_user ON public.processed_operations (user_id);
```

### 3.1 Penegakan Row-Level Security (RLS) Ketat

Setiap tabel di Supabase wajib mengaktifkan RLS dengan kebijakan isolasi berbasis `auth.uid() = user_id`:

```sql
-- Aktifkan RLS
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminder_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.processed_operations ENABLE ROW LEVEL SECURITY;

-- Kebijakan Tabel Items
CREATE POLICY "Items owner full access" ON public.items
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Kebijakan Tabel Reminders
CREATE POLICY "Reminders owner full access" ON public.reminders
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Kebijakan Tabel Reminder Logs (Append-Only & Read-Only)
CREATE POLICY "Logs owner read access" ON public.reminder_logs
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Logs owner insert access" ON public.reminder_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Cegah Update & Delete pada Riwayat Log
CREATE POLICY "Logs reject update" ON public.reminder_logs
    FOR UPDATE TO authenticated USING (false);

CREATE POLICY "Logs reject delete" ON public.reminder_logs
    FOR DELETE TO authenticated USING (false);

-- Kebijakan Processed Operations
CREATE POLICY "Operations owner full access" ON public.processed_operations
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
```

---

## 4. RPC Supabase Atomik & Idempotent

Untuk menjamin efisiensi jaringan dan keandalan sinkronisasi, interaksi data tidak dilakukan melalui REST tabel per baris, melainkan melalui dua fungsi RPC (*Stored Procedure*) berkinerja tinggi:

### 4.1 RPC `sync_push_mutations`
Memproses batch mutasi dari outbox klien dalam satu transaksi database atomik:

```sql
CREATE OR REPLACE FUNCTION public.sync_push_mutations(p_mutations JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_mutation JSONB;
    v_op_id UUID;
    v_entity_type TEXT;
    v_op_type TEXT;
    v_rec_id UUID;
    v_version INT;
    v_payload JSONB;
    v_existing_version INT;
    v_existing_deleted TIMESTAMPTZ;
    v_results JSONB := '[]'::JSONB;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'UNAUTHORIZED: Sesi otentikasi tidak valid';
    END IF;

    FOR v_mutation IN SELECT * FROM jsonb_array_elements(p_mutations)
    LOOP
        v_op_id       := (v_mutation->>'operation_id')::UUID;
        v_entity_type := v_mutation->>'entity_type';
        v_op_type     := v_mutation->>'operation_type';
        v_rec_id      := (v_mutation->>'record_id')::UUID;
        v_version     := (v_mutation->>'version')::INT;
        v_payload     := v_mutation->'payload';

        -- 1. Pemeriksaan Idempotensi
        IF EXISTS (SELECT 1 FROM processed_operations WHERE operation_id = v_op_id) THEN
            v_results := v_results || jsonb_build_object(
                'operation_id', v_op_id,
                'status', 'duplicate_ignored'
            );
            CONTINUE;
        END IF;

        -- 2. Pemrosesan Sesuai Entitas (Contoh: items)
        IF v_entity_type = 'item' THEN
            SELECT version, deleted_at INTO v_existing_version, v_existing_deleted
            FROM items WHERE id = v_rec_id AND user_id = v_user_id;

            IF v_existing_version IS NOT NULL AND v_existing_version > v_version THEN
                -- Konflik: Versi server lebih baru -> Tolak mutasi (LWW)
                v_results := v_results || jsonb_build_object(
                    'operation_id', v_op_id,
                    'status', 'conflict_rejected',
                    'server_version', v_existing_version
                );
            ELSE
                IF v_op_type = 'insert' OR v_op_type = 'update' THEN
                    INSERT INTO items (
                        id, user_id, name, category, brand, model_number,
                        serial_or_plate_number, purchase_date, has_odometer,
                        current_odometer, photo_remote_path, notes, is_archived,
                        created_at, updated_at, deleted_at, version
                    ) VALUES (
                        v_rec_id, v_user_id,
                        v_payload->>'name',
                        v_payload->>'category',
                        v_payload->>'brand',
                        v_payload->>'model_number',
                        v_payload->>'serial_or_plate_number',
                        (v_payload->>'purchase_date')::DATE,
                        COALESCE((v_payload->>'has_odometer')::BOOLEAN, FALSE),
                        COALESCE((v_payload->>'current_odometer')::BIGINT, 0),
                        v_payload->>'photo_remote_path',
                        v_payload->>'notes',
                        COALESCE((v_payload->>'is_archived')::BOOLEAN, FALSE),
                        COALESCE((v_payload->>'created_at')::TIMESTAMPTZ, now()),
                        COALESCE((v_payload->>'updated_at')::TIMESTAMPTZ, now()),
                        (v_payload->>'deleted_at')::TIMESTAMPTZ,
                        v_version
                    )
                    ON CONFLICT (id) DO UPDATE SET
                        name = EXCLUDED.name,
                        category = EXCLUDED.category,
                        brand = EXCLUDED.brand,
                        model_number = EXCLUDED.model_number,
                        serial_or_plate_number = EXCLUDED.serial_or_plate_number,
                        purchase_date = EXCLUDED.purchase_date,
                        has_odometer = EXCLUDED.has_odometer,
                        current_odometer = EXCLUDED.current_odometer,
                        photo_remote_path = EXCLUDED.photo_remote_path,
                        notes = EXCLUDED.notes,
                        is_archived = EXCLUDED.is_archived,
                        updated_at = EXCLUDED.updated_at,
                        deleted_at = EXCLUDED.deleted_at,
                        version = EXCLUDED.version;
                ELSIF v_op_type = 'delete' THEN
                    -- Soft Delete Tombstone
                    UPDATE items
                    SET deleted_at = now(), version = v_version, updated_at = now()
                    WHERE id = v_rec_id AND user_id = v_user_id;
                END IF;

                -- Catat operasi yang berhasil diproses
                INSERT INTO processed_operations (operation_id, user_id, entity_type, record_id)
                VALUES (v_op_id, v_user_id, v_entity_type, v_rec_id);

                v_results := v_results || jsonb_build_object(
                    'operation_id', v_op_id,
                    'status', 'accepted',
                    'version', v_version
                );
            END IF;

        -- Pemrosesan entitas reminders & reminder_logs mengikuti logika identik
        ELSIF v_entity_type = 'reminder' THEN
            -- [Penanganan tabel reminders dengan pola yang sama]
            INSERT INTO processed_operations (operation_id, user_id, entity_type, record_id)
            VALUES (v_op_id, v_user_id, v_entity_type, v_rec_id);
            v_results := v_results || jsonb_build_object('operation_id', v_op_id, 'status', 'accepted');

        ELSIF v_entity_type = 'reminder_log' THEN
            -- [Penanganan append-only reminder_logs]
            INSERT INTO processed_operations (operation_id, user_id, entity_type, record_id)
            VALUES (v_op_id, v_user_id, v_entity_type, v_rec_id);
            v_results := v_results || jsonb_build_object('operation_id', v_op_id, 'status', 'accepted');
        END IF;
    END LOOP;

    RETURN jsonb_build_object(
        'server_timestamp', timezone('utc'::text, now()),
        'mutations_result', v_results
    );
END;
$$;
```

### 4.2 RPC `sync_pull_changes`
Mengambil seluruh perubahan (rekaman baru, terbarui, atau tombstone) yang terjadi setelah stempel waktu tertentu:

```sql
CREATE OR REPLACE FUNCTION public.sync_pull_changes(
    p_since TIMESTAMPTZ DEFAULT NULL,
    p_limit INT DEFAULT 500
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_items JSONB;
    v_reminders JSONB;
    v_logs JSONB;
    v_server_time TIMESTAMPTZ := timezone('utc'::text, now());
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'UNAUTHORIZED: Sesi otentikasi tidak valid';
    END IF;

    -- Tarik items yang berubah (termasuk yang deleted_at IS NOT NULL)
    SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::JSONB) INTO v_items
    FROM (
        SELECT * FROM items
        WHERE user_id = v_user_id
          AND (p_since IS NULL OR updated_at > p_since OR deleted_at > p_since)
        ORDER BY updated_at ASC
        LIMIT p_limit
    ) t;

    -- Tarik reminders yang berubah
    SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::JSONB) INTO v_reminders
    FROM (
        SELECT * FROM reminders
        WHERE user_id = v_user_id
          AND (p_since IS NULL OR updated_at > p_since OR deleted_at > p_since)
        ORDER BY updated_at ASC
        LIMIT p_limit
    ) t;

    -- Tarik reminder_logs yang bertambah
    SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::JSONB) INTO v_logs
    FROM (
        SELECT * FROM reminder_logs
        WHERE user_id = v_user_id
          AND (p_since IS NULL OR created_at > p_since)
        ORDER BY created_at ASC
        LIMIT p_limit
    ) t;

    RETURN jsonb_build_object(
        'server_timestamp', v_server_time,
        'items', v_items,
        'reminders', v_reminders,
        'reminder_logs', v_logs
    );
END;
$$;
```

---

## 5. Desain Private Supabase Storage untuk Foto Barang

Foto profil barang disimpan secara terisolasi menggunakan fitur Storage Supabase dengan akses privat:

### 5.1 Spesifikasi Bucket
- **Nama Bucket**: `item-photos`
- **Tipe Akses**: **Private** (`public = false`). Seluruh akses publik tanpa token diblokir (*403 Forbidden*).
- **Maksimal Ukuran Berkas**: 2 MB (foto dikompresi di klien hingga < 1 MB).
- **Format yang Diterima**: `image/jpeg`, `image/png`, `image/webp`.

### 5.2 Struktur Objek Path
Berkas foto disimpan dengan pola hierarki kepemilikan:
```
item-photos/{user_id}/{item_id}/{file_uuid}.jpg
```
Contoh path:
```
item-photos/550e8400-e29b-41d4-a716-446655440000/a3bb189e-8bf9-3888-9912-ace4e6543002/9f8c1b3d-1111-4444-9999-abcdef123456.jpg
```

### 5.3 Kebijakan Akses Storage RLS (PostgreSQL)

```sql
-- Kebijakan Akses Baca (Short-Lived Signed URL atau Direct Download Autentikasi)
CREATE POLICY "Users can only read own item photos"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'item-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Kebijakan Unggah Foto
CREATE POLICY "Users can only upload to own item folder"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'item-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Kebijakan Hapus Foto
CREATE POLICY "Users can only delete own item photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'item-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);
```

### 5.4 Strategi Cache Lokal & Signed URL
1. **Lokal Sebagai Sumber Tampilan**:
   - Berkas asli hasil kompresi kamera/galeri disimpan di direktori internal aplikasi (`DirectoryPathProvider.getApplicationDocumentsDirectory()`). Kolom `items.photo_local_path` mereferensikan file ini.
   - Antarmuka pengguna merender foto dari `photo_local_path` tanpa menunggu latensi unduhan jaringan.
2. **Sinkronisasi & Unduhan di Perangkat Baru**:
   - Jika pengguna masuk di perangkat baru (`photo_local_path` belum ada), aplikasi meminta *Short-Lived Signed URL* (durasi 60 menit) via API Supabase Storage:
     ```dart
     final signedUrl = await supabase.storage
         .from('item-photos')
         .createSignedUrl(photoRemotePath, 3600);
     ```
   - Gambar diunduh ke penyimpanan lokal perangkat satu kali dan `photo_local_path` diperbarui.

---

## 6. Migrasi & Versioning Skema Drift di Flutter

Drift menyediakan kelas `MigrationStrategy` terstruktur untuk memastikan evolusi skema database lokal tidak mengakibatkan hilangnya data pengguna (*zero data loss*).

### 6.1 Siklus Hidup Database & Pragmas
Setiap inisialisasi basis data Drift wajib menjalankan pragma performa dan integritas:

```dart
@DriftDatabase(tables: [Items, Reminders, ReminderLogs, SyncOutbox, SyncMetadata])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // 1. Aktifkan penegakan Foreign Key SQLite
      await customStatement('PRAGMA foreign_keys = ON;');
      // 2. Aktifkan Write-Ahead Logging (WAL) untuk konkurensi tinggi
      await customStatement('PRAGMA journal_mode = WAL;');
      // 3. Optimasi performa sinkronisasi transaksi
      await customStatement('PRAGMA synchronous = NORMAL;');
    },
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Skema migrasi bertahap (Incremental Migrations)
      for (var targetVersion = from + 1; targetVersion <= to; targetVersion++) {
        switch (targetVersion) {
          case 2:
            // Contoh upgrade di masa mendatang:
            // await m.addColumn(reminders, reminders.newColumn);
            break;
        }
      }
    },
  );
}
```

### 6.2 Aturan Integritas Migrasi
1. **Tidak Ada Penghapusan Kolom Destruktif**: Kolom yang tidak lagi digunakan ditandai *deprecated* sebelum dihapus pada rilis mayor.
2. **Uji Validasi Skema Otomatis**: Setiap versi skema baru wajib menyertakan pengujian migrasi menggunakan `drift_dev:schema test` untuk memverifikasi bahwa data dari `schemaVersion n` bermigrasi sempurna ke `schemaVersion n+1`.
# Kontrak lokal M021 (Drift schemaVersion 2)

Migrasi aditif v1→v2 membuat `user_preferences` (`user_id` primary key,
`locale` null untuk bahasa perangkat atau `id`/`en`, `distance_unit` `km`/`mi`,
`timezone_override` null untuk perangkat atau nama IANA, `reminder_time` `HH:mm`
default `09:00`). Pengaturan milik satu akun pada satu perangkat, **tidak** masuk
outbox atau Supabase; perubahan akun tidak boleh menampilkan preferensi akun lain.
Upgrade tidak menyalin/menghapus item, reminder, log, maupun antrean outbox.

Calendar date disimpan `YYYY-MM-DD` tanpa offset (tanggal selesai/target); instant
disimpan ISO 8601 UTC dengan `Z` (waktu kejadian/audit). Konversi jam dinding
memakai zona IANA efektif: override akun atau identifier perangkat dari native
Android/iOS, dibaca kembali saat aplikasi resume. Waktu yang tidak ada saat DST
spring-forward dilewati; waktu ganda fall-back memilih instant paling awal.
Reminder berbasis pemakaian/jarak tidak diberi tanggal kalender rekaan. Perubahan
zona/waktu memancarkan state untuk scheduler di tiket berikutnya; belum ada alarm
yang dipasang atau di-reschedule oleh M021.
# ROOTIN-M018: implementasi klien sync (27 Oktober 2026)

`lib/core/sync/mobile_sync.dart` mengirim operasi outbox berdasarkan `id` secara
FIFO, satu per RPC. Penulis mutasi baru harus menyimpan **seluruh request RPC**
(`operation_id`, `record_id`, `entity_type`, `operation_type`, `version` server
yang diharapkan, `payload`) di `payload_json` dalam transaksi bersama perubahan
lokal. Request tersebut tidak boleh dibuat ulang dengan UUID/versi/timestamp
baru saat retry. Entri lama berisi payload saja hanya bisa diproses otomatis
untuk insert item/reminder versi 1; aksi lain ditahan `failed` untuk pemulihan
manual. Entri `processing` setelah crash dicoba lagi dengan identitas sama;
`conflict`/`failed` menahan FIFO hingga keputusan eksplisit. `acceptServer`
hanya tersedia untuk konflik terakhir agar tidak membuang mutasi dependennya.

Pull menyimpan kursor JSON di `sync_metadata` per `user_id` dan menerapkan
seluruh snapshot paginasi beserta checkpoint dalam satu transaksi SQLite. RPC pull yang ada
menyajikan snapshot versi terakhir setiap baris (bukan log perubahan), sehingga
setiap sesi refresh mengulang snapshot dari awal: kursor lanjut hanya untuk
paginasi sesi itu. Snapshot lebih dari 10.000 perubahan ditolak agar tidak
menumpuk tanpa batas di memori; tidak ada checkpoint parsial. Entri outbox
yang belum diselesaikan tidak ditimpa snapshot.
Data lokal dipisah melalui `user_id`; logout tidak menghapus antrean. Metode
`clearAllUserData` menolak penghapusan selama antrean user belum kosong.
Sinkronisasi dipicu refresh layar; belum ada sinkronisasi background atau
penjadwalan notifikasi. Tabel lokal belum memodelkan `progress_event` ataupun
preferensi server: data tersebut tidak diproyeksikan ke Drift dalam tahap ini.
