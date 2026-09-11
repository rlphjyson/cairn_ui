import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';

/// Form primitives.
abstract final class FormsSection {
  /// Builds the section.
  static Widget build(BuildContext context) => const _Forms();
}

class _Forms extends StatefulWidget {
  const _Forms();

  @override
  State<_Forms> createState() => _FormsState();
}

class _FormsState extends State<_Forms> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  bool? _terms = false;
  bool _notifications = true;
  String _plan = 'pro';
  double _volume = 0.6;
  bool _bold = false;
  Set<String> _alignment = <String>{'center'};
  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Demo(
          title: 'Button',
          note:
              'Six variants and eight sizes. Heights are h-6 / h-8 / h-9 / '
              'h-10, i.e. 24, 32, 36 and 40 logical pixels.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s3,
            children: <Widget>[
              DemoRow(
                children: <Widget>[
                  CairnButton(onPressed: () {}, child: const Text('Primary')),
                  CairnButton(
                    variant: CairnButtonVariant.secondary,
                    onPressed: () {},
                    child: const Text('Secondary'),
                  ),
                  CairnButton(
                    variant: CairnButtonVariant.destructive,
                    onPressed: () {},
                    child: const Text('Destructive'),
                  ),
                  CairnButton(
                    variant: CairnButtonVariant.outline,
                    onPressed: () {},
                    child: const Text('Outline'),
                  ),
                  CairnButton(
                    variant: CairnButtonVariant.ghost,
                    onPressed: () {},
                    child: const Text('Ghost'),
                  ),
                  CairnButton(
                    variant: CairnButtonVariant.link,
                    onPressed: () {},
                    child: const Text('Link'),
                  ),
                ],
              ),
              DemoRow(
                children: <Widget>[
                  CairnButton(
                    size: CairnButtonSize.xs,
                    onPressed: () {},
                    child: const Text('xs'),
                  ),
                  CairnButton(
                    size: CairnButtonSize.sm,
                    onPressed: () {},
                    child: const Text('sm'),
                  ),
                  CairnButton(onPressed: () {}, child: const Text('md')),
                  CairnButton(
                    size: CairnButtonSize.lg,
                    onPressed: () {},
                    child: const Text('lg'),
                  ),
                  CairnButton.icon(
                    icon: const CairnIcon(CairnIconData.check),
                    semanticLabel: 'Confirm',
                    variant: CairnButtonVariant.outline,
                    onPressed: () {},
                  ),
                  CairnButton(
                    onPressed: () {},
                    leading: const CairnSpinner(),
                    child: const Text('Loading'),
                  ),
                  const CairnButton(onPressed: null, child: Text('Disabled')),
                ],
              ),
            ],
          ),
        ),
        Demo(
          title: 'Input, Textarea and Label',
          note:
              'h-9 with px-3 padding, rounded-md and a shadow-xs resting '
              'elevation. Focus adds a 3px ring at 50% alpha.',
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s4,
              children: <Widget>[
                CairnFormField(
                  label: 'Email',
                  description: 'We will never share it.',
                  error: _emailError,
                  child: CairnInput(
                    controller: _email,
                    placeholder: 'name@example.com',
                    hasError: _emailError != null,
                    onChanged: (String v) => setState(() {
                      _emailError = v.isEmpty || v.contains('@')
                          ? null
                          : 'Enter a valid email address.';
                    }),
                  ),
                ),
                CairnFormField(
                  label: 'Bio',
                  child: CairnTextarea(
                    controller: _bio,
                    placeholder: 'Tell us a little about yourself...',
                  ),
                ),
                const CairnInput(placeholder: 'Disabled', enabled: false),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Checkbox, Switch and Radio Group',
          note:
              'The switch track is h-[1.15rem] w-8 - literally 18.4 x 32 '
              'logical pixels, not a rounded number.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s5,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: CairnSpacing.s2,
                children: <Widget>[
                  CairnCheckbox(
                    value: _terms,
                    tristate: true,
                    onChanged: (bool? v) => setState(() => _terms = v),
                  ),
                  const CairnLabel('Accept terms and conditions'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: CairnSpacing.s2,
                children: <Widget>[
                  CairnSwitch(
                    value: _notifications,
                    semanticLabel: 'Notifications',
                    onChanged: (bool v) => setState(() => _notifications = v),
                  ),
                  const CairnLabel('Email notifications'),
                ],
              ),
              CairnRadioGroup<String>(
                value: _plan,
                onChanged: (String v) => setState(() => _plan = v),
                children: const <Widget>[
                  CairnRadioItem<String>(value: 'free', label: Text('Free')),
                  CairnRadioItem<String>(value: 'pro', label: Text('Pro')),
                  CairnRadioItem<String>(
                    value: 'team',
                    label: Text('Team (unavailable)'),
                    enabled: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        Demo(
          title: 'Slider',
          note:
              'The thumb is a literal bg-white in both themes, and the focus '
              'halo is ring-4 rather than the usual 3px.',
          child: SizedBox(
            width: 320,
            child: CairnSlider(
              value: _volume,
              semanticLabel: 'Volume',
              onChanged: (double v) => setState(() => _volume = v),
            ),
          ),
        ),
        Demo(
          title: 'Toggle and Toggle Group',
          child: DemoRow(
            children: <Widget>[
              CairnToggle(
                value: _bold,
                variant: CairnToggleVariant.outline,
                onChanged: (bool v) => setState(() => _bold = v),
                child: const Text('Bold'),
              ),
              CairnToggleGroup<String>(
                values: _alignment,
                variant: CairnToggleVariant.outline,
                onChanged: (Set<String> v) => setState(() => _alignment = v),
                items: const <CairnToggleGroupItem<String>>[
                  CairnToggleGroupItem<String>(
                    value: 'left',
                    child: Text('Left'),
                  ),
                  CairnToggleGroupItem<String>(
                    value: 'center',
                    child: Text('Center'),
                  ),
                  CairnToggleGroupItem<String>(
                    value: 'right',
                    child: Text('Right'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Demo(
          title: 'Input OTP',
          note:
              'One hidden field behind painted slots, so paste and SMS '
              'autofill keep working. Only the first slot draws a left border, '
              'which avoids doubled hairlines between slots.',
          child: CairnInputOtp(length: 6, groupSizes: <int>[3, 3]),
        ),
      ],
    );
  }
}
