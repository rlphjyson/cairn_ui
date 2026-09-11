import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A one-time-code field.
///
/// Each slot is `h-9 w-9 border-y border-r border-input text-sm shadow-xs`,
/// with `first:rounded-l-md first:border-l last:rounded-r-md` — so the group
/// reads as a single joined control with **no doubled borders** between slots,
/// which is what the `border-r`-only rule achieves.
///
/// The active slot gets `border-ring ring-[3px] ring-ring/50` and shows a
/// blinking caret (`h-4 w-px animate-caret-blink duration-1000`).
///
/// ## Implementation note
///
/// This is a single hidden [EditableText] behind a row of painted slots, not
/// one field per digit. Per-digit fields break paste, break the platform's SMS
/// autofill, and make backspace behave strangely — all of which the real
/// `input-otp` library also avoids by using one input.
///
/// ```dart
/// CairnInputOtp(
///   length: 6,
///   onCompleted: (code) => verify(code),
/// );
/// ```
class CairnInputOtp extends StatefulWidget {
  /// Creates a one-time-code field.
  const CairnInputOtp({
    super.key,
    this.length = 6,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.hasError = false,
    this.groupSizes,
    this.autofocus = false,
  }) : assert(length > 0, 'length must be positive');

  /// How many digits the code has.
  final int length;

  /// Controls the entered value.
  final TextEditingController? controller;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// Called whenever the value changes.
  final ValueChanged<String>? onChanged;

  /// Called once the full code has been entered.
  final ValueChanged<String>? onCompleted;

  /// Whether input is accepted.
  final bool enabled;

  /// Marks the control invalid.
  final bool hasError;

  /// Optional slot grouping, e.g. `[3, 3]` renders `123-456` with a gap.
  ///
  /// Must sum to [length]. Null renders one continuous group.
  final List<int>? groupSizes;

  /// Whether to take focus on first build.
  final bool autofocus;

  @override
  State<CairnInputOtp> createState() => _CairnInputOtpState();
}

class _CairnInputOtpState extends State<CairnInputOtp> {
  TextEditingController? _internalController;
  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode? _internalFocus;
  FocusNode get _focus => widget.focusNode ?? (_internalFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _focus.removeListener(_onFocusChanged);
    _internalController?.dispose();
    _internalFocus?.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onChanged?.call(_controller.text);
    if (_controller.text.length == widget.length) {
      widget.onCompleted?.call(_controller.text);
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  /// Slot indices split into visual groups.
  List<List<int>> get _groups {
    final List<int> sizes = widget.groupSizes ?? <int>[widget.length];
    final List<List<int>> out = <List<int>>[];
    int cursor = 0;
    for (final int size in sizes) {
      out.add(<int>[for (int i = 0; i < size; i++) cursor + i]);
      cursor += size;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String value = _controller.text;
    final int activeIndex = value.length.clamp(0, widget.length - 1);
    final bool focused = _focus.hasFocus;

    return Semantics(
      label: 'One-time code',
      textField: true,
      child: GestureDetector(
        onTap: widget.enabled ? _focus.requestFocus : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: Stack(
            children: <Widget>[
              // The real, invisible input. Zero-sized rather than
              // Offstage/Visibility so it can still hold focus and receive IME
              // and autofill events.
              SizedBox(
                width: 0,
                height: 0,
                child: EditableText(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  readOnly: !widget.enabled,
                  style: const TextStyle(fontSize: 1),
                  cursorColor: const Color(0x00000000),
                  backgroundCursorColor: const Color(0x00000000),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int g = 0; g < _groups.length; g++) ...<Widget>[
                    if (g > 0) const SizedBox(width: CairnSpacing.s2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final int i in _groups[g])
                          _Slot(
                            char: i < value.length ? value[i] : null,
                            active: focused && i == activeIndex,
                            isFirst: i == _groups[g].first,
                            isLast: i == _groups[g].last,
                            hasError: widget.hasError,
                            theme: theme,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One digit slot.
class _Slot extends StatelessWidget {
  const _Slot({
    required this.char,
    required this.active,
    required this.isFirst,
    required this.isLast,
    required this.hasError,
    required this.theme,
  });

  final String? char;
  final bool active;
  final bool isFirst;
  final bool isLast;
  final bool hasError;
  final CairnTheme theme;

  /// `h-9 w-9`.
  static const double _size = 36.0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = theme.brightness == Brightness.dark;
    final Color borderColor = hasError
        ? theme.destructive
        : (active ? theme.ring : theme.input);
    final double radius = theme.radiusScale.md;

    final BorderRadius shape = BorderRadius.horizontal(
      left: isFirst ? Radius.circular(radius) : Radius.zero,
      right: isLast ? Radius.circular(radius) : Radius.zero,
    );

    // Slots are `bg-transparent` in light mode, so the active slot's 3px ring
    // has to be clipped outside the slot or it floods the digit.
    return CairnShadowed(
      borderRadius: shape,
      shadows: <BoxShadow>[
        ...CairnShadows.xs,
        if (active) ...(hasError ? theme.invalidRing : theme.focusRing),
      ],
      child: AnimatedContainer(
        duration: CairnMotion.d150,
        curve: CairnMotion.standard,
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? theme.input.withOpacityModifier(0.3)
              : const Color(0x00000000),
          // Only the first slot draws a left border, so adjacent slots share one
          // hairline instead of stacking two.
          border: Border(
            top: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            left: isFirst ? BorderSide(color: borderColor) : BorderSide.none,
          ),
          borderRadius: shape,
        ),
        child: char != null
            ? Text(
                char!,
                style: theme
                    .textStyle(CairnTypography.sm)
                    .copyWith(color: theme.foreground),
              )
            : (active ? _Caret(color: theme.foreground) : null),
      ),
    );
  }
}

/// The blinking caret in the active slot — `h-4 w-px animate-caret-blink`.
class _Caret extends StatefulWidget {
  const _Caret({required this.color});

  final Color color;

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    // `duration-1000`.
    duration: CairnMotion.d1000,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget bar = Container(width: 1, height: 16, color: widget.color);

    // A blinking caret never settles, so reduce-motion (and golden tests, which
    // set it) get a solid caret instead.
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion && _controller.isAnimating) {
      _controller.stop();
      return bar;
    }
    if (reduceMotion) return bar;

    return FadeTransition(opacity: _controller, child: bar);
  }
}
