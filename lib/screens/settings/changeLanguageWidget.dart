import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/generalMethods.dart';

import '../../cubits/appLocalizationCubit.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/stringLables.dart';

class ChangeLanguageWidget extends StatelessWidget {
  const ChangeLanguageWidget({Key? key}) : super(key: key);

  Widget _buildAppLanguageTile(
      {required Map appLanguage,
      required BuildContext context,
      required String currentSelectedLanguageCode}) {
    bool iscurrlang =
        appLanguage["languageCode"] == currentSelectedLanguageCode;
    Color textcolor = iscurrlang
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;
    return ListTile(
      onTap: () {
        context
            .read<AppLocalizationCubit>()
            .changeLanguage(appLanguage["languageCode"]);
      },
      leading: Icon(
        iscurrlang ? Icons.radio_button_checked : Icons.radio_button_off,
        color: textcolor,
      ),
      title: Text(
        appLanguage["languageName"],
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .merge(TextStyle(color: textcolor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getLables(appLanguageKey, context: context),
          style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold),
        ),
        Divider(
          color: lightGrey,
          height: 40,
        ),
        BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
          builder: (context, state) {
            return Column(
              children: Constant.appLanguages
                  .map((appLanguage) => _buildAppLanguageTile(
                      appLanguage: appLanguage,
                      context: context,
                      currentSelectedLanguageCode: state.language.languageCode))
                  .toList(),
            );
          },
        )
      ],
    );
  }
}
