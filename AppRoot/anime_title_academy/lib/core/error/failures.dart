

abstract class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message);
}

class AIGenerationFailure extends AppFailure {
  const AIGenerationFailure(super.message);
}

class StorageFailure extends AppFailure {
  const StorageFailure(super.message);
}

class CacheFailure extends AppFailure {
  const CacheFailure(super.message);
}
