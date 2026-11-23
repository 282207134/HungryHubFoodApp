import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hub_state.dart';

const orange = Color(0xFFF07A10);
const gold = Color(0xFFFFBA00);
const pageInset = EdgeInsets.symmetric(horizontal: 16);
const cardRadius = BorderRadius.all(Radius.circular(10));

ThemeData hubTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final paper = dark ? const Color(0xFF121212) : Colors.white;
  final ink = dark ? Colors.white : const Color(0xFF030303);
  final muted = dark ? const Color(0xFF8A8D9E) : const Color(0xFF3C3C3C);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(seedColor: orange, brightness: brightness)
        .copyWith(
          primary: orange,
          surface: paper,
          onSurface: ink,
          onSurfaceVariant: muted,
          outline: dark ? const Color(0xFF3F3F3F) : const Color(0xFFD9D9D9),
          surfaceContainerLow: dark
              ? const Color(0xFF222222)
              : const Color(0xFFF8F8F8),
        ),
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: paper,
    dividerColor: dark ? const Color(0xFF3F3F3F) : const Color(0xFFE7E7E7),
    visualDensity: VisualDensity.standard,
  );
}

extension HubColors on BuildContext {
  ColorScheme get palette => Theme.of(this).colorScheme;
  Color get ink => palette.onSurface;
  Color get muted => palette.onSurfaceVariant;
  Color get paper => palette.surface;
  Color get soft => palette.surfaceContainerLow;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class Label extends StatelessWidget {
  const Label(
    this.text, {
    super.key,
    this.size = 14,
    this.weight = FontWeight.w400,
    this.color,
    this.maxLines,
    this.align,
    this.italic = false,
  });

  final String text;
  final double size;
  final FontWeight weight;
  final Color? color;
  final int? maxLines;
  final TextAlign? align;
  final bool italic;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
    textAlign: align,
    style: TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color ?? context.ink,
      height: 1.5,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    ),
  );
}

class Photo extends StatelessWidget {
  const Photo(
    this.file, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });
  final String file;
  final BoxFit fit;
  final double? width, height;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$file',
    width: width,
    height: height,
    fit: fit,
    excludeFromSemantics: true,
  );
}

class HubButton extends StatelessWidget {
  const HubButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.outlined = false,
    this.height = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final active = !outlined && onPressed != null;
    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: padding,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(borderRadius: cardRadius),
          backgroundColor: active
              ? orange
              : context.soft.withValues(alpha: .48),
          foregroundColor: active ? Colors.white : context.muted,
          disabledForegroundColor: context.muted,
          side: active
              ? BorderSide.none
              : BorderSide(color: context.palette.outline),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class ActionIcon extends StatelessWidget {
  const ActionIcon(
    this.icon,
    this.label, {
    super.key,
    required this.onTap,
    this.color,
    this.size = 24,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: label,
    icon: Icon(icon, size: size, color: color ?? context.ink),
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
    style: IconButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );
}

class HubPage extends StatelessWidget {
  const HubPage({super.key, required this.children, this.footer, this.tab});

  final List<Widget> children;
  final Widget? footer;
  final HubTab? tab;

  @override
  Widget build(BuildContext context) {
    final system = MediaQuery.viewPaddingOf(context);
    return HubScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  top: math.max(0, 78 - system.top),
                  bottom: 10,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: children,
              ),
            ),
            if (footer != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  tab == null ? math.max(system.bottom, 24) + 24 : 30,
                ),
                child: SizedBox(width: double.infinity, child: footer),
              ),
            if (tab != null) HubNav(active: tab!),
          ],
        ),
      ),
    );
  }
}

class HubScaffold extends StatelessWidget {
  const HubScaffold({
    super.key,
    required this.body,
    this.background,
    this.overlay,
  });
  final Widget body;
  final Color? background;
  final SystemUiOverlayStyle? overlay;

  @override
  Widget build(BuildContext context) {
    final icons = context.isDark ? Brightness.light : Brightness.dark;
    final style =
        (overlay ??
                SystemUiOverlayStyle(
                  statusBarIconBrightness: icons,
                  statusBarBrightness: context.isDark
                      ? Brightness.dark
                      : Brightness.light,
                  systemNavigationBarIconBrightness: icons,
                ))
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarContrastEnforced: false,
            );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: Scaffold(backgroundColor: background, body: body),
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.onBell, this.onBack});
  final String title;
  final VoidCallback? onBell, onBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: pageInset,
    child: SizedBox(
      height: 24,
      child: Row(
        children: [
          if (onBack != null) ...[
            ActionIcon(
              Icons.arrow_back_ios_new_rounded,
              'Back',
              onTap: onBack!,
              size: 18,
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Label(title, size: 16, weight: FontWeight.w500, maxLines: 1),
          ),
          if (onBell != null)
            ActionIcon(
              Icons.notifications_none_rounded,
              'Notifications',
              onTap: onBell!,
            ),
        ],
      ),
    ),
  );
}

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key, required this.onBell, this.onLocation});
  final VoidCallback onBell;
  final VoidCallback? onLocation;

  @override
  Widget build(BuildContext context) => Padding(
    padding: pageInset,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InkWell(
            onTap: onLocation,
            borderRadius: cardRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: orange,
                      size: 16,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Label(
                        'Your Location',
                        color: context.muted,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const Label(
                  'Karachi | Pakistan',
                  size: 20,
                  weight: FontWeight.w500,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        ActionIcon(
          Icons.notifications_none_rounded,
          'Notifications',
          onTap: onBell,
        ),
      ],
    ),
  );
}

