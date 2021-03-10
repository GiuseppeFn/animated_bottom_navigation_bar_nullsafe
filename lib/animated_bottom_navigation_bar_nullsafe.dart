library animated_bottom_navigation_bar_nullsafe;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:animated_bottom_navigation_bar_nullsafe/src/navigation_bar_item.dart';

/// Signature for a function that creates a widget for a given index & state.
/// Used by [AnimatedBottomNavigationBar.builder].
typedef IndexedWidgetBuilder = Widget Function(int index, bool isActive);

class AnimatedBottomNavigationBar extends StatefulWidget {
  /// Widgets to render in the tab bar.
  final IndexedWidgetBuilder? tabBuilder;

  /// Total item count.
  final int? itemCount;

  /// Icon data to render in the tab bar.
  final List<IconData>? icons;

  /// Handler which is passed every updated active index.
  final Function(int) onTap;

  /// Current index of selected tab bar item.
  final int activeIndex;

  /// Optional custom size for each tab bar icon.
  final double? iconSize;

  /// Optional custom tab bar height.
  final double? height;

  /// Optional custom tab bar elevation.
  final double? elevation;

  /// Optional custom maximum spread radius for splash selection animation.
  final double? splashRadius;

  /// Optional custom splash selection animation speed.
  final int? splashSpeedInMilliseconds;

  /// Optional custom tab bar background color.
  final Color? backgroundColor;

  /// Optional custom splash selection animation color.
  final Color? splashColor;

  /// Optional custom currently selected tab bar [IconData] color.
  final Color? activeColor;

  /// Optional custom currently unselected tab bar [IconData] color.
  final Color? inactiveColor;

  final BorderRadius borderRadius;

  AnimatedBottomNavigationBar._internal({
    Key? key,
    required this.activeIndex,
    required this.onTap,
    this.tabBuilder,
    this.itemCount,
    this.icons,
    this.height,
    this.elevation,
    this.splashRadius,
    this.splashSpeedInMilliseconds,
    this.backgroundColor,
    this.splashColor,
    this.activeColor,
    this.borderRadius:BorderRadius.zero,
    this.inactiveColor,
    this.iconSize,
  })  : assert(icons != null || itemCount != null),
        assert(((itemCount ?? icons!.length) >= 2) &&
            ((itemCount ?? icons!.length) <= 5)),
        super(key: key);

  AnimatedBottomNavigationBar({
    Key? key,
    required List<IconData> icons,
    required int activeIndex,
    required Function(int) onTap,
    double height = 56,
    double elevation = 8,
    double splashRadius = 24,
    int splashSpeedInMilliseconds = 300,
    Color backgroundColor = Colors.white,
    Color splashColor = Colors.purple,
    Color activeColor = Colors.deepPurpleAccent,
    Color inactiveColor = Colors.black,
    BorderRadius borderRadius = BorderRadius.zero,
    double iconSize = 24,
  }) : this._internal(
          key: key,
          icons: icons,
          activeIndex: activeIndex,
          onTap: onTap,
          height: height,
          elevation: elevation,
          splashRadius: splashRadius,
          splashSpeedInMilliseconds: splashSpeedInMilliseconds,
          backgroundColor: backgroundColor,
          splashColor: splashColor,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          borderRadius: borderRadius,
          iconSize: iconSize,
        );

  AnimatedBottomNavigationBar.builder({
    Key? key,
    required int itemCount,
    required IndexedWidgetBuilder tabBuilder,
    required int activeIndex,
    required Function(int) onTap,
    double height = 56,
    double elevation = 8,
    double splashRadius = 24,
    int splashSpeedInMilliseconds = 300,
    Color backgroundColor = Colors.white,
    Color splashColor = Colors.purple,
    BorderRadius borderRadius=BorderRadius.zero,
  }) : this._internal(
          key: key,
          tabBuilder: tabBuilder,
          itemCount: itemCount,
          activeIndex: activeIndex,
          onTap: onTap,
          height: height,
          elevation: elevation,
          splashRadius: splashRadius,
          splashSpeedInMilliseconds: splashSpeedInMilliseconds,
          backgroundColor: backgroundColor,
          splashColor: splashColor,
          borderRadius: borderRadius,
        );

  @override
  _AnimatedBottomNavigationBarState createState() =>
      _AnimatedBottomNavigationBarState();
}

class _AnimatedBottomNavigationBarState
    extends State<AnimatedBottomNavigationBar> with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  double _bubbleRadius = 0;
  double _iconScale = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AnimatedBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      _startBubbleAnimation();
    }
  }

  _startBubbleAnimation() {
    _bubbleController = AnimationController(
      duration: Duration(milliseconds: widget.splashSpeedInMilliseconds!),
      vsync: this,
    );

    final CurvedAnimation bubbleCurve = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.linear,
    );

    Tween<double>(begin: 0, end: 1).animate(bubbleCurve)
      ..addListener(() {
        setState(() {
          _bubbleRadius = widget.splashRadius! * bubbleCurve.value;
          if (_bubbleRadius == widget.splashRadius) {
            _bubbleRadius = 0;
          }

          if (bubbleCurve.value < 0.5) {
            _iconScale = 1 + bubbleCurve.value;
          } else {
            _iconScale = 2 - bubbleCurve.value;
          }
        },);
      },);

    if (_bubbleController.isAnimating) {
      _bubbleController.reset();
    }
    _bubbleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: widget.elevation!,
        borderRadius: widget.borderRadius,
        child: Container(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: _buildItems(),
          ),
      ),
    );
  }

  List<Widget> _buildItems() {
    final itemCount = widget.itemCount ?? widget.icons!.length;
    List<Widget> items = [];
    bool isActive = false;
    for (int i = 0; i < itemCount; i++) {
      isActive = i == widget.activeIndex;
      items.add(
        NavigationBarItem(
          isActive: isActive,
          bubbleRadius: _bubbleRadius,
          maxBubbleRadius: widget.splashRadius,
          bubbleColor: widget.splashColor,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
          child: widget.tabBuilder?.call(i, isActive),
          iconData: widget.icons?.elementAt(i),
          iconScale: _iconScale,
          iconSize: widget.iconSize,
          onTap: () => widget.onTap(i),
        ),
      );
    }
    return items;
  }
}
