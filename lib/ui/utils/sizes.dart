import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

abstract class ThemeSize {
  ThemeSize._();

  // GAP

  static const Map<Sizing, Gap> _gap = {
    xxs: Gap(2),
    xs: Gap(5),
    s: Gap(10),
    m: Gap(16),
    l: Gap(30),
    xl: Gap(36),
    xxl: Gap(42),
    xxxl: Gap(52)
  };

  static Gap gap(Sizing size) => _gap[size]!;

  // SIDEBAR

  static const Map<Sizing, double> _sideBarDefaultWidth = {m: 72};
  static double sideBarWidth = _sideBarDefaultWidth[m]!;
  static const Map<Sizing, double> _preferredSizeAppBar = {m: 200};
  static double preferredSize = _preferredSizeAppBar[m]!;

  // CONTENT MAX WIDTH

  static const Map<Sizing, double> _contentMaxWidth = {
    xs: 200,
    s: 300,
    m: 400,
    l: 500
  };
  static BoxConstraints contentMaxWidth(Sizing size) =>
      BoxConstraints(maxWidth: _contentMaxWidth[size]!);

  static const Map<Sizing, double> _contentMaxHeight = {
    xs: 200,
    s: 300,
    m: 400,
    l: 500
  };
  static BoxConstraints contentMaxHeight(Sizing size) =>
      BoxConstraints(maxHeight: _contentMaxHeight[size]!);

  // RIGHT PANEL

  static const Map<Sizing, double> _tabletRightPanelDefaultWidth = {m: 400};
  static double tabletRightPanelWidth = _tabletRightPanelDefaultWidth[m]!;
  static BoxConstraints tabletRightPanelMaxWidth =
      BoxConstraints(maxWidth: _tabletRightPanelDefaultWidth[m]!);

  // SCREEN

  static const Map<Sizing, double> _screenDefaultWidth = {m: 768};
  static double tabletMinScreenWidth = _screenDefaultWidth[m]!;

  // ANIMATION DURATION

  static const Map<Sizing, Duration> _animationDefaultDuration = {
    s: Duration(milliseconds: 350),
    m: Duration(milliseconds: 500)
  };
  static Duration animationDuration = _animationDefaultDuration[m]!;

  // PADDING

  static const Map<Sizing, double> _paddingDefaultValue = {
    zero: 0,
    xxs: 5,
    xs: 8,
    s: 20,
    m: 30,
    l: 40,
    xl: 50,
    xxl: 100
  };
  static double paddingValue(Sizing size) => _paddingDefaultValue[size]!;
  static EdgeInsets padding(Sizing size) => EdgeInsets.all(paddingValue(size));
  static EdgeInsets paddingSymmetric(Sizing sizeX, Sizing sizeY) =>
      EdgeInsets.symmetric(
          horizontal: paddingValue(sizeX), vertical: paddingValue(sizeY));
  static EdgeInsets paddingOnly(
          {Sizing top = zero,
          Sizing bottom = zero,
          Sizing left = zero,
          Sizing right = zero}) =>
      EdgeInsets.only(
          top: paddingValue(top),
          bottom: paddingValue(bottom),
          left: paddingValue(left),
          right: paddingValue(right));
  static EdgeInsets paddingAllExcept(Sizing all,
          {Sizing? top, Sizing? bottom, Sizing? left, Sizing? right}) =>
      EdgeInsets.only(
          top: paddingValue(top ?? all),
          bottom: paddingValue(bottom ?? all),
          left: paddingValue(left ?? all),
          right: paddingValue(right ?? all));
  static EdgeInsets paddingLTRB(
          Sizing left, Sizing top, Sizing right, Sizing bottom) =>
      EdgeInsets.fromLTRB(paddingValue(left), paddingValue(top),
          paddingValue(right), paddingValue(bottom));

  // BORDER-RADIUS

