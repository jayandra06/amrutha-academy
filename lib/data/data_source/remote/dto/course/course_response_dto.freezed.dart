// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CourseResponseDto _$CourseResponseDtoFromJson(Map<String, dynamic> json) {
  return _CourseResponseDto.fromJson(json);
}

/// @nodoc
mixin _$CourseResponseDto {
  String? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int? get reviewsCount => throw _privateConstructorUsedError;
  int? get price => throw _privateConstructorUsedError;
  int? get originalPrice => throw _privateConstructorUsedError;
  int? get students => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  bool? get certificate => throw _privateConstructorUsedError;
  MentorResponseDto? get mentor => throw _privateConstructorUsedError;
  String? get about => throw _privateConstructorUsedError;
  List<ToolResponseDto>? get tools => throw _privateConstructorUsedError;
  bool? get isFavourite => throw _privateConstructorUsedError;

  /// Serializes this CourseResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseResponseDtoCopyWith<CourseResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseResponseDtoCopyWith<$Res> {
  factory $CourseResponseDtoCopyWith(
          CourseResponseDto value, $Res Function(CourseResponseDto) then) =
      _$CourseResponseDtoCopyWithImpl<$Res, CourseResponseDto>;
  @useResult
  $Res call(
      {String? id,
      String? title,
      String? category,
      String? image,
      double? rating,
      int? reviewsCount,
      int? price,
      int? originalPrice,
      int? students,
      int? duration,
      bool? certificate,
      MentorResponseDto? mentor,
      String? about,
      List<ToolResponseDto>? tools,
      bool? isFavourite});

  $MentorResponseDtoCopyWith<$Res>? get mentor;
}

