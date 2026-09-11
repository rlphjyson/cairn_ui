import 'package:flutter/widgets.dart';

import '../../internal/anchored_overlay.dart';
import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../internal/popover_layer.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../menu/menu.dart';

/// The size of a [CairnSelect] trigger.
enum CairnSelectSize {
  /// `data-[size=sm]:h-8`.
  sm,

  /// `data-[size=default]:h-9`.
  md,
}

/// One option in a [CairnSelect].
@immutable
class CairnSelectOption<T> {
  /// Creates a select option.
  const CairnSelectOption({
    required this.value,
    required this.label,
    this.leading,
    this.enabled = true,
  });

  /// The value this option carries.
  final T value;

  /// The text shown in the trigger and the menu.
  final String label;

  /// An optional leading icon.
  final Widget? leading;

  /// Whether the option can be chosen.
  final bool enabled;
}

/// A dropdown value picker matching shadcn/ui's `Select`.
///
/// The trigger is `flex w-fit items-center justify-between gap-2 rounded-md
/// border border-input bg-transparent px-3 py-2 text-sm shadow-xs` at `h-9`,
/// with a `size-4 opacity-50` chevron.
///
/// The menu is `min-w-[8rem] rounded-md border bg-popover p-1 shadow-md`, and
/// is at least as wide as its trigger — shadcn/ui expresses that with
/// `min-w-[var(--radix-select-trigger-width)]`, which Cairn reproduces through
/// [CairnPopoverLayout]'s `matchAnchorWidth`.
///
/// The placeholder renders in `--muted-foreground` (`data-[placeholder]`), and
/// the selected row carries a trailing check at `size-3.5`.
///
/// ```dart
/// CairnSelect<String>(
///   value: framework,
///   placeholder: 'Select a framework',
///   options: const [
///     CairnSelectOption(value: 'flutter', label: 'Flutter'),
///     CairnSelectOption(value: 'react', label: 'React'),
///   ],
///   onChanged: (v) => setState(() => framework = v),
/// );
/// ```
class CairnSelect<T> extends StatefulWidget {
  /// Creates a select.
  const CairnSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select...',
    this.size = CairnSelectSize.md,
    this.width,
    this.maxMenuHeight = 320.0,
    this.hasError = false,
    this.focusNode,
    this.semanticLabel,
  });

  /// The available options.
  final List<CairnSelectOption<T>> options;

  /// The currently selected value.
  final T? value;

  /// Called when the user picks an option. Null disables the select.
  final ValueChanged<T>? onChanged;

  /// Text shown when nothing is selected.
  final String placeholder;

  /// The trigger height.
  final CairnSelectSize size;

  /// An optional fixed trigger width. Null sizes to content (`w-fit`).
  final double? width;

  /// How tall the menu may grow before scrolling.
  final double maxMenuHeight;

  /// Marks the control invalid.
  final bool hasError;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// The accessible name.
  final String? semanticLabel;

  @override
  State<CairnSelect<T>> createState() => _CairnSelectState<T>();
}

class _CairnSelectState<T> extends State<CairnSelect<T>> {
  final CairnOverlayController _controller = CairnOverlayController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onChanged != null;

  CairnSelectOption<T>? get _selected {
    for (final CairnSelectOption<T> o in widget.options) {
      if (o.value == widget.value) return o;
    }
    return null;
  }

  double get _height => widget.size == CairnSelectSize.sm ? 32.0 : 36.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final CairnSelectOption<T>? selected = _selected;

    return CairnAnchoredOverlay(
      controller: _controller,
      side: CairnSide.bottom,
      align: CairnAlign.start,
      offset: 4.0,
      matchAnchorWidth: true,
      anchor: CairnInteractive(
        enabled: _enabled,
        focusNode: widget.focusNode,
        onTap: _controller.toggle,
        semanticLabel: widget.semanticLabel,
        builder: (BuildContext context, CairnStates states) {
          final Color borderColor = widget.hasError
              ? theme.destructive
              : (states.focused ? theme.ring : theme.input);

          return Opacity(
            opacity: states.disabled ? 0.5 : 1.0,
            // `bg-transparent` in light mode: clip shadows to the exterior.
            child: CairnShadowed(
              borderRadius: BorderRadius.circular(theme.radiusScale.md),
              shadows: <BoxShadow>[
                ...CairnShadows.xs,
                if (states.focused)
                  ...(widget.hasError ? theme.invalidRing : theme.focusRing),
              ],
              child: AnimatedContainer(
                duration: CairnMotion.d150,
                curve: CairnMotion.standard,
                height: _height,
                width: widget.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: CairnSpacing.s3,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.input.withValues(
                          alpha: states.hovered ? 0.5 : 0.3,
                        )
                      : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(theme.radiusScale.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: widget.width == null
                      ? MainAxisSize.min
                      : MainAxisSize.max,
                  spacing: CairnSpacing.s2,
                  children: <Widget>[
                    if (selected?.leading != null)
                      IconTheme(
                        data: IconThemeData(
                          color: theme.mutedForeground,
                          size: 16,
                        ),
                        child: selected!.leading!,
                      ),
                    Flexible(
                      child: Text(
                        selected?.label ?? widget.placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              // `data-[placeholder]:text-muted-foreground`.
                              color: selected == null
                                  ? theme.mutedForeground
                                  : theme.foreground,
                            ),
                      ),
                    ),
                    // `size-4 opacity-50`.
                    Opacity(
                      opacity: 0.5,
                      child: CairnIcon(
                        CairnIconData.chevronDown,
                        color: theme.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      overlayBuilder: (BuildContext context) => CairnMenuPanel(
        maxHeight: widget.maxMenuHeight,
        children: <Widget>[
          for (final CairnSelectOption<T> option in widget.options)
            _SelectRow<T>(
              option: option,
              selected: option.value == widget.value,
              onTap: () {
                widget.onChanged?.call(option.value);
                _controller.close();
              },
            ),
        ],
      ),
    );
  }
}

/// One row in the open menu.
///
/// `py-1.5 pr-8 pl-2` — the 32px right padding reserves room for the check,
/// which is absolutely positioned at `right-2` in a `size-3.5` box.
class _SelectRow<T> extends StatelessWidget {
  const _SelectRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CairnSelectOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Stack(
      children: <Widget>[
        CairnMenuItem(
          enabled: option.enabled,
          onPressed: onTap,
          leading: option.leading,
          child: Padding(
            // Reserve `pr-8` for the check indicator.
            padding: const EdgeInsets.only(right: CairnSpacing.s6),
            child: Text(option.label),
          ),
        ),
        if (selected)
          Positioned(
            right: CairnSpacing.s2 + CairnSpacing.s1,
            top: 0,
            bottom: 0,
            child: Center(
              child: CairnIcon(
                CairnIconData.check,
                size: 14,
                color: theme.popoverForeground,
              ),
            ),
          ),
      ],
    );
  }
}
