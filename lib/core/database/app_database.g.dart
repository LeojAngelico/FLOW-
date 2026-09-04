// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (length(display_name) <= 24)',
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (age BETWEEN 9 AND 120)',
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (weight_kg BETWEEN 25.0 AND 250.0)',
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _environmentMeta = const VerificationMeta(
    'environment',
  );
  @override
  late final GeneratedColumn<String> environment = GeneratedColumn<String>(
    'environment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialCircumstancesMeta =
      const VerificationMeta('specialCircumstances');
  @override
  late final GeneratedColumn<String> specialCircumstances =
      GeneratedColumn<String>(
        'special_circumstances',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _dailyTargetMlMeta = const VerificationMeta(
    'dailyTargetMl',
  );
  @override
  late final GeneratedColumn<int> dailyTargetMl = GeneratedColumn<int>(
    'daily_target_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (daily_target_ml BETWEEN 500 AND 4000)',
  );
  static const VerificationMeta _targetSourceMeta = const VerificationMeta(
    'targetSource',
  );
  @override
  late final GeneratedColumn<String> targetSource = GeneratedColumn<String>(
    'target_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculatorMethodIdMeta =
      const VerificationMeta('calculatorMethodId');
  @override
  late final GeneratedColumn<String> calculatorMethodId =
      GeneratedColumn<String>(
        'calculator_method_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _profileCreatedAtMeta = const VerificationMeta(
    'profileCreatedAt',
  );
  @override
  late final GeneratedColumn<int> profileCreatedAt = GeneratedColumn<int>(
    'profile_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    age,
    sex,
    weightKg,
    activityLevel,
    environment,
    specialCircumstances,
    dailyTargetMl,
    targetSource,
    calculatorMethodId,
    profileCreatedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityLevelMeta);
    }
    if (data.containsKey('environment')) {
      context.handle(
        _environmentMeta,
        environment.isAcceptableOrUnknown(
          data['environment']!,
          _environmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_environmentMeta);
    }
    if (data.containsKey('special_circumstances')) {
      context.handle(
        _specialCircumstancesMeta,
        specialCircumstances.isAcceptableOrUnknown(
          data['special_circumstances']!,
          _specialCircumstancesMeta,
        ),
      );
    }
    if (data.containsKey('daily_target_ml')) {
      context.handle(
        _dailyTargetMlMeta,
        dailyTargetMl.isAcceptableOrUnknown(
          data['daily_target_ml']!,
          _dailyTargetMlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyTargetMlMeta);
    }
    if (data.containsKey('target_source')) {
      context.handle(
        _targetSourceMeta,
        targetSource.isAcceptableOrUnknown(
          data['target_source']!,
          _targetSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetSourceMeta);
    }
    if (data.containsKey('calculator_method_id')) {
      context.handle(
        _calculatorMethodIdMeta,
        calculatorMethodId.isAcceptableOrUnknown(
          data['calculator_method_id']!,
          _calculatorMethodIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatorMethodIdMeta);
    }
    if (data.containsKey('profile_created_at')) {
      context.handle(
        _profileCreatedAtMeta,
        profileCreatedAt.isAcceptableOrUnknown(
          data['profile_created_at']!,
          _profileCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profileCreatedAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      )!,
      environment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment'],
      )!,
      specialCircumstances: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_circumstances'],
      )!,
      dailyTargetMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_target_ml'],
      )!,
      targetSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_source'],
      )!,
      calculatorMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculator_method_id'],
      )!,
      profileCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String? displayName;
  final int age;
  final String sex;
  final double weightKg;
  final String activityLevel;
  final String environment;
  final String specialCircumstances;
  final int dailyTargetMl;
  final String targetSource;
  final String calculatorMethodId;
  final int profileCreatedAt;
  final int updatedAt;
  const UserProfile({
    required this.id,
    this.displayName,
    required this.age,
    required this.sex,
    required this.weightKg,
    required this.activityLevel,
    required this.environment,
    required this.specialCircumstances,
    required this.dailyTargetMl,
    required this.targetSource,
    required this.calculatorMethodId,
    required this.profileCreatedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['age'] = Variable<int>(age);
    map['sex'] = Variable<String>(sex);
    map['weight_kg'] = Variable<double>(weightKg);
    map['activity_level'] = Variable<String>(activityLevel);
    map['environment'] = Variable<String>(environment);
    map['special_circumstances'] = Variable<String>(specialCircumstances);
    map['daily_target_ml'] = Variable<int>(dailyTargetMl);
    map['target_source'] = Variable<String>(targetSource);
    map['calculator_method_id'] = Variable<String>(calculatorMethodId);
    map['profile_created_at'] = Variable<int>(profileCreatedAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      age: Value(age),
      sex: Value(sex),
      weightKg: Value(weightKg),
      activityLevel: Value(activityLevel),
      environment: Value(environment),
      specialCircumstances: Value(specialCircumstances),
      dailyTargetMl: Value(dailyTargetMl),
      targetSource: Value(targetSource),
      calculatorMethodId: Value(calculatorMethodId),
      profileCreatedAt: Value(profileCreatedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      age: serializer.fromJson<int>(json['age']),
      sex: serializer.fromJson<String>(json['sex']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      activityLevel: serializer.fromJson<String>(json['activityLevel']),
      environment: serializer.fromJson<String>(json['environment']),
      specialCircumstances: serializer.fromJson<String>(
        json['specialCircumstances'],
      ),
      dailyTargetMl: serializer.fromJson<int>(json['dailyTargetMl']),
      targetSource: serializer.fromJson<String>(json['targetSource']),
      calculatorMethodId: serializer.fromJson<String>(
        json['calculatorMethodId'],
      ),
      profileCreatedAt: serializer.fromJson<int>(json['profileCreatedAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'age': serializer.toJson<int>(age),
      'sex': serializer.toJson<String>(sex),
      'weightKg': serializer.toJson<double>(weightKg),
      'activityLevel': serializer.toJson<String>(activityLevel),
      'environment': serializer.toJson<String>(environment),
      'specialCircumstances': serializer.toJson<String>(specialCircumstances),
      'dailyTargetMl': serializer.toJson<int>(dailyTargetMl),
      'targetSource': serializer.toJson<String>(targetSource),
      'calculatorMethodId': serializer.toJson<String>(calculatorMethodId),
      'profileCreatedAt': serializer.toJson<int>(profileCreatedAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    Value<String?> displayName = const Value.absent(),
    int? age,
    String? sex,
    double? weightKg,
    String? activityLevel,
    String? environment,
    String? specialCircumstances,
    int? dailyTargetMl,
    String? targetSource,
    String? calculatorMethodId,
    int? profileCreatedAt,
    int? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    displayName: displayName.present ? displayName.value : this.displayName,
    age: age ?? this.age,
    sex: sex ?? this.sex,
    weightKg: weightKg ?? this.weightKg,
    activityLevel: activityLevel ?? this.activityLevel,
    environment: environment ?? this.environment,
    specialCircumstances: specialCircumstances ?? this.specialCircumstances,
    dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
    targetSource: targetSource ?? this.targetSource,
    calculatorMethodId: calculatorMethodId ?? this.calculatorMethodId,
    profileCreatedAt: profileCreatedAt ?? this.profileCreatedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      age: data.age.present ? data.age.value : this.age,
      sex: data.sex.present ? data.sex.value : this.sex,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      environment: data.environment.present
          ? data.environment.value
          : this.environment,
      specialCircumstances: data.specialCircumstances.present
          ? data.specialCircumstances.value
          : this.specialCircumstances,
      dailyTargetMl: data.dailyTargetMl.present
          ? data.dailyTargetMl.value
          : this.dailyTargetMl,
      targetSource: data.targetSource.present
          ? data.targetSource.value
          : this.targetSource,
      calculatorMethodId: data.calculatorMethodId.present
          ? data.calculatorMethodId.value
          : this.calculatorMethodId,
      profileCreatedAt: data.profileCreatedAt.present
          ? data.profileCreatedAt.value
          : this.profileCreatedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('age: $age, ')
          ..write('sex: $sex, ')
          ..write('weightKg: $weightKg, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('environment: $environment, ')
          ..write('specialCircumstances: $specialCircumstances, ')
          ..write('dailyTargetMl: $dailyTargetMl, ')
          ..write('targetSource: $targetSource, ')
          ..write('calculatorMethodId: $calculatorMethodId, ')
          ..write('profileCreatedAt: $profileCreatedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    age,
    sex,
    weightKg,
    activityLevel,
    environment,
    specialCircumstances,
    dailyTargetMl,
    targetSource,
    calculatorMethodId,
    profileCreatedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.age == this.age &&
          other.sex == this.sex &&
          other.weightKg == this.weightKg &&
          other.activityLevel == this.activityLevel &&
          other.environment == this.environment &&
          other.specialCircumstances == this.specialCircumstances &&
          other.dailyTargetMl == this.dailyTargetMl &&
          other.targetSource == this.targetSource &&
          other.calculatorMethodId == this.calculatorMethodId &&
          other.profileCreatedAt == this.profileCreatedAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String?> displayName;
  final Value<int> age;
  final Value<String> sex;
  final Value<double> weightKg;
  final Value<String> activityLevel;
  final Value<String> environment;
  final Value<String> specialCircumstances;
  final Value<int> dailyTargetMl;
  final Value<String> targetSource;
  final Value<String> calculatorMethodId;
  final Value<int> profileCreatedAt;
  final Value<int> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.age = const Value.absent(),
    this.sex = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.environment = const Value.absent(),
    this.specialCircumstances = const Value.absent(),
    this.dailyTargetMl = const Value.absent(),
    this.targetSource = const Value.absent(),
    this.calculatorMethodId = const Value.absent(),
    this.profileCreatedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    required int age,
    required String sex,
    required double weightKg,
    required String activityLevel,
    required String environment,
    this.specialCircumstances = const Value.absent(),
    required int dailyTargetMl,
    required String targetSource,
    required String calculatorMethodId,
    required int profileCreatedAt,
    required int updatedAt,
  }) : age = Value(age),
       sex = Value(sex),
       weightKg = Value(weightKg),
       activityLevel = Value(activityLevel),
       environment = Value(environment),
       dailyTargetMl = Value(dailyTargetMl),
       targetSource = Value(targetSource),
       calculatorMethodId = Value(calculatorMethodId),
       profileCreatedAt = Value(profileCreatedAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<int>? age,
    Expression<String>? sex,
    Expression<double>? weightKg,
    Expression<String>? activityLevel,
    Expression<String>? environment,
    Expression<String>? specialCircumstances,
    Expression<int>? dailyTargetMl,
    Expression<String>? targetSource,
    Expression<String>? calculatorMethodId,
    Expression<int>? profileCreatedAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (age != null) 'age': age,
      if (sex != null) 'sex': sex,
      if (weightKg != null) 'weight_kg': weightKg,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (environment != null) 'environment': environment,
      if (specialCircumstances != null)
        'special_circumstances': specialCircumstances,
      if (dailyTargetMl != null) 'daily_target_ml': dailyTargetMl,
      if (targetSource != null) 'target_source': targetSource,
      if (calculatorMethodId != null)
        'calculator_method_id': calculatorMethodId,
      if (profileCreatedAt != null) 'profile_created_at': profileCreatedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String?>? displayName,
    Value<int>? age,
    Value<String>? sex,
    Value<double>? weightKg,
    Value<String>? activityLevel,
    Value<String>? environment,
    Value<String>? specialCircumstances,
    Value<int>? dailyTargetMl,
    Value<String>? targetSource,
    Value<String>? calculatorMethodId,
    Value<int>? profileCreatedAt,
    Value<int>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      environment: environment ?? this.environment,
      specialCircumstances: specialCircumstances ?? this.specialCircumstances,
      dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
      targetSource: targetSource ?? this.targetSource,
      calculatorMethodId: calculatorMethodId ?? this.calculatorMethodId,
      profileCreatedAt: profileCreatedAt ?? this.profileCreatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (environment.present) {
      map['environment'] = Variable<String>(environment.value);
    }
    if (specialCircumstances.present) {
      map['special_circumstances'] = Variable<String>(
        specialCircumstances.value,
      );
    }
    if (dailyTargetMl.present) {
      map['daily_target_ml'] = Variable<int>(dailyTargetMl.value);
    }
    if (targetSource.present) {
      map['target_source'] = Variable<String>(targetSource.value);
    }
    if (calculatorMethodId.present) {
      map['calculator_method_id'] = Variable<String>(calculatorMethodId.value);
    }
    if (profileCreatedAt.present) {
      map['profile_created_at'] = Variable<int>(profileCreatedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('age: $age, ')
          ..write('sex: $sex, ')
          ..write('weightKg: $weightKg, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('environment: $environment, ')
          ..write('specialCircumstances: $specialCircumstances, ')
          ..write('dailyTargetMl: $dailyTargetMl, ')
          ..write('targetSource: $targetSource, ')
          ..write('calculatorMethodId: $calculatorMethodId, ')
          ..write('profileCreatedAt: $profileCreatedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HydrationEntriesTable extends HydrationEntries
    with TableInfo<$HydrationEntriesTable, HydrationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HydrationEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMlMeta = const VerificationMeta(
    'amountMl',
  );
  @override
  late final GeneratedColumn<int> amountMl = GeneratedColumn<int>(
    'amount_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_ml BETWEEN 50 AND 2000)',
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountMl,
    occurredAt,
    localDate,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hydration_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HydrationEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_ml')) {
      context.handle(
        _amountMlMeta,
        amountMl.isAcceptableOrUnknown(data['amount_ml']!, _amountMlMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMlMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HydrationEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HydrationEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_ml'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HydrationEntriesTable createAlias(String alias) {
    return $HydrationEntriesTable(attachedDatabase, alias);
  }
}

class HydrationEntry extends DataClass implements Insertable<HydrationEntry> {
  final String id;
  final int amountMl;
  final int occurredAt;
  final String localDate;
  final String source;
  final int createdAt;
  const HydrationEntry({
    required this.id,
    required this.amountMl,
    required this.occurredAt,
    required this.localDate,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_ml'] = Variable<int>(amountMl);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['local_date'] = Variable<String>(localDate);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  HydrationEntriesCompanion toCompanion(bool nullToAbsent) {
    return HydrationEntriesCompanion(
      id: Value(id),
      amountMl: Value(amountMl),
      occurredAt: Value(occurredAt),
      localDate: Value(localDate),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory HydrationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HydrationEntry(
      id: serializer.fromJson<String>(json['id']),
      amountMl: serializer.fromJson<int>(json['amountMl']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountMl': serializer.toJson<int>(amountMl),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'localDate': serializer.toJson<String>(localDate),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  HydrationEntry copyWith({
    String? id,
    int? amountMl,
    int? occurredAt,
    String? localDate,
    String? source,
    int? createdAt,
  }) => HydrationEntry(
    id: id ?? this.id,
    amountMl: amountMl ?? this.amountMl,
    occurredAt: occurredAt ?? this.occurredAt,
    localDate: localDate ?? this.localDate,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  HydrationEntry copyWithCompanion(HydrationEntriesCompanion data) {
    return HydrationEntry(
      id: data.id.present ? data.id.value : this.id,
      amountMl: data.amountMl.present ? data.amountMl.value : this.amountMl,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HydrationEntry(')
          ..write('id: $id, ')
          ..write('amountMl: $amountMl, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('localDate: $localDate, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amountMl, occurredAt, localDate, source, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HydrationEntry &&
          other.id == this.id &&
          other.amountMl == this.amountMl &&
          other.occurredAt == this.occurredAt &&
          other.localDate == this.localDate &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class HydrationEntriesCompanion extends UpdateCompanion<HydrationEntry> {
  final Value<String> id;
  final Value<int> amountMl;
  final Value<int> occurredAt;
  final Value<String> localDate;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<int> rowid;
  const HydrationEntriesCompanion({
    this.id = const Value.absent(),
    this.amountMl = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.localDate = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HydrationEntriesCompanion.insert({
    required String id,
    required int amountMl,
    required int occurredAt,
    required String localDate,
    required String source,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountMl = Value(amountMl),
       occurredAt = Value(occurredAt),
       localDate = Value(localDate),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<HydrationEntry> custom({
    Expression<String>? id,
    Expression<int>? amountMl,
    Expression<int>? occurredAt,
    Expression<String>? localDate,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMl != null) 'amount_ml': amountMl,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (localDate != null) 'local_date': localDate,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HydrationEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? amountMl,
    Value<int>? occurredAt,
    Value<String>? localDate,
    Value<String>? source,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return HydrationEntriesCompanion(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      occurredAt: occurredAt ?? this.occurredAt,
      localDate: localDate ?? this.localDate,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountMl.present) {
      map['amount_ml'] = Variable<int>(amountMl.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HydrationEntriesCompanion(')
          ..write('id: $id, ')
          ..write('amountMl: $amountMl, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('localDate: $localDate, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyHydrationTable extends DailyHydration
    with TableInfo<$DailyHydrationTable, DailyHydrationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyHydrationTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMlMeta = const VerificationMeta(
    'totalMl',
  );
  @override
  late final GeneratedColumn<int> totalMl = GeneratedColumn<int>(
    'total_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetMlMeta = const VerificationMeta(
    'targetMl',
  );
  @override
  late final GeneratedColumn<int> targetMl = GeneratedColumn<int>(
    'target_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (target_ml BETWEEN 500 AND 4000)',
  );
  static const VerificationMeta _goalCompletedMeta = const VerificationMeta(
    'goalCompleted',
  );
  @override
  late final GeneratedColumn<bool> goalCompleted = GeneratedColumn<bool>(
    'goal_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("goal_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _goalCompletedAtMeta = const VerificationMeta(
    'goalCompletedAt',
  );
  @override
  late final GeneratedColumn<int> goalCompletedAt = GeneratedColumn<int>(
    'goal_completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryCountMeta = const VerificationMeta(
    'entryCount',
  );
  @override
  late final GeneratedColumn<int> entryCount = GeneratedColumn<int>(
    'entry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('noData'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    totalMl,
    targetMl,
    goalCompleted,
    goalCompletedAt,
    entryCount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_hydration';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyHydrationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_ml')) {
      context.handle(
        _totalMlMeta,
        totalMl.isAcceptableOrUnknown(data['total_ml']!, _totalMlMeta),
      );
    }
    if (data.containsKey('target_ml')) {
      context.handle(
        _targetMlMeta,
        targetMl.isAcceptableOrUnknown(data['target_ml']!, _targetMlMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMlMeta);
    }
    if (data.containsKey('goal_completed')) {
      context.handle(
        _goalCompletedMeta,
        goalCompleted.isAcceptableOrUnknown(
          data['goal_completed']!,
          _goalCompletedMeta,
        ),
      );
    }
    if (data.containsKey('goal_completed_at')) {
      context.handle(
        _goalCompletedAtMeta,
        goalCompletedAt.isAcceptableOrUnknown(
          data['goal_completed_at']!,
          _goalCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('entry_count')) {
      context.handle(
        _entryCountMeta,
        entryCount.isAcceptableOrUnknown(data['entry_count']!, _entryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyHydrationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyHydrationData(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      totalMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_ml'],
      )!,
      targetMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_ml'],
      )!,
      goalCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}goal_completed'],
      )!,
      goalCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_completed_at'],
      ),
      entryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $DailyHydrationTable createAlias(String alias) {
    return $DailyHydrationTable(attachedDatabase, alias);
  }
}

class DailyHydrationData extends DataClass
    implements Insertable<DailyHydrationData> {
  final String date;
  final int totalMl;
  final int targetMl;
  final bool goalCompleted;
  final int? goalCompletedAt;
  final int entryCount;
  final String status;
  const DailyHydrationData({
    required this.date,
    required this.totalMl,
    required this.targetMl,
    required this.goalCompleted,
    this.goalCompletedAt,
    required this.entryCount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['total_ml'] = Variable<int>(totalMl);
    map['target_ml'] = Variable<int>(targetMl);
    map['goal_completed'] = Variable<bool>(goalCompleted);
    if (!nullToAbsent || goalCompletedAt != null) {
      map['goal_completed_at'] = Variable<int>(goalCompletedAt);
    }
    map['entry_count'] = Variable<int>(entryCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  DailyHydrationCompanion toCompanion(bool nullToAbsent) {
    return DailyHydrationCompanion(
      date: Value(date),
      totalMl: Value(totalMl),
      targetMl: Value(targetMl),
      goalCompleted: Value(goalCompleted),
      goalCompletedAt: goalCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(goalCompletedAt),
      entryCount: Value(entryCount),
      status: Value(status),
    );
  }

  factory DailyHydrationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyHydrationData(
      date: serializer.fromJson<String>(json['date']),
      totalMl: serializer.fromJson<int>(json['totalMl']),
      targetMl: serializer.fromJson<int>(json['targetMl']),
      goalCompleted: serializer.fromJson<bool>(json['goalCompleted']),
      goalCompletedAt: serializer.fromJson<int?>(json['goalCompletedAt']),
      entryCount: serializer.fromJson<int>(json['entryCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'totalMl': serializer.toJson<int>(totalMl),
      'targetMl': serializer.toJson<int>(targetMl),
      'goalCompleted': serializer.toJson<bool>(goalCompleted),
      'goalCompletedAt': serializer.toJson<int?>(goalCompletedAt),
      'entryCount': serializer.toJson<int>(entryCount),
      'status': serializer.toJson<String>(status),
    };
  }

  DailyHydrationData copyWith({
    String? date,
    int? totalMl,
    int? targetMl,
    bool? goalCompleted,
    Value<int?> goalCompletedAt = const Value.absent(),
    int? entryCount,
    String? status,
  }) => DailyHydrationData(
    date: date ?? this.date,
    totalMl: totalMl ?? this.totalMl,
    targetMl: targetMl ?? this.targetMl,
    goalCompleted: goalCompleted ?? this.goalCompleted,
    goalCompletedAt: goalCompletedAt.present
        ? goalCompletedAt.value
        : this.goalCompletedAt,
    entryCount: entryCount ?? this.entryCount,
    status: status ?? this.status,
  );
  DailyHydrationData copyWithCompanion(DailyHydrationCompanion data) {
    return DailyHydrationData(
      date: data.date.present ? data.date.value : this.date,
      totalMl: data.totalMl.present ? data.totalMl.value : this.totalMl,
      targetMl: data.targetMl.present ? data.targetMl.value : this.targetMl,
      goalCompleted: data.goalCompleted.present
          ? data.goalCompleted.value
          : this.goalCompleted,
      goalCompletedAt: data.goalCompletedAt.present
          ? data.goalCompletedAt.value
          : this.goalCompletedAt,
      entryCount: data.entryCount.present
          ? data.entryCount.value
          : this.entryCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyHydrationData(')
          ..write('date: $date, ')
          ..write('totalMl: $totalMl, ')
          ..write('targetMl: $targetMl, ')
          ..write('goalCompleted: $goalCompleted, ')
          ..write('goalCompletedAt: $goalCompletedAt, ')
          ..write('entryCount: $entryCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    totalMl,
    targetMl,
    goalCompleted,
    goalCompletedAt,
    entryCount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyHydrationData &&
          other.date == this.date &&
          other.totalMl == this.totalMl &&
          other.targetMl == this.targetMl &&
          other.goalCompleted == this.goalCompleted &&
          other.goalCompletedAt == this.goalCompletedAt &&
          other.entryCount == this.entryCount &&
          other.status == this.status);
}

class DailyHydrationCompanion extends UpdateCompanion<DailyHydrationData> {
  final Value<String> date;
  final Value<int> totalMl;
  final Value<int> targetMl;
  final Value<bool> goalCompleted;
  final Value<int?> goalCompletedAt;
  final Value<int> entryCount;
  final Value<String> status;
  final Value<int> rowid;
  const DailyHydrationCompanion({
    this.date = const Value.absent(),
    this.totalMl = const Value.absent(),
    this.targetMl = const Value.absent(),
    this.goalCompleted = const Value.absent(),
    this.goalCompletedAt = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyHydrationCompanion.insert({
    required String date,
    this.totalMl = const Value.absent(),
    required int targetMl,
    this.goalCompleted = const Value.absent(),
    this.goalCompletedAt = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       targetMl = Value(targetMl);
  static Insertable<DailyHydrationData> custom({
    Expression<String>? date,
    Expression<int>? totalMl,
    Expression<int>? targetMl,
    Expression<bool>? goalCompleted,
    Expression<int>? goalCompletedAt,
    Expression<int>? entryCount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (totalMl != null) 'total_ml': totalMl,
      if (targetMl != null) 'target_ml': targetMl,
      if (goalCompleted != null) 'goal_completed': goalCompleted,
      if (goalCompletedAt != null) 'goal_completed_at': goalCompletedAt,
      if (entryCount != null) 'entry_count': entryCount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyHydrationCompanion copyWith({
    Value<String>? date,
    Value<int>? totalMl,
    Value<int>? targetMl,
    Value<bool>? goalCompleted,
    Value<int?>? goalCompletedAt,
    Value<int>? entryCount,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return DailyHydrationCompanion(
      date: date ?? this.date,
      totalMl: totalMl ?? this.totalMl,
      targetMl: targetMl ?? this.targetMl,
      goalCompleted: goalCompleted ?? this.goalCompleted,
      goalCompletedAt: goalCompletedAt ?? this.goalCompletedAt,
      entryCount: entryCount ?? this.entryCount,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (totalMl.present) {
      map['total_ml'] = Variable<int>(totalMl.value);
    }
    if (targetMl.present) {
      map['target_ml'] = Variable<int>(targetMl.value);
    }
    if (goalCompleted.present) {
      map['goal_completed'] = Variable<bool>(goalCompleted.value);
    }
    if (goalCompletedAt.present) {
      map['goal_completed_at'] = Variable<int>(goalCompletedAt.value);
    }
    if (entryCount.present) {
      map['entry_count'] = Variable<int>(entryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyHydrationCompanion(')
          ..write('date: $date, ')
          ..write('totalMl: $totalMl, ')
          ..write('targetMl: $targetMl, ')
          ..write('goalCompleted: $goalCompleted, ')
          ..write('goalCompletedAt: $goalCompletedAt, ')
          ..write('entryCount: $entryCount, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $XpEventsTable extends XpEvents with TableInfo<$XpEventsTable, XpEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XpEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount >= 0)',
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    localDate,
    occurredAt,
    refId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xp_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<XpEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XpEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XpEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
    );
  }

  @override
  $XpEventsTable createAlias(String alias) {
    return $XpEventsTable(attachedDatabase, alias);
  }
}

class XpEvent extends DataClass implements Insertable<XpEvent> {
  final String id;
  final String type;
  final int amount;
  final String localDate;
  final int occurredAt;
  final String? refId;
  const XpEvent({
    required this.id,
    required this.type,
    required this.amount,
    required this.localDate,
    required this.occurredAt,
    this.refId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    map['local_date'] = Variable<String>(localDate);
    map['occurred_at'] = Variable<int>(occurredAt);
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    return map;
  }

  XpEventsCompanion toCompanion(bool nullToAbsent) {
    return XpEventsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      localDate: Value(localDate),
      occurredAt: Value(occurredAt),
      refId: refId == null && nullToAbsent
          ? const Value.absent()
          : Value(refId),
    );
  }

  factory XpEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XpEvent(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      localDate: serializer.fromJson<String>(json['localDate']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      refId: serializer.fromJson<String?>(json['refId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'localDate': serializer.toJson<String>(localDate),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'refId': serializer.toJson<String?>(refId),
    };
  }

  XpEvent copyWith({
    String? id,
    String? type,
    int? amount,
    String? localDate,
    int? occurredAt,
    Value<String?> refId = const Value.absent(),
  }) => XpEvent(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    localDate: localDate ?? this.localDate,
    occurredAt: occurredAt ?? this.occurredAt,
    refId: refId.present ? refId.value : this.refId,
  );
  XpEvent copyWithCompanion(XpEventsCompanion data) {
    return XpEvent(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      refId: data.refId.present ? data.refId.value : this.refId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XpEvent(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('localDate: $localDate, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('refId: $refId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, amount, localDate, occurredAt, refId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XpEvent &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.localDate == this.localDate &&
          other.occurredAt == this.occurredAt &&
          other.refId == this.refId);
}

class XpEventsCompanion extends UpdateCompanion<XpEvent> {
  final Value<String> id;
  final Value<String> type;
  final Value<int> amount;
  final Value<String> localDate;
  final Value<int> occurredAt;
  final Value<String?> refId;
  final Value<int> rowid;
  const XpEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.localDate = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.refId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  XpEventsCompanion.insert({
    required String id,
    required String type,
    required int amount,
    required String localDate,
    required int occurredAt,
    this.refId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amount = Value(amount),
       localDate = Value(localDate),
       occurredAt = Value(occurredAt);
  static Insertable<XpEvent> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? localDate,
    Expression<int>? occurredAt,
    Expression<String>? refId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (localDate != null) 'local_date': localDate,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (refId != null) 'ref_id': refId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  XpEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<int>? amount,
    Value<String>? localDate,
    Value<int>? occurredAt,
    Value<String?>? refId,
    Value<int>? rowid,
  }) {
    return XpEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      localDate: localDate ?? this.localDate,
      occurredAt: occurredAt ?? this.occurredAt,
      refId: refId ?? this.refId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XpEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('localDate: $localDate, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('refId: $refId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedMeta = const VerificationMeta(
    'unlocked',
  );
  @override
  late final GeneratedColumn<bool> unlocked = GeneratedColumn<bool>(
    'unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<int> unlockedAt = GeneratedColumn<int>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressCurrentMeta = const VerificationMeta(
    'progressCurrent',
  );
  @override
  late final GeneratedColumn<int> progressCurrent = GeneratedColumn<int>(
    'progress_current',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    unlocked,
    unlockedAt,
    progressCurrent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
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
    if (data.containsKey('unlocked')) {
      context.handle(
        _unlockedMeta,
        unlocked.isAcceptableOrUnknown(data['unlocked']!, _unlockedMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('progress_current')) {
      context.handle(
        _progressCurrentMeta,
        progressCurrent.isAcceptableOrUnknown(
          data['progress_current']!,
          _progressCurrentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      unlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}unlocked'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_at'],
      ),
      progressCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_current'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String key;
  final bool unlocked;
  final int? unlockedAt;
  final int progressCurrent;
  const Achievement({
    required this.key,
    required this.unlocked,
    this.unlockedAt,
    required this.progressCurrent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['unlocked'] = Variable<bool>(unlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<int>(unlockedAt);
    }
    map['progress_current'] = Variable<int>(progressCurrent);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      key: Value(key),
      unlocked: Value(unlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      progressCurrent: Value(progressCurrent),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      key: serializer.fromJson<String>(json['key']),
      unlocked: serializer.fromJson<bool>(json['unlocked']),
      unlockedAt: serializer.fromJson<int?>(json['unlockedAt']),
      progressCurrent: serializer.fromJson<int>(json['progressCurrent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'unlocked': serializer.toJson<bool>(unlocked),
      'unlockedAt': serializer.toJson<int?>(unlockedAt),
      'progressCurrent': serializer.toJson<int>(progressCurrent),
    };
  }

  Achievement copyWith({
    String? key,
    bool? unlocked,
    Value<int?> unlockedAt = const Value.absent(),
    int? progressCurrent,
  }) => Achievement(
    key: key ?? this.key,
    unlocked: unlocked ?? this.unlocked,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    progressCurrent: progressCurrent ?? this.progressCurrent,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      key: data.key.present ? data.key.value : this.key,
      unlocked: data.unlocked.present ? data.unlocked.value : this.unlocked,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      progressCurrent: data.progressCurrent.present
          ? data.progressCurrent.value
          : this.progressCurrent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('key: $key, ')
          ..write('unlocked: $unlocked, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('progressCurrent: $progressCurrent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, unlocked, unlockedAt, progressCurrent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.key == this.key &&
          other.unlocked == this.unlocked &&
          other.unlockedAt == this.unlockedAt &&
          other.progressCurrent == this.progressCurrent);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> key;
  final Value<bool> unlocked;
  final Value<int?> unlockedAt;
  final Value<int> progressCurrent;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.key = const Value.absent(),
    this.unlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String key,
    this.unlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<Achievement> custom({
    Expression<String>? key,
    Expression<bool>? unlocked,
    Expression<int>? unlockedAt,
    Expression<int>? progressCurrent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (unlocked != null) 'unlocked': unlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (progressCurrent != null) 'progress_current': progressCurrent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? key,
    Value<bool>? unlocked,
    Value<int?>? unlockedAt,
    Value<int>? progressCurrent,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      key: key ?? this.key,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (unlocked.present) {
      map['unlocked'] = Variable<bool>(unlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<int>(unlockedAt.value);
    }
    if (progressCurrent.present) {
      map['progress_current'] = Variable<int>(progressCurrent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('key: $key, ')
          ..write('unlocked: $unlocked, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TriviaProgressTable extends TriviaProgress
    with TableInfo<$TriviaProgressTable, TriviaProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TriviaProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenAtMeta = const VerificationMeta('seenAt');
  @override
  late final GeneratedColumn<int> seenAt = GeneratedColumn<int>(
    'seen_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _answeredCorrectlyMeta = const VerificationMeta(
    'answeredCorrectly',
  );
  @override
  late final GeneratedColumn<bool> answeredCorrectly = GeneratedColumn<bool>(
    'answered_correctly',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("answered_correctly" IN (0, 1))',
    ),
  );
  static const VerificationMeta _awardedXpMeta = const VerificationMeta(
    'awardedXp',
  );
  @override
  late final GeneratedColumn<bool> awardedXp = GeneratedColumn<bool>(
    'awarded_xp',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("awarded_xp" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    type,
    seenAt,
    completed,
    answeredCorrectly,
    awardedXp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trivia_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<TriviaProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('seen_at')) {
      context.handle(
        _seenAtMeta,
        seenAt.isAcceptableOrUnknown(data['seen_at']!, _seenAtMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('answered_correctly')) {
      context.handle(
        _answeredCorrectlyMeta,
        answeredCorrectly.isAcceptableOrUnknown(
          data['answered_correctly']!,
          _answeredCorrectlyMeta,
        ),
      );
    }
    if (data.containsKey('awarded_xp')) {
      context.handle(
        _awardedXpMeta,
        awardedXp.isAcceptableOrUnknown(data['awarded_xp']!, _awardedXpMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  TriviaProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TriviaProgressData(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      seenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seen_at'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      answeredCorrectly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}answered_correctly'],
      ),
      awardedXp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}awarded_xp'],
      )!,
    );
  }

  @override
  $TriviaProgressTable createAlias(String alias) {
    return $TriviaProgressTable(attachedDatabase, alias);
  }
}

class TriviaProgressData extends DataClass
    implements Insertable<TriviaProgressData> {
  final String itemId;
  final String type;
  final int? seenAt;
  final bool completed;
  final bool? answeredCorrectly;
  final bool awardedXp;
  const TriviaProgressData({
    required this.itemId,
    required this.type,
    this.seenAt,
    required this.completed,
    this.answeredCorrectly,
    required this.awardedXp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || seenAt != null) {
      map['seen_at'] = Variable<int>(seenAt);
    }
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || answeredCorrectly != null) {
      map['answered_correctly'] = Variable<bool>(answeredCorrectly);
    }
    map['awarded_xp'] = Variable<bool>(awardedXp);
    return map;
  }

  TriviaProgressCompanion toCompanion(bool nullToAbsent) {
    return TriviaProgressCompanion(
      itemId: Value(itemId),
      type: Value(type),
      seenAt: seenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(seenAt),
      completed: Value(completed),
      answeredCorrectly: answeredCorrectly == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredCorrectly),
      awardedXp: Value(awardedXp),
    );
  }

  factory TriviaProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TriviaProgressData(
      itemId: serializer.fromJson<String>(json['itemId']),
      type: serializer.fromJson<String>(json['type']),
      seenAt: serializer.fromJson<int?>(json['seenAt']),
      completed: serializer.fromJson<bool>(json['completed']),
      answeredCorrectly: serializer.fromJson<bool?>(json['answeredCorrectly']),
      awardedXp: serializer.fromJson<bool>(json['awardedXp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'type': serializer.toJson<String>(type),
      'seenAt': serializer.toJson<int?>(seenAt),
      'completed': serializer.toJson<bool>(completed),
      'answeredCorrectly': serializer.toJson<bool?>(answeredCorrectly),
      'awardedXp': serializer.toJson<bool>(awardedXp),
    };
  }

  TriviaProgressData copyWith({
    String? itemId,
    String? type,
    Value<int?> seenAt = const Value.absent(),
    bool? completed,
    Value<bool?> answeredCorrectly = const Value.absent(),
    bool? awardedXp,
  }) => TriviaProgressData(
    itemId: itemId ?? this.itemId,
    type: type ?? this.type,
    seenAt: seenAt.present ? seenAt.value : this.seenAt,
    completed: completed ?? this.completed,
    answeredCorrectly: answeredCorrectly.present
        ? answeredCorrectly.value
        : this.answeredCorrectly,
    awardedXp: awardedXp ?? this.awardedXp,
  );
  TriviaProgressData copyWithCompanion(TriviaProgressCompanion data) {
    return TriviaProgressData(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      type: data.type.present ? data.type.value : this.type,
      seenAt: data.seenAt.present ? data.seenAt.value : this.seenAt,
      completed: data.completed.present ? data.completed.value : this.completed,
      answeredCorrectly: data.answeredCorrectly.present
          ? data.answeredCorrectly.value
          : this.answeredCorrectly,
      awardedXp: data.awardedXp.present ? data.awardedXp.value : this.awardedXp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TriviaProgressData(')
          ..write('itemId: $itemId, ')
          ..write('type: $type, ')
          ..write('seenAt: $seenAt, ')
          ..write('completed: $completed, ')
          ..write('answeredCorrectly: $answeredCorrectly, ')
          ..write('awardedXp: $awardedXp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    type,
    seenAt,
    completed,
    answeredCorrectly,
    awardedXp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TriviaProgressData &&
          other.itemId == this.itemId &&
          other.type == this.type &&
          other.seenAt == this.seenAt &&
          other.completed == this.completed &&
          other.answeredCorrectly == this.answeredCorrectly &&
          other.awardedXp == this.awardedXp);
}

class TriviaProgressCompanion extends UpdateCompanion<TriviaProgressData> {
  final Value<String> itemId;
  final Value<String> type;
  final Value<int?> seenAt;
  final Value<bool> completed;
  final Value<bool?> answeredCorrectly;
  final Value<bool> awardedXp;
  final Value<int> rowid;
  const TriviaProgressCompanion({
    this.itemId = const Value.absent(),
    this.type = const Value.absent(),
    this.seenAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.answeredCorrectly = const Value.absent(),
    this.awardedXp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TriviaProgressCompanion.insert({
    required String itemId,
    required String type,
    this.seenAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.answeredCorrectly = const Value.absent(),
    this.awardedXp = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       type = Value(type);
  static Insertable<TriviaProgressData> custom({
    Expression<String>? itemId,
    Expression<String>? type,
    Expression<int>? seenAt,
    Expression<bool>? completed,
    Expression<bool>? answeredCorrectly,
    Expression<bool>? awardedXp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (type != null) 'type': type,
      if (seenAt != null) 'seen_at': seenAt,
      if (completed != null) 'completed': completed,
      if (answeredCorrectly != null) 'answered_correctly': answeredCorrectly,
      if (awardedXp != null) 'awarded_xp': awardedXp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TriviaProgressCompanion copyWith({
    Value<String>? itemId,
    Value<String>? type,
    Value<int?>? seenAt,
    Value<bool>? completed,
    Value<bool?>? answeredCorrectly,
    Value<bool>? awardedXp,
    Value<int>? rowid,
  }) {
    return TriviaProgressCompanion(
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      seenAt: seenAt ?? this.seenAt,
      completed: completed ?? this.completed,
      answeredCorrectly: answeredCorrectly ?? this.answeredCorrectly,
      awardedXp: awardedXp ?? this.awardedXp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (seenAt.present) {
      map['seen_at'] = Variable<int>(seenAt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (answeredCorrectly.present) {
      map['answered_correctly'] = Variable<bool>(answeredCorrectly.value);
    }
    if (awardedXp.present) {
      map['awarded_xp'] = Variable<bool>(awardedXp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TriviaProgressCompanion(')
          ..write('itemId: $itemId, ')
          ..write('type: $type, ')
          ..write('seenAt: $seenAt, ')
          ..write('completed: $completed, ')
          ..write('answeredCorrectly: $answeredCorrectly, ')
          ..write('awardedXp: $awardedXp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderSettingsTable extends ReminderSettings
    with TableInfo<$ReminderSettingsTable, ReminderSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _startMinuteOfDayMeta = const VerificationMeta(
    'startMinuteOfDay',
  );
  @override
  late final GeneratedColumn<int> startMinuteOfDay = GeneratedColumn<int>(
    'start_minute_of_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(480),
  );
  static const VerificationMeta _endMinuteOfDayMeta = const VerificationMeta(
    'endMinuteOfDay',
  );
  @override
  late final GeneratedColumn<int> endMinuteOfDay = GeneratedColumn<int>(
    'end_minute_of_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1320),
  );
  static const VerificationMeta _intervalMinutesMeta = const VerificationMeta(
    'intervalMinutes',
  );
  @override
  late final GeneratedColumn<int> intervalMinutes = GeneratedColumn<int>(
    'interval_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120),
  );
  static const VerificationMeta _activeWeekdaysMeta = const VerificationMeta(
    'activeWeekdays',
  );
  @override
  late final GeneratedColumn<String> activeWeekdays = GeneratedColumn<String>(
    'active_weekdays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6,7'),
  );
  static const VerificationMeta _messageStyleMeta = const VerificationMeta(
    'messageStyle',
  );
  @override
  late final GeneratedColumn<String> messageStyle = GeneratedColumn<String>(
    'message_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('friendly'),
  );
  static const VerificationMeta _soundIdMeta = const VerificationMeta(
    'soundId',
  );
  @override
  late final GeneratedColumn<String> soundId = GeneratedColumn<String>(
    'sound_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopWhenGoalMetMeta = const VerificationMeta(
    'stopWhenGoalMet',
  );
  @override
  late final GeneratedColumn<bool> stopWhenGoalMet = GeneratedColumn<bool>(
    'stop_when_goal_met',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stop_when_goal_met" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    enabled,
    startMinuteOfDay,
    endMinuteOfDay,
    intervalMinutes,
    activeWeekdays,
    messageStyle,
    soundId,
    stopWhenGoalMet,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('start_minute_of_day')) {
      context.handle(
        _startMinuteOfDayMeta,
        startMinuteOfDay.isAcceptableOrUnknown(
          data['start_minute_of_day']!,
          _startMinuteOfDayMeta,
        ),
      );
    }
    if (data.containsKey('end_minute_of_day')) {
      context.handle(
        _endMinuteOfDayMeta,
        endMinuteOfDay.isAcceptableOrUnknown(
          data['end_minute_of_day']!,
          _endMinuteOfDayMeta,
        ),
      );
    }
    if (data.containsKey('interval_minutes')) {
      context.handle(
        _intervalMinutesMeta,
        intervalMinutes.isAcceptableOrUnknown(
          data['interval_minutes']!,
          _intervalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('active_weekdays')) {
      context.handle(
        _activeWeekdaysMeta,
        activeWeekdays.isAcceptableOrUnknown(
          data['active_weekdays']!,
          _activeWeekdaysMeta,
        ),
      );
    }
    if (data.containsKey('message_style')) {
      context.handle(
        _messageStyleMeta,
        messageStyle.isAcceptableOrUnknown(
          data['message_style']!,
          _messageStyleMeta,
        ),
      );
    }
    if (data.containsKey('sound_id')) {
      context.handle(
        _soundIdMeta,
        soundId.isAcceptableOrUnknown(data['sound_id']!, _soundIdMeta),
      );
    }
    if (data.containsKey('stop_when_goal_met')) {
      context.handle(
        _stopWhenGoalMetMeta,
        stopWhenGoalMet.isAcceptableOrUnknown(
          data['stop_when_goal_met']!,
          _stopWhenGoalMetMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      startMinuteOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute_of_day'],
      )!,
      endMinuteOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute_of_day'],
      )!,
      intervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_minutes'],
      )!,
      activeWeekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_weekdays'],
      )!,
      messageStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_style'],
      )!,
      soundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_id'],
      ),
      stopWhenGoalMet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stop_when_goal_met'],
      )!,
    );
  }

  @override
  $ReminderSettingsTable createAlias(String alias) {
    return $ReminderSettingsTable(attachedDatabase, alias);
  }
}

class ReminderSetting extends DataClass implements Insertable<ReminderSetting> {
  final int id;
  final bool enabled;
  final int startMinuteOfDay;
  final int endMinuteOfDay;
  final int intervalMinutes;
  final String activeWeekdays;
  final String messageStyle;
  final String? soundId;
  final bool stopWhenGoalMet;
  const ReminderSetting({
    required this.id,
    required this.enabled,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
    required this.intervalMinutes,
    required this.activeWeekdays,
    required this.messageStyle,
    this.soundId,
    required this.stopWhenGoalMet,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enabled'] = Variable<bool>(enabled);
    map['start_minute_of_day'] = Variable<int>(startMinuteOfDay);
    map['end_minute_of_day'] = Variable<int>(endMinuteOfDay);
    map['interval_minutes'] = Variable<int>(intervalMinutes);
    map['active_weekdays'] = Variable<String>(activeWeekdays);
    map['message_style'] = Variable<String>(messageStyle);
    if (!nullToAbsent || soundId != null) {
      map['sound_id'] = Variable<String>(soundId);
    }
    map['stop_when_goal_met'] = Variable<bool>(stopWhenGoalMet);
    return map;
  }

  ReminderSettingsCompanion toCompanion(bool nullToAbsent) {
    return ReminderSettingsCompanion(
      id: Value(id),
      enabled: Value(enabled),
      startMinuteOfDay: Value(startMinuteOfDay),
      endMinuteOfDay: Value(endMinuteOfDay),
      intervalMinutes: Value(intervalMinutes),
      activeWeekdays: Value(activeWeekdays),
      messageStyle: Value(messageStyle),
      soundId: soundId == null && nullToAbsent
          ? const Value.absent()
          : Value(soundId),
      stopWhenGoalMet: Value(stopWhenGoalMet),
    );
  }

  factory ReminderSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderSetting(
      id: serializer.fromJson<int>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      startMinuteOfDay: serializer.fromJson<int>(json['startMinuteOfDay']),
      endMinuteOfDay: serializer.fromJson<int>(json['endMinuteOfDay']),
      intervalMinutes: serializer.fromJson<int>(json['intervalMinutes']),
      activeWeekdays: serializer.fromJson<String>(json['activeWeekdays']),
      messageStyle: serializer.fromJson<String>(json['messageStyle']),
      soundId: serializer.fromJson<String?>(json['soundId']),
      stopWhenGoalMet: serializer.fromJson<bool>(json['stopWhenGoalMet']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enabled': serializer.toJson<bool>(enabled),
      'startMinuteOfDay': serializer.toJson<int>(startMinuteOfDay),
      'endMinuteOfDay': serializer.toJson<int>(endMinuteOfDay),
      'intervalMinutes': serializer.toJson<int>(intervalMinutes),
      'activeWeekdays': serializer.toJson<String>(activeWeekdays),
      'messageStyle': serializer.toJson<String>(messageStyle),
      'soundId': serializer.toJson<String?>(soundId),
      'stopWhenGoalMet': serializer.toJson<bool>(stopWhenGoalMet),
    };
  }

  ReminderSetting copyWith({
    int? id,
    bool? enabled,
    int? startMinuteOfDay,
    int? endMinuteOfDay,
    int? intervalMinutes,
    String? activeWeekdays,
    String? messageStyle,
    Value<String?> soundId = const Value.absent(),
    bool? stopWhenGoalMet,
  }) => ReminderSetting(
    id: id ?? this.id,
    enabled: enabled ?? this.enabled,
    startMinuteOfDay: startMinuteOfDay ?? this.startMinuteOfDay,
    endMinuteOfDay: endMinuteOfDay ?? this.endMinuteOfDay,
    intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    activeWeekdays: activeWeekdays ?? this.activeWeekdays,
    messageStyle: messageStyle ?? this.messageStyle,
    soundId: soundId.present ? soundId.value : this.soundId,
    stopWhenGoalMet: stopWhenGoalMet ?? this.stopWhenGoalMet,
  );
  ReminderSetting copyWithCompanion(ReminderSettingsCompanion data) {
    return ReminderSetting(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      startMinuteOfDay: data.startMinuteOfDay.present
          ? data.startMinuteOfDay.value
          : this.startMinuteOfDay,
      endMinuteOfDay: data.endMinuteOfDay.present
          ? data.endMinuteOfDay.value
          : this.endMinuteOfDay,
      intervalMinutes: data.intervalMinutes.present
          ? data.intervalMinutes.value
          : this.intervalMinutes,
      activeWeekdays: data.activeWeekdays.present
          ? data.activeWeekdays.value
          : this.activeWeekdays,
      messageStyle: data.messageStyle.present
          ? data.messageStyle.value
          : this.messageStyle,
      soundId: data.soundId.present ? data.soundId.value : this.soundId,
      stopWhenGoalMet: data.stopWhenGoalMet.present
          ? data.stopWhenGoalMet.value
          : this.stopWhenGoalMet,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderSetting(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('startMinuteOfDay: $startMinuteOfDay, ')
          ..write('endMinuteOfDay: $endMinuteOfDay, ')
          ..write('intervalMinutes: $intervalMinutes, ')
          ..write('activeWeekdays: $activeWeekdays, ')
          ..write('messageStyle: $messageStyle, ')
          ..write('soundId: $soundId, ')
          ..write('stopWhenGoalMet: $stopWhenGoalMet')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    enabled,
    startMinuteOfDay,
    endMinuteOfDay,
    intervalMinutes,
    activeWeekdays,
    messageStyle,
    soundId,
    stopWhenGoalMet,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderSetting &&
          other.id == this.id &&
          other.enabled == this.enabled &&
          other.startMinuteOfDay == this.startMinuteOfDay &&
          other.endMinuteOfDay == this.endMinuteOfDay &&
          other.intervalMinutes == this.intervalMinutes &&
          other.activeWeekdays == this.activeWeekdays &&
          other.messageStyle == this.messageStyle &&
          other.soundId == this.soundId &&
          other.stopWhenGoalMet == this.stopWhenGoalMet);
}

class ReminderSettingsCompanion extends UpdateCompanion<ReminderSetting> {
  final Value<int> id;
  final Value<bool> enabled;
  final Value<int> startMinuteOfDay;
  final Value<int> endMinuteOfDay;
  final Value<int> intervalMinutes;
  final Value<String> activeWeekdays;
  final Value<String> messageStyle;
  final Value<String?> soundId;
  final Value<bool> stopWhenGoalMet;
  const ReminderSettingsCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.startMinuteOfDay = const Value.absent(),
    this.endMinuteOfDay = const Value.absent(),
    this.intervalMinutes = const Value.absent(),
    this.activeWeekdays = const Value.absent(),
    this.messageStyle = const Value.absent(),
    this.soundId = const Value.absent(),
    this.stopWhenGoalMet = const Value.absent(),
  });
  ReminderSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.startMinuteOfDay = const Value.absent(),
    this.endMinuteOfDay = const Value.absent(),
    this.intervalMinutes = const Value.absent(),
    this.activeWeekdays = const Value.absent(),
    this.messageStyle = const Value.absent(),
    this.soundId = const Value.absent(),
    this.stopWhenGoalMet = const Value.absent(),
  });
  static Insertable<ReminderSetting> custom({
    Expression<int>? id,
    Expression<bool>? enabled,
    Expression<int>? startMinuteOfDay,
    Expression<int>? endMinuteOfDay,
    Expression<int>? intervalMinutes,
    Expression<String>? activeWeekdays,
    Expression<String>? messageStyle,
    Expression<String>? soundId,
    Expression<bool>? stopWhenGoalMet,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
      if (startMinuteOfDay != null) 'start_minute_of_day': startMinuteOfDay,
      if (endMinuteOfDay != null) 'end_minute_of_day': endMinuteOfDay,
      if (intervalMinutes != null) 'interval_minutes': intervalMinutes,
      if (activeWeekdays != null) 'active_weekdays': activeWeekdays,
      if (messageStyle != null) 'message_style': messageStyle,
      if (soundId != null) 'sound_id': soundId,
      if (stopWhenGoalMet != null) 'stop_when_goal_met': stopWhenGoalMet,
    });
  }

  ReminderSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? enabled,
    Value<int>? startMinuteOfDay,
    Value<int>? endMinuteOfDay,
    Value<int>? intervalMinutes,
    Value<String>? activeWeekdays,
    Value<String>? messageStyle,
    Value<String?>? soundId,
    Value<bool>? stopWhenGoalMet,
  }) {
    return ReminderSettingsCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      startMinuteOfDay: startMinuteOfDay ?? this.startMinuteOfDay,
      endMinuteOfDay: endMinuteOfDay ?? this.endMinuteOfDay,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      messageStyle: messageStyle ?? this.messageStyle,
      soundId: soundId ?? this.soundId,
      stopWhenGoalMet: stopWhenGoalMet ?? this.stopWhenGoalMet,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (startMinuteOfDay.present) {
      map['start_minute_of_day'] = Variable<int>(startMinuteOfDay.value);
    }
    if (endMinuteOfDay.present) {
      map['end_minute_of_day'] = Variable<int>(endMinuteOfDay.value);
    }
    if (intervalMinutes.present) {
      map['interval_minutes'] = Variable<int>(intervalMinutes.value);
    }
    if (activeWeekdays.present) {
      map['active_weekdays'] = Variable<String>(activeWeekdays.value);
    }
    if (messageStyle.present) {
      map['message_style'] = Variable<String>(messageStyle.value);
    }
    if (soundId.present) {
      map['sound_id'] = Variable<String>(soundId.value);
    }
    if (stopWhenGoalMet.present) {
      map['stop_when_goal_met'] = Variable<bool>(stopWhenGoalMet.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderSettingsCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('startMinuteOfDay: $startMinuteOfDay, ')
          ..write('endMinuteOfDay: $endMinuteOfDay, ')
          ..write('intervalMinutes: $intervalMinutes, ')
          ..write('activeWeekdays: $activeWeekdays, ')
          ..write('messageStyle: $messageStyle, ')
          ..write('soundId: $soundId, ')
          ..write('stopWhenGoalMet: $stopWhenGoalMet')
          ..write(')'))
        .toString();
  }
}

class $ProgressMetaTable extends ProgressMeta
    with TableInfo<$ProgressMetaTable, ProgressMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestStreakMeta = const VerificationMeta(
    'bestStreak',
  );
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
    'best_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, bestStreak];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('best_streak')) {
      context.handle(
        _bestStreakMeta,
        bestStreak.isAcceptableOrUnknown(data['best_streak']!, _bestStreakMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_streak'],
      )!,
    );
  }

  @override
  $ProgressMetaTable createAlias(String alias) {
    return $ProgressMetaTable(attachedDatabase, alias);
  }
}

class ProgressMetaData extends DataClass
    implements Insertable<ProgressMetaData> {
  final int id;
  final int bestStreak;
  const ProgressMetaData({required this.id, required this.bestStreak});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['best_streak'] = Variable<int>(bestStreak);
    return map;
  }

  ProgressMetaCompanion toCompanion(bool nullToAbsent) {
    return ProgressMetaCompanion(id: Value(id), bestStreak: Value(bestStreak));
  }

  factory ProgressMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressMetaData(
      id: serializer.fromJson<int>(json['id']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bestStreak': serializer.toJson<int>(bestStreak),
    };
  }

  ProgressMetaData copyWith({int? id, int? bestStreak}) => ProgressMetaData(
    id: id ?? this.id,
    bestStreak: bestStreak ?? this.bestStreak,
  );
  ProgressMetaData copyWithCompanion(ProgressMetaCompanion data) {
    return ProgressMetaData(
      id: data.id.present ? data.id.value : this.id,
      bestStreak: data.bestStreak.present
          ? data.bestStreak.value
          : this.bestStreak,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressMetaData(')
          ..write('id: $id, ')
          ..write('bestStreak: $bestStreak')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bestStreak);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressMetaData &&
          other.id == this.id &&
          other.bestStreak == this.bestStreak);
}

class ProgressMetaCompanion extends UpdateCompanion<ProgressMetaData> {
  final Value<int> id;
  final Value<int> bestStreak;
  const ProgressMetaCompanion({
    this.id = const Value.absent(),
    this.bestStreak = const Value.absent(),
  });
  ProgressMetaCompanion.insert({
    this.id = const Value.absent(),
    this.bestStreak = const Value.absent(),
  });
  static Insertable<ProgressMetaData> custom({
    Expression<int>? id,
    Expression<int>? bestStreak,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bestStreak != null) 'best_streak': bestStreak,
    });
  }

  ProgressMetaCompanion copyWith({Value<int>? id, Value<int>? bestStreak}) {
    return ProgressMetaCompanion(
      id: id ?? this.id,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressMetaCompanion(')
          ..write('id: $id, ')
          ..write('bestStreak: $bestStreak')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $HydrationEntriesTable hydrationEntries = $HydrationEntriesTable(
    this,
  );
  late final $DailyHydrationTable dailyHydration = $DailyHydrationTable(this);
  late final $XpEventsTable xpEvents = $XpEventsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $TriviaProgressTable triviaProgress = $TriviaProgressTable(this);
  late final $ReminderSettingsTable reminderSettings = $ReminderSettingsTable(
    this,
  );
  late final $ProgressMetaTable progressMeta = $ProgressMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    hydrationEntries,
    dailyHydration,
    xpEvents,
    achievements,
    triviaProgress,
    reminderSettings,
    progressMeta,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String?> displayName,
      required int age,
      required String sex,
      required double weightKg,
      required String activityLevel,
      required String environment,
      Value<String> specialCircumstances,
      required int dailyTargetMl,
      required String targetSource,
      required String calculatorMethodId,
      required int profileCreatedAt,
      required int updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String?> displayName,
      Value<int> age,
      Value<String> sex,
      Value<double> weightKg,
      Value<String> activityLevel,
      Value<String> environment,
      Value<String> specialCircumstances,
      Value<int> dailyTargetMl,
      Value<String> targetSource,
      Value<String> calculatorMethodId,
      Value<int> profileCreatedAt,
      Value<int> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialCircumstances => $composableBuilder(
    column: $table.specialCircumstances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyTargetMl => $composableBuilder(
    column: $table.dailyTargetMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetSource => $composableBuilder(
    column: $table.targetSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculatorMethodId => $composableBuilder(
    column: $table.calculatorMethodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profileCreatedAt => $composableBuilder(
    column: $table.profileCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialCircumstances => $composableBuilder(
    column: $table.specialCircumstances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTargetMl => $composableBuilder(
    column: $table.dailyTargetMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetSource => $composableBuilder(
    column: $table.targetSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculatorMethodId => $composableBuilder(
    column: $table.calculatorMethodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profileCreatedAt => $composableBuilder(
    column: $table.profileCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialCircumstances => $composableBuilder(
    column: $table.specialCircumstances,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyTargetMl => $composableBuilder(
    column: $table.dailyTargetMl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetSource => $composableBuilder(
    column: $table.targetSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculatorMethodId => $composableBuilder(
    column: $table.calculatorMethodId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get profileCreatedAt => $composableBuilder(
    column: $table.profileCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String> activityLevel = const Value.absent(),
                Value<String> environment = const Value.absent(),
                Value<String> specialCircumstances = const Value.absent(),
                Value<int> dailyTargetMl = const Value.absent(),
                Value<String> targetSource = const Value.absent(),
                Value<String> calculatorMethodId = const Value.absent(),
                Value<int> profileCreatedAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                displayName: displayName,
                age: age,
                sex: sex,
                weightKg: weightKg,
                activityLevel: activityLevel,
                environment: environment,
                specialCircumstances: specialCircumstances,
                dailyTargetMl: dailyTargetMl,
                targetSource: targetSource,
                calculatorMethodId: calculatorMethodId,
                profileCreatedAt: profileCreatedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                required int age,
                required String sex,
                required double weightKg,
                required String activityLevel,
                required String environment,
                Value<String> specialCircumstances = const Value.absent(),
                required int dailyTargetMl,
                required String targetSource,
                required String calculatorMethodId,
                required int profileCreatedAt,
                required int updatedAt,
              }) => UserProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                age: age,
                sex: sex,
                weightKg: weightKg,
                activityLevel: activityLevel,
                environment: environment,
                specialCircumstances: specialCircumstances,
                dailyTargetMl: dailyTargetMl,
                targetSource: targetSource,
                calculatorMethodId: calculatorMethodId,
                profileCreatedAt: profileCreatedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$HydrationEntriesTableCreateCompanionBuilder =
    HydrationEntriesCompanion Function({
      required String id,
      required int amountMl,
      required int occurredAt,
      required String localDate,
      required String source,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$HydrationEntriesTableUpdateCompanionBuilder =
    HydrationEntriesCompanion Function({
      Value<String> id,
      Value<int> amountMl,
      Value<int> occurredAt,
      Value<String> localDate,
      Value<String> source,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$HydrationEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HydrationEntriesTable> {
  $$HydrationEntriesTableFilterComposer({
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

  ColumnFilters<int> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HydrationEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HydrationEntriesTable> {
  $$HydrationEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HydrationEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HydrationEntriesTable> {
  $$HydrationEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMl =>
      $composableBuilder(column: $table.amountMl, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HydrationEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HydrationEntriesTable,
          HydrationEntry,
          $$HydrationEntriesTableFilterComposer,
          $$HydrationEntriesTableOrderingComposer,
          $$HydrationEntriesTableAnnotationComposer,
          $$HydrationEntriesTableCreateCompanionBuilder,
          $$HydrationEntriesTableUpdateCompanionBuilder,
          (
            HydrationEntry,
            BaseReferences<
              _$AppDatabase,
              $HydrationEntriesTable,
              HydrationEntry
            >,
          ),
          HydrationEntry,
          PrefetchHooks Function()
        > {
  $$HydrationEntriesTableTableManager(
    _$AppDatabase db,
    $HydrationEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HydrationEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HydrationEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HydrationEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountMl = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HydrationEntriesCompanion(
                id: id,
                amountMl: amountMl,
                occurredAt: occurredAt,
                localDate: localDate,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountMl,
                required int occurredAt,
                required String localDate,
                required String source,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => HydrationEntriesCompanion.insert(
                id: id,
                amountMl: amountMl,
                occurredAt: occurredAt,
                localDate: localDate,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HydrationEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HydrationEntriesTable,
      HydrationEntry,
      $$HydrationEntriesTableFilterComposer,
      $$HydrationEntriesTableOrderingComposer,
      $$HydrationEntriesTableAnnotationComposer,
      $$HydrationEntriesTableCreateCompanionBuilder,
      $$HydrationEntriesTableUpdateCompanionBuilder,
      (
        HydrationEntry,
        BaseReferences<_$AppDatabase, $HydrationEntriesTable, HydrationEntry>,
      ),
      HydrationEntry,
      PrefetchHooks Function()
    >;
typedef $$DailyHydrationTableCreateCompanionBuilder =
    DailyHydrationCompanion Function({
      required String date,
      Value<int> totalMl,
      required int targetMl,
      Value<bool> goalCompleted,
      Value<int?> goalCompletedAt,
      Value<int> entryCount,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$DailyHydrationTableUpdateCompanionBuilder =
    DailyHydrationCompanion Function({
      Value<String> date,
      Value<int> totalMl,
      Value<int> targetMl,
      Value<bool> goalCompleted,
      Value<int?> goalCompletedAt,
      Value<int> entryCount,
      Value<String> status,
      Value<int> rowid,
    });

class $$DailyHydrationTableFilterComposer
    extends Composer<_$AppDatabase, $DailyHydrationTable> {
  $$DailyHydrationTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMl => $composableBuilder(
    column: $table.totalMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMl => $composableBuilder(
    column: $table.targetMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalCompletedAt => $composableBuilder(
    column: $table.goalCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyHydrationTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyHydrationTable> {
  $$DailyHydrationTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMl => $composableBuilder(
    column: $table.totalMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMl => $composableBuilder(
    column: $table.targetMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalCompletedAt => $composableBuilder(
    column: $table.goalCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyHydrationTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyHydrationTable> {
  $$DailyHydrationTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get totalMl =>
      $composableBuilder(column: $table.totalMl, builder: (column) => column);

  GeneratedColumn<int> get targetMl =>
      $composableBuilder(column: $table.targetMl, builder: (column) => column);

  GeneratedColumn<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalCompletedAt => $composableBuilder(
    column: $table.goalCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$DailyHydrationTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyHydrationTable,
          DailyHydrationData,
          $$DailyHydrationTableFilterComposer,
          $$DailyHydrationTableOrderingComposer,
          $$DailyHydrationTableAnnotationComposer,
          $$DailyHydrationTableCreateCompanionBuilder,
          $$DailyHydrationTableUpdateCompanionBuilder,
          (
            DailyHydrationData,
            BaseReferences<
              _$AppDatabase,
              $DailyHydrationTable,
              DailyHydrationData
            >,
          ),
          DailyHydrationData,
          PrefetchHooks Function()
        > {
  $$DailyHydrationTableTableManager(
    _$AppDatabase db,
    $DailyHydrationTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyHydrationTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyHydrationTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyHydrationTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> totalMl = const Value.absent(),
                Value<int> targetMl = const Value.absent(),
                Value<bool> goalCompleted = const Value.absent(),
                Value<int?> goalCompletedAt = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyHydrationCompanion(
                date: date,
                totalMl: totalMl,
                targetMl: targetMl,
                goalCompleted: goalCompleted,
                goalCompletedAt: goalCompletedAt,
                entryCount: entryCount,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int> totalMl = const Value.absent(),
                required int targetMl,
                Value<bool> goalCompleted = const Value.absent(),
                Value<int?> goalCompletedAt = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyHydrationCompanion.insert(
                date: date,
                totalMl: totalMl,
                targetMl: targetMl,
                goalCompleted: goalCompleted,
                goalCompletedAt: goalCompletedAt,
                entryCount: entryCount,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyHydrationTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyHydrationTable,
      DailyHydrationData,
      $$DailyHydrationTableFilterComposer,
      $$DailyHydrationTableOrderingComposer,
      $$DailyHydrationTableAnnotationComposer,
      $$DailyHydrationTableCreateCompanionBuilder,
      $$DailyHydrationTableUpdateCompanionBuilder,
      (
        DailyHydrationData,
        BaseReferences<_$AppDatabase, $DailyHydrationTable, DailyHydrationData>,
      ),
      DailyHydrationData,
      PrefetchHooks Function()
    >;
typedef $$XpEventsTableCreateCompanionBuilder =
    XpEventsCompanion Function({
      required String id,
      required String type,
      required int amount,
      required String localDate,
      required int occurredAt,
      Value<String?> refId,
      Value<int> rowid,
    });
typedef $$XpEventsTableUpdateCompanionBuilder =
    XpEventsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<int> amount,
      Value<String> localDate,
      Value<int> occurredAt,
      Value<String?> refId,
      Value<int> rowid,
    });

class $$XpEventsTableFilterComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XpEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XpEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);
}

class $$XpEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $XpEventsTable,
          XpEvent,
          $$XpEventsTableFilterComposer,
          $$XpEventsTableOrderingComposer,
          $$XpEventsTableAnnotationComposer,
          $$XpEventsTableCreateCompanionBuilder,
          $$XpEventsTableUpdateCompanionBuilder,
          (XpEvent, BaseReferences<_$AppDatabase, $XpEventsTable, XpEvent>),
          XpEvent,
          PrefetchHooks Function()
        > {
  $$XpEventsTableTableManager(_$AppDatabase db, $XpEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XpEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XpEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XpEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => XpEventsCompanion(
                id: id,
                type: type,
                amount: amount,
                localDate: localDate,
                occurredAt: occurredAt,
                refId: refId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required int amount,
                required String localDate,
                required int occurredAt,
                Value<String?> refId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => XpEventsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                localDate: localDate,
                occurredAt: occurredAt,
                refId: refId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XpEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $XpEventsTable,
      XpEvent,
      $$XpEventsTableFilterComposer,
      $$XpEventsTableOrderingComposer,
      $$XpEventsTableAnnotationComposer,
      $$XpEventsTableCreateCompanionBuilder,
      $$XpEventsTableUpdateCompanionBuilder,
      (XpEvent, BaseReferences<_$AppDatabase, $XpEventsTable, XpEvent>),
      XpEvent,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String key,
      Value<bool> unlocked,
      Value<int?> unlockedAt,
      Value<int> progressCurrent,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> key,
      Value<bool> unlocked,
      Value<int?> unlockedAt,
      Value<int> progressCurrent,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
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

  ColumnFilters<bool> get unlocked => $composableBuilder(
    column: $table.unlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
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

  ColumnOrderings<bool> get unlocked => $composableBuilder(
    column: $table.unlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<bool> get unlocked =>
      $composableBuilder(column: $table.unlocked, builder: (column) => column);

  GeneratedColumn<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<bool> unlocked = const Value.absent(),
                Value<int?> unlockedAt = const Value.absent(),
                Value<int> progressCurrent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                key: key,
                unlocked: unlocked,
                unlockedAt: unlockedAt,
                progressCurrent: progressCurrent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<bool> unlocked = const Value.absent(),
                Value<int?> unlockedAt = const Value.absent(),
                Value<int> progressCurrent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                key: key,
                unlocked: unlocked,
                unlockedAt: unlockedAt,
                progressCurrent: progressCurrent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$TriviaProgressTableCreateCompanionBuilder =
    TriviaProgressCompanion Function({
      required String itemId,
      required String type,
      Value<int?> seenAt,
      Value<bool> completed,
      Value<bool?> answeredCorrectly,
      Value<bool> awardedXp,
      Value<int> rowid,
    });
typedef $$TriviaProgressTableUpdateCompanionBuilder =
    TriviaProgressCompanion Function({
      Value<String> itemId,
      Value<String> type,
      Value<int?> seenAt,
      Value<bool> completed,
      Value<bool?> answeredCorrectly,
      Value<bool> awardedXp,
      Value<int> rowid,
    });

class $$TriviaProgressTableFilterComposer
    extends Composer<_$AppDatabase, $TriviaProgressTable> {
  $$TriviaProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get answeredCorrectly => $composableBuilder(
    column: $table.answeredCorrectly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get awardedXp => $composableBuilder(
    column: $table.awardedXp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TriviaProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $TriviaProgressTable> {
  $$TriviaProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get answeredCorrectly => $composableBuilder(
    column: $table.answeredCorrectly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get awardedXp => $composableBuilder(
    column: $table.awardedXp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TriviaProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $TriviaProgressTable> {
  $$TriviaProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get answeredCorrectly => $composableBuilder(
    column: $table.answeredCorrectly,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get awardedXp =>
      $composableBuilder(column: $table.awardedXp, builder: (column) => column);
}

class $$TriviaProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TriviaProgressTable,
          TriviaProgressData,
          $$TriviaProgressTableFilterComposer,
          $$TriviaProgressTableOrderingComposer,
          $$TriviaProgressTableAnnotationComposer,
          $$TriviaProgressTableCreateCompanionBuilder,
          $$TriviaProgressTableUpdateCompanionBuilder,
          (
            TriviaProgressData,
            BaseReferences<
              _$AppDatabase,
              $TriviaProgressTable,
              TriviaProgressData
            >,
          ),
          TriviaProgressData,
          PrefetchHooks Function()
        > {
  $$TriviaProgressTableTableManager(
    _$AppDatabase db,
    $TriviaProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TriviaProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TriviaProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TriviaProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> seenAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool?> answeredCorrectly = const Value.absent(),
                Value<bool> awardedXp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TriviaProgressCompanion(
                itemId: itemId,
                type: type,
                seenAt: seenAt,
                completed: completed,
                answeredCorrectly: answeredCorrectly,
                awardedXp: awardedXp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required String type,
                Value<int?> seenAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool?> answeredCorrectly = const Value.absent(),
                Value<bool> awardedXp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TriviaProgressCompanion.insert(
                itemId: itemId,
                type: type,
                seenAt: seenAt,
                completed: completed,
                answeredCorrectly: answeredCorrectly,
                awardedXp: awardedXp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TriviaProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TriviaProgressTable,
      TriviaProgressData,
      $$TriviaProgressTableFilterComposer,
      $$TriviaProgressTableOrderingComposer,
      $$TriviaProgressTableAnnotationComposer,
      $$TriviaProgressTableCreateCompanionBuilder,
      $$TriviaProgressTableUpdateCompanionBuilder,
      (
        TriviaProgressData,
        BaseReferences<_$AppDatabase, $TriviaProgressTable, TriviaProgressData>,
      ),
      TriviaProgressData,
      PrefetchHooks Function()
    >;
typedef $$ReminderSettingsTableCreateCompanionBuilder =
    ReminderSettingsCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<int> startMinuteOfDay,
      Value<int> endMinuteOfDay,
      Value<int> intervalMinutes,
      Value<String> activeWeekdays,
      Value<String> messageStyle,
      Value<String?> soundId,
      Value<bool> stopWhenGoalMet,
    });
typedef $$ReminderSettingsTableUpdateCompanionBuilder =
    ReminderSettingsCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<int> startMinuteOfDay,
      Value<int> endMinuteOfDay,
      Value<int> intervalMinutes,
      Value<String> activeWeekdays,
      Value<String> messageStyle,
      Value<String?> soundId,
      Value<bool> stopWhenGoalMet,
    });

class $$ReminderSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderSettingsTable> {
  $$ReminderSettingsTableFilterComposer({
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

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinuteOfDay => $composableBuilder(
    column: $table.startMinuteOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinuteOfDay => $composableBuilder(
    column: $table.endMinuteOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeWeekdays => $composableBuilder(
    column: $table.activeWeekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageStyle => $composableBuilder(
    column: $table.messageStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundId => $composableBuilder(
    column: $table.soundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get stopWhenGoalMet => $composableBuilder(
    column: $table.stopWhenGoalMet,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderSettingsTable> {
  $$ReminderSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinuteOfDay => $composableBuilder(
    column: $table.startMinuteOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinuteOfDay => $composableBuilder(
    column: $table.endMinuteOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeWeekdays => $composableBuilder(
    column: $table.activeWeekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageStyle => $composableBuilder(
    column: $table.messageStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundId => $composableBuilder(
    column: $table.soundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get stopWhenGoalMet => $composableBuilder(
    column: $table.stopWhenGoalMet,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderSettingsTable> {
  $$ReminderSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get startMinuteOfDay => $composableBuilder(
    column: $table.startMinuteOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinuteOfDay => $composableBuilder(
    column: $table.endMinuteOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeWeekdays => $composableBuilder(
    column: $table.activeWeekdays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageStyle => $composableBuilder(
    column: $table.messageStyle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get soundId =>
      $composableBuilder(column: $table.soundId, builder: (column) => column);

  GeneratedColumn<bool> get stopWhenGoalMet => $composableBuilder(
    column: $table.stopWhenGoalMet,
    builder: (column) => column,
  );
}

class $$ReminderSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderSettingsTable,
          ReminderSetting,
          $$ReminderSettingsTableFilterComposer,
          $$ReminderSettingsTableOrderingComposer,
          $$ReminderSettingsTableAnnotationComposer,
          $$ReminderSettingsTableCreateCompanionBuilder,
          $$ReminderSettingsTableUpdateCompanionBuilder,
          (
            ReminderSetting,
            BaseReferences<
              _$AppDatabase,
              $ReminderSettingsTable,
              ReminderSetting
            >,
          ),
          ReminderSetting,
          PrefetchHooks Function()
        > {
  $$ReminderSettingsTableTableManager(
    _$AppDatabase db,
    $ReminderSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> startMinuteOfDay = const Value.absent(),
                Value<int> endMinuteOfDay = const Value.absent(),
                Value<int> intervalMinutes = const Value.absent(),
                Value<String> activeWeekdays = const Value.absent(),
                Value<String> messageStyle = const Value.absent(),
                Value<String?> soundId = const Value.absent(),
                Value<bool> stopWhenGoalMet = const Value.absent(),
              }) => ReminderSettingsCompanion(
                id: id,
                enabled: enabled,
                startMinuteOfDay: startMinuteOfDay,
                endMinuteOfDay: endMinuteOfDay,
                intervalMinutes: intervalMinutes,
                activeWeekdays: activeWeekdays,
                messageStyle: messageStyle,
                soundId: soundId,
                stopWhenGoalMet: stopWhenGoalMet,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> startMinuteOfDay = const Value.absent(),
                Value<int> endMinuteOfDay = const Value.absent(),
                Value<int> intervalMinutes = const Value.absent(),
                Value<String> activeWeekdays = const Value.absent(),
                Value<String> messageStyle = const Value.absent(),
                Value<String?> soundId = const Value.absent(),
                Value<bool> stopWhenGoalMet = const Value.absent(),
              }) => ReminderSettingsCompanion.insert(
                id: id,
                enabled: enabled,
                startMinuteOfDay: startMinuteOfDay,
                endMinuteOfDay: endMinuteOfDay,
                intervalMinutes: intervalMinutes,
                activeWeekdays: activeWeekdays,
                messageStyle: messageStyle,
                soundId: soundId,
                stopWhenGoalMet: stopWhenGoalMet,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderSettingsTable,
      ReminderSetting,
      $$ReminderSettingsTableFilterComposer,
      $$ReminderSettingsTableOrderingComposer,
      $$ReminderSettingsTableAnnotationComposer,
      $$ReminderSettingsTableCreateCompanionBuilder,
      $$ReminderSettingsTableUpdateCompanionBuilder,
      (
        ReminderSetting,
        BaseReferences<_$AppDatabase, $ReminderSettingsTable, ReminderSetting>,
      ),
      ReminderSetting,
      PrefetchHooks Function()
    >;
typedef $$ProgressMetaTableCreateCompanionBuilder =
    ProgressMetaCompanion Function({Value<int> id, Value<int> bestStreak});
typedef $$ProgressMetaTableUpdateCompanionBuilder =
    ProgressMetaCompanion Function({Value<int> id, Value<int> bestStreak});

class $$ProgressMetaTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressMetaTable> {
  $$ProgressMetaTableFilterComposer({
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

  ColumnFilters<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressMetaTable> {
  $$ProgressMetaTableOrderingComposer({
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

  ColumnOrderings<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressMetaTable> {
  $$ProgressMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => column,
  );
}

class $$ProgressMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressMetaTable,
          ProgressMetaData,
          $$ProgressMetaTableFilterComposer,
          $$ProgressMetaTableOrderingComposer,
          $$ProgressMetaTableAnnotationComposer,
          $$ProgressMetaTableCreateCompanionBuilder,
          $$ProgressMetaTableUpdateCompanionBuilder,
          (
            ProgressMetaData,
            BaseReferences<_$AppDatabase, $ProgressMetaTable, ProgressMetaData>,
          ),
          ProgressMetaData,
          PrefetchHooks Function()
        > {
  $$ProgressMetaTableTableManager(_$AppDatabase db, $ProgressMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
              }) => ProgressMetaCompanion(id: id, bestStreak: bestStreak),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
              }) =>
                  ProgressMetaCompanion.insert(id: id, bestStreak: bestStreak),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressMetaTable,
      ProgressMetaData,
      $$ProgressMetaTableFilterComposer,
      $$ProgressMetaTableOrderingComposer,
      $$ProgressMetaTableAnnotationComposer,
      $$ProgressMetaTableCreateCompanionBuilder,
      $$ProgressMetaTableUpdateCompanionBuilder,
      (
        ProgressMetaData,
        BaseReferences<_$AppDatabase, $ProgressMetaTable, ProgressMetaData>,
      ),
      ProgressMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$HydrationEntriesTableTableManager get hydrationEntries =>
      $$HydrationEntriesTableTableManager(_db, _db.hydrationEntries);
  $$DailyHydrationTableTableManager get dailyHydration =>
      $$DailyHydrationTableTableManager(_db, _db.dailyHydration);
  $$XpEventsTableTableManager get xpEvents =>
      $$XpEventsTableTableManager(_db, _db.xpEvents);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$TriviaProgressTableTableManager get triviaProgress =>
      $$TriviaProgressTableTableManager(_db, _db.triviaProgress);
  $$ReminderSettingsTableTableManager get reminderSettings =>
      $$ReminderSettingsTableTableManager(_db, _db.reminderSettings);
  $$ProgressMetaTableTableManager get progressMeta =>
      $$ProgressMetaTableTableManager(_db, _db.progressMeta);
}
