import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'sidebar_menu_item.dart';

class SidebarExpandableSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<SidebarMenuItem> children;

  const SidebarExpandableSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  State<SidebarExpandableSection> createState() =>
      _SidebarExpandableSectionState();
}

class _SidebarExpandableSectionState extends State<SidebarExpandableSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _rotationAnimation =
        Tween<double>(begin: 0, end: 0.5).animate(_expandAnimation);
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(widget.icon, color: AppColors.secondary),
          title: Text(
            widget.title,
            style:
                const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          trailing: RotationTransition(
            turns: _rotationAnimation,
            child: const Icon(Icons.keyboard_arrow_down,
                color: AppColors.secondary),
          ),
          onTap: _toggleExpand,
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: 1.0,
          child: Column(children: widget.children),
        ),
      ],
    );
  }
}
