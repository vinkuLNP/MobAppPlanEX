import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<CaseType, Params> {
  Future<Either<Failure, CaseType>> call(Params params);
}

class NoParams {}
