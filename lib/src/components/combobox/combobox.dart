import 'package:flutter/material.dart'
    show InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart';
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
import '../select/select.dart';

/// A searchable select matching shadcn/ui's `Combobox` recipe.
///
/// Like the Date Picker, shadcn/ui documents this as a composition rather than
/// shipping it: a Popover holding a Command list, triggered by an outline
/// Button that shows the chosen label and a `chevrons-up-down` glyph at 50%
/// opacity.
///
/// Cairn packages the same composition. Filtering, highlight-follows-keyboard
/// and Enter-to-choose all behave as in [CairnCommand], because a combobox is
/// really a command palette bound to a value.
///
/// ```dart
/// CairnCombobox<String>(
///   value: framework,
///   options: const [
///     CairnSelectOption(value: 'flutter', label: 'Flutter'),
///     CairnSelectOption(value: 'svelte', label: 'Svelte'),
///   ],
///   onChanged: (v) => setState(() => framework = v),
/// );
/// ```
class CairnCombobox<T> extends StatefulWidget {
  /// Creates a combobox.
  const CairnCombobox({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select...',
    this.searchPlaceholder = 'Search...',
    this.emptyMessage = 'No results found.',
    this.width = 240.0,
    this.maxMenuHeight = 280.0,
    this.hasError = false,
  });

  /// The available options.
  final List<CairnSelectOption<T>> options;

  /// The selected value.
  final T? value;

  /// Called when an option is chosen.
  final ValueChanged<T>? onChanged;

  /// The trigger's text when nothing is selected.
  final String placeholder;

  /// The search field's placeholder.
  final String searchPlaceholder;

  /// Shown when the filter matches nothing.
  final String emptyMessage;

  /// The trigger width. The menu matches it.
  final double width;

  /// How tall the option list may grow.
  final double maxMenuHeight;

  /// Marks the control invalid.
  final bool hasError;

  @override
  State<CairnCombobox<T>> createState() => _CairnComboboxState<T>();
}

