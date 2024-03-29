// Copyright (c) 2018, codegrue. All rights reserved. Use of this source code
// is governed by the MIT license that can be found in the LICENSE file.

import 'package:card_settings/card_settings.dart';
import 'package:card_settings/interfaces/common_field_properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// This is a password field. It obscures the entered text.
class CardSettingsFloat extends CardSettingsText
    implements ICommonFieldProperties {
  CardSettingsFloat({
    Key? key,
    String label = 'Label',
    TextAlign? labelAlign,
    double? labelWidth,
    TextAlign? contentAlign,
    String? hintText,
    double initialValue = 0.0,
    Icon? icon,
    Widget? requiredIndicator,
    String? unitLabel,
    int maxLength = 10,
    bool visible = true,
    bool enabled = true,
    bool autofocus = false,
    bool obscureText = false,
    bool autocorrect = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
    ValueChanged<String?>? onChanged,
    TextEditingController? controller,
    FocusNode? focusNode,
    TextInputAction? inputAction,
    FocusNode? inputActionNode,
    TextInputType? keyboardType,
    TextStyle? style,
    MaxLengthEnforcement? maxLengthEnforcement = MaxLengthEnforcement.enforced,
    ValueChanged<String>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool? showMaterialonIOS,
    EdgeInsetsGeometry? fieldPadding,
  }) : super(
          key: key,
          label: label,
          hintText: hintText,
          labelAlign: labelAlign,
          labelWidth: labelWidth,
          showMaterialonIOS: showMaterialonIOS,
          contentAlign: contentAlign,
          initialValue: initialValue.toString(),
          unitLabel: unitLabel,
          icon: icon,
          requiredIndicator: requiredIndicator,
          maxLength: maxLength,
          visible: visible,
          enabled: enabled,
          autofocus: autofocus,
          obscureText: obscureText,
          autocorrect: autocorrect,
          autovalidateMode: autovalidateMode,
          fieldPadding: fieldPadding,
          validator: (value) {
            if (validator == null) return null;
            return validator(intelligentCast<String>(value));
          },
          onSaved: (value) {
            if (onSaved == null) return;
            onSaved(intelligentCast<String>(value));
          },
          onChanged: (value) {
            if (onChanged == null) return;
            onChanged(intelligentCast<String?>(value));
          },
          controller: controller,
          focusNode: focusNode,
          inputAction: inputAction,
          inputActionNode: inputActionNode,
          keyboardType: keyboardType ??
              const TextInputType.numberWithOptions(decimal: false),
          style: style,
          maxLengthEnforcement: maxLengthEnforcement,
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
            FilteringTextInputFormatter.allow(RegExp("[0-9\.]+")),
          ],
        );
}
