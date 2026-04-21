import 'package:flutter/widgets.dart';

String tr3(
  BuildContext context, {
  required String fr,
  required String en,
  required String ar,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'en':
      return en;
    case 'ar':
      return ar;
    default:
      return fr;
  }
}

