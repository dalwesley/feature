//@dart=2.15

import 'package:mobile_ahazou/core/data/models/user/subscription/children_model.dart';
import 'package:mobile_ahazou/core/domain/entities/user/subscription/children.dart';
import 'package:mobile_ahazou/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:mobile_ahazou/features/children_control/data/datasources/childrens_control_datasource.dart';
import 'package:mobile_ahazou/features/children_control/domain/repositories/childrens_control_repository.dart';
import 'package:mobile_ahazou/services/logging/logger.dart';

class ChildrensControlRepositoryImpl implements ChildrensControlRepository {
  final ChildensControlDataSource remoteDataSource;
  ChildrensControlRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> generateLink({
    String? linkParam,
    String? userId,
    String? title,
    String? description,
    String? image,
  }) async {
    try {
      final result = await remoteDataSource.generateLink(
        description: description.toString(),
        image: image.toString(),
        linkParam: linkParam.toString(),
        title: title.toString(),
        userId: userId.toString(),
      );
      return Right(result);
    } catch (e, s) {
      AhzLogger.getInstance().error(e, s);
      return Left(ServerFailure(message: e.toString(), stack: s));
    }
  }

  @override
  Future<Either<Failure, bool>> removeChildrenAndParent(
      {required Children children, parentId}) async {
    try {
      final result = await remoteDataSource.removeChildrenAndParent(
        children: ChildrenModel.fromEntity(children),
        parentId: parentId,
      );
      return Right(result);
    } catch (e, s) {
      AhzLogger.getInstance().error(e, s);
      return Left(ServerFailure(message: e.toString(), stack: s));
    }
  }
}
