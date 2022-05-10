// @dart=2.15

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ahazou/components/app_bar.dart';
import 'package:mobile_ahazou/components/bottom_sheet.dart';
import 'package:mobile_ahazou/components/button.dart';
import 'package:mobile_ahazou/components/expansion_tile_simple.dart';
import 'package:mobile_ahazou/components/icon.dart';
import 'package:mobile_ahazou/components/text.dart';
import 'package:mobile_ahazou/components/view_item.dart';
import 'package:mobile_ahazou/core/domain/entities/user/subscription/children.dart';
import 'package:mobile_ahazou/core/domain/entities/user/user.dart';
import 'package:mobile_ahazou/core/provider/user_provider.dart';
import 'package:mobile_ahazou/features/children_control/presentation/provider/friends_state_notifier.dart';
import 'package:mobile_ahazou/features/shares/shares.dart';
import 'package:mobile_ahazou/resources/icons.dart';
import 'package:mobile_ahazou/resources/strings.dart';
import 'package:mobile_ahazou/resources/trackers.dart';
import 'package:mobile_ahazou/services/firebase/firebase_remote_config.dart';
import 'package:mobile_ahazou/services/tracking/tracker.dart';
import 'package:mobile_ahazou/utils/theme/ahz_colors.dart';
import 'package:mobile_ahazou/utils/theme/ahz_font.dart';
import 'package:mobile_ahazou/utils/theme/ahz_spacing.dart';
import 'package:mobile_ahazou/utils/type_face_custom.dart';

class ChildrenControlPage extends ConsumerWidget {
  const ChildrenControlPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(userDataProvider).when(
            data: (data) => _builder(context, data, ref),
            error: (e, s) => const SizedBox(),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
    );
  }
}

int childrenCount = 0;
bool hasChildrenToAdd = true;
dynamic _link;
Shares? _shares;
List<Children> childrens = [];

Widget _builder(BuildContext context, User data, WidgetRef ref) {
  childrens = data.getChildrensList();
  _shares = Shares(context: context);
  _shares?.init();
  _makeInitialCheckOnChildrens(context, ref);

  return Scaffold(
    backgroundColor: AhzColors.defaultBackground,
    appBar: AhzAppBar(
      hasBackButton: true,
      icon: AhzIcons.monoCancel,
      title: AhzText(
        text: Strings.childrensAddNavbarHeader,
        variant: AhzTextVariant.displayM,
        color: AhzColors.neutral[900],
      ),
    ),
    body: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(
            right: AhzSpacing.m, left: AhzSpacing.m, top: AhzSpacing.s),
        child: Column(
          children: <Widget>[
            if (hasChildrenToAdd) ...[_buildCardWithLink()],
            if (childrenCount > 0) ...[_buildChildrenList(context, ref)]
          ],
        ),
      ),
    ),
  );
}

bool _makeInitialCheckOnChildrens(BuildContext context, WidgetRef ref) {
  _link = ref.watch(getLinkProvider);

  childrenCount = childrens.length;
  if (childrenCount < 0) {
    hasChildrenToAdd = true;
    return true;
  }
  return false;
}

Widget _buildCardWithLink() {
  final List<BenefitItem> benefits = [
    BenefitItem(
        AhzFirebaseRemoteConfig.getInstance().getMaxFriends().toString() +
            Strings.ahzFriendsBenefit1,
        AhzIcons.mono_like),
    BenefitItem(Strings.ahzFriendsBenefit2, AhzIcons.mono_post_collection),
    BenefitItem(Strings.ahzFriendsBenefit3, AhzIcons.mono_idea),
  ];

  return Column(children: [
    _cardText(
        Strings.yourLinkToFriends1(
            AhzFirebaseRemoteConfig.getInstance().getMaxFriends().toString()),
        variant: AhzTextVariant.displayM),
    Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: benefits.length,
        itemBuilder: (context, i) => _buildBenefit(context, benefits[i]),
      ),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(
          right: AhzSpacing.m, top: AhzSpacing.s, left: AhzSpacing.s),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: AhzSpacing.xxs),
      child: AhzButton(
        label: Strings.friendsProfileMenuTitle,
        variant: AhzButtonVariant.primary,
        onPressed: () {
          Tracker.trackEventWithProperties(
              Trackers.shareFriends, {"network": "default"});
          _shares?.showBottomSheet(
              share: Share.DEFAULT, text: _link.value.toString());
        },
        margin: const EdgeInsets.only(bottom: AhzSpacing.s, top: AhzSpacing.m),
      ),
    ),
    ExpansionTileSimple(
      expandedAlignment: Alignment.topLeft,
      children: [
        AhzText(
          text: Strings.ahzFriendsFaqText1,
          variant: AhzTextVariant.bodyS,
          color: AhzColors.neutral[800],
        ),
      ],
      title: AhzText(
        text: Strings.ahzFriendsFaqTitle1,
        color: AhzColors.primary,
        variant: AhzTextVariant.subtitle,
      ),
    ),
    ExpansionTileSimple(
      expandedAlignment: Alignment.topLeft,
      children: [
        AhzText(
          text: Strings.ahzFriendsFaqText2,
          variant: AhzTextVariant.bodyS,
          color: AhzColors.neutral[800],
        ),
      ],
      title: AhzText(
        text: Strings.ahzFriendsFaqTitle2,
        color: AhzColors.primary,
        variant: AhzTextVariant.subtitle,
      ),
    ),
  ]);
}

