// // coverage:ignore-file
// // GENERATED CODE - DO NOT MODIFY BY HAND
// // ignore_for_file: type=lint
// // ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

// part of 'traceroute_state.dart';

// // **************************************************************************
// // FreezedGenerator
// // **************************************************************************

// T _$identity<T>(T value) => value;

// final _privateConstructorUsedError = UnsupportedError(
//     'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

// /// @nodoc
// mixin _$TracerouteState {
//   bool get isLoading => throw _privateConstructorUsedError;
//   List<Map<String, dynamic>> get results => throw _privateConstructorUsedError;
//   String? get error => throw _privateConstructorUsedError;
//   String? get targetAddress => throw _privateConstructorUsedError;
//   bool get isCompleted => throw _privateConstructorUsedError;

//   /// Create a copy of TracerouteState
//   /// with the given fields replaced by the non-null parameter values.
//   @JsonKey(includeFromJson: false, includeToJson: false)
//   $TracerouteStateCopyWith<TracerouteState> get copyWith =>
//       throw _privateConstructorUsedError;
// }

// /// @nodoc
// abstract class $TracerouteStateCopyWith<$Res> {
//   factory $TracerouteStateCopyWith(
//           TracerouteState value, $Res Function(TracerouteState) then) =
//       _$TracerouteStateCopyWithImpl<$Res, TracerouteState>;
//   @useResult
//   $Res call(
//       {bool isLoading,
//       List<Map<String, dynamic>> results,
//       String? error,
//       String? targetAddress,
//       bool isCompleted});
// }

// /// @nodoc
// class _$TracerouteStateCopyWithImpl<$Res, $Val extends TracerouteState>
//     implements $TracerouteStateCopyWith<$Res> {
//   _$TracerouteStateCopyWithImpl(this._value, this._then);

//   // ignore: unused_field
//   final $Val _value;
//   // ignore: unused_field
//   final $Res Function($Val) _then;

//   /// Create a copy of TracerouteState
//   /// with the given fields replaced by the non-null parameter values.
//   @pragma('vm:prefer-inline')
//   @override
//   $Res call({
//     Object? isLoading = null,
//     Object? results = null,
//     Object? error = freezed,
//     Object? targetAddress = freezed,
//     Object? isCompleted = null,
//   }) {
//     return _then(_value.copyWith(
//       isLoading: null == isLoading
//           ? _value.isLoading
//           : isLoading // ignore: cast_nullable_to_non_nullable
//               as bool,
//       results: null == results
//           ? _value.results
//           : results // ignore: cast_nullable_to_non_nullable
//               as List<Map<String, dynamic>>,
//       error: freezed == error
//           ? _value.error
//           : error // ignore: cast_nullable_to_non_nullable
//               as String?,
//       targetAddress: freezed == targetAddress
//           ? _value.targetAddress
//           : targetAddress // ignore: cast_nullable_to_non_nullable
//               as String?,
//       isCompleted: null == isCompleted
//           ? _value.isCompleted
//           : isCompleted // ignore: cast_nullable_to_non_nullable
//               as bool,
//     ) as $Val);
//   }
// }

// /// @nodoc
// abstract class _$$TracerouteStateImplCopyWith<$Res>
//     implements $TracerouteStateCopyWith<$Res> {
//   factory _$$TracerouteStateImplCopyWith(_$TracerouteStateImpl value,
//           $Res Function(_$TracerouteStateImpl) then) =
//       __$$TracerouteStateImplCopyWithImpl<$Res>;
//   @override
//   @useResult
//   $Res call(
//       {bool isLoading,
//       List<Map<String, dynamic>> results,
//       String? error,
//       String? targetAddress,
//       bool isCompleted});
// }

// /// @nodoc
// class __$$TracerouteStateImplCopyWithImpl<$Res>
//     extends _$TracerouteStateCopyWithImpl<$Res, _$TracerouteStateImpl>
//     implements _$$TracerouteStateImplCopyWith<$Res> {
//   __$$TracerouteStateImplCopyWithImpl(
//       _$TracerouteStateImpl _value, $Res Function(_$TracerouteStateImpl) _then)
//       : super(_value, _then);

