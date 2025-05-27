/// A simple implementation of Either for functional error handling
/// Either<L, R> represents a value that can be either Left (error) or Right (success)
abstract class Either<L, R> {
  const Either();

  /// Returns true if this is a Left (error) value
  bool get isLeft;

  /// Returns true if this is a Right (success) value
  bool get isRight => !isLeft;

  /// Fold the Either into a single value by providing functions for both cases
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);

  /// Map the Right value, leaving Left unchanged
  Either<L, T> map<T>(T Function(R right) mapper);

  /// Map the Left value, leaving Right unchanged
  Either<T, R> mapLeft<T>(T Function(L left) mapper);

  /// Chain operations on the Right value
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper);

  /// Get the Right value or throw an exception
  R get rightValue;

  /// Get the Left value or throw an exception
  L get leftValue;

  /// Get the Right value or return a default
  R getOrElse(R defaultValue);

  /// Create a Left (error) value
  static Either<L, R> left<L, R>(L value) => Left<L, R>(value);

  /// Create a Right (success) value
  static Either<L, R> right<L, R>(R value) => Right<L, R>(value);
}

/// Left represents an error value
class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  bool get isLeft => true;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Left<L, T>(value);
  }

  @override
  Either<T, R> mapLeft<T>(T Function(L left) mapper) {
    return Left<T, R>(mapper(value));
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) {
    return Left<L, T>(value);
  }

  @override
  R get rightValue => throw Exception('Called rightValue on Left');

  @override
  L get leftValue => value;

  @override
  R getOrElse(R defaultValue) => defaultValue;

  @override
  bool operator ==(Object other) {
    return other is Left<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Right represents a success value
class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  bool get isLeft => false;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Right<L, T>(mapper(value));
  }

  @override
  Either<T, R> mapLeft<T>(T Function(L left) mapper) {
    return Right<T, R>(value);
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) {
    return mapper(value);
  }

  @override
  R get rightValue => value;

  @override
  L get leftValue => throw Exception('Called leftValue on Right');

  @override
  R getOrElse(R defaultValue) => value;

  @override
  bool operator ==(Object other) {
    return other is Right<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
