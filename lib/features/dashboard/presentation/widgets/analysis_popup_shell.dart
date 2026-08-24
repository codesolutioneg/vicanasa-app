import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shared chrome for Revenue / Expenses analysis bottom sheets.
class AnalysisPopupShell extends StatelessWidget {
  const AnalysisPopupShell({
    super.key,
    required this.title,
    required this.headerColor,
    required this.headerIcon,
    required this.scrollController,
    required this.children,
  });

  final String title;
  final Color headerColor;
  final IconData headerIcon;
  final ScrollController scrollController;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            color: headerColor,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Icon(headerIcon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAnalysisPopup(
  BuildContext context, {
  required String title,
  required Color headerColor,
  required IconData headerIcon,
  required List<Widget> Function(ScrollController scroll) body,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (_, scroll) => AnalysisPopupShell(
        title: title,
        headerColor: headerColor,
        headerIcon: headerIcon,
        scrollController: scroll,
        children: body(scroll),
      ),
    ),
  );
}
