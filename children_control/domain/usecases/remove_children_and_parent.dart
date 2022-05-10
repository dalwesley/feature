//@dart=2.15
import 'package:dartz/dartz.dart';
import 'package:mobile_ahazou/core/domain/entities/user/subscription/children.dart';
import 'package:mobile_ahazou/core/domain/repositories/user_repository.dart';
import 'package:mobile_ahazou/core/error/failures.dart';
import 'package:mobile_ahazou/features/children_control/domain/repositories/childrens_control_repository.dart';

class RemoveChildrenAndParent {
  final ChildrensControlRepository repository;
  final UserRepository userRepository;

  RemoveChildrenAndParent(this.repository, this.userRepository);

  Future<Either<Failure, bool>> removeChildrenAndParent(
      {required Children children}) async {
    final userResult = await userRepository.getUser();

    return userResult.fold(
      (error) => throw error,
      (user) async => repository.removeChildrenAndParent(
          children: children, parentId: user.id),
    );
  }
}