  static const Map<Sizing, double> _borderRadiusDefaultValue = {
    zero: 0,
    xxs: 4,
    xs: 12,
    s: 15,
    m: 22,
    l: 32,
    xl: 40,
    xxl: 50
  };
  static double borderRadiusValue(Sizing? size) =>
      _borderRadiusDefaultValue[size ?? zero]!;

  static BorderRadius borderRadius(Sizing size) =>
      BorderRadius.all(Radius.circular(borderRadiusValue(size)));
  static BorderRadius borderHorizontal(Sizing left, [Sizing? right]) =>
      BorderRadius.horizontal(
          left: Radius.circular(borderRadiusValue(left)),
          right: Radius.circular(borderRadiusValue(right ?? left)));
  static BorderRadius borderVertical(Sizing top, [Sizing? bottom]) =>
      BorderRadius.vertical(
          top: Radius.circular(borderRadiusValue(top)),
          bottom: Radius.circular(borderRadiusValue(bottom ?? top)));
  static BorderRadius borderOnly(
          {Sizing? topLeft,
          Sizing? topRight,
          Sizing? bottomLeft,
          Sizing? bottomRight}) =>
      BorderRadius.only(
          topLeft: Radius.circular(borderRadiusValue(topLeft)),
          topRight: Radius.circular(borderRadiusValue(topRight)),
          bottomLeft: Radius.circular(borderRadiusValue(bottomLeft)),
          bottomRight: Radius.circular(borderRadiusValue(bottomRight)));

  static BorderRadius borderTop(Sizing topLeft, [Sizing? topRight]) =>
      borderOnly(topLeft: topLeft, topRight: topRight ?? topLeft);
  static BorderRadius borderBottom(Sizing bottomLeft, [Sizing? bottomRight]) =>
      borderOnly(
          bottomLeft: bottomLeft, bottomRight: bottomRight ?? bottomLeft);

  // TEXT

  static const Map<Sizing, double> _textDefaultSize = {
    xxs: 8,
    xs: 10,
    s: 12,
    m: 14,
    l: 16,
    xl: 18,
    xxl: 20,
    xxxl: 40
  };
  static double text(Sizing size) => _textDefaultSize[size]!;

  // BUTTON

  static const Map<Sizing, double> _buttonDefaultHeight = {
    xs: 20,
    s: 30,
    m: 40
  };
  static double buttonHeight(Sizing size) => _buttonDefaultHeight[size]!;

  // INPUT

  static const Map<Sizing, double> _inputBorderDefaultHeight = {
    xs: 35,
    s: 42.5,
    m: 55.5
  };
  static double inputHeight(Sizing size) => _inputBorderDefaultHeight[size]!;

  static const Map<Sizing, double> _inputBorderDefaultWidth = {m: 1, l: 2};
  static double inputBorder(Sizing size) => _inputBorderDefaultWidth[size]!;

  // ICON

  static const Map<Sizing, double> _iconDefaultSize = {
    xs: 14,
    s: 20,
    m: 24,
    l: 32,
    xl: 40,
    xxl: 60,
    xxxl: 74
  };
  static double iconSize(Sizing size) => _iconDefaultSize[size]!;

  // IMAGE

  static const Map<Sizing, double> _imageDefaultHeight = {
    s: 32,
    m: 48,
    l: 74,
    xl: 96,
    xxl: 128,
    xxxl: 256
  };
  static double imageHeight(Sizing size) => _imageDefaultHeight[size]!;

  static const Map<Sizing, double> _contractDefinitionSize = {
    s: 32,
    m: 48,
    l: 70
  };
  static double contractDefinition(Sizing size) =>
      _contractDefinitionSize[size]!;
}

enum Sizing { zero, xxs, xs, s, m, l, xl, xxl, xxxl }

const zero = Sizing.zero;
const xxs = Sizing.xxs;
const xs = Sizing.xs;
const s = Sizing.s;
const m = Sizing.m;
const l = Sizing.l;
const xl = Sizing.xl;
const xxl = Sizing.xxl;
const xxxl = Sizing.xxxl;
