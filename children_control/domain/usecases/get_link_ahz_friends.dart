// @dart=2.15

import 'package:dartz/dartz.dart';
import 'package:mobile_ahazou/core/domain/repositories/user_repository.dart';
import 'package:mobile_ahazou/core/error/failures.dart';
import 'package:mobile_ahazou/features/children_control/domain/repositories/childrens_control_repository.dart';
import 'package:mobile_ahazou/resources/strings.dart';

class GetLinkAhzFriends {
  final ChildrensControlRepository repository;
  final UserRepository userRepository;

  GetLinkAhzFriends(this.repository, this.userRepository);

  Future<Either<Failure, String>> getLink() async {
    final userResult = await userRepository.getUser();

    return userResult.fold(
      (error) => throw error,
      (user) async => repository.generateLink(
        linkParam: "friendOf",
        userId: user.id,
        title: Strings.ahzFriendsShareText,
        description: Strings.ahzFriendsDescription,
      ),
    );
  }
}