/// @nodoc
class _$CourseResponseDtoCopyWithImpl<$Res, $Val extends CourseResponseDto>
    implements $CourseResponseDtoCopyWith<$Res> {
  _$CourseResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? category = freezed,
    Object? image = freezed,
    Object? rating = freezed,
    Object? reviewsCount = freezed,
    Object? price = freezed,
    Object? originalPrice = freezed,
    Object? students = freezed,
    Object? duration = freezed,
    Object? certificate = freezed,
    Object? mentor = freezed,
    Object? about = freezed,
    Object? tools = freezed,
    Object? isFavourite = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviewsCount: freezed == reviewsCount
          ? _value.reviewsCount
          : reviewsCount // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int?,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      students: freezed == students
          ? _value.students
          : students // ignore: cast_nullable_to_non_nullable
              as int?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      certificate: freezed == certificate
          ? _value.certificate
          : certificate // ignore: cast_nullable_to_non_nullable
              as bool?,
      mentor: freezed == mentor
          ? _value.mentor
          : mentor // ignore: cast_nullable_to_non_nullable
              as MentorResponseDto?,
      about: freezed == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String?,
      tools: freezed == tools
          ? _value.tools
          : tools // ignore: cast_nullable_to_non_nullable
              as List<ToolResponseDto>?,
      isFavourite: freezed == isFavourite
          ? _value.isFavourite
          : isFavourite // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }

  /// Create a copy of CourseResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MentorResponseDtoCopyWith<$Res>? get mentor {
    if (_value.mentor == null) {
      return null;
    }

    return $MentorResponseDtoCopyWith<$Res>(_value.mentor!, (value) {
      return _then(_value.copyWith(mentor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CourseResponseDtoImplCopyWith<$Res>
    implements $CourseResponseDtoCopyWith<$Res> {
  factory _$$CourseResponseDtoImplCopyWith(_$CourseResponseDtoImpl value,
          $Res Function(_$CourseResponseDtoImpl) then) =
      __$$CourseResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? title,
      String? category,
      String? image,
      double? rating,
      int? reviewsCount,
      int? price,
      int? originalPrice,
      int? students,
      int? duration,
      bool? certificate,
      MentorResponseDto? mentor,
      String? about,
      List<ToolResponseDto>? tools,
      bool? isFavourite});

  @override
  $MentorResponseDtoCopyWith<$Res>? get mentor;
}

/// @nodoc
class __$$CourseResponseDtoImplCopyWithImpl<$Res>
    extends _$CourseResponseDtoCopyWithImpl<$Res, _$CourseResponseDtoImpl>
    implements _$$CourseResponseDtoImplCopyWith<$Res> {
  __$$CourseResponseDtoImplCopyWithImpl(_$CourseResponseDtoImpl _value,
      $Res Function(_$CourseResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CourseResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? category = freezed,
    Object? image = freezed,
    Object? rating = freezed,
    Object? reviewsCount = freezed,
    Object? price = freezed,
    Object? originalPrice = freezed,
    Object? students = freezed,
    Object? duration = freezed,
    Object? certificate = freezed,
    Object? mentor = freezed,
    Object? about = freezed,
    Object? tools = freezed,
    Object? isFavourite = freezed,
  }) {
    return _then(_$CourseResponseDtoImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviewsCount: freezed == reviewsCount
          ? _value.reviewsCount
          : reviewsCount // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int?,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      students: freezed == students
          ? _value.students
          : students // ignore: cast_nullable_to_non_nullable
              as int?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      certificate: freezed == certificate
          ? _value.certificate
          : certificate // ignore: cast_nullable_to_non_nullable
              as bool?,
      mentor: freezed == mentor
          ? _value.mentor
          : mentor // ignore: cast_nullable_to_non_nullable
              as MentorResponseDto?,
      about: freezed == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String?,
      tools: freezed == tools
          ? _value._tools
          : tools // ignore: cast_nullable_to_non_nullable
              as List<ToolResponseDto>?,
      isFavourite: freezed == isFavourite
          ? _value.isFavourite
          : isFavourite // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseResponseDtoImpl implements _CourseResponseDto {
  const _$CourseResponseDtoImpl(
      {this.id,
      this.title,
      this.category,
      this.image,
      this.rating,
      this.reviewsCount,
      this.price,
      this.originalPrice,
      this.students,
      this.duration,
      this.certificate,
      this.mentor,
      this.about,
      final List<ToolResponseDto>? tools,
      this.isFavourite})
      : _tools = tools;

  factory _$CourseResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseResponseDtoImplFromJson(json);

  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? category;
  @override
  final String? image;
  @override
  final double? rating;
  @override
  final int? reviewsCount;
  @override
  final int? price;
  @override
  final int? originalPrice;
  @override
  final int? students;
  @override
  final int? duration;
  @override
  final bool? certificate;
  @override
  final MentorResponseDto? mentor;
  @override
  final String? about;
  final List<ToolResponseDto>? _tools;
  @override
  List<ToolResponseDto>? get tools {
    final value = _tools;
    if (value == null) return null;
    if (_tools is EqualUnmodifiableListView) return _tools;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isFavourite;

  @override
  String toString() {
    return 'CourseResponseDto(id: $id, title: $title, category: $category, image: $image, rating: $rating, reviewsCount: $reviewsCount, price: $price, originalPrice: $originalPrice, students: $students, duration: $duration, certificate: $certificate, mentor: $mentor, about: $about, tools: $tools, isFavourite: $isFavourite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewsCount, reviewsCount) ||
                other.reviewsCount == reviewsCount) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.students, students) ||
                other.students == students) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.certificate, certificate) ||
                other.certificate == certificate) &&
            (identical(other.mentor, mentor) || other.mentor == mentor) &&
            (identical(other.about, about) || other.about == about) &&
            const DeepCollectionEquality().equals(other._tools, _tools) &&
            (identical(other.isFavourite, isFavourite) ||
                other.isFavourite == isFavourite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      category,
      image,
      rating,
      reviewsCount,
      price,
      originalPrice,
      students,
      duration,
      certificate,
      mentor,
      about,
      const DeepCollectionEquality().hash(_tools),
      isFavourite);

  /// Create a copy of CourseResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseResponseDtoImplCopyWith<_$CourseResponseDtoImpl> get copyWith =>
      __$$CourseResponseDtoImplCopyWithImpl<_$CourseResponseDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _CourseResponseDto implements CourseResponseDto {
  const factory _CourseResponseDto(
      {final String? id,
      final String? title,
      final String? category,
      final String? image,
      final double? rating,
      final int? reviewsCount,
      final int? price,
      final int? originalPrice,
      final int? students,
      final int? duration,
      final bool? certificate,
      final MentorResponseDto? mentor,
      final String? about,
      final List<ToolResponseDto>? tools,
      final bool? isFavourite}) = _$CourseResponseDtoImpl;

  factory _CourseResponseDto.fromJson(Map<String, dynamic> json) =
      _$CourseResponseDtoImpl.fromJson;

  @override
  String? get id;
  @override
  String? get title;
  @override
  String? get category;
  @override
  String? get image;
  @override
  double? get rating;
  @override
  int? get reviewsCount;
  @override
  int? get price;
  @override
  int? get originalPrice;
  @override
  int? get students;
  @override
  int? get duration;
  @override
  bool? get certificate;
  @override
  MentorResponseDto? get mentor;
  @override
  String? get about;
  @override
  List<ToolResponseDto>? get tools;
  @override
  bool? get isFavourite;

  /// Create a copy of CourseResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseResponseDtoImplCopyWith<_$CourseResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ToolResponseDto _$ToolResponseDtoFromJson(Map<String, dynamic> json) {
  return _ToolResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ToolResponseDto {
  String? get name => throw _privateConstructorUsedError;
  String? get iconUrl => throw _privateConstructorUsedError;

  /// Serializes this ToolResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToolResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToolResponseDtoCopyWith<ToolResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolResponseDtoCopyWith<$Res> {
  factory $ToolResponseDtoCopyWith(
          ToolResponseDto value, $Res Function(ToolResponseDto) then) =
      _$ToolResponseDtoCopyWithImpl<$Res, ToolResponseDto>;
  @useResult
  $Res call({String? name, String? iconUrl});
}

/// @nodoc
class _$ToolResponseDtoCopyWithImpl<$Res, $Val extends ToolResponseDto>
    implements $ToolResponseDtoCopyWith<$Res> {
  _$ToolResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? iconUrl = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToolResponseDtoImplCopyWith<$Res>
    implements $ToolResponseDtoCopyWith<$Res> {
  factory _$$ToolResponseDtoImplCopyWith(_$ToolResponseDtoImpl value,
          $Res Function(_$ToolResponseDtoImpl) then) =
      __$$ToolResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, String? iconUrl});
}

/// @nodoc
class __$$ToolResponseDtoImplCopyWithImpl<$Res>
    extends _$ToolResponseDtoCopyWithImpl<$Res, _$ToolResponseDtoImpl>
    implements _$$ToolResponseDtoImplCopyWith<$Res> {
  __$$ToolResponseDtoImplCopyWithImpl(
      _$ToolResponseDtoImpl _value, $Res Function(_$ToolResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ToolResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? iconUrl = freezed,
  }) {
    return _then(_$ToolResponseDtoImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToolResponseDtoImpl implements _ToolResponseDto {
  const _$ToolResponseDtoImpl({this.name, this.iconUrl});

  factory _$ToolResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToolResponseDtoImplFromJson(json);

  @override
  final String? name;
  @override
  final String? iconUrl;

  @override
  String toString() {
    return 'ToolResponseDto(name: $name, iconUrl: $iconUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToolResponseDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, iconUrl);

  /// Create a copy of ToolResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToolResponseDtoImplCopyWith<_$ToolResponseDtoImpl> get copyWith =>
      __$$ToolResponseDtoImplCopyWithImpl<_$ToolResponseDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToolResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _ToolResponseDto implements ToolResponseDto {
  const factory _ToolResponseDto({final String? name, final String? iconUrl}) =
      _$ToolResponseDtoImpl;

  factory _ToolResponseDto.fromJson(Map<String, dynamic> json) =
      _$ToolResponseDtoImpl.fromJson;

  @override
  String? get name;
  @override
  String? get iconUrl;

  /// Create a copy of ToolResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToolResponseDtoImplCopyWith<_$ToolResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
