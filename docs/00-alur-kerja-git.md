# Alur kerja Git — Rootin Mobile Flutter

Revisi 4 — proyek Flutter + Dart baru untuk iOS/Android; GitHub Issues/Projects menjadi sistem tiket; Rootin Web tetap terpisah.

Dokumen ini dipakai bersama AGENTS.md. Semua pekerjaan repository dilakukan Executor pada branch dan worktree tiket. Coordinator mengelola orkestrasi serta PR; Analyst dan Reviewer tidak mengedit source.

## 1. Scope hasil kerja dan repository

- Pekerjaan dilakukan pada repository Rootin Mobile baru dengan Flutter + Dart, target iOS dan Android, serta backend Supabase mobile.
- Rootin Web tetap menjadi proyek terpisah. Repository, source, remote, database dan deployment website tidak termasuk ownership mobile.
- URL repository mobile belum ditetapkan dokumen ini. Coordinator mencatat ROOTIN_MOBILE_REPO_URL, path checkout dan origin/main yang benar di metadata Run; jangan memakai URL repository lama secara otomatis.
- Jika remote/baseline main repository baru belum tersedia, laporkan kebutuhan setup. Jangan membuat worktree dari repository website untuk melewati blocker.
- Pembangunan dimulai dari nol; tidak ada tiket migrasi router/source website, shared web/mobile package, regresi browser atau perubahan layanan website secara implisit.
- Gunakan satu aplikasi Flutter di root, dengan lib/, test/, integration_test/, android/, ios/, assets/ dan konfigurasi pubspec. ADR dapat merinci struktur internal, tetapi tidak mengubah target produk tanpa instruksi user.
- Stack aktif: Flutter/Dart, Riverpod, go_router, Material 3 kustom/adaptif, Drift/SQLite, Supabase, flutter_local_notifications, FCM/APNs bila diperlukan, dan RevenueCat saat billing masuk scope.
- Syarat issue lama yang bertentangan dengan keputusan ini harus dipetakan ke scope Flutter dan dicatat dalam spec/PR; update issue jika otorisasi Run mencakupnya.

## 2. Identitas tiket

Repository tiket dan Issues: https://github.com/andresanjaya/rootin/issues

GitHub Project untuk status kerja: https://github.com/users/andresanjaya/projects/4/views/1?system_template=kanban

- Identitas stabil produk: `ROOTIN-M000` untuk roadmap dan `ROOTIN-M001`–`ROOTIN-M027` untuk tiket kerja. Setiap ID harus dicocokkan dengan GitHub Issue yang tepat sebelum menjalankan pekerjaan.
- Gunakan nomor issue dan URL aktual dari repository tiket. Jangan menurunkan nomor issue dari ID ROOTIN-Mxxx.
- Isi issue adalah sumber scope dan acceptance criteria; status GitHub Project adalah sumber workflow. Periksa status dan opsi field aktual. Issue berstatus open tidak otomatis berarti Ready.
- Periksa apakah issue sudah menjadi item Project sebelum mengandalkan status. Jika belum, tambahkan hanya jika akses/tool tersedia dan tindakan itu termasuk otorisasi Run; jika tidak, laporkan blocker.
- Jangan membuat issue duplikat untuk memenuhi kebutuhan CLI. Jika orca mewajibkan issue, pakai nomor issue yang sudah diverifikasi dan periksa apakah issue repo berbeda dari repo kode didukung.

## 3. Nama branch

Format branch menggunakan nomor GitHub Issue aktual:

```text
<type>/<nomor-issue>-<slug>
```

Contoh berikut menggunakan mapping issue yang sudah dibuat; verifikasi judul issue sebelum membuat branch:

- `docs/27-prd-mobile` — ROOTIN-M001, issue #27
- `docs/2-arsitektur-mobile` — ROOTIN-M003, issue #2
- `chore/6-flutter-scaffold` — ROOTIN-M007, issue #6
- `feat/10-form-reminder` — ROOTIN-M011, issue #10
- `fix/19-retry-push` — ROOTIN-M020, issue #19
- `test/24-validasi-mobile` — ROOTIN-M025, issue #24

