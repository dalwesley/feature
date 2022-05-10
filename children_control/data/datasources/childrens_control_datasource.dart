//@dart=2.15

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:mobile_ahazou/core/data/models/user/subscription/children_model.dart';

import 'package:mobile_ahazou/resources/constants.dart';
import 'package:mobile_ahazou/resources/environment_variable.dart';
import 'package:mobile_ahazou/resources/trackers.dart';
import 'package:mobile_ahazou/services/logging/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ChildensControlDataSource {
  Future<bool> removeChildrenAndParent(
      {required ChildrenModel children, parentId});
  Future<String> generateLink(
      {String linkParam,
      String userId,
      String title,
      String description,
      String image});
}

class ChildensControlDataSourceImpl implements ChildensControlDataSource {
  final SharedPreferences sharedPreferences;
  final FirebaseFirestore fireStore;
  const ChildensControlDataSourceImpl(
      {required this.sharedPreferences, required this.fireStore});

  @override
  Future<String> generateLink(
      {String? linkParam,
      String? userId,
      String? title,
      String? description,
      String? image}) async {
    try {
      final Uri fallbackUrl = Uri.parse("ahazou.com");
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: environment.uriPrefix,
        link: Uri.parse(environment.baseLinkToGenerate + '$linkParam=$userId'),
        androidParameters: AndroidParameters(
          packageName: environment.googlePlayIdentifier,
          minimumVersion: 1,
          fallbackUrl: fallbackUrl,
        ),
        iosParameters: IOSParameters(
            bundleId: environment.appStoreBundle,
            appStoreId: environment.appStoreIdentifier,
            fallbackUrl: fallbackUrl,
            ipadFallbackUrl: fallbackUrl,
            ipadBundleId: environment.appStoreBundle),
        googleAnalyticsParameters: const GoogleAnalyticsParameters(
          source: "mobile",
          campaign: Trackers.AhzFriends,
          medium: Trackers.AhzFriends,
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
            imageUrl: Uri.parse(image!),
            title: title,
            description: description),
      );

      final dynamicLinks = FirebaseDynamicLinks.instance;
      final ShortDynamicLink shortDynamicLink =
          await dynamicLinks.buildShortLink(parameters);
      return shortDynamicLink.shortUrl.toString();
    } catch (e, s) {
      AhzLogger.getInstance().error(e, s);
      return "";
    }
  }

  @override
  Future<bool> removeChildrenAndParent(
      {required ChildrenModel children, parentId}) async {
    bool removeChildren = false;
    bool removeParent = false;

    removeParent = await _removeParentOnChildren(children.id, parentId);
    removeChildren = await _removeChildrenOnParent(children, parentId);

    if (removeChildren && removeParent) {
      return true;
    }
    return false;
  }

  Future<bool> _removeChildrenOnParent(ChildrenModel children, parentId) async {
    try {
      await fireStore.collection("users").doc(parentId).set({
        "subscription": {
          "children": FieldValue.arrayRemove([
            {
              "id": children.id,
              "profile": {
                "name": children.profile?.name,
                "email": children.profile?.email,
                "phone_number": children.profile?.phoneNumber,
              }
            }
          ])
        },
      }, SetOptions(merge: true));
      if (children.profile?.phoneNumber == null ||
          children.profile!.phoneNumber.isEmpty) {
        await fireStore.collection("users").doc(parentId).set({
          "subscription": {
            "children": FieldValue.arrayRemove([
              {
                "id": children.id,
                "profile": {
                  "name": children.profile?.name,
                  "email": children.profile?.email,
                  "phone_number": null,
                }
              }
            ])
          },
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e, s) {
      AhzLogger.getInstance().error(e, s);
      return false;
    }
  }

  Future<bool> _removeParentOnChildren(String childrenId, parentId) async {
    try {
      await fireStore.collection("users").doc(childrenId).set({
        "subscription": {"parent": FieldValue.delete()}
      }, SetOptions(merge: true));
      return true;
    } catch (e, s) {
      AhzLogger.getInstance().error(e, s);
      return false;
    }
  }
}