class HubField extends StatefulWidget {
  const HubField(
    this.hint, {
    super.key,
    required this.controller,
    this.password = false,
    this.reveal = false,
    this.keyboard,
    this.prefix,
    this.highlight = false,
  });
  final String hint;
  final TextEditingController controller;
  final bool password, reveal, highlight;
  final TextInputType? keyboard;
  final Widget? prefix;

  @override
  State<HubField> createState() => _HubFieldState();
}

class _HubFieldState extends State<HubField> {
  final focus = FocusNode();
  late bool show = widget.reveal;

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([focus, widget.controller]),
    builder: (context, _) {
      final focused = focus.hasFocus;
      final filled = focused || widget.controller.text.isNotEmpty;
      return Container(
        constraints: const BoxConstraints(minHeight: 64),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? context.soft : context.soft.withValues(alpha: .35),
          borderRadius: cardRadius,
          border: Border.all(
            color: filled ? Colors.transparent : context.palette.outline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            if (focused || widget.highlight)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: 2,
                child: ColoredBox(color: orange),
              ),
            TextField(
              controller: widget.controller,
              focusNode: focus,
              keyboardType: widget.keyboard,
              obscureText: widget.password && !show,
              autocorrect: !widget.password,
              enableSuggestions: !widget.password,
              cursorColor: orange,
              style: TextStyle(color: context.ink, fontSize: 14, height: 1.5),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
                hintText: widget.hint,
                hintStyle: TextStyle(color: context.muted, fontSize: 14),
                prefixIcon: widget.prefix,
                suffixIcon: widget.password
                    ? ActionIcon(
                        show
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        show ? 'Hide password' : 'Show password',
                        color: context.muted,
                        onTap: () => setState(() => show = !show),
                      )
                    : null,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ChoiceRow extends StatelessWidget {
  const ChoiceRow(
    this.text, {
    super.key,
    required this.onTap,
    this.selected = false,
    this.detail,
  });
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final String? detail;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected
          ? orange.withValues(alpha: context.isDark ? .15 : .08)
          : context.soft.withValues(alpha: .35),
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: selected ? orange : context.palette.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: Container(
          constraints: BoxConstraints(minHeight: detail == null ? 56 : 83),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label(text, color: context.muted),
                    if (detail != null) ...[
                      const SizedBox(height: 4),
                      Label(detail!, color: context.muted, size: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? orange : context.muted,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class HubNav extends StatelessWidget {
  const HubNav({super.key, required this.active});
  final HubTab active;

  @override
  Widget build(BuildContext context) {
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 24.0);
    final colors = context.palette;
    return SizedBox(
      height: 103 + bottom,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _NavPainter(colors.surface, colors.outline),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            top: 39,
            child: Row(
              children: [
                _tab(
                  context,
                  HubTab.home,
                  Icons.home_outlined,
                  Icons.home_rounded,
                  'Home',
                ),
                _tab(
                  context,
                  HubTab.search,
                  Icons.search,
                  Icons.manage_search,
                  'Search',
                ),
                const Spacer(),
                _tab(
                  context,
                  HubTab.nearby,
                  Icons.location_on_outlined,
                  Icons.location_on_rounded,
                  'Nearby',
                ),
                _tab(
                  context,
                  HubTab.profile,
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  'Profile',
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: orange,
              elevation: 2,
              shape: CircleBorder(
                side: BorderSide(color: colors.surface, width: 3),
              ),
              child: SizedBox(
                width: 54,
                height: 54,
                child: ActionIcon(
                  Icons.shopping_bag_outlined,
                  'Cart',
                  onTap: () => context.goTab(HubTab.cart),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    HubTab tab,
    IconData icon,
    IconData selected,
    String name,
  ) => Expanded(
    child: ActionIcon(
      active == tab ? selected : icon,
      name,
      onTap: () => context.goTab(tab),
      color: active == tab ? orange : context.ink,
    ),
  );
}

class _NavPainter extends CustomPainter {
  const _NavPainter(this.surface, this.outline);
  final Color surface, outline;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 2;
    final path = Path()
      ..moveTo(0, 24)
      ..lineTo(c - 46, 24)
      ..cubicTo(c - 24, 24, c - 29, 56, c, 56)
      ..cubicTo(c + 29, 56, c + 24, 24, c + 46, 24)
      ..lineTo(size.width, 24)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawShadow(path, outline, 3, false);
    canvas.drawPath(path, Paint()..color = surface);
  }

  @override
  bool shouldRepaint(_NavPainter old) =>
      old.surface != surface || old.outline != outline;
}

void feedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}