Gunakan nomor issue, bukan ID produk, dan pertahankan nama branch yang sama sepanjang putaran revisi.

| Jenis pekerjaan | Type |
| --- | --- |
| Fitur pengguna | feat |
| Perbaikan bug | fix |
| Dokumentasi/desain/ADR | docs |
| Pengujian | test |
| CI dan workflow build | ci |
| Setup/scaffold/konfigurasi | chore |
| Refactor tanpa perubahan perilaku | refactor |

Slug huruf kecil, kebab-case, maksimal lima kata deskripsi setelah ID tiket. Tipe dipilih berdasarkan perubahan yang dikerjakan, bukan semata posisi tiket.

## 4. Preflight dan worktree

Coordinator memeriksa checkout bersih pada repository mobile yang sesuai ROOTIN_MOBILE_REPO_URL, akses GitHub Issues/Projects dan Flutter SDK, serta help lokal orca/OpenCode. Pastikan origin/main berasal dari repository mobile. Jangan menyentuh Rootin Web, mengubah remote-nya atau menimpa pekerjaan user yang belum di-commit.

Ambil referensi terbaru tanpa mengedit main:

```bash
git fetch origin
git rev-parse origin/main
```

Coordinator membuat worktree dari `origin/main` dan mencatat base SHA. Bentuk command berikut berasal dari kontrak workflow yang diminta; cocokkan dengan `orca worktree create --help` pada instalasi user sebelum digunakan:

```bash
# Contoh untuk instalasi yang mengizinkan --issue tidak diisi.
orca worktree create --name "$TICKET_BRANCH" --base-branch origin/main --no-parent --json
```

`TICKET_BRANCH` harus sudah diisi dengan branch yang tervalidasi. Jika help mendukungnya, tambahkan nomor issue aktual pada `--issue`. Verifikasi apakah orca mengaitkan issue dari repository tiket atau repository kode. Bila CLI tidak mendukung repo issue terpisah, gunakan alur yang didokumentasikan oleh instalasi; jangan mengarang ID atau flag.

Executor dan Reviewer diluncurkan melalui worker-start dengan runner `--agent opencode`, di worktree `--worktree branch:<branch>`. Konfigurasi profil peran/model diperiksa terpisah; jangan menganggap `--agent` berarti model.

Pada awal tugas:

```bash
git branch --show-current
git rev-parse --show-toplevel
git status --short
git rev-parse HEAD
```

Branch harus cocok dengan spec dan bukan main. Revisi menggunakan worktree yang sama. Jangan menjalankan `git reset --hard`, checkout paksa, rebase/force-push atau pembersihan otomatis untuk mengatasi state yang tidak dipahami.

## 5. Commit dan push

Executor menjalankan dart format --output=none --set-exit-if-changed ., flutter analyze, flutter test dan pemeriksaan Android/iOS/backend yang relevan. integration_test, development build, perangkat nyata dan release build dijalankan sesuai gate tiket. SDK, suite atau credential yang belum tersedia dilaporkan sebagai gap; check website tidak menjadi gate. Stage path milik tiket secara eksplisit; hindari git add . yang bisa memasukkan artefak/rahasia/perubahan lain.

Format commit:

```text
<type>(<scope>): <deskripsi singkat>
```

Contoh:

- `docs(rootin): define mobile MVP scope`
- `chore(mobile): scaffold Flutter application`
- `feat(reminders): add usage progress actions`
- `fix(push): retry transient delivery failures`

Perubahan database/API dan dokumentasi terkait berada dalam commit yang sama bila diperlukan. pubspec.yaml/pubspec.lock, code generation, dan konfigurasi native harus selaras dengan rencana Analyst serta ownership. Commit source/generated file yang memang diperlukan proyek; jangan commit build/, .dart_tool/, credential signing atau secret. Jangan mengubah proyek Rootin Web.

