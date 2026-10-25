// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelNumberMeta = const VerificationMeta(
    'modelNumber',
  );
  @override
  late final GeneratedColumn<String> modelNumber = GeneratedColumn<String>(
    'model_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialOrPlateNumberMeta =
      const VerificationMeta('serialOrPlateNumber');
  @override
  late final GeneratedColumn<String> serialOrPlateNumber =
      GeneratedColumn<String>(
        'serial_or_plate_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<String> purchaseDate = GeneratedColumn<String>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasOdometerMeta = const VerificationMeta(
    'hasOdometer',
  );
  @override
  late final GeneratedColumn<bool> hasOdometer = GeneratedColumn<bool>(
    'has_odometer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_odometer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currentOdometerMeta = const VerificationMeta(
    'currentOdometer',
  );
  @override
  late final GeneratedColumn<int> currentOdometer = GeneratedColumn<int>(
    'current_odometer',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _photoLocalPathMeta = const VerificationMeta(
    'photoLocalPath',
  );
  @override
  late final GeneratedColumn<String> photoLocalPath = GeneratedColumn<String>(
    'photo_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoRemotePathMeta = const VerificationMeta(
    'photoRemotePath',
  );
  @override
  late final GeneratedColumn<String> photoRemotePath = GeneratedColumn<String>(
    'photo_remote_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    category,
    brand,
    modelNumber,
    serialOrPlateNumber,
    purchaseDate,
    hasOdometer,
    currentOdometer,
    photoLocalPath,
    photoRemotePath,
    notes,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('model_number')) {
      context.handle(
        _modelNumberMeta,
        modelNumber.isAcceptableOrUnknown(
          data['model_number']!,
          _modelNumberMeta,
        ),
      );
    }
    if (data.containsKey('serial_or_plate_number')) {
      context.handle(
        _serialOrPlateNumberMeta,
        serialOrPlateNumber.isAcceptableOrUnknown(
          data['serial_or_plate_number']!,
          _serialOrPlateNumberMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('has_odometer')) {
      context.handle(
        _hasOdometerMeta,
        hasOdometer.isAcceptableOrUnknown(
          data['has_odometer']!,
          _hasOdometerMeta,
        ),
      );
    }
    if (data.containsKey('current_odometer')) {
      context.handle(
        _currentOdometerMeta,
        currentOdometer.isAcceptableOrUnknown(
          data['current_odometer']!,
          _currentOdometerMeta,
        ),
      );
    }
    if (data.containsKey('photo_local_path')) {
      context.handle(
        _photoLocalPathMeta,
        photoLocalPath.isAcceptableOrUnknown(
          data['photo_local_path']!,
          _photoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('photo_remote_path')) {
      context.handle(
        _photoRemotePathMeta,
        photoRemotePath.isAcceptableOrUnknown(
          data['photo_remote_path']!,
          _photoRemotePathMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      modelNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_number'],
      ),
      serialOrPlateNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_or_plate_number'],
      ),
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_date'],
      ),
      hasOdometer:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}has_odometer'],
          )!,
      currentOdometer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_odometer'],
      ),
      photoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_local_path'],
      ),
      photoRemotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_remote_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_archived'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}version'],
          )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? brand;
  final String? modelNumber;
  final String? serialOrPlateNumber;
  final String? purchaseDate;
  final bool hasOdometer;
  final int? currentOdometer;
  final String? photoLocalPath;
  final String? photoRemotePath;
  final String? notes;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  const Item({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.brand,
    this.modelNumber,
    this.serialOrPlateNumber,
    this.purchaseDate,
    required this.hasOdometer,
    this.currentOdometer,
    this.photoLocalPath,
    this.photoRemotePath,
    this.notes,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || modelNumber != null) {
      map['model_number'] = Variable<String>(modelNumber);
    }
    if (!nullToAbsent || serialOrPlateNumber != null) {
      map['serial_or_plate_number'] = Variable<String>(serialOrPlateNumber);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<String>(purchaseDate);
    }
    map['has_odometer'] = Variable<bool>(hasOdometer);
    if (!nullToAbsent || currentOdometer != null) {
      map['current_odometer'] = Variable<int>(currentOdometer);
    }
    if (!nullToAbsent || photoLocalPath != null) {
      map['photo_local_path'] = Variable<String>(photoLocalPath);
    }
    if (!nullToAbsent || photoRemotePath != null) {
      map['photo_remote_path'] = Variable<String>(photoRemotePath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      category: Value(category),
      brand:
          brand == null && nullToAbsent ? const Value.absent() : Value(brand),
      modelNumber:
          modelNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(modelNumber),
      serialOrPlateNumber:
          serialOrPlateNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(serialOrPlateNumber),
      purchaseDate:
          purchaseDate == null && nullToAbsent
              ? const Value.absent()
              : Value(purchaseDate),
      hasOdometer: Value(hasOdometer),
      currentOdometer:
          currentOdometer == null && nullToAbsent
              ? const Value.absent()
              : Value(currentOdometer),
      photoLocalPath:
          photoLocalPath == null && nullToAbsent
              ? const Value.absent()
              : Value(photoLocalPath),
      photoRemotePath:
          photoRemotePath == null && nullToAbsent
              ? const Value.absent()
              : Value(photoRemotePath),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      version: Value(version),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      brand: serializer.fromJson<String?>(json['brand']),
      modelNumber: serializer.fromJson<String?>(json['modelNumber']),
      serialOrPlateNumber: serializer.fromJson<String?>(
        json['serialOrPlateNumber'],
      ),
      purchaseDate: serializer.fromJson<String?>(json['purchaseDate']),
      hasOdometer: serializer.fromJson<bool>(json['hasOdometer']),
      currentOdometer: serializer.fromJson<int?>(json['currentOdometer']),
      photoLocalPath: serializer.fromJson<String?>(json['photoLocalPath']),
      photoRemotePath: serializer.fromJson<String?>(json['photoRemotePath']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'brand': serializer.toJson<String?>(brand),
      'modelNumber': serializer.toJson<String?>(modelNumber),
      'serialOrPlateNumber': serializer.toJson<String?>(serialOrPlateNumber),
      'purchaseDate': serializer.toJson<String?>(purchaseDate),
      'hasOdometer': serializer.toJson<bool>(hasOdometer),
      'currentOdometer': serializer.toJson<int?>(currentOdometer),
      'photoLocalPath': serializer.toJson<String?>(photoLocalPath),
      'photoRemotePath': serializer.toJson<String?>(photoRemotePath),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  Item copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    Value<String?> brand = const Value.absent(),
    Value<String?> modelNumber = const Value.absent(),
    Value<String?> serialOrPlateNumber = const Value.absent(),
    Value<String?> purchaseDate = const Value.absent(),
    bool? hasOdometer,
    Value<int?> currentOdometer = const Value.absent(),
    Value<String?> photoLocalPath = const Value.absent(),
    Value<String?> photoRemotePath = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
  }) => Item(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    category: category ?? this.category,
    brand: brand.present ? brand.value : this.brand,
    modelNumber: modelNumber.present ? modelNumber.value : this.modelNumber,
    serialOrPlateNumber:
        serialOrPlateNumber.present
            ? serialOrPlateNumber.value
            : this.serialOrPlateNumber,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    hasOdometer: hasOdometer ?? this.hasOdometer,
    currentOdometer:
        currentOdometer.present ? currentOdometer.value : this.currentOdometer,
    photoLocalPath:
        photoLocalPath.present ? photoLocalPath.value : this.photoLocalPath,
    photoRemotePath:
        photoRemotePath.present ? photoRemotePath.value : this.photoRemotePath,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      brand: data.brand.present ? data.brand.value : this.brand,
      modelNumber:
          data.modelNumber.present ? data.modelNumber.value : this.modelNumber,
      serialOrPlateNumber:
          data.serialOrPlateNumber.present
              ? data.serialOrPlateNumber.value
              : this.serialOrPlateNumber,
      purchaseDate:
          data.purchaseDate.present
              ? data.purchaseDate.value
              : this.purchaseDate,
      hasOdometer:
          data.hasOdometer.present ? data.hasOdometer.value : this.hasOdometer,
      currentOdometer:
          data.currentOdometer.present
              ? data.currentOdometer.value
              : this.currentOdometer,
      photoLocalPath:
          data.photoLocalPath.present
              ? data.photoLocalPath.value
              : this.photoLocalPath,
      photoRemotePath:
          data.photoRemotePath.present
              ? data.photoRemotePath.value
              : this.photoRemotePath,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('modelNumber: $modelNumber, ')
          ..write('serialOrPlateNumber: $serialOrPlateNumber, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('hasOdometer: $hasOdometer, ')
          ..write('currentOdometer: $currentOdometer, ')
          ..write('photoLocalPath: $photoLocalPath, ')
          ..write('photoRemotePath: $photoRemotePath, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    category,
    brand,
    modelNumber,
    serialOrPlateNumber,
    purchaseDate,
    hasOdometer,
    currentOdometer,
    photoLocalPath,
    photoRemotePath,
    notes,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.category == this.category &&
          other.brand == this.brand &&
          other.modelNumber == this.modelNumber &&
          other.serialOrPlateNumber == this.serialOrPlateNumber &&
          other.purchaseDate == this.purchaseDate &&
          other.hasOdometer == this.hasOdometer &&
          other.currentOdometer == this.currentOdometer &&
          other.photoLocalPath == this.photoLocalPath &&
          other.photoRemotePath == this.photoRemotePath &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> brand;
  final Value<String?> modelNumber;
  final Value<String?> serialOrPlateNumber;
  final Value<String?> purchaseDate;
  final Value<bool> hasOdometer;
  final Value<int?> currentOdometer;
  final Value<String?> photoLocalPath;
  final Value<String?> photoRemotePath;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.brand = const Value.absent(),
    this.modelNumber = const Value.absent(),
    this.serialOrPlateNumber = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.hasOdometer = const Value.absent(),
    this.currentOdometer = const Value.absent(),
    this.photoLocalPath = const Value.absent(),
    this.photoRemotePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required String category,
    this.brand = const Value.absent(),
    this.modelNumber = const Value.absent(),
    this.serialOrPlateNumber = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.hasOdometer = const Value.absent(),
    this.currentOdometer = const Value.absent(),
    this.photoLocalPath = const Value.absent(),
    this.photoRemotePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? brand,
    Expression<String>? modelNumber,
    Expression<String>? serialOrPlateNumber,
    Expression<String>? purchaseDate,
    Expression<bool>? hasOdometer,
    Expression<int>? currentOdometer,
    Expression<String>? photoLocalPath,
    Expression<String>? photoRemotePath,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (modelNumber != null) 'model_number': modelNumber,
      if (serialOrPlateNumber != null)
        'serial_or_plate_number': serialOrPlateNumber,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (hasOdometer != null) 'has_odometer': hasOdometer,
      if (currentOdometer != null) 'current_odometer': currentOdometer,
      if (photoLocalPath != null) 'photo_local_path': photoLocalPath,
      if (photoRemotePath != null) 'photo_remote_path': photoRemotePath,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? category,
    Value<String?>? brand,
    Value<String?>? modelNumber,
    Value<String?>? serialOrPlateNumber,
    Value<String?>? purchaseDate,
    Value<bool>? hasOdometer,
    Value<int?>? currentOdometer,
    Value<String?>? photoLocalPath,
    Value<String?>? photoRemotePath,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      modelNumber: modelNumber ?? this.modelNumber,
      serialOrPlateNumber: serialOrPlateNumber ?? this.serialOrPlateNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      hasOdometer: hasOdometer ?? this.hasOdometer,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      photoLocalPath: photoLocalPath ?? this.photoLocalPath,
      photoRemotePath: photoRemotePath ?? this.photoRemotePath,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (modelNumber.present) {
      map['model_number'] = Variable<String>(modelNumber.value);
    }
    if (serialOrPlateNumber.present) {
      map['serial_or_plate_number'] = Variable<String>(
        serialOrPlateNumber.value,
      );
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<String>(purchaseDate.value);
    }
    if (hasOdometer.present) {
      map['has_odometer'] = Variable<bool>(hasOdometer.value);
    }
    if (currentOdometer.present) {
      map['current_odometer'] = Variable<int>(currentOdometer.value);
    }
    if (photoLocalPath.present) {
      map['photo_local_path'] = Variable<String>(photoLocalPath.value);
    }
    if (photoRemotePath.present) {
      map['photo_remote_path'] = Variable<String>(photoRemotePath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('modelNumber: $modelNumber, ')
          ..write('serialOrPlateNumber: $serialOrPlateNumber, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('hasOdometer: $hasOdometer, ')
          ..write('currentOdometer: $currentOdometer, ')
          ..write('photoLocalPath: $photoLocalPath, ')
          ..write('photoRemotePath: $photoRemotePath, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineTypeMeta = const VerificationMeta(
    'engineType',
  );
  @override
  late final GeneratedColumn<String> engineType = GeneratedColumn<String>(
    'engine_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalUnitMeta = const VerificationMeta(
    'intervalUnit',
  );
  @override
  late final GeneratedColumn<String> intervalUnit = GeneratedColumn<String>(
    'interval_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalValueMeta = const VerificationMeta(
    'intervalValue',
  );
  @override
  late final GeneratedColumn<int> intervalValue = GeneratedColumn<int>(
    'interval_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baselineModeMeta = const VerificationMeta(
    'baselineMode',
  );
  @override
  late final GeneratedColumn<String> baselineMode = GeneratedColumn<String>(
    'baseline_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('actual_completion'),
  );
  static const VerificationMeta _anchorDayMeta = const VerificationMeta(
    'anchorDay',
  );
  @override
  late final GeneratedColumn<int> anchorDay = GeneratedColumn<int>(
    'anchor_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetTimeMeta = const VerificationMeta(
    'targetTime',
  );
  @override
  late final GeneratedColumn<String> targetTime = GeneratedColumn<String>(
    'target_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageCounterMeta = const VerificationMeta(
    'usageCounter',
  );
  @override
  late final GeneratedColumn<int> usageCounter = GeneratedColumn<int>(
    'usage_counter',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _usageThresholdMeta = const VerificationMeta(
    'usageThreshold',
  );
  @override
  late final GeneratedColumn<int> usageThreshold = GeneratedColumn<int>(
    'usage_threshold',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageUnitMeta = const VerificationMeta(
    'usageUnit',
  );
  @override
  late final GeneratedColumn<String> usageUnit = GeneratedColumn<String>(
    'usage_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastServiceOdometerMeta =
      const VerificationMeta('lastServiceOdometer');
  @override
  late final GeneratedColumn<int> lastServiceOdometer = GeneratedColumn<int>(
    'last_service_odometer',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalKmMeta = const VerificationMeta(
    'intervalKm',
  );
  @override
  late final GeneratedColumn<int> intervalKm = GeneratedColumn<int>(
    'interval_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozeUntilMeta = const VerificationMeta(
    'snoozeUntil',
  );
  @override
  late final GeneratedColumn<String> snoozeUntil = GeneratedColumn<String>(
    'snooze_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    itemId,
    name,
    engineType,
    intervalUnit,
    intervalValue,
    baselineMode,
    anchorDay,
    targetDate,
    targetTime,
    usageCounter,
    usageThreshold,
    usageUnit,
    lastServiceOdometer,
    intervalKm,
    snoozeUntil,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('engine_type')) {
      context.handle(
        _engineTypeMeta,
        engineType.isAcceptableOrUnknown(data['engine_type']!, _engineTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_engineTypeMeta);
    }
    if (data.containsKey('interval_unit')) {
      context.handle(
        _intervalUnitMeta,
        intervalUnit.isAcceptableOrUnknown(
          data['interval_unit']!,
          _intervalUnitMeta,
        ),
      );
    }
    if (data.containsKey('interval_value')) {
      context.handle(
        _intervalValueMeta,
        intervalValue.isAcceptableOrUnknown(
          data['interval_value']!,
          _intervalValueMeta,
        ),
      );
    }
    if (data.containsKey('baseline_mode')) {
      context.handle(
        _baselineModeMeta,
        baselineMode.isAcceptableOrUnknown(
          data['baseline_mode']!,
          _baselineModeMeta,
        ),
      );
    }
    if (data.containsKey('anchor_day')) {
      context.handle(
        _anchorDayMeta,
        anchorDay.isAcceptableOrUnknown(data['anchor_day']!, _anchorDayMeta),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('target_time')) {
      context.handle(
        _targetTimeMeta,
        targetTime.isAcceptableOrUnknown(data['target_time']!, _targetTimeMeta),
      );
    }
    if (data.containsKey('usage_counter')) {
      context.handle(
        _usageCounterMeta,
        usageCounter.isAcceptableOrUnknown(
          data['usage_counter']!,
          _usageCounterMeta,
        ),
      );
    }
    if (data.containsKey('usage_threshold')) {
      context.handle(
        _usageThresholdMeta,
        usageThreshold.isAcceptableOrUnknown(
          data['usage_threshold']!,
          _usageThresholdMeta,
        ),
      );
    }
    if (data.containsKey('usage_unit')) {
      context.handle(
        _usageUnitMeta,
        usageUnit.isAcceptableOrUnknown(data['usage_unit']!, _usageUnitMeta),
      );
    }
    if (data.containsKey('last_service_odometer')) {
      context.handle(
        _lastServiceOdometerMeta,
        lastServiceOdometer.isAcceptableOrUnknown(
          data['last_service_odometer']!,
          _lastServiceOdometerMeta,
        ),
      );
    }
    if (data.containsKey('interval_km')) {
      context.handle(
        _intervalKmMeta,
        intervalKm.isAcceptableOrUnknown(data['interval_km']!, _intervalKmMeta),
      );
    }
    if (data.containsKey('snooze_until')) {
      context.handle(
        _snoozeUntilMeta,
        snoozeUntil.isAcceptableOrUnknown(
          data['snooze_until']!,
          _snoozeUntilMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      engineType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}engine_type'],
          )!,
      intervalUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interval_unit'],
      ),
      intervalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_value'],
      ),
      baselineMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baseline_mode'],
      ),
      anchorDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_day'],
      ),
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_date'],
      ),
      targetTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_time'],
      ),
      usageCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_counter'],
      ),
      usageThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_threshold'],
      ),
      usageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_unit'],
      ),
      lastServiceOdometer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_service_odometer'],
      ),
      intervalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_km'],
      ),
      snoozeUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snooze_until'],
      ),
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_active'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}version'],
          )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String userId;
  final String itemId;
  final String name;
  final String engineType;
  final String? intervalUnit;
  final int? intervalValue;
  final String? baselineMode;
  final int? anchorDay;
  final String? targetDate;
  final String? targetTime;
  final int? usageCounter;
  final int? usageThreshold;
  final String? usageUnit;
  final int? lastServiceOdometer;
  final int? intervalKm;
  final String? snoozeUntil;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  const Reminder({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.name,
    required this.engineType,
    this.intervalUnit,
    this.intervalValue,
    this.baselineMode,
    this.anchorDay,
    this.targetDate,
    this.targetTime,
    this.usageCounter,
    this.usageThreshold,
    this.usageUnit,
    this.lastServiceOdometer,
    this.intervalKm,
    this.snoozeUntil,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['item_id'] = Variable<String>(itemId);
    map['name'] = Variable<String>(name);
    map['engine_type'] = Variable<String>(engineType);
    if (!nullToAbsent || intervalUnit != null) {
      map['interval_unit'] = Variable<String>(intervalUnit);
    }
    if (!nullToAbsent || intervalValue != null) {
      map['interval_value'] = Variable<int>(intervalValue);
    }
    if (!nullToAbsent || baselineMode != null) {
      map['baseline_mode'] = Variable<String>(baselineMode);
    }
    if (!nullToAbsent || anchorDay != null) {
      map['anchor_day'] = Variable<int>(anchorDay);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(targetDate);
    }
    if (!nullToAbsent || targetTime != null) {
      map['target_time'] = Variable<String>(targetTime);
    }
    if (!nullToAbsent || usageCounter != null) {
      map['usage_counter'] = Variable<int>(usageCounter);
    }
    if (!nullToAbsent || usageThreshold != null) {
      map['usage_threshold'] = Variable<int>(usageThreshold);
    }
    if (!nullToAbsent || usageUnit != null) {
      map['usage_unit'] = Variable<String>(usageUnit);
    }
    if (!nullToAbsent || lastServiceOdometer != null) {
      map['last_service_odometer'] = Variable<int>(lastServiceOdometer);
    }
    if (!nullToAbsent || intervalKm != null) {
      map['interval_km'] = Variable<int>(intervalKm);
    }
    if (!nullToAbsent || snoozeUntil != null) {
      map['snooze_until'] = Variable<String>(snoozeUntil);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      userId: Value(userId),
      itemId: Value(itemId),
      name: Value(name),
      engineType: Value(engineType),
      intervalUnit:
          intervalUnit == null && nullToAbsent
              ? const Value.absent()
              : Value(intervalUnit),
      intervalValue:
          intervalValue == null && nullToAbsent
              ? const Value.absent()
              : Value(intervalValue),
      baselineMode:
          baselineMode == null && nullToAbsent
              ? const Value.absent()
              : Value(baselineMode),
      anchorDay:
          anchorDay == null && nullToAbsent
              ? const Value.absent()
              : Value(anchorDay),
      targetDate:
          targetDate == null && nullToAbsent
              ? const Value.absent()
              : Value(targetDate),
      targetTime:
          targetTime == null && nullToAbsent
              ? const Value.absent()
              : Value(targetTime),
      usageCounter:
          usageCounter == null && nullToAbsent
              ? const Value.absent()
              : Value(usageCounter),
      usageThreshold:
          usageThreshold == null && nullToAbsent
              ? const Value.absent()
              : Value(usageThreshold),
      usageUnit:
          usageUnit == null && nullToAbsent
              ? const Value.absent()
              : Value(usageUnit),
      lastServiceOdometer:
          lastServiceOdometer == null && nullToAbsent
              ? const Value.absent()
              : Value(lastServiceOdometer),
      intervalKm:
          intervalKm == null && nullToAbsent
              ? const Value.absent()
              : Value(intervalKm),
      snoozeUntil:
          snoozeUntil == null && nullToAbsent
              ? const Value.absent()
              : Value(snoozeUntil),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      version: Value(version),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      name: serializer.fromJson<String>(json['name']),
      engineType: serializer.fromJson<String>(json['engineType']),
      intervalUnit: serializer.fromJson<String?>(json['intervalUnit']),
      intervalValue: serializer.fromJson<int?>(json['intervalValue']),
      baselineMode: serializer.fromJson<String?>(json['baselineMode']),
      anchorDay: serializer.fromJson<int?>(json['anchorDay']),
      targetDate: serializer.fromJson<String?>(json['targetDate']),
      targetTime: serializer.fromJson<String?>(json['targetTime']),
      usageCounter: serializer.fromJson<int?>(json['usageCounter']),
      usageThreshold: serializer.fromJson<int?>(json['usageThreshold']),
      usageUnit: serializer.fromJson<String?>(json['usageUnit']),
      lastServiceOdometer: serializer.fromJson<int?>(
        json['lastServiceOdometer'],
      ),
      intervalKm: serializer.fromJson<int?>(json['intervalKm']),
      snoozeUntil: serializer.fromJson<String?>(json['snoozeUntil']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'itemId': serializer.toJson<String>(itemId),
      'name': serializer.toJson<String>(name),
      'engineType': serializer.toJson<String>(engineType),
      'intervalUnit': serializer.toJson<String?>(intervalUnit),
      'intervalValue': serializer.toJson<int?>(intervalValue),
      'baselineMode': serializer.toJson<String?>(baselineMode),
      'anchorDay': serializer.toJson<int?>(anchorDay),
      'targetDate': serializer.toJson<String?>(targetDate),
      'targetTime': serializer.toJson<String?>(targetTime),
      'usageCounter': serializer.toJson<int?>(usageCounter),
      'usageThreshold': serializer.toJson<int?>(usageThreshold),
      'usageUnit': serializer.toJson<String?>(usageUnit),
      'lastServiceOdometer': serializer.toJson<int?>(lastServiceOdometer),
      'intervalKm': serializer.toJson<int?>(intervalKm),
      'snoozeUntil': serializer.toJson<String?>(snoozeUntil),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? name,
    String? engineType,
    Value<String?> intervalUnit = const Value.absent(),
    Value<int?> intervalValue = const Value.absent(),
    Value<String?> baselineMode = const Value.absent(),
    Value<int?> anchorDay = const Value.absent(),
    Value<String?> targetDate = const Value.absent(),
    Value<String?> targetTime = const Value.absent(),
    Value<int?> usageCounter = const Value.absent(),
    Value<int?> usageThreshold = const Value.absent(),
    Value<String?> usageUnit = const Value.absent(),
    Value<int?> lastServiceOdometer = const Value.absent(),
    Value<int?> intervalKm = const Value.absent(),
    Value<String?> snoozeUntil = const Value.absent(),
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
  }) => Reminder(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    itemId: itemId ?? this.itemId,
    name: name ?? this.name,
    engineType: engineType ?? this.engineType,
    intervalUnit: intervalUnit.present ? intervalUnit.value : this.intervalUnit,
    intervalValue:
        intervalValue.present ? intervalValue.value : this.intervalValue,
    baselineMode: baselineMode.present ? baselineMode.value : this.baselineMode,
    anchorDay: anchorDay.present ? anchorDay.value : this.anchorDay,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    targetTime: targetTime.present ? targetTime.value : this.targetTime,
    usageCounter: usageCounter.present ? usageCounter.value : this.usageCounter,
    usageThreshold:
        usageThreshold.present ? usageThreshold.value : this.usageThreshold,
    usageUnit: usageUnit.present ? usageUnit.value : this.usageUnit,
    lastServiceOdometer:
        lastServiceOdometer.present
            ? lastServiceOdometer.value
            : this.lastServiceOdometer,
    intervalKm: intervalKm.present ? intervalKm.value : this.intervalKm,
    snoozeUntil: snoozeUntil.present ? snoozeUntil.value : this.snoozeUntil,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      name: data.name.present ? data.name.value : this.name,
      engineType:
          data.engineType.present ? data.engineType.value : this.engineType,
      intervalUnit:
          data.intervalUnit.present
              ? data.intervalUnit.value
              : this.intervalUnit,
      intervalValue:
          data.intervalValue.present
              ? data.intervalValue.value
              : this.intervalValue,
      baselineMode:
          data.baselineMode.present
              ? data.baselineMode.value
              : this.baselineMode,
      anchorDay: data.anchorDay.present ? data.anchorDay.value : this.anchorDay,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      targetTime:
          data.targetTime.present ? data.targetTime.value : this.targetTime,
      usageCounter:
          data.usageCounter.present
              ? data.usageCounter.value
              : this.usageCounter,
      usageThreshold:
          data.usageThreshold.present
              ? data.usageThreshold.value
              : this.usageThreshold,
      usageUnit: data.usageUnit.present ? data.usageUnit.value : this.usageUnit,
      lastServiceOdometer:
          data.lastServiceOdometer.present
              ? data.lastServiceOdometer.value
              : this.lastServiceOdometer,
      intervalKm:
          data.intervalKm.present ? data.intervalKm.value : this.intervalKm,
      snoozeUntil:
          data.snoozeUntil.present ? data.snoozeUntil.value : this.snoozeUntil,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('itemId: $itemId, ')
          ..write('name: $name, ')
          ..write('engineType: $engineType, ')
          ..write('intervalUnit: $intervalUnit, ')
          ..write('intervalValue: $intervalValue, ')
          ..write('baselineMode: $baselineMode, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('targetDate: $targetDate, ')
          ..write('targetTime: $targetTime, ')
          ..write('usageCounter: $usageCounter, ')
          ..write('usageThreshold: $usageThreshold, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('lastServiceOdometer: $lastServiceOdometer, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('snoozeUntil: $snoozeUntil, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    itemId,
    name,
    engineType,
    intervalUnit,
    intervalValue,
    baselineMode,
    anchorDay,
    targetDate,
    targetTime,
    usageCounter,
    usageThreshold,
    usageUnit,
    lastServiceOdometer,
    intervalKm,
    snoozeUntil,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.itemId == this.itemId &&
          other.name == this.name &&
          other.engineType == this.engineType &&
          other.intervalUnit == this.intervalUnit &&
          other.intervalValue == this.intervalValue &&
          other.baselineMode == this.baselineMode &&
          other.anchorDay == this.anchorDay &&
          other.targetDate == this.targetDate &&
          other.targetTime == this.targetTime &&
          other.usageCounter == this.usageCounter &&
          other.usageThreshold == this.usageThreshold &&
          other.usageUnit == this.usageUnit &&
          other.lastServiceOdometer == this.lastServiceOdometer &&
          other.intervalKm == this.intervalKm &&
          other.snoozeUntil == this.snoozeUntil &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> itemId;
  final Value<String> name;
  final Value<String> engineType;
  final Value<String?> intervalUnit;
  final Value<int?> intervalValue;
  final Value<String?> baselineMode;
  final Value<int?> anchorDay;
  final Value<String?> targetDate;
  final Value<String?> targetTime;
  final Value<int?> usageCounter;
  final Value<int?> usageThreshold;
  final Value<String?> usageUnit;
  final Value<int?> lastServiceOdometer;
  final Value<int?> intervalKm;
  final Value<String?> snoozeUntil;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.name = const Value.absent(),
    this.engineType = const Value.absent(),
    this.intervalUnit = const Value.absent(),
    this.intervalValue = const Value.absent(),
    this.baselineMode = const Value.absent(),
    this.anchorDay = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.targetTime = const Value.absent(),
    this.usageCounter = const Value.absent(),
    this.usageThreshold = const Value.absent(),
    this.usageUnit = const Value.absent(),
    this.lastServiceOdometer = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String userId,
    required String itemId,
    required String name,
    required String engineType,
    this.intervalUnit = const Value.absent(),
    this.intervalValue = const Value.absent(),
    this.baselineMode = const Value.absent(),
    this.anchorDay = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.targetTime = const Value.absent(),
    this.usageCounter = const Value.absent(),
    this.usageThreshold = const Value.absent(),
    this.usageUnit = const Value.absent(),
    this.lastServiceOdometer = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
    this.isActive = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       itemId = Value(itemId),
       name = Value(name),
       engineType = Value(engineType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? itemId,
    Expression<String>? name,
    Expression<String>? engineType,
    Expression<String>? intervalUnit,
    Expression<int>? intervalValue,
    Expression<String>? baselineMode,
    Expression<int>? anchorDay,
    Expression<String>? targetDate,
    Expression<String>? targetTime,
    Expression<int>? usageCounter,
    Expression<int>? usageThreshold,
    Expression<String>? usageUnit,
    Expression<int>? lastServiceOdometer,
    Expression<int>? intervalKm,
    Expression<String>? snoozeUntil,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (itemId != null) 'item_id': itemId,
      if (name != null) 'name': name,
      if (engineType != null) 'engine_type': engineType,
      if (intervalUnit != null) 'interval_unit': intervalUnit,
      if (intervalValue != null) 'interval_value': intervalValue,
      if (baselineMode != null) 'baseline_mode': baselineMode,
      if (anchorDay != null) 'anchor_day': anchorDay,
      if (targetDate != null) 'target_date': targetDate,
      if (targetTime != null) 'target_time': targetTime,
      if (usageCounter != null) 'usage_counter': usageCounter,
      if (usageThreshold != null) 'usage_threshold': usageThreshold,
      if (usageUnit != null) 'usage_unit': usageUnit,
      if (lastServiceOdometer != null)
        'last_service_odometer': lastServiceOdometer,
      if (intervalKm != null) 'interval_km': intervalKm,
      if (snoozeUntil != null) 'snooze_until': snoozeUntil,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? itemId,
    Value<String>? name,
    Value<String>? engineType,
    Value<String?>? intervalUnit,
    Value<int?>? intervalValue,
    Value<String?>? baselineMode,
    Value<int?>? anchorDay,
    Value<String?>? targetDate,
    Value<String?>? targetTime,
    Value<int?>? usageCounter,
    Value<int?>? usageThreshold,
    Value<String?>? usageUnit,
    Value<int?>? lastServiceOdometer,
    Value<int?>? intervalKm,
    Value<String?>? snoozeUntil,
    Value<bool>? isActive,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      engineType: engineType ?? this.engineType,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      intervalValue: intervalValue ?? this.intervalValue,
      baselineMode: baselineMode ?? this.baselineMode,
      anchorDay: anchorDay ?? this.anchorDay,
      targetDate: targetDate ?? this.targetDate,
      targetTime: targetTime ?? this.targetTime,
      usageCounter: usageCounter ?? this.usageCounter,
      usageThreshold: usageThreshold ?? this.usageThreshold,
      usageUnit: usageUnit ?? this.usageUnit,
      lastServiceOdometer: lastServiceOdometer ?? this.lastServiceOdometer,
      intervalKm: intervalKm ?? this.intervalKm,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (engineType.present) {
      map['engine_type'] = Variable<String>(engineType.value);
    }
    if (intervalUnit.present) {
      map['interval_unit'] = Variable<String>(intervalUnit.value);
    }
    if (intervalValue.present) {
      map['interval_value'] = Variable<int>(intervalValue.value);
    }
    if (baselineMode.present) {
      map['baseline_mode'] = Variable<String>(baselineMode.value);
    }
    if (anchorDay.present) {
      map['anchor_day'] = Variable<int>(anchorDay.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (targetTime.present) {
      map['target_time'] = Variable<String>(targetTime.value);
    }
    if (usageCounter.present) {
      map['usage_counter'] = Variable<int>(usageCounter.value);
    }
    if (usageThreshold.present) {
      map['usage_threshold'] = Variable<int>(usageThreshold.value);
    }
    if (usageUnit.present) {
      map['usage_unit'] = Variable<String>(usageUnit.value);
    }
    if (lastServiceOdometer.present) {
      map['last_service_odometer'] = Variable<int>(lastServiceOdometer.value);
    }
    if (intervalKm.present) {
      map['interval_km'] = Variable<int>(intervalKm.value);
    }
    if (snoozeUntil.present) {
      map['snooze_until'] = Variable<String>(snoozeUntil.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('itemId: $itemId, ')
          ..write('name: $name, ')
          ..write('engineType: $engineType, ')
          ..write('intervalUnit: $intervalUnit, ')
          ..write('intervalValue: $intervalValue, ')
          ..write('baselineMode: $baselineMode, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('targetDate: $targetDate, ')
          ..write('targetTime: $targetTime, ')
          ..write('usageCounter: $usageCounter, ')
          ..write('usageThreshold: $usageThreshold, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('lastServiceOdometer: $lastServiceOdometer, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('snoozeUntil: $snoozeUntil, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderLogsTable extends ReminderLogs
    with TableInfo<$ReminderLogsTable, ReminderLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionDateMeta = const VerificationMeta(
    'completionDate',
  );
  @override
  late final GeneratedColumn<String> completionDate = GeneratedColumn<String>(
    'completion_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerAtCompletionMeta =
      const VerificationMeta('odometerAtCompletion');
  @override
  late final GeneratedColumn<int> odometerAtCompletion = GeneratedColumn<int>(
    'odometer_at_completion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _performedByMeta = const VerificationMeta(
    'performedBy',
  );
  @override
  late final GeneratedColumn<String> performedBy = GeneratedColumn<String>(
    'performed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    itemId,
    reminderId,
    completedAt,
    completionDate,
    odometerAtCompletion,
    cost,
    performedBy,
    notes,
    createdAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('completion_date')) {
      context.handle(
        _completionDateMeta,
        completionDate.isAcceptableOrUnknown(
          data['completion_date']!,
          _completionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completionDateMeta);
    }
    if (data.containsKey('odometer_at_completion')) {
      context.handle(
        _odometerAtCompletionMeta,
        odometerAtCompletion.isAcceptableOrUnknown(
          data['odometer_at_completion']!,
          _odometerAtCompletionMeta,
        ),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('performed_by')) {
      context.handle(
        _performedByMeta,
        performedBy.isAcceptableOrUnknown(
          data['performed_by']!,
          _performedByMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderLog(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      reminderId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}reminder_id'],
          )!,
      completedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}completed_at'],
          )!,
      completionDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}completion_date'],
          )!,
      odometerAtCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_at_completion'],
      ),
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      ),
      performedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}performed_by'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      version:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}version'],
          )!,
    );
  }

  @override
  $ReminderLogsTable createAlias(String alias) {
    return $ReminderLogsTable(attachedDatabase, alias);
  }
}

class ReminderLog extends DataClass implements Insertable<ReminderLog> {
  final String id;
  final String userId;
  final String itemId;
  final String reminderId;
  final String completedAt;
  final String completionDate;
  final int? odometerAtCompletion;
  final double? cost;
  final String? performedBy;
  final String? notes;
  final String createdAt;
  final int version;
  const ReminderLog({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.reminderId,
    required this.completedAt,
    required this.completionDate,
    this.odometerAtCompletion,
    this.cost,
    this.performedBy,
    this.notes,
    required this.createdAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['item_id'] = Variable<String>(itemId);
    map['reminder_id'] = Variable<String>(reminderId);
    map['completed_at'] = Variable<String>(completedAt);
    map['completion_date'] = Variable<String>(completionDate);
    if (!nullToAbsent || odometerAtCompletion != null) {
      map['odometer_at_completion'] = Variable<int>(odometerAtCompletion);
    }
    if (!nullToAbsent || cost != null) {
      map['cost'] = Variable<double>(cost);
    }
    if (!nullToAbsent || performedBy != null) {
      map['performed_by'] = Variable<String>(performedBy);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  ReminderLogsCompanion toCompanion(bool nullToAbsent) {
    return ReminderLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      itemId: Value(itemId),
      reminderId: Value(reminderId),
      completedAt: Value(completedAt),
      completionDate: Value(completionDate),
      odometerAtCompletion:
          odometerAtCompletion == null && nullToAbsent
              ? const Value.absent()
              : Value(odometerAtCompletion),
      cost: cost == null && nullToAbsent ? const Value.absent() : Value(cost),
      performedBy:
          performedBy == null && nullToAbsent
              ? const Value.absent()
              : Value(performedBy),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      version: Value(version),
    );
  }

  factory ReminderLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      reminderId: serializer.fromJson<String>(json['reminderId']),
      completedAt: serializer.fromJson<String>(json['completedAt']),
      completionDate: serializer.fromJson<String>(json['completionDate']),
      odometerAtCompletion: serializer.fromJson<int?>(
        json['odometerAtCompletion'],
      ),
      cost: serializer.fromJson<double?>(json['cost']),
      performedBy: serializer.fromJson<String?>(json['performedBy']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'itemId': serializer.toJson<String>(itemId),
      'reminderId': serializer.toJson<String>(reminderId),
      'completedAt': serializer.toJson<String>(completedAt),
      'completionDate': serializer.toJson<String>(completionDate),
      'odometerAtCompletion': serializer.toJson<int?>(odometerAtCompletion),
      'cost': serializer.toJson<double?>(cost),
      'performedBy': serializer.toJson<String?>(performedBy),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'version': serializer.toJson<int>(version),
    };
  }

  ReminderLog copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? reminderId,
    String? completedAt,
    String? completionDate,
    Value<int?> odometerAtCompletion = const Value.absent(),
    Value<double?> cost = const Value.absent(),
    Value<String?> performedBy = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdAt,
    int? version,
  }) => ReminderLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    itemId: itemId ?? this.itemId,
    reminderId: reminderId ?? this.reminderId,
    completedAt: completedAt ?? this.completedAt,
    completionDate: completionDate ?? this.completionDate,
    odometerAtCompletion:
        odometerAtCompletion.present
            ? odometerAtCompletion.value
            : this.odometerAtCompletion,
    cost: cost.present ? cost.value : this.cost,
    performedBy: performedBy.present ? performedBy.value : this.performedBy,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    version: version ?? this.version,
  );
  ReminderLog copyWithCompanion(ReminderLogsCompanion data) {
    return ReminderLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      reminderId:
          data.reminderId.present ? data.reminderId.value : this.reminderId,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      completionDate:
          data.completionDate.present
              ? data.completionDate.value
              : this.completionDate,
      odometerAtCompletion:
          data.odometerAtCompletion.present
              ? data.odometerAtCompletion.value
              : this.odometerAtCompletion,
      cost: data.cost.present ? data.cost.value : this.cost,
      performedBy:
          data.performedBy.present ? data.performedBy.value : this.performedBy,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('itemId: $itemId, ')
          ..write('reminderId: $reminderId, ')
          ..write('completedAt: $completedAt, ')
          ..write('completionDate: $completionDate, ')
          ..write('odometerAtCompletion: $odometerAtCompletion, ')
          ..write('cost: $cost, ')
          ..write('performedBy: $performedBy, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    itemId,
    reminderId,
    completedAt,
    completionDate,
    odometerAtCompletion,
    cost,
    performedBy,
    notes,
    createdAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.itemId == this.itemId &&
          other.reminderId == this.reminderId &&
          other.completedAt == this.completedAt &&
          other.completionDate == this.completionDate &&
          other.odometerAtCompletion == this.odometerAtCompletion &&
          other.cost == this.cost &&
          other.performedBy == this.performedBy &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.version == this.version);
}

class ReminderLogsCompanion extends UpdateCompanion<ReminderLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> itemId;
  final Value<String> reminderId;
  final Value<String> completedAt;
  final Value<String> completionDate;
  final Value<int?> odometerAtCompletion;
  final Value<double?> cost;
  final Value<String?> performedBy;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<int> version;
  final Value<int> rowid;
  const ReminderLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.odometerAtCompletion = const Value.absent(),
    this.cost = const Value.absent(),
    this.performedBy = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderLogsCompanion.insert({
    required String id,
    required String userId,
    required String itemId,
    required String reminderId,
    required String completedAt,
    required String completionDate,
    this.odometerAtCompletion = const Value.absent(),
    this.cost = const Value.absent(),
    this.performedBy = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       itemId = Value(itemId),
       reminderId = Value(reminderId),
       completedAt = Value(completedAt),
       completionDate = Value(completionDate),
       createdAt = Value(createdAt);
  static Insertable<ReminderLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? itemId,
    Expression<String>? reminderId,
    Expression<String>? completedAt,
    Expression<String>? completionDate,
    Expression<int>? odometerAtCompletion,
    Expression<double>? cost,
    Expression<String>? performedBy,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (itemId != null) 'item_id': itemId,
      if (reminderId != null) 'reminder_id': reminderId,
      if (completedAt != null) 'completed_at': completedAt,
      if (completionDate != null) 'completion_date': completionDate,
      if (odometerAtCompletion != null)
        'odometer_at_completion': odometerAtCompletion,
      if (cost != null) 'cost': cost,
      if (performedBy != null) 'performed_by': performedBy,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? itemId,
    Value<String>? reminderId,
    Value<String>? completedAt,
    Value<String>? completionDate,
    Value<int?>? odometerAtCompletion,
    Value<double?>? cost,
    Value<String?>? performedBy,
    Value<String?>? notes,
    Value<String>? createdAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ReminderLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      reminderId: reminderId ?? this.reminderId,
      completedAt: completedAt ?? this.completedAt,
      completionDate: completionDate ?? this.completionDate,
      odometerAtCompletion: odometerAtCompletion ?? this.odometerAtCompletion,
      cost: cost ?? this.cost,
      performedBy: performedBy ?? this.performedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (completionDate.present) {
      map['completion_date'] = Variable<String>(completionDate.value);
    }
    if (odometerAtCompletion.present) {
      map['odometer_at_completion'] = Variable<int>(odometerAtCompletion.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (performedBy.present) {
      map['performed_by'] = Variable<String>(performedBy.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('itemId: $itemId, ')
          ..write('reminderId: $reminderId, ')
          ..write('completedAt: $completedAt, ')
          ..write('completionDate: $completionDate, ')
          ..write('odometerAtCompletion: $odometerAtCompletion, ')
          ..write('cost: $cost, ')
          ..write('performedBy: $performedBy, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<String> lastAttemptAt = GeneratedColumn<String>(
    'last_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationId,
    userId,
    entityType,
    recordId,
    operationType,
    payloadJson,
    createdAt,
    retryCount,
    lastAttemptAt,
    status,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      operationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      entityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_type'],
          )!,
      recordId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}record_id'],
          )!,
      operationType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation_type'],
          )!,
      payloadJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload_json'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      retryCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}retry_count'],
          )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_attempt_at'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int id;
  final String operationId;
  final String userId;
  final String entityType;
  final String recordId;
  final String operationType;
  final String payloadJson;
  final String createdAt;
  final int retryCount;
  final String? lastAttemptAt;
  final String status;
  final String? errorMessage;
  const SyncOutboxData({
    required this.id,
    required this.operationId,
    required this.userId,
    required this.entityType,
    required this.recordId,
    required this.operationType,
    required this.payloadJson,
    required this.createdAt,
    required this.retryCount,
    this.lastAttemptAt,
    required this.status,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation_id'] = Variable<String>(operationId);
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<String>(entityType);
    map['record_id'] = Variable<String>(recordId);
    map['operation_type'] = Variable<String>(operationType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<String>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<String>(lastAttemptAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      operationId: Value(operationId),
      userId: Value(userId),
      entityType: Value(entityType),
      recordId: Value(recordId),
      operationType: Value(operationType),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastAttemptAt:
          lastAttemptAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastAttemptAt),
      status: Value(status),
      errorMessage:
          errorMessage == null && nullToAbsent
              ? const Value.absent()
              : Value(errorMessage),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<int>(json['id']),
      operationId: serializer.fromJson<String>(json['operationId']),
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttemptAt: serializer.fromJson<String?>(json['lastAttemptAt']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operationId': serializer.toJson<String>(operationId),
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'recordId': serializer.toJson<String>(recordId),
      'operationType': serializer.toJson<String>(operationType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttemptAt': serializer.toJson<String?>(lastAttemptAt),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncOutboxData copyWith({
    int? id,
    String? operationId,
    String? userId,
    String? entityType,
    String? recordId,
    String? operationType,
    String? payloadJson,
    String? createdAt,
    int? retryCount,
    Value<String?> lastAttemptAt = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncOutboxData(
    id: id ?? this.id,
    operationId: operationId ?? this.operationId,
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    recordId: recordId ?? this.recordId,
    operationType: operationType ?? this.operationType,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastAttemptAt:
        lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      operationId:
          data.operationId.present ? data.operationId.value : this.operationId,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operationType:
          data.operationType.present
              ? data.operationType.value
              : this.operationType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastAttemptAt:
          data.lastAttemptAt.present
              ? data.lastAttemptAt.value
              : this.lastAttemptAt,
      status: data.status.present ? data.status.value : this.status,
      errorMessage:
          data.errorMessage.present
              ? data.errorMessage.value
              : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('recordId: $recordId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationId,
    userId,
    entityType,
    recordId,
    operationType,
    payloadJson,
    createdAt,
    retryCount,
    lastAttemptAt,
    status,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.operationId == this.operationId &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.recordId == this.recordId &&
          other.operationType == this.operationType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> id;
  final Value<String> operationId;
  final Value<String> userId;
  final Value<String> entityType;
  final Value<String> recordId;
  final Value<String> operationType;
  final Value<String> payloadJson;
  final Value<String> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastAttemptAt;
  final Value<String> status;
  final Value<String?> errorMessage;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.id = const Value.absent(),
    required String operationId,
    required String userId,
    required String entityType,
    required String recordId,
    required String operationType,
    required String payloadJson,
    required String createdAt,
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : operationId = Value(operationId),
       userId = Value(userId),
       entityType = Value(entityType),
       recordId = Value(recordId),
       operationType = Value(operationType),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? id,
    Expression<String>? operationId,
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<String>? recordId,
    Expression<String>? operationType,
    Expression<String>? payloadJson,
    Expression<String>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastAttemptAt,
    Expression<String>? status,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationId != null) 'operation_id': operationId,
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (recordId != null) 'record_id': recordId,
      if (operationType != null) 'operation_type': operationType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? operationId,
    Value<String>? userId,
    Value<String>? entityType,
    Value<String>? recordId,
    Value<String>? operationType,
    Value<String>? payloadJson,
    Value<String>? createdAt,
    Value<int>? retryCount,
    Value<String?>? lastAttemptAt,
    Value<String>? status,
    Value<String?>? errorMessage,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      recordId: recordId ?? this.recordId,
      operationType: operationType ?? this.operationType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<String>(lastAttemptAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('recordId: $recordId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<String> lastSyncedAt = GeneratedColumn<String>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastServerVersionMeta = const VerificationMeta(
    'lastServerVersion',
  );
  @override
  late final GeneratedColumn<int> lastServerVersion = GeneratedColumn<int>(
    'last_server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    userId,
    lastSyncedAt,
    lastServerVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_server_version')) {
      context.handle(
        _lastServerVersionMeta,
        lastServerVersion.isAcceptableOrUnknown(
          data['last_server_version']!,
          _lastServerVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key, userId};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastServerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_server_version'],
      ),
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String key;
  final String userId;
  final String? lastSyncedAt;
  final int? lastServerVersion;
  final String updatedAt;
  const SyncMetadataData({
    required this.key,
    required this.userId,
    this.lastSyncedAt,
    this.lastServerVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt);
    }
    if (!nullToAbsent || lastServerVersion != null) {
      map['last_server_version'] = Variable<int>(lastServerVersion);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      key: Value(key),
      userId: Value(userId),
      lastSyncedAt:
          lastSyncedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSyncedAt),
      lastServerVersion:
          lastServerVersion == null && nullToAbsent
              ? const Value.absent()
              : Value(lastServerVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      key: serializer.fromJson<String>(json['key']),
      userId: serializer.fromJson<String>(json['userId']),
      lastSyncedAt: serializer.fromJson<String?>(json['lastSyncedAt']),
      lastServerVersion: serializer.fromJson<int?>(json['lastServerVersion']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'userId': serializer.toJson<String>(userId),
      'lastSyncedAt': serializer.toJson<String?>(lastSyncedAt),
      'lastServerVersion': serializer.toJson<int?>(lastServerVersion),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SyncMetadataData copyWith({
    String? key,
    String? userId,
    Value<String?> lastSyncedAt = const Value.absent(),
    Value<int?> lastServerVersion = const Value.absent(),
    String? updatedAt,
  }) => SyncMetadataData(
    key: key ?? this.key,
    userId: userId ?? this.userId,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastServerVersion:
        lastServerVersion.present
            ? lastServerVersion.value
            : this.lastServerVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      key: data.key.present ? data.key.value : this.key,
      userId: data.userId.present ? data.userId.value : this.userId,
      lastSyncedAt:
          data.lastSyncedAt.present
              ? data.lastSyncedAt.value
              : this.lastSyncedAt,
      lastServerVersion:
          data.lastServerVersion.present
              ? data.lastServerVersion.value
              : this.lastServerVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('key: $key, ')
          ..write('userId: $userId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastServerVersion: $lastServerVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, userId, lastSyncedAt, lastServerVersion, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.key == this.key &&
          other.userId == this.userId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastServerVersion == this.lastServerVersion &&
          other.updatedAt == this.updatedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> key;
  final Value<String> userId;
  final Value<String?> lastSyncedAt;
  final Value<int?> lastServerVersion;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.key = const Value.absent(),
    this.userId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastServerVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String key,
    required String userId,
    this.lastSyncedAt = const Value.absent(),
    this.lastServerVersion = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? key,
    Expression<String>? userId,
    Expression<String>? lastSyncedAt,
    Expression<int>? lastServerVersion,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (userId != null) 'user_id': userId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastServerVersion != null) 'last_server_version': lastServerVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? userId,
    Value<String?>? lastSyncedAt,
    Value<int?>? lastServerVersion,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      key: key ?? this.key,
      userId: userId ?? this.userId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastServerVersion: lastServerVersion ?? this.lastServerVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt.value);
    }
    if (lastServerVersion.present) {
      map['last_server_version'] = Variable<int>(lastServerVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('key: $key, ')
          ..write('userId: $userId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastServerVersion: $lastServerVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $ReminderLogsTable reminderLogs = $ReminderLogsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final ItemsDao itemsDao = ItemsDao(this as AppDatabase);
  late final RemindersDao remindersDao = RemindersDao(this as AppDatabase);
  late final ReminderLogsDao reminderLogsDao = ReminderLogsDao(
    this as AppDatabase,
  );
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    reminders,
    reminderLogs,
    syncOutbox,
    syncMetadata,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminder_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reminders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminder_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      required String id,
      required String userId,
      required String name,
      required String category,
      Value<String?> brand,
      Value<String?> modelNumber,
      Value<String?> serialOrPlateNumber,
      Value<String?> purchaseDate,
      Value<bool> hasOdometer,
      Value<int?> currentOdometer,
      Value<String?> photoLocalPath,
      Value<String?> photoRemotePath,
      Value<String?> notes,
      Value<bool> isArchived,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> category,
      Value<String?> brand,
      Value<String?> modelNumber,
      Value<String?> serialOrPlateNumber,
      Value<String?> purchaseDate,
      Value<bool> hasOdometer,
      Value<int?> currentOdometer,
      Value<String?> photoLocalPath,
      Value<String?> photoRemotePath,
      Value<String?> notes,
      Value<bool> isArchived,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, Item> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: $_aliasNameGenerator(db.items.id, db.reminders.itemId),
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderLogsTable, List<ReminderLog>>
  _reminderLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderLogs,
    aliasName: $_aliasNameGenerator(db.items.id, db.reminderLogs.itemId),
  );

  $$ReminderLogsTableProcessedTableManager get reminderLogsRefs {
    final manager = $$ReminderLogsTableTableManager(
      $_db,
      $_db.reminderLogs,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialOrPlateNumber => $composableBuilder(
    column: $table.serialOrPlateNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasOdometer => $composableBuilder(
    column: $table.hasOdometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentOdometer => $composableBuilder(
    column: $table.currentOdometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoRemotePath => $composableBuilder(
    column: $table.photoRemotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderLogsRefs(
    Expression<bool> Function($$ReminderLogsTableFilterComposer f) f,
  ) {
    final $$ReminderLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderLogs,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderLogsTableFilterComposer(
            $db: $db,
            $table: $db.reminderLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialOrPlateNumber => $composableBuilder(
    column: $table.serialOrPlateNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasOdometer => $composableBuilder(
    column: $table.hasOdometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentOdometer => $composableBuilder(
    column: $table.currentOdometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoRemotePath => $composableBuilder(
    column: $table.photoRemotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serialOrPlateNumber => $composableBuilder(
    column: $table.serialOrPlateNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasOdometer => $composableBuilder(
    column: $table.hasOdometer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentOdometer => $composableBuilder(
    column: $table.currentOdometer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoRemotePath => $composableBuilder(
    column: $table.photoRemotePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderLogsRefs<T extends Object>(
    Expression<T> Function($$ReminderLogsTableAnnotationComposer a) f,
  ) {
    final $$ReminderLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderLogs,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, $$ItemsTableReferences),
          Item,
          PrefetchHooks Function({bool remindersRefs, bool reminderLogsRefs})
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> modelNumber = const Value.absent(),
                Value<String?> serialOrPlateNumber = const Value.absent(),
                Value<String?> purchaseDate = const Value.absent(),
                Value<bool> hasOdometer = const Value.absent(),
                Value<int?> currentOdometer = const Value.absent(),
                Value<String?> photoLocalPath = const Value.absent(),
                Value<String?> photoRemotePath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                userId: userId,
                name: name,
                category: category,
                brand: brand,
                modelNumber: modelNumber,
                serialOrPlateNumber: serialOrPlateNumber,
                purchaseDate: purchaseDate,
                hasOdometer: hasOdometer,
                currentOdometer: currentOdometer,
                photoLocalPath: photoLocalPath,
                photoRemotePath: photoRemotePath,
                notes: notes,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required String category,
                Value<String?> brand = const Value.absent(),
                Value<String?> modelNumber = const Value.absent(),
                Value<String?> serialOrPlateNumber = const Value.absent(),
                Value<String?> purchaseDate = const Value.absent(),
                Value<bool> hasOdometer = const Value.absent(),
                Value<int?> currentOdometer = const Value.absent(),
                Value<String?> photoLocalPath = const Value.absent(),
                Value<String?> photoRemotePath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                category: category,
                brand: brand,
                modelNumber: modelNumber,
                serialOrPlateNumber: serialOrPlateNumber,
                purchaseDate: purchaseDate,
                hasOdometer: hasOdometer,
                currentOdometer: currentOdometer,
                photoLocalPath: photoLocalPath,
                photoRemotePath: photoRemotePath,
                notes: notes,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ItemsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            remindersRefs = false,
            reminderLogsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (remindersRefs) db.reminders,
                if (reminderLogsRefs) db.reminderLogs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (remindersRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, Reminder>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._remindersRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                  if (reminderLogsRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, ReminderLog>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._reminderLogsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderLogsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, $$ItemsTableReferences),
      Item,
      PrefetchHooks Function({bool remindersRefs, bool reminderLogsRefs})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String userId,
      required String itemId,
      required String name,
      required String engineType,
      Value<String?> intervalUnit,
      Value<int?> intervalValue,
      Value<String?> baselineMode,
      Value<int?> anchorDay,
      Value<String?> targetDate,
      Value<String?> targetTime,
      Value<int?> usageCounter,
      Value<int?> usageThreshold,
      Value<String?> usageUnit,
      Value<int?> lastServiceOdometer,
      Value<int?> intervalKm,
      Value<String?> snoozeUntil,
      Value<bool> isActive,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> itemId,
      Value<String> name,
      Value<String> engineType,
      Value<String?> intervalUnit,
      Value<int?> intervalValue,
      Value<String?> baselineMode,
      Value<int?> anchorDay,
      Value<String?> targetDate,
      Value<String?> targetTime,
      Value<int?> usageCounter,
      Value<int?> usageThreshold,
      Value<String?> usageUnit,
      Value<int?> lastServiceOdometer,
      Value<int?> intervalKm,
      Value<String?> snoozeUntil,
      Value<bool> isActive,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.reminders.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReminderLogsTable, List<ReminderLog>>
  _reminderLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderLogs,
    aliasName: $_aliasNameGenerator(
      db.reminders.id,
      db.reminderLogs.reminderId,
    ),
  );

  $$ReminderLogsTableProcessedTableManager get reminderLogsRefs {
    final manager = $$ReminderLogsTableTableManager(
      $_db,
      $_db.reminderLogs,
    ).filter((f) => f.reminderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineType => $composableBuilder(
    column: $table.engineType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baselineMode => $composableBuilder(
    column: $table.baselineMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTime => $composableBuilder(
    column: $table.targetTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCounter => $composableBuilder(
    column: $table.usageCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageThreshold => $composableBuilder(
    column: $table.usageThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageUnit => $composableBuilder(
    column: $table.usageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastServiceOdometer => $composableBuilder(
    column: $table.lastServiceOdometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reminderLogsRefs(
    Expression<bool> Function($$ReminderLogsTableFilterComposer f) f,
  ) {
    final $$ReminderLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderLogs,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderLogsTableFilterComposer(
            $db: $db,
            $table: $db.reminderLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineType => $composableBuilder(
    column: $table.engineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baselineMode => $composableBuilder(
    column: $table.baselineMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTime => $composableBuilder(
    column: $table.targetTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCounter => $composableBuilder(
    column: $table.usageCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageThreshold => $composableBuilder(
    column: $table.usageThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageUnit => $composableBuilder(
    column: $table.usageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastServiceOdometer => $composableBuilder(
    column: $table.lastServiceOdometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get engineType => $composableBuilder(
    column: $table.engineType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baselineMode => $composableBuilder(
    column: $table.baselineMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anchorDay =>
      $composableBuilder(column: $table.anchorDay, builder: (column) => column);

  GeneratedColumn<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetTime => $composableBuilder(
    column: $table.targetTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageCounter => $composableBuilder(
    column: $table.usageCounter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageThreshold => $composableBuilder(
    column: $table.usageThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usageUnit =>
      $composableBuilder(column: $table.usageUnit, builder: (column) => column);

  GeneratedColumn<int> get lastServiceOdometer => $composableBuilder(
    column: $table.lastServiceOdometer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reminderLogsRefs<T extends Object>(
    Expression<T> Function($$ReminderLogsTableAnnotationComposer a) f,
  ) {
    final $$ReminderLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderLogs,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool itemId, bool reminderLogsRefs})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> engineType = const Value.absent(),
                Value<String?> intervalUnit = const Value.absent(),
                Value<int?> intervalValue = const Value.absent(),
                Value<String?> baselineMode = const Value.absent(),
                Value<int?> anchorDay = const Value.absent(),
                Value<String?> targetDate = const Value.absent(),
                Value<String?> targetTime = const Value.absent(),
                Value<int?> usageCounter = const Value.absent(),
                Value<int?> usageThreshold = const Value.absent(),
                Value<String?> usageUnit = const Value.absent(),
                Value<int?> lastServiceOdometer = const Value.absent(),
                Value<int?> intervalKm = const Value.absent(),
                Value<String?> snoozeUntil = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                userId: userId,
                itemId: itemId,
                name: name,
                engineType: engineType,
                intervalUnit: intervalUnit,
                intervalValue: intervalValue,
                baselineMode: baselineMode,
                anchorDay: anchorDay,
                targetDate: targetDate,
                targetTime: targetTime,
                usageCounter: usageCounter,
                usageThreshold: usageThreshold,
                usageUnit: usageUnit,
                lastServiceOdometer: lastServiceOdometer,
                intervalKm: intervalKm,
                snoozeUntil: snoozeUntil,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String itemId,
                required String name,
                required String engineType,
                Value<String?> intervalUnit = const Value.absent(),
                Value<int?> intervalValue = const Value.absent(),
                Value<String?> baselineMode = const Value.absent(),
                Value<int?> anchorDay = const Value.absent(),
                Value<String?> targetDate = const Value.absent(),
                Value<String?> targetTime = const Value.absent(),
                Value<int?> usageCounter = const Value.absent(),
                Value<int?> usageThreshold = const Value.absent(),
                Value<String?> usageUnit = const Value.absent(),
                Value<int?> lastServiceOdometer = const Value.absent(),
                Value<int?> intervalKm = const Value.absent(),
                Value<String?> snoozeUntil = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                userId: userId,
                itemId: itemId,
                name: name,
                engineType: engineType,
                intervalUnit: intervalUnit,
                intervalValue: intervalValue,
                baselineMode: baselineMode,
                anchorDay: anchorDay,
                targetDate: targetDate,
                targetTime: targetTime,
                usageCounter: usageCounter,
                usageThreshold: usageThreshold,
                usageUnit: usageUnit,
                lastServiceOdometer: lastServiceOdometer,
                intervalKm: intervalKm,
                snoozeUntil: snoozeUntil,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$RemindersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({itemId = false, reminderLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (reminderLogsRefs) db.reminderLogs],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$RemindersTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$RemindersTableReferences._itemIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reminderLogsRefs)
                    await $_getPrefetchedData<
                      Reminder,
                      $RemindersTable,
                      ReminderLog
                    >(
                      currentTable: table,
                      referencedTable: $$RemindersTableReferences
                          ._reminderLogsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$RemindersTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderLogsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.reminderId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool itemId, bool reminderLogsRefs})
    >;
typedef $$ReminderLogsTableCreateCompanionBuilder =
    ReminderLogsCompanion Function({
      required String id,
      required String userId,
      required String itemId,
      required String reminderId,
      required String completedAt,
      required String completionDate,
      Value<int?> odometerAtCompletion,
      Value<double?> cost,
      Value<String?> performedBy,
      Value<String?> notes,
      required String createdAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$ReminderLogsTableUpdateCompanionBuilder =
    ReminderLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> itemId,
      Value<String> reminderId,
      Value<String> completedAt,
      Value<String> completionDate,
      Value<int?> odometerAtCompletion,
      Value<double?> cost,
      Value<String?> performedBy,
      Value<String?> notes,
      Value<String> createdAt,
      Value<int> version,
      Value<int> rowid,
    });

final class $$ReminderLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReminderLogsTable, ReminderLog> {
  $$ReminderLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.reminderLogs.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RemindersTable _reminderIdTable(_$AppDatabase db) =>
      db.reminders.createAlias(
        $_aliasNameGenerator(db.reminderLogs.reminderId, db.reminders.id),
      );

  $$RemindersTableProcessedTableManager get reminderId {
    final $_column = $_itemColumn<String>('reminder_id')!;

    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reminderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderLogsTable> {
  $$ReminderLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerAtCompletion => $composableBuilder(
    column: $table.odometerAtCompletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RemindersTableFilterComposer get reminderId {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderLogsTable> {
  $$ReminderLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerAtCompletion => $composableBuilder(
    column: $table.odometerAtCompletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RemindersTableOrderingComposer get reminderId {
    final $$RemindersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableOrderingComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderLogsTable> {
  $$ReminderLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odometerAtCompletion => $composableBuilder(
    column: $table.odometerAtCompletion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RemindersTableAnnotationComposer get reminderId {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderLogsTable,
          ReminderLog,
          $$ReminderLogsTableFilterComposer,
          $$ReminderLogsTableOrderingComposer,
          $$ReminderLogsTableAnnotationComposer,
          $$ReminderLogsTableCreateCompanionBuilder,
          $$ReminderLogsTableUpdateCompanionBuilder,
          (ReminderLog, $$ReminderLogsTableReferences),
          ReminderLog,
          PrefetchHooks Function({bool itemId, bool reminderId})
        > {
  $$ReminderLogsTableTableManager(_$AppDatabase db, $ReminderLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ReminderLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ReminderLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ReminderLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> reminderId = const Value.absent(),
                Value<String> completedAt = const Value.absent(),
                Value<String> completionDate = const Value.absent(),
                Value<int?> odometerAtCompletion = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<String?> performedBy = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderLogsCompanion(
                id: id,
                userId: userId,
                itemId: itemId,
                reminderId: reminderId,
                completedAt: completedAt,
                completionDate: completionDate,
                odometerAtCompletion: odometerAtCompletion,
                cost: cost,
                performedBy: performedBy,
                notes: notes,
                createdAt: createdAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String itemId,
                required String reminderId,
                required String completedAt,
                required String completionDate,
                Value<int?> odometerAtCompletion = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<String?> performedBy = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderLogsCompanion.insert(
                id: id,
                userId: userId,
                itemId: itemId,
                reminderId: reminderId,
                completedAt: completedAt,
                completionDate: completionDate,
                odometerAtCompletion: odometerAtCompletion,
                cost: cost,
                performedBy: performedBy,
                notes: notes,
                createdAt: createdAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ReminderLogsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({itemId = false, reminderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$ReminderLogsTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$ReminderLogsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (reminderId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.reminderId,
                            referencedTable: $$ReminderLogsTableReferences
                                ._reminderIdTable(db),
                            referencedColumn:
                                $$ReminderLogsTableReferences
                                    ._reminderIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReminderLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderLogsTable,
      ReminderLog,
      $$ReminderLogsTableFilterComposer,
      $$ReminderLogsTableOrderingComposer,
      $$ReminderLogsTableAnnotationComposer,
      $$ReminderLogsTableCreateCompanionBuilder,
      $$ReminderLogsTableUpdateCompanionBuilder,
      (ReminderLog, $$ReminderLogsTableReferences),
      ReminderLog,
      PrefetchHooks Function({bool itemId, bool reminderId})
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> id,
      required String operationId,
      required String userId,
      required String entityType,
      required String recordId,
      required String operationType,
      required String payloadJson,
      required String createdAt,
      Value<int> retryCount,
      Value<String?> lastAttemptAt,
      Value<String> status,
      Value<String?> errorMessage,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> id,
      Value<String> operationId,
      Value<String> userId,
      Value<String> entityType,
      Value<String> recordId,
      Value<String> operationType,
      Value<String> payloadJson,
      Value<String> createdAt,
      Value<int> retryCount,
      Value<String?> lastAttemptAt,
      Value<String> status,
      Value<String?> errorMessage,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastAttemptAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                operationId: operationId,
                userId: userId,
                entityType: entityType,
                recordId: recordId,
                operationType: operationType,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                status: status,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operationId,
                required String userId,
                required String entityType,
                required String recordId,
                required String operationType,
                required String payloadJson,
                required String createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastAttemptAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                operationId: operationId,
                userId: userId,
                entityType: entityType,
                recordId: recordId,
                operationType: operationType,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                status: status,
                errorMessage: errorMessage,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String key,
      required String userId,
      Value<String?> lastSyncedAt,
      Value<int?> lastServerVersion,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> key,
      Value<String> userId,
      Value<String?> lastSyncedAt,
      Value<int?> lastServerVersion,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastServerVersion => $composableBuilder(
    column: $table.lastServerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastServerVersion => $composableBuilder(
    column: $table.lastServerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastServerVersion => $composableBuilder(
    column: $table.lastServerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<int?> lastServerVersion = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                key: key,
                userId: userId,
                lastSyncedAt: lastSyncedAt,
                lastServerVersion: lastServerVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String userId,
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<int?> lastServerVersion = const Value.absent(),
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                key: key,
                userId: userId,
                lastSyncedAt: lastSyncedAt,
                lastServerVersion: lastServerVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$ReminderLogsTableTableManager get reminderLogs =>
      $$ReminderLogsTableTableManager(_db, _db.reminderLogs);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
