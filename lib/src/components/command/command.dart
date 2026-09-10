import 'package:flutter/material.dart' show TextField, InputDecoration;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// One entry in a [CairnCommand] palette.
@immutable
class CairnCommandItem {
  /// Creates a command item.
  const CairnCommandItem({
    required this.label,
    required this.onSelected,
    this.group,
    this.icon,
    this.shortcut,
    this.keywords = const <String>[],
  });

  /// The item's visible label.
  final String label;

  /// Invoked when the item is chosen.
  final VoidCallback onSelected;

  /// An optional group heading this item belongs under.
  final String? group;

  /// An optional leading icon.
  final Widget? icon;

  /// A trailing keyboard hint.
  final String? shortcut;

  /// Extra terms that should match this item during filtering.
  ///
  /// cmdk supports the same concept, so "Sign out" can be found by typing
  /// "logout".
  final List<String> keywords;

  /// Whether this item matches [query].
  bool matches(String query) {
    if (query.isEmpty) return true;
    final String q = query.toLowerCase();
    if (label.toLowerCase().contains(q)) return true;
    if (group != null && group!.toLowerCase().contains(q)) return true;
    return keywords.any((String k) => k.toLowerCase().contains(q));
  }
}

/// A searchable command palette matching shadcn/ui's `Command` (cmdk).
///
/// The shell is `flex h-full w-full flex-col overflow-hidden rounded-md
/// bg-popover text-popover-foreground`. The search row is `flex h-9 items-center
/// gap-2 border-b px-3` with a `size-4 opacity-50` magnifier, the list is
/// `max-h-[300px] overflow-y-auto`, and the empty state is `py-6 text-center
/// text-sm`.
///
/// ## Keyboard model
///
/// cmdk keeps focus in the input at all times and moves a *highlight* through
/// the list with the arrow keys — the list items themselves are never focused.
/// Cairn does the same: arrow keys and Enter are intercepted above the text
/// field, so typing and navigating never fight each other.
///
/// ```dart
/// showCairnCommandPalette(
///   context: context,
///   items: [
///     CairnCommandItem(
///       label: 'New file',
///       group: 'Actions',
///       shortcut: 'Ctrl+N',
///       onSelected: () {},
///     ),
///   ],
/// );
/// ```
class CairnCommand extends StatefulWidget {
  /// Creates a command palette body.
  const CairnCommand({
    super.key,
    required this.items,
    this.placeholder = 'Type a command or search...',
    this.emptyMessage = 'No results found.',
    this.maxListHeight = 300.0,
    this.onDismiss,
    this.autofocus = true,
  });

  /// The available commands.
  final List<CairnCommandItem> items;

  /// The search field's placeholder.
  final String placeholder;

  /// Shown when nothing matches.
  final String emptyMessage;

  /// `max-h-[300px]`.
  final double maxListHeight;

  /// Called after an item is chosen, or on Escape.
  final VoidCallback? onDismiss;

  /// Whether the search field takes focus immediately.
  final bool autofocus;

  @override
  State<CairnCommand> createState() => _CairnCommandState();
}

