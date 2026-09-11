import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bacassistant/utils/system_ui.dart';

class WrapAppBar extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? leftButton;
  final Widget? rightButton;

  const WrapAppBar({
    super.key,
    required this.child,
    this.title,
    this.leftButton,
    this.rightButton,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyleFor(
        colorScheme,
        brightness: Theme.of(context).brightness,
        barColor: colorScheme.surface,
      ),
      child: ColoredBox(
        color: colorScheme.surface,
        child: SafeArea(
          child: Stack(
            children: [
              child,
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: SizedBox(
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (title != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.78),
                            border:
                                Border.all(color: colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            title!,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: leftButton ??
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                textDirection: TextDirection.ltr,
                              ),
                              color: colorScheme.onSurface,
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    colorScheme.surface.withValues(alpha: 0.78),
                                side: BorderSide(
                                  color: colorScheme.outlineVariant,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                      ),
                      if (rightButton != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: rightButton,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
