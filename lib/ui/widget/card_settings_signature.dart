// Copyright (c) 2018, codegrue. All rights reserved. Use of this source code
// is governed by the MIT license that can be found in the LICENSE file.

import 'package:card_settings/card_settings.dart';
import 'package:card_settings/helpers/platform_functions.dart';
import 'package:card_settings/interfaces/common_field_properties.dart';
import 'package:card_settings/interfaces/text_field_properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:on_site_intervention_app/ui/utils/i18n.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

import '../../models/model_field.dart';
import '../../network/api/image.api.dart';
import '../signature_page.dart';

class widgetSignature extends StatefulWidget {
  final String initialValue;
  final FormFieldValidator<String>? validator;
  final Field field;
  final BuildContext context;

  const widgetSignature(
      {super.key,
      required this.initialValue,
      required this.context,
      required this.validator,
      required this.field});

  @override
  State<widgetSignature> createState() => _widgetSignatureState();
}

class _widgetSignatureState extends State<widgetSignature> {
  late String stringSVG;

  @override
  void initState() {
    super.initState();
    stringSVG = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    SvgPicture? svpP = null;
    try {
      if (ImageApi.isSvgPath(stringSVG)) {
        svpP = SvgPicture.string(stringSVG);
      }
    } catch (e) {
      svpP = null;
      print("error");
    }
    return Column(children: [
      IconButton(
        padding: EdgeInsets.zero,
        iconSize: 50,
        icon: const Icon(Icons.draw),
        onPressed: () async {
          if (context.mounted) {
            var stringReturnSVG = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return const SignaturePage();
            }));

            if (stringReturnSVG == null) {
              return;
            }
            stringSVG = stringReturnSVG;
            widget.validator!(stringReturnSVG);
            setState(() {});
          }
        },
      ),
      (svpP != null) ? svpP : Text(translateI18N("signature"))
    ]);
  }
}

/// This is a standard one line text entry  It's based on the [TextFormField] widget.
class CardSettingsSignature extends FormField<String>
    implements ICommonFieldProperties, ITextFieldProperties {
  final Field field;

  CardSettingsSignature(
      {Key? key,
      String? initialValue,
      bool autovalidate = false,
      AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
      this.enabled = true,
      this.onSaved,
      this.validator,
      this.onChanged,
      this.controller,
      this.textCapitalization = TextCapitalization.none,
      this.keyboardType = TextInputType.text,
      this.maxLengthEnforcement = MaxLengthEnforcement.enforced,
      this.inputMask,
      this.inputFormatters,
      this.onFieldSubmitted,
      this.style,
      this.focusNode,
      this.inputAction,
      this.inputActionNode,
      this.label = 'Label',
      this.contentOnNewLine = false,
      this.maxLength = 20,
      this.numberOfLines = 1,
      this.showCounter = false,
      this.visible = true,
      this.autocorrect = true,
      this.obscureText = false,
      this.autofocus = false,
      this.contentAlign,
      this.hintText,
      this.icon,
      this.labelAlign,
      this.labelWidth,
      this.prefixText,
      this.requiredIndicator,
      this.unitLabel,
      this.showMaterialonIOS,
      this.showClearButtonIOS = OverlayVisibilityMode.never,
      this.fieldPadding,
      this.contentPadding = const EdgeInsets.all(0.0),
      required this.field})
      : assert(maxLength > 0),
        assert(controller == null || inputMask == null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<String> field) =>
              (field as _CardSettingsSignatureState)._build(field.context),
        );

  @override
  final ValueChanged<String>? onChanged;

  final TextEditingController? controller;

  final String? inputMask;

  final FocusNode? focusNode;

  final TextInputAction? inputAction;

  final FocusNode? inputActionNode;

  final TextInputType keyboardType;

  final TextCapitalization textCapitalization;

  final TextStyle? style;

  // If false the field is grayed out and unresponsive
  @override
  // If false, grays out the field and makes it unresponsive
  final bool enabled;

  final MaxLengthEnforcement? maxLengthEnforcement;

  final ValueChanged<String>? onFieldSubmitted;

  final List<TextInputFormatter>? inputFormatters;

  // The text to identify the field to the user
  @override
  final String label;

  // The alignment of the label paret of the field. Default is left.
  @override
  final TextAlign? labelAlign;

  // The width of the field label. If provided overrides the global setting.
  @override
  final double? labelWidth;

  // controls how the widget in the content area of the field is aligned
  @override
  final TextAlign? contentAlign;

  final String? unitLabel;

  final String? prefixText;

  @override
  // text to display to guide the user on what to enter
  final String? hintText;

  // The icon to display to the left of the field content
  @override
  final Icon? icon;

  // A widget to show next to the label if the field is required
  @override
  final Widget? requiredIndicator;

  final bool contentOnNewLine;

  final int maxLength;

  final int numberOfLines;

  final bool showCounter;

  // If false hides the widget on the card setting panel
  @override
  final bool visible;

  final bool autofocus;

  final bool obscureText;

  final bool autocorrect;

  // Force the widget to use Material style on an iOS device
  @override
  final bool? showMaterialonIOS;

  // provides padding to wrap the entire field
  @override
  final EdgeInsetsGeometry? fieldPadding;

  final EdgeInsetsGeometry contentPadding;

  ///Since the CupertinoTextField does not support onSaved, please use [onChanged] or [onFieldSubmitted] instead
  @override
  final FormFieldSetter<String>? onSaved;

  ///In material mode this shows the validation text under the field
  ///In cupertino mode, it shows a [red] [Border] around the [CupertinoTextField]
  @override
  final FormFieldValidator<String>? validator;

  final OverlayVisibilityMode showClearButtonIOS;

  @override
  _CardSettingsSignatureState createState() => _CardSettingsSignatureState();
}

