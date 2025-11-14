abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = "Server Failure"]);
}

class CacheFailure extends Failure {
  CacheFailure([super.message = "Cache Failure"]);
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message = "No Internet Connection"]);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([super.message = "Unauthorized"]);
}