//   /// Create a copy of TracerouteState
//   /// with the given fields replaced by the non-null parameter values.
//   @pragma('vm:prefer-inline')
//   @override
//   $Res call({
//     Object? isLoading = null,
//     Object? results = null,
//     Object? error = freezed,
//     Object? targetAddress = freezed,
//     Object? isCompleted = null,
//   }) {
//     return _then(_$TracerouteStateImpl(
//       isLoading: null == isLoading
//           ? _value.isLoading
//           : isLoading // ignore: cast_nullable_to_non_nullable
//               as bool,
//       results: null == results
//           ? _value._results
//           : results // ignore: cast_nullable_to_non_nullable
//               as List<Map<String, dynamic>>,
//       error: freezed == error
//           ? _value.error
//           : error // ignore: cast_nullable_to_non_nullable
//               as String?,
//       targetAddress: freezed == targetAddress
//           ? _value.targetAddress
//           : targetAddress // ignore: cast_nullable_to_non_nullable
//               as String?,
//       isCompleted: null == isCompleted
//           ? _value.isCompleted
//           : isCompleted // ignore: cast_nullable_to_non_nullable
//               as bool,
//     ));
//   }
// }

// /// @nodoc

// class _$TracerouteStateImpl implements _TracerouteState {
//   const _$TracerouteStateImpl(
//       {this.isLoading = false,
//       final List<Map<String, dynamic>> results = const [],
//       this.error,
//       this.targetAddress,
//       this.isCompleted = false})
//       : _results = results;

//   @override
//   @JsonKey()
//   final bool isLoading;
//   final List<Map<String, dynamic>> _results;
//   @override
//   @JsonKey()
//   List<Map<String, dynamic>> get results {
//     if (_results is EqualUnmodifiableListView) return _results;
//     // ignore: implicit_dynamic_type
//     return EqualUnmodifiableListView(_results);
//   }

//   @override
//   final String? error;
//   @override
//   final String? targetAddress;
//   @override
//   @JsonKey()
//   final bool isCompleted;

//   @override
//   String toString() {
//     return 'TracerouteState(isLoading: $isLoading, results: $results, error: $error, targetAddress: $targetAddress, isCompleted: $isCompleted)';
//   }

//   @override
//   bool operator ==(Object other) {
//     return identical(this, other) ||
//         (other.runtimeType == runtimeType &&
//             other is _$TracerouteStateImpl &&
//             (identical(other.isLoading, isLoading) ||
//                 other.isLoading == isLoading) &&
//             const DeepCollectionEquality().equals(other._results, _results) &&
//             (identical(other.error, error) || other.error == error) &&
//             (identical(other.targetAddress, targetAddress) ||
//                 other.targetAddress == targetAddress) &&
//             (identical(other.isCompleted, isCompleted) ||
//                 other.isCompleted == isCompleted));
//   }

//   @override
//   int get hashCode => Object.hash(
//       runtimeType,
//       isLoading,
//       const DeepCollectionEquality().hash(_results),
//       error,
//       targetAddress,
//       isCompleted);

//   /// Create a copy of TracerouteState
//   /// with the given fields replaced by the non-null parameter values.
//   @JsonKey(includeFromJson: false, includeToJson: false)
//   @override
//   @pragma('vm:prefer-inline')
//   _$$TracerouteStateImplCopyWith<_$TracerouteStateImpl> get copyWith =>
//       __$$TracerouteStateImplCopyWithImpl<_$TracerouteStateImpl>(
//           this, _$identity);
// }

// abstract class _TracerouteState implements TracerouteState {
//   const factory _TracerouteState(
//       {final bool isLoading,
//       final List<Map<String, dynamic>> results,
//       final String? error,
//       final String? targetAddress,
//       final bool isCompleted}) = _$TracerouteStateImpl;

//   @override
//   bool get isLoading;
//   @override
//   List<Map<String, dynamic>> get results;
//   @override
//   String? get error;
//   @override
//   String? get targetAddress;
//   @override
//   bool get isCompleted;

//   /// Create a copy of TracerouteState
//   /// with the given fields replaced by the non-null parameter values.
//   @override
//   @JsonKey(includeFromJson: false, includeToJson: false)
//   _$$TracerouteStateImplCopyWith<_$TracerouteStateImpl> get copyWith =>
//       throw _privateConstructorUsedError;
// }