Widget _buildChildrenList(BuildContext context, WidgetRef ref) {
  return Container(
    margin: const EdgeInsets.only(top: AhzSpacing.s),
    width: double.infinity,
    child: Column(
      children: <Widget>[
        AhzText(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: AhzSpacing.l),
          text: Strings.yourFriends,
          variant: AhzTextVariant.displayM,
          color: AhzColors.neutral[900],
        ),
        Column(children: _buildViewItemList(context, ref))
      ],
    ),
  );
}

class BenefitItem {
  String title;
  AhzIcon icon;

  BenefitItem(this.title, String icon)
      : icon = AhzIcon(
          icon: icon,
          color: AhzColors.neutral[300],
        );
}

AhzText _cardText(String value,
        {AhzTextVariant variant = AhzTextVariant.buttonS,
        TextAlign align = TextAlign.center}) =>
    AhzText(
      text: value,
      variant: variant,
      textAlign: align,
      margin: const EdgeInsets.only(top: AhzSpacing.m),
    );

Widget _buildBenefit(BuildContext context, BenefitItem benefit) => Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: benefit.icon,
            height: AhzSpacing.l,
            width: AhzSpacing.l,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 128,
            child: Html(
              data: benefit.title,
              shrinkWrap: true,
              style: {
                "html": Style(
                    fontSize: const FontSize(AhzFont.s),
                    fontFamily: setTypeFace(TypeFaceCustom.INTER_REGULAR)),
              },
            ),
          ),
        ],
      ),
    );

List<Widget> _buildViewItemList(BuildContext context, WidgetRef ref) {
  final List<Widget> result = [];
  for (var value in childrens) {
    result.add(_getViewItem(context, ref, value));
  }
  return result;
}

ViewItem _getViewItem(BuildContext context, WidgetRef ref, Children children) =>
    ViewItem(
      withEffect: false,
      isFriends: true,
      icon: AhzIcon(icon: AhzIcons.color_friends, size: AhzIconSize.l),
      size: ViewItemSize.l,
      title: AhzText(
        text: children.profile!.name,
        color: AhzColors.neutral[900],
        variant: AhzTextVariant.buttonM,
      ),
      subTitle: AhzText(
        text: children.profile!.email,
        color: AhzColors.neutral[500],
        variant: AhzTextVariant.bodyS,
      ),
      onFriendsTap: () {
        delete(context, ref, children);
      },
    );

void delete(BuildContext context, WidgetRef ref, Children children) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: AhzColors.defaultBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AhzSpacing.radiusXL),
        topRight: Radius.circular(AhzSpacing.radiusXL),
      ),
    ),
    builder: (BuildContext bc) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AhzBottomSheet(
            context,
            isCenter: false,
            children: <Widget>[
              AhzText(
                margin: const EdgeInsets.only(bottom: AhzSpacing.s),
                variant: AhzTextVariant.displayM,
                textAlign: TextAlign.left,
                color: AhzColors.black,
                text: Strings.removeFriendTitle,
              ),
              AhzText(
                margin: const EdgeInsets.only(bottom: AhzSpacing.s),
                variant: AhzTextVariant.bodyM,
                textAlign: TextAlign.left,
                color: AhzColors.black,
                text:
                    Strings.removeAhazouFriendsSubtitle(children.profile!.name),
              ),
              Align(
                alignment: Alignment.center,
                child: AhzButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(removeChildrenAndParentProvider(children));
                  },
                  label: Strings.my_logos_btn_remove,
                  variant: AhzButtonVariant.secondary,
                  margin: const EdgeInsets.only(top: AhzSpacing.xl),
                ),
              ),
              const SizedBox(height: AhzSpacing.s),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AhzSpacing.m),
                  child: AhzButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: Strings.cancel,
                    variant: AhzButtonVariant.negative,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
