//@dart=2.15

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ahazou/core/domain/entities/user/subscription/children.dart';
import 'package:mobile_ahazou/core/provider/friends_provider.dart';
import 'package:mobile_ahazou/core/provider/user_provider.dart';

final getLinkProvider = FutureProvider.autoDispose<String>((ref) async {
  final result = await ref.watch(getLinkAhzFriends).getLink();
  return result.fold(
    (e) {
      throw e;
    },
    (data) {
      return data;
    },
  );
});

final removeChildrenAndParentProvider =
    FutureProvider.family<bool, Children>((ref, children) async {
  final result = await ref
      .watch(removeChildrenAndParent)
      .removeChildrenAndParent(children: children);

  return result.fold(
    (e) {
      throw e;
    },
    (data) {
      ref.read(claenMemoryCache);
      ref.refresh(userDataProvider);
      return data;
    },
  );
});

final claenMemoryCache = FutureProvider.autoDispose<bool>((ref) async {
  final result = ref.watch(cleanMemoryCache).call();

  return result.fold(
    (e) {
      throw e;
    },
    (data) {
      return data;
    },
  );
});