class _CairnCommandState extends State<CairnCommand> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scroll = ScrollController();
  int _highlighted = 0;

  @override
  void dispose() {
    _query.dispose();
    _inputFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<CairnCommandItem> get _filtered => widget.items
      .where((CairnCommandItem i) => i.matches(_query.text))
      .toList(growable: false);

  void _move(int delta) {
    final List<CairnCommandItem> list = _filtered;
    if (list.isEmpty) return;
    setState(() {
      // Wraps, matching cmdk's `loop` behaviour.
      _highlighted = (_highlighted + delta) % list.length;
      if (_highlighted < 0) _highlighted += list.length;
    });
  }

  void _choose([int? index]) {
    final List<CairnCommandItem> list = _filtered;
    final int i = index ?? _highlighted;
    if (i < 0 || i >= list.length) return;
    list[i].onSelected();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<CairnCommandItem> list = _filtered;

    // Group headings are emitted whenever the group changes, matching how
    // cmdk renders `CommandGroup` blocks.
    String? lastGroup;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.enter): _ChooseIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): _ChooseIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
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
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              widget.onDismiss?.call();
              return null;
            },
          ),
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.popover,
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
            border: Border.all(color: theme.border),
            boxShadow: CairnShadows.lg,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // `flex h-9 items-center gap-2 border-b px-3`.
                Container(
                  height: 44.0,
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
                        child: TextField(
                          controller: _query,
                          focusNode: _inputFocus,
                          autofocus: widget.autofocus,
                          onChanged: (_) => setState(() => _highlighted = 0),
                          style: theme
                              .textStyle(CairnTypography.sm)
                              .copyWith(color: theme.foreground),
                          cursorColor: theme.foreground,
                          cursorWidth: 1.0,
                          decoration: InputDecoration.collapsed(
                            hintText: widget.placeholder,
                            hintStyle: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(color: theme.mutedForeground),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxListHeight),
                  child: list.isEmpty
                      ? Padding(
                          // `py-6 text-center text-sm`.
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
                          controller: _scroll,
                          padding: const EdgeInsets.symmetric(
                            vertical: CairnSpacing.s1,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              for (int i = 0; i < list.length; i++) ...<Widget>[
                                if (list[i].group != null &&
                                    list[i].group != lastGroup)
                                  Builder(
                                    builder: (BuildContext context) {
                                      lastGroup = list[i].group;
                                      return _GroupHeading(
                                        text: list[i].group!,
                                      );
                                    },
                                  ),
                                _CommandRow(
                                  item: list[i],
                                  highlighted: i == _highlighted,
                                  onTap: () => _choose(i),
                                  onHover: () =>
                                      setState(() => _highlighted = i),
                                ),
                              ],
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

/// A group heading — `px-2 py-1.5 text-xs font-medium text-muted-foreground`.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: CairnSpacing.s3,
        right: CairnSpacing.s3,
        top: CairnSpacing.s1p5,
        bottom: CairnSpacing.s1p5,
      ),
      child: Text(
        text,
        style: theme
            .textStyle(CairnTypography.xs)
            .copyWith(
              fontWeight: CairnTypography.medium,
              color: theme.mutedForeground,
            ),
      ),
    );
  }
}

/// One command row.
///
/// Highlighting is driven by `data-[selected=true]`, not `:hover`, because the
/// keyboard owns the highlight — so hovering *sets* the highlight rather than
/// painting a separate hover state.
class _CommandRow extends StatelessWidget {
  const _CommandRow({
    required this.item,
    required this.highlighted,
    required this.onTap,
    required this.onHover,
  });

  final CairnCommandItem item;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return MouseRegion(
      onEnter: (_) => onHover(),
      cursor: SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
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
              if (item.icon != null)
                IconTheme(
                  data: IconThemeData(color: theme.mutedForeground, size: 16),
                  child: SizedBox.square(dimension: 16, child: item.icon),
                ),
              Expanded(
                child: Text(
                  item.label,
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
              if (item.shortcut != null)
                Text(
                  item.shortcut!,
                  style: theme
                      .textStyle(CairnTypography.xs)
                      .copyWith(
                        color: theme.mutedForeground,
                        letterSpacing: CairnTypography.trackingWidest(12),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Moves the command palette highlight.
class _MoveIntent extends Intent {
  const _MoveIntent(this.delta);

  final int delta;
}

/// Activates the highlighted command.
class _ChooseIntent extends Intent {
  const _ChooseIntent();
}

/// Shows a [CairnCommand] as a centred modal.
///
/// shadcn/ui's `CommandDialog` renders the palette inside a Dialog with
/// `overflow-hidden p-0`, i.e. the palette provides its own chrome.
Future<void> showCairnCommandPalette({
  required BuildContext context,
  required List<CairnCommandItem> items,
  String placeholder = 'Type a command or search...',
  String emptyMessage = 'No results found.',
}) {
  final CairnTheme theme = CairnTheme.of(context);
  return Navigator.of(context, rootNavigator: true).push<void>(
    _CommandRoute(
      barrierColor: theme.overlay,
      builder: (BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(CairnSpacing.s4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: CairnCommand(
              items: items,
              placeholder: placeholder,
              emptyMessage: emptyMessage,
              onDismiss: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The route used by [showCairnCommandPalette].
class _CommandRoute extends PopupRoute<void> {
  _CommandRoute({required this.builder, required this.barrierColor});

  final WidgetBuilder builder;

  @override
  final Color barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => CairnMotion.d200;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => SafeArea(child: Builder(builder: builder));

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurvedAnimation curved = CurvedAnimation(
      parent: animation,
      curve: CairnMotion.easeOut,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}
