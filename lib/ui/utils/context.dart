import 'colors.dart';
import 'sizes.dart';
import 'package:flutter/material.dart';

extension ContextTool on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get height => mediaQuery.size.height;

  double get width => mediaQuery.size.width;

  bool get isTablet => width >= ThemeSize.tabletMinScreenWidth;

  /* Translation get translation => Translation.of(this);

  String getGenericErrorMessage(Object error) => error is StateError
      ? translation.fileNotFoundError
      : error is HttpException
      ? translation.httpError(error.message)
      : error is SocketException
      ? translation.networkError
      : error is FileSystemException
      ? translation.diskSpaceError
      : translation.unknownError;
 */

  void showModal(Widget modal,
          {bool barrierDismissible = true,
          Color barrierColor = ThemeColor.lightGrey}) =>
      showGeneralDialog(
          context: this,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierDismissible ? 'Close' : null,
          barrierColor: barrierColor,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              modal);
}

extension SnackBarsContextExtensions on BuildContext {
  void showSuccessSnackBar(
    String text, {
    SnackBarAction? action,
    bool isInfinite = false,
  }) =>
      showCustomSnackBar(
        text: text,
        icon: const Icon(Icons.check_circle_outline, color: ThemeColor.success),
        action: action,
        isInfinite: isInfinite,
      );

  void showInformationSnackBar(
    String text, {
    SnackBarAction? action,
    bool isInfinite = false,
  }) =>
      showCustomSnackBar(
        text: text,
        icon: const Icon(Icons.info_outline_rounded,
            color: ThemeColor.blackThemeColor),
        action: action,
        isInfinite: isInfinite,
      );

  void showWarningSnackBar(
    String text, {
    SnackBarAction? action,
    bool isInfinite = false,
  }) =>
      showCustomSnackBar(
        text: text,
        icon:
            const Icon(Icons.error_outline_rounded, color: ThemeColor.warning),
        action: action,
        isInfinite: isInfinite,
      );

  void showErrorSnackBar(
    String text, {
    SnackBarAction? action,
    bool isInfinite = false,
  }) =>
      showCustomSnackBar(
        text: text,
        icon: const Icon(Icons.error_rounded, color: ThemeColor.error),
        action: action,
        isInfinite: isInfinite,
      );

  void showCustomSnackBar({
    required String text,
    required Widget icon,
    SnackBarAction? action,
    bool isInfinite = false,
  }) =>
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              icon,
              ThemeSize.gap(m),
              Expanded(
                child: Text(text, style: textTheme.bodyLarge),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ThemeColor.white,
          action: action,
          duration: isInfinite
              ? const Duration(days: 365)
              : const Duration(seconds: 4),
          dismissDirection:
              isInfinite ? DismissDirection.none : DismissDirection.down,
        ),
      );
}