Push biasa hanya ke branch tiket:

```bash
git push -u origin "$TICKET_BRANCH"
```

Pada revisi, push commit tambahan ke branch yang sama. Jangan force push. Jika base berubah dan menimbulkan konflik, Coordinator mengirim spec penanganan konflik kepada Executor tanpa mengizinkan perubahan main.

## 6. Review yang mengikat ke commit

- Reviewer membandingkan head SHA tiket dengan base main repository mobile yang dicatat, menjalankan gate Flutter/backend/dokumen yang relevan, dan melaporkan perubahan di luar ownership. Widget test, simulator atau screenshot tidak menggantikan bukti build/perangkat nyata yang diwajibkan.
- Reviewer tidak memperbaiki source, melakukan commit/push, atau approve PR.
- Hasil lolos hanya berlaku untuk head SHA yang ditinjau. Setelah ada commit baru, review yang relevan harus diulang.
- Maksimal tiga putaran Executor–Reviewer; kegagalan terakhir dilaporkan kepada user.

## 7. Pull request oleh Coordinator

Sebelum membuat PR, cek apakah PR untuk head branch sudah ada. Jika sudah ada, perbarui PR yang sama setelah review terbaru; jangan membuat duplikat.

Tulis body PR ke file sementara di area orchestration, dengan newline nyata dan tanpa secret. Gunakan `--body-file`:

```bash
gh pr create --base main --head "$TICKET_BRANCH" --title "$PR_TITLE" --body-file "$PR_BODY_FILE"
```

`PR_TITLE` mengikuti Conventional Commits. Isi body:

```markdown
## Perubahan
Masalah pengguna dan perilaku akhir pada aplikasi iOS/Android atau backend terkait.

## Tiket
ROOTIN-Mxxx — nomor dan URL GitHub Issue yang sudah diverifikasi.

## Verifikasi
- Command dan hasil/exit code.
- Bukti build/uji Android dan iOS atau prototipe sesuai scope.
- Dampak perubahan schema lokal/server dan sinkronisasi bila terkait.
- Konfirmasi scope perubahan hanya pada repository/backend mobile yang ditetapkan.
- Batas pengujian dan langkah manual yang belum dilakukan.

## Review
- Head SHA yang diluluskan Reviewer.
- Putaran review.
- Temuan non-blocking dan risiko tersisa.
```

Tambahkan `Closes #<n>` hanya jika issue yang benar sudah diverifikasi dan auto-close saat user merge memang diinginkan. Jika PR dibuat di repo kode yang berbeda dari repo issue, gunakan bentuk lintas repo seperti `Closes andresanjaya/rootin#27` setelah memverifikasi sintaks GitHub yang berlaku. Jika tidak ingin auto-close, cantumkan tautan issue tanpa keyword penutup. Gunakan nomor issue numerik yang sudah diverifikasi; ID `ROOTIN-Mxxx` bukan nomor issue.

Setelah PR terbuka, Coordinator menautkan URL PR ke issue dan memindahkan item GitHub Project ke Review hanya jika perubahan itu termasuk otorisasi Run serta tersedia tool yang berhasil. Jika Project belum dapat diubah, laporkan blocker dan jangan mengklaim status berubah. Agent tidak memindahkan item ke Done atau menutup issue.

## 8. Larangan merge dan penutupan

Semua peran dilarang:

- `gh pr merge` dengan opsi apa pun, termasuk auto/admin.
- `git push` ke main, force push, atau perubahan main melalui merge/rebase/cherry-pick.
- `gh pr review --approve`, menutup PR/issue, atau mengubah branch protection.
- Menghapus branch/worktree tanpa instruksi user.

User melakukan merge sendiri setelah memeriksa PR. Run agent berakhir pada `PR_OPEN / WAITING_USER_MERGE`.