class _CairnComboboxState<T> extends State<CairnCombobox<T>> {
  final CairnOverlayController _controller = CairnOverlayController();
  final TextEditingController _query = TextEditingController();
  int _highlighted = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onOpenChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onOpenChanged);
    _controller.dispose();
    _query.dispose();
    super.dispose();
  }

  /// Reset the filter each time the menu opens, matching cmdk.
  void _onOpenChanged() {
    if (!_controller.isOpen) return;
    _query.clear();
    _highlighted = 0;
  }

  List<CairnSelectOption<T>> get _filtered {
    final String q = _query.text.toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options
        .where((CairnSelectOption<T> o) => o.label.toLowerCase().contains(q))
        .toList(growable: false);
  }

  CairnSelectOption<T>? get _selected {
    for (final CairnSelectOption<T> o in widget.options) {
      if (o.value == widget.value) return o;
    }
    return null;
  }

  void _move(int delta) {
    final int length = _filtered.length;
    if (length == 0) return;
    setState(() {
      _highlighted = (_highlighted + delta) % length;
      if (_highlighted < 0) _highlighted += length;
    });
  }

  void _choose([int? index]) {
    final List<CairnSelectOption<T>> list = _filtered;
    final int i = index ?? _highlighted;
    if (i < 0 || i >= list.length || !list[i].enabled) return;
    widget.onChanged?.call(list[i].value);
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool enabled = widget.onChanged != null;

    return CairnAnchoredOverlay(
      controller: _controller,
      side: CairnSide.bottom,
      align: CairnAlign.start,
      offset: 4.0,
      matchAnchorWidth: true,
      anchor: CairnInteractive(
        enabled: enabled,
        onTap: _controller.toggle,
        semanticLabel: widget.placeholder,
        builder: (BuildContext context, CairnStates states) {
          final Color borderColor = widget.hasError
              ? theme.destructive
              : (states.focused ? theme.ring : theme.input);

          return Opacity(
            opacity: enabled ? 1.0 : 0.5,
            // `bg-transparent` at rest: clip shadows to the exterior.
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
                height: 36.0,
                width: widget.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: CairnSpacing.s3,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.input.withValues(
                          alpha: states.hovered ? 0.5 : 0.3,
                        )
                      : (states.hovered
                            ? theme.accent
                            : const Color(0x00000000)),
                  borderRadius: BorderRadius.circular(theme.radiusScale.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  spacing: CairnSpacing.s2,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selected?.label ?? widget.placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              color: _selected == null
                                  ? theme.mutedForeground
                                  : theme.foreground,
                            ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: CairnIcon(
                        CairnIconData.chevronsUpDown,
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
      overlayBuilder: (BuildContext context) => _buildMenu(theme),
    );
  }

  Widget _buildMenu(CairnTheme theme) {
    final List<CairnSelectOption<T>> list = _filtered;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.enter): _ChooseIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): _ChooseIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _MoveIntent: CallbackAction<_MoveIntent>(
            onInvoke: (_MoveIntent i) {
              _move(i.delta);
              return null;
            },
          ),
          _ChooseIntent: CallbackAction<_ChooseIntent>(
            onInvoke: (_) {
              _choose();
              return null;
            },
          ),
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.popover,
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
            border: Border.all(color: theme.border),
            boxShadow: CairnShadows.md,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: CairnSpacing.s3,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: theme.border)),
                  ),
                  child: Row(
                    spacing: CairnSpacing.s2,
                    children: <Widget>[
                      Opacity(
                        opacity: 0.5,
                        child: CairnIcon(
                          CairnIconData.search,
                          color: theme.foreground,
                        ),
                      ),
                      Expanded(
                        // See CairnInput on why the Material is supplied here.
                        child: Material(
                          type: MaterialType.transparency,
                          child: TextField(
                            controller: _query,
                            autofocus: true,
                            onChanged: (_) => setState(() => _highlighted = 0),
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(color: theme.foreground),
                            cursorColor: theme.foreground,
                            cursorWidth: 1.0,
                            decoration: InputDecoration.collapsed(
                              hintText: widget.searchPlaceholder,
                              hintStyle: theme
                                  .textStyle(CairnTypography.sm)
                                  .copyWith(color: theme.mutedForeground),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxMenuHeight),
                  child: list.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: CairnSpacing.s6,
                          ),
                          child: Text(
                            widget.emptyMessage,
                            textAlign: TextAlign.center,
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(color: theme.mutedForeground),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            vertical: CairnSpacing.s1,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              for (int i = 0; i < list.length; i++)
                                _ComboRow<T>(
                                  option: list[i],
                                  highlighted: i == _highlighted,
                                  selected: list[i].value == widget.value,
                                  onTap: () => _choose(i),
                                  onHover: () =>
                                      setState(() => _highlighted = i),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One option row in the combobox menu.
class _ComboRow<T> extends StatelessWidget {
  const _ComboRow({
    required this.option,
    required this.highlighted,
    required this.selected,
    required this.onTap,
    required this.onHover,
  });

  final CairnSelectOption<T> option;
  final bool highlighted;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return MouseRegion(
      onEnter: (_) => onHover(),
      cursor: SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: option.enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: option.enabled ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: CairnMotion.d100,
            margin: const EdgeInsets.symmetric(horizontal: CairnSpacing.s1),
            padding: const EdgeInsets.symmetric(
              horizontal: CairnSpacing.s2,
              vertical: CairnSpacing.s1p5,
            ),
            decoration: BoxDecoration(
              color: highlighted ? theme.accent : const Color(0x00000000),
              borderRadius: BorderRadius.circular(theme.radiusScale.sm),
            ),
            child: Row(
              spacing: CairnSpacing.s2,
              children: <Widget>[
                // The check occupies its slot even when unselected, so labels
                // do not shift as the selection moves.
                SizedBox.square(
                  dimension: 16,
                  child: selected
                      ? CairnIcon(
                          CairnIconData.check,
                          size: 16,
                          color: theme.popoverForeground,
                        )
                      : null,
                ),
                Expanded(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(
                          color: highlighted
                              ? theme.accentForeground
                              : theme.popoverForeground,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Moves the combobox highlight.
class _MoveIntent extends Intent {
  const _MoveIntent(this.delta);

  final int delta;
}

/// Chooses the highlighted option.
class _ChooseIntent extends Intent {
  const _ChooseIntent();
}
