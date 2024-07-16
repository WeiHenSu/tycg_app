import 'package:flutter/material.dart';
import 'package:tycg/configs/app_colors.dart';

class FabItem {
  const FabItem(this.title, this.icon, {required this.onPress});

  final IconData icon;
  final VoidCallback onPress;
  final String title;
}

class FabMenuItem extends StatelessWidget {
  const FabMenuItem(this.item, {Key? key}) : super(key: key);

  final FabItem item;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 16),
      color: sWhite,
      splashColor: sGrey.withOpacity(0.1),
      highlightColor: sGrey.withOpacity(0.1),
      elevation: 0,
      highlightElevation: 2,
      disabledColor: Colors.white,
      onPressed: () => item.onPress(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(item.title),
          const SizedBox(width: 8),
          Icon(item.icon, color: sPurple),
        ],
      ),
    );
  }
}

class ExpandedAnimationFab extends AnimatedWidget {
  const ExpandedAnimationFab({
    Key? key,
    required this.items,
    required this.onPress,
    required Animation<double> animation,
  }) : super(key: key, listenable: animation);

  final List<FabItem> items;
  final VoidCallback onPress;

  Animation<double> get _animation => listenable as Animation<double>;

  Widget buildItem(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;

    final transform = Matrix4.translationValues(
      -(screenWidth - _animation.value * screenWidth) *
          ((items.length - index) / 4),
      0.0,
      0.0,
    );

    return Align(
      alignment: Alignment.centerRight,
      child: Transform(
        transform: transform,
        child: Opacity(
          opacity: _animation.value,
          child: FabMenuItem(items[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          ignoring: _animation.value == 0,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 9),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: buildItem,
          ),
        ),
        FloatingActionButton(
          backgroundColor: sPurple,
          shape: const CircleBorder(),
          onPressed: onPress,
          child: AnimatedIcon(
            icon: AnimatedIcons.add_event,
            progress: _animation,
            color: sWhite,
          ),
        ),
      ],
    );
  }
}
