//@dart=2.15

import 'package:dartz/dartz.dart';
import 'package:mobile_ahazou/core/domain/entities/user/subscription/children.dart';
import 'package:mobile_ahazou/core/error/failures.dart';

abstract class ChildrensControlRepository {
  Future<Either<Failure, bool>> removeChildrenAndParent(
      {required Children children, parentId});

  Future<Either<Failure, String>> generateLink(
      {String linkParam,
      String userId,
      String title,
      String description,
      String image});
}
