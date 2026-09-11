import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The severity of a [CairnToast].
enum CairnToastVariant {
  /// A neutral message.
  normal,

  /// A success confirmation, with a check icon.
  success,

  /// An error, styled with the destructive token.
  error,

  /// An informational note.
  info,
}

/// A transient notification.
///
/// A toast is `rounded-md border bg-popover p-4 text-popover-foreground
/// shadow-lg`, stacked bottom-right, sliding in from the edge and
/// auto-dismissing after four seconds — long enough to read a sentence, short
/// enough that a burst of them clears.
///
/// ## Where the stack lives
///
/// Toasts must outlive the widget that triggered them — a toast fired from a
/// screen that then pops must still finish showing. [CairnToaster] therefore
/// owns an [OverlayEntry] on the root overlay, not a widget in the caller's
/// subtree, and [CairnToast.show] finds it through the [Overlay] rather than an
/// inherited widget.
@immutable
class CairnToast {
  /// Creates a toast description.
  const CairnToast({
    required this.title,
    this.description,
    this.variant = CairnToastVariant.normal,
    this.duration = const Duration(seconds: 4),
    this.action,
    this.onActionPressed,
  });

  /// The heading — `text-sm font-medium`.
  final String title;

  /// Optional supporting text — `text-sm text-muted-foreground`.
  final String? description;

  /// The severity.
  final CairnToastVariant variant;

  /// How long before it dismisses itself.
  final Duration duration;

  /// An optional action label.
  final String? action;

  /// Called when the action is pressed.
  final VoidCallback? onActionPressed;

  /// Shows this toast in the nearest root [Overlay].
  ///
  /// Returns once the toast has been queued; it dismisses itself.
  static void show(BuildContext context, CairnToast toast) {
    _CairnToasterState.of(context)?.push(toast);
  }
}

/// Hosts the toast stack.
///
/// Place once, above the rest of the app:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => CairnToaster(child: child!),
///   home: const HomeScreen(),
/// );
/// ```
class CairnToaster extends StatefulWidget {
  /// Creates a toast host.
  const CairnToaster({
    super.key,
    required this.child,
    this.alignment = Alignment.bottomRight,
    this.maxVisible = 3,
    this.width = 356.0,
  });

  /// The app below the toast layer.
  final Widget child;

  /// Where the stack sits. Sonner defaults to bottom-right.
  final Alignment alignment;

  /// How many toasts are shown at once before the oldest is dropped.
  final int maxVisible;

  /// Sonner's toast width.
  final double width;

  @override
  State<CairnToaster> createState() => _CairnToasterState();
}

class _CairnToasterState extends State<CairnToaster> {
  final List<_ToastEntry> _entries = <_ToastEntry>[];

  /// Finds the nearest toaster state.
  static _CairnToasterState? of(BuildContext context) =>
      context.findAncestorStateOfType<_CairnToasterState>();

  @override
  void dispose() {
    for (final _ToastEntry e in _entries) {
      e.timer?.cancel();
    }
    super.dispose();
  }

  void push(CairnToast toast) {
    final _ToastEntry entry = _ToastEntry(toast: toast, key: UniqueKey());
    setState(() {
      _entries.add(entry);
      // Drop the oldest once the stack is full.
      while (_entries.length > widget.maxVisible) {
        final _ToastEntry dropped = _entries.removeAt(0);
        dropped.timer?.cancel();
      }
    });

    entry.timer = Timer(toast.duration, () => _dismiss(entry));
  }

  void _dismiss(_ToastEntry entry) {
    entry.timer?.cancel();
    if (!mounted) return;
    setState(() => _entries.remove(entry));
  }

