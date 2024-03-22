// Copyright (c) 2018, codegrue. All rights reserved. Use of this source code
// is governed by the MIT license that can be found in the LICENSE file.

import 'package:card_settings/helpers/platform_functions.dart';
import 'package:card_settings/interfaces/common_field_properties.dart';
import 'package:card_settings/interfaces/text_field_properties.dart';
import 'package:card_settings/widgets/card_settings_field.dart';
import 'package:card_settings/widgets/card_settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:flutter/cupertino.dart';

/// This is a standard one line text entry  It's based on the [TextFormField] widget.
class CardSettingsAutoCompleteText extends FormField<String>
    implements ICommonFieldProperties, ITextFieldProperties {
  CardSettingsAutoCompleteText({
    Key? key,
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
    required this.items,
  })  : assert(maxLength > 0),
        assert(controller == null || inputMask == null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<String> field) =>
              (field as _CardSettingsTextState)._build(field.context),
        );

  final List items;

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
  _CardSettingsTextState createState() => _CardSettingsTextState();
}

class _CardSettingsTextState extends FormFieldState<String> {
  TextEditingController? _controller;

  List items = [];

  @override
  CardSettingsAutoCompleteText get widget =>
      super.widget as CardSettingsAutoCompleteText;

  @override
  void initState() {
    super.initState();
    _initController(widget.initialValue);
    items = widget.items;
  }

  @override
  void didUpdateWidget(CardSettingsAutoCompleteText oldWidget) {
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
      widget.onChanged!(value);
    }
  }

  void _onFieldSubmitted(String value) {
    if (this.widget.focusNode != null) this.widget.focusNode!.unfocus();

    if (this.widget.inputActionNode != null) {
      this.widget.inputActionNode!.requestFocus();
      return;
    }

    if (this.widget.onFieldSubmitted != null)
      this.widget.onFieldSubmitted!(value);
  }

  Widget _build(BuildContext context) {
    return _buildMaterialTextbox(context);
  }

  List<String> companies = ["a", "b", "c"];

  CardSettingsField _buildMaterialTextbox(BuildContext context) {
    return CardSettingsField(
      label: widget.label,
      labelAlign: widget.labelAlign,
      labelWidth: widget.labelWidth,
      visible: widget.visible,
      unitLabel: widget.unitLabel,
      icon: widget.icon,
      requiredIndicator: widget.requiredIndicator,
      contentOnNewLine: widget.contentOnNewLine,
      enabled: widget.enabled,
      fieldPadding: widget.fieldPadding,
      content: RawAutocomplete<String>(
        initialValue: TextEditingValue(text: _controller!.text),
        optionsBuilder: (TextEditingValue textEditingValue) {
          List<String> _options = [];
          for (var i = 0; i < items.length; i++) {
            var s = items[i];
            _options.add("${s}");
          }

          return _options.where((String option) {
            return option.contains(textEditingValue.text.toLowerCase());
          });
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return TextFormField(
            // initialValue: initialValue,
            controller: textEditingController,
            focusNode: focusNode,
            onChanged: _handleOnChanged,
            onFieldSubmitted: _onFieldSubmitted,
          );
        },
        onSelected: _handleOnChanged,
        optionsViewBuilder: (BuildContext context,
            void Function(String) onSelected, Iterable<String> options) {
          return Align(
              alignment: Alignment.topLeft,
              child: Material(
                  elevation: 4.0,
                  child: SizedBox(
                      height: 200.0,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option),
                            ),
                          );
                        },
                      ))));
        },
      ),

      /*TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.inputAction,
        textCapitalization: widget.textCapitalization,
        enabled: widget.enabled,
        readOnly: !widget.enabled,
        style: contentStyle(context, value, widget.enabled),
        decoration: InputDecoration(
          contentPadding: widget.contentPadding,
          border: InputBorder.none,
          errorText: errorText,
          prefixText: widget.prefixText,
          hintText: widget.hintText,
          isDense: true,
        ),
        textAlign:
            widget.contentAlign ?? CardSettings.of(context)!.contentAlign,
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
      ),*/
    );
  }
}