class _CardSettingsSignatureState extends FormFieldState<String> {
  TextEditingController? _controller;

  @override
  CardSettingsSignature get widget => super.widget as CardSettingsSignature;

  @override
  void initState() {
    super.initState();
    _initController(widget.initialValue);
  }

  @override
  void didUpdateWidget(CardSettingsSignature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _initController(oldWidget.controller?.value.toString());
    }
  }

  void _initController(String? initialValue) {
    if (widget.controller == null) {
      if (widget.inputMask == null) {
        _controller = TextEditingController(text: initialValue);
      } else {
        _controller =
            MaskedTextController(mask: widget.inputMask!, text: initialValue);
      }
    } else {
      _controller = widget.controller;
    }

    _controller!.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _controller!.text = widget.initialValue ?? '';
    });
  }

  void _handleControllerChanged() {
    if (_controller!.text != value) {
      didChange(_controller!.text);
    }
  }

  void _handleOnChanged(String value) {
    if (widget.onChanged != null) {
      // `value` doesn't apple any masks when this is called, so the controller has the actual formatted value
      widget.onChanged!(_controller!.value.text);
    }
  }

  void _onFieldSubmitted(String value) {
    if (widget.focusNode != null) widget.focusNode!.unfocus();

    if (widget.inputActionNode != null) {
      widget.inputActionNode!.requestFocus();
      return;
    }

    if (widget.onFieldSubmitted != null) {
      widget.onFieldSubmitted!(value);
    }
  }

  Widget _build(BuildContext context) {
    if (showCupertino(context, widget.showMaterialonIOS)) {
      return _buildCupertinoTextbox(context);
    } else {
      return _buildMaterialTextbox(context);
    }
  }

  Container _buildCupertinoTextbox(BuildContext context) {
    bool hasError = false;
    if (widget.validator != null) {
      String? errorMessage = widget.validator!(value);
      hasError = (errorMessage != null);
    }

    final ls = labelStyle(context, widget.enabled);
    final _child = CupertinoTextField(
      prefix: widget.prefixText == null
          ? null
          : Text(
              widget.prefixText ?? '',
              style: ls,
            ),
      suffix: widget.unitLabel == null
          ? null
          : Text(
              widget.unitLabel ?? '',
              style: ls,
            ),
      controller: _controller,
      focusNode: widget.focusNode,
      textInputAction: widget.inputAction,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      style: contentStyle(context, value, widget.enabled),
      decoration: hasError
          ? BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: const BorderRadius.all(
                Radius.circular(4.0),
              ),
            )
          : const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: CupertinoColors.lightBackgroundGray,
                  style: BorderStyle.solid,
                  width: 0.0,
                ),
                bottom: BorderSide(
                  color: CupertinoColors.lightBackgroundGray,
                  style: BorderStyle.solid,
                  width: 0.0,
                ),
                left: BorderSide(
                  color: CupertinoColors.lightBackgroundGray,
                  style: BorderStyle.solid,
                  width: 0.0,
                ),
                right: BorderSide(
                  color: CupertinoColors.lightBackgroundGray,
                  style: BorderStyle.solid,
                  width: 0.0,
                ),
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(4.0),
              ),
            ),
      clearButtonMode: widget.showClearButtonIOS,
      placeholder: widget.hintText,
      textAlign: widget.contentAlign ?? TextAlign.end,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      maxLines: widget.numberOfLines,
      maxLength: (widget.showCounter)
          ? widget.maxLength
          : null, // if we want counter use default behavior
      onChanged: _handleOnChanged,
      onSubmitted: _onFieldSubmitted,
      inputFormatters: widget.inputFormatters ??
          [
            // if we don't want the counter, use this maxLength instead
            LengthLimitingTextInputFormatter(widget.maxLength)
          ],
      enabled: widget.enabled,
    );
    return Container(
      child: widget.visible == false
          ? null
          : widget.contentOnNewLine == true
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CSControl(
                      nameWidget: widget.requiredIndicator != null
                          ? Text(
                              (widget.label) + ' *',
                              style: ls,
                            )
                          : Text(widget.label, style: ls),
                      contentWidget: Container(),
                      style: CSWidgetStyle(icon: widget.icon),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : CupertinoColors.white,
                      child: _child,
                    ),
                    Container(
                      padding:
                          widget.showCounter ? const EdgeInsets.all(5.0) : null,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : CupertinoColors.white,
                      child: widget.showCounter
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "${_controller?.text.length ?? 0}/${widget.maxLength}",
                                  style: const TextStyle(
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CSControl(
                      nameWidget: SizedBox(
                        width: widget.labelWidth ??
                            CardSettings.of(context)?.labelWidth ??
                            120.0,
                        child: widget.requiredIndicator != null
                            ? Text((widget.label) + ' *', style: ls)
                            : Text(widget.label, style: ls),
                      ),
                      contentWidget: Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: _child,
                        ),
                      ),
                      style: CSWidgetStyle(icon: widget.icon),
                    ),
                    Container(
                      padding:
                          widget.showCounter ? const EdgeInsets.all(5.0) : null,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : CupertinoColors.white,
                      child: widget.showCounter
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "${_controller?.text.length ?? 0}/${widget.maxLength}",
                                  style: const TextStyle(
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ],
                ),
    );
  }

  CardSettingsField _buildMaterialTextbox(BuildContext context) {
    return CardSettingsField(
        label: "",
        labelAlign: widget.labelAlign,
        labelWidth: 0,
        visible: widget.visible,
        unitLabel: widget.unitLabel,
        icon: widget.icon,
        requiredIndicator: widget.requiredIndicator,
        contentOnNewLine: widget.contentOnNewLine,
        enabled: widget.enabled,
        fieldPadding: widget.fieldPadding,
        content: widgetSignature(
            initialValue: widget.initialValue ?? '',
            context: context,
            validator: widget.validator,
            field: widget.field));
  }
}