  @override
  Widget build(BuildContext context) {
    final bool bottom = widget.alignment.y > 0;

    return Stack(
      children: <Widget>[
        widget.child,
        Positioned.fill(
          child: SafeArea(
            child: IgnorePointer(
              // Only the toasts themselves take pointer events; the rest of
              // this layer must stay transparent to clicks.
              ignoring: _entries.isEmpty,
              child: Align(
                alignment: widget.alignment,
                child: Padding(
                  padding: const EdgeInsets.all(CairnSpacing.s4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: CairnSpacing.s2,
                    children: <Widget>[
                      for (final _ToastEntry e
                          in bottom ? _entries : _entries.reversed)
                        _ToastCard(
                          key: e.key,
                          toast: e.toast,
                          width: widget.width,
                          fromBottom: bottom,
                          onDismiss: () => _dismiss(e),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A queued toast plus its auto-dismiss timer.
class _ToastEntry {
  _ToastEntry({required this.toast, required this.key});

  final CairnToast toast;
  final Key key;
  Timer? timer;
}

/// One rendered toast.
class _ToastCard extends StatefulWidget {
  const _ToastCard({
    super.key,
    required this.toast,
    required this.width,
    required this.fromBottom,
    required this.onDismiss,
  });

  final CairnToast toast;
  final double width;
  final bool fromBottom;
  final VoidCallback onDismiss;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: CairnMotion.d300,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    final (
      CairnIconData? icon,
      Color iconColor,
    ) = switch (widget.toast.variant) {
      CairnToastVariant.normal => (null, theme.foreground),
      CairnToastVariant.success => (
        CairnIconData.circleCheck,
        theme.foreground,
      ),
      CairnToastVariant.error => (CairnIconData.alert, theme.destructive),
      CairnToastVariant.info => (CairnIconData.info, theme.mutedForeground),
    };

    final CurvedAnimation curved = CurvedAnimation(
      parent: _controller,
      curve: CairnMotion.easeOut,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, widget.fromBottom ? 1 : -1),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(
        opacity: curved,
        child: Semantics(
          liveRegion: true,
          label: widget.toast.description == null
              ? widget.toast.title
              : '${widget.toast.title}. ${widget.toast.description}',
          child: Container(
            width: widget.width,
            padding: const EdgeInsets.all(CairnSpacing.s4),
            decoration: BoxDecoration(
              color: theme.popover,
              borderRadius: BorderRadius.circular(theme.radiusScale.md),
              border: Border.all(color: theme.border),
              boxShadow: CairnShadows.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s3,
              children: <Widget>[
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: CairnIcon(icon, color: iconColor),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: CairnSpacing.s1,
                    children: <Widget>[
                      Text(
                        widget.toast.title,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              fontWeight: CairnTypography.medium,
                              color: theme.popoverForeground,
                            ),
                      ),
                      if (widget.toast.description != null)
                        Text(
                          widget.toast.description!,
                          style: theme
                              .textStyle(CairnTypography.sm)
                              .copyWith(color: theme.mutedForeground),
                        ),
                    ],
                  ),
                ),
                if (widget.toast.action != null)
                  CairnInteractive(
                    onTap: () {
                      widget.toast.onActionPressed?.call();
                      widget.onDismiss();
                    },
                    semanticLabel: widget.toast.action,
                    builder: (BuildContext context, CairnStates states) =>
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: CairnSpacing.s3,
                            vertical: CairnSpacing.s1p5,
                          ),
                          decoration: BoxDecoration(
                            color: states.hovered
                                ? theme.primary.withValues(alpha: 0.9)
                                : theme.primary,
                            borderRadius: BorderRadius.circular(
                              theme.radiusScale.sm,
                            ),
                          ),
                          child: Text(
                            widget.toast.action!,
                            style: theme
                                .textStyle(CairnTypography.xs)
                                .copyWith(
                                  fontWeight: CairnTypography.medium,
                                  color: theme.primaryForeground,
                                ),
                          ),
                        ),
                  ),
                CairnInteractive(
                  onTap: widget.onDismiss,
                  semanticLabel: 'Dismiss',
                  builder: (BuildContext context, CairnStates states) =>
                      Opacity(
                        opacity: states.hovered ? 1.0 : 0.5,
                        child: CairnIcon(
                          CairnIconData.close,
                          size: 14,
                          color: theme.mutedForeground,
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
