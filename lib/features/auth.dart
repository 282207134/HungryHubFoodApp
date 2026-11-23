import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/hub_state.dart';
import '../core/ui.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => HubScaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _SplashBackdrop(context.isDark)),
            ),
            Positioned(
              top: h * .09,
              left: w * .16,
              width: w * .68,
              child: context.isDark
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Photo(
                          'splash-logo.png',
                          width: w * .68,
                          fit: BoxFit.contain,
                        ),
                        Positioned.fill(
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (rect) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFF07A10)],
                              stops: [.64, 1],
                            ).createShader(rect),
                            child: Photo(
                              'splash-logo.png',
                              width: w * .68,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Photo('splash-logo.png', fit: BoxFit.contain),
            ),
            Positioned(
              left: -w * .10,
              top: h * .29,
              width: w * .51,
              child: const Photo('splash-side.png', fit: BoxFit.contain),
            ),
            Positioned(
              right: -w * .015,
              top: h * .66,
              width: w * .30,
              child: const Photo('splash-right.png', fit: BoxFit.contain),
            ),
            Positioned(
              left: -w * .08,
              top: h * .73,
              width: w * .90,
              child: const Photo('splash-bottom.png', fit: BoxFit.contain),
            ),
            Positioned(
              right: w * .10,
              top: h * .25,
              child: SizedBox(
                width: 128,
                height: 128,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _StartRing(context.ink)),
                    ),
                    Material(
                      color: orange,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => context.open(const OnboardingPage()),
                        child: const Tooltip(
                          message: 'Get Started',
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: Icon(
                              Icons.north_east_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _SplashBackdrop extends CustomPainter {
  const _SplashBackdrop(this.dark);
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = dark ? const Color(0xFF232323) : const Color(0xFFF8F8F8);
    for (var x = size.width * .35; x < size.width; x += size.width * .065) {
      canvas.drawLine(
        Offset(x, size.height * .17),
        Offset(x, size.height * .56),
        line,
      );
    }
    for (
      var y = size.height * .17;
      y < size.height * .56;
      y += size.height * .035
    ) {
      canvas.drawLine(Offset(size.width * .35, y), Offset(size.width, y), line);
    }
    final phrases = ['EAT AND', 'DELICIOUS', 'FOOD'];
    for (var i = 0; i < phrases.length; i++) {
      final text = TextPainter(
        text: TextSpan(
          text: phrases[i],
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: size.width * .24,
            color: dark ? const Color(0xFF292929) : const Color(0xFFF2F2F2),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(
        size.width * (.02 + i * .30),
        size.height * (i == 2 ? .65 : .77),
      );
      canvas.rotate(-math.pi / 2);
      text.paint(canvas, Offset.zero);
      canvas.restore();
      text.dispose();
    }
  }

  @override
  bool shouldRepaint(_SplashBackdrop oldDelegate) => oldDelegate.dark != dark;
}

class _StartRing extends CustomPainter {
  const _StartRing(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const copy = 'Get Started · Get Started · ';
    final center = size.center(Offset.zero);
    for (var i = 0; i < copy.length; i++) {
      final angle = i * (math.pi * 2 / copy.length) - math.pi / 2;
      final text = TextPainter(
        text: TextSpan(
          text: copy[i],
          style: TextStyle(
            fontFamily: 'Poppins',
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(
        center.dx + math.cos(angle) * 57,
        center.dy + math.sin(angle) * 57,
      );
      canvas.rotate(angle + math.pi / 2);
      text.paint(canvas, Offset(-text.width / 2, -text.height / 2));
      canvas.restore();
      text.dispose();
    }
  }

  @override
  bool shouldRepaint(_StartRing oldDelegate) => oldDelegate.color != color;
}

const _intro = [
  (
    'intro-order.png',
    'Order Your Food',
    'Now you can order your food anytime from your mobile. 24/7 available for delivery. Enjoy your food with us.',
  ),
  (
    'intro-safe.png',
    'Safe Food Transfer',
    'We maintain safety and cleanliness while preparing your food.',
  ),
  (
    'intro-fast.png',
    'Fast Delivery',
    'We deliver your food immediately at your doorsteps.',
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late int index = widget.initialIndex;

  void finish() => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => const SignUpPage()));

  @override
  Widget build(BuildContext context) => HubScaffold(
    overlay: SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarIconBrightness: context.isDark
          ? Brightness.light
          : Brightness.dark,
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final (image, title, summary) = _intro[index];
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Photo(
                    image,
                    width: constraints.maxWidth,
                    height: math.min(
                      constraints.maxWidth * 476 / 390,
                      constraints.maxHeight * .57,
                    ),
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Label(title, size: 24, weight: FontWeight.w700),
                        const SizedBox(height: 12),
                        Label(summary, color: context.muted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 48),
              child: Row(
                children: [
                  for (var i = 0; i < _intro.length; i++) ...[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == index ? orange : context.palette.outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  HubButton(
                    index == 0 ? 'Skip' : 'Back',
                    height: 48,
                    outlined: true,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    onPressed: index == 0
                        ? finish
                        : () => setState(() => index--),
                  ),
                  const SizedBox(width: 12),
                  HubButton(
                    'Next',
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    onPressed: index == _intro.length - 1
                        ? finish
                        : () => setState(() => index++),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

bool isValidEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
bool _validPhone(String value) =>
    value.replaceAll(RegExp(r'\D'), '').length >= 8;
String _fixture(String value, int state, {bool primary = true}) =>
    switch (state) {
      2 => value,
      1 when primary => value.substring(0, value.length - 1),
      _ => '',
    };

class _AuthLayout extends StatelessWidget {
  const _AuthLayout(
    this.title, {
    required this.fields,
    required this.footer,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final List<Widget> fields;
  final Widget footer;
  @override
  Widget build(BuildContext context) => HubPage(
    footer: footer,
    children: [
      Padding(
        padding: pageInset,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Label(title, size: 24, weight: FontWeight.w700),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Label(subtitle!, color: context.muted),
            ],
            const SizedBox(height: 32),
            ...fields,
          ],
        ),
      ),
    ],
  );
}

class _AuthLink extends StatelessWidget {
  const _AuthLink(this.leading, this.action, this.onTap);
  final String leading, action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    child: Text.rich(
      TextSpan(
        text: leading,
        style: TextStyle(color: context.muted),
        children: [
          TextSpan(
            text: action,
            style: const TextStyle(color: orange),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.sample = 0});
  final int sample;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final email = TextEditingController(
    text: _fixture('william@example.com', widget.sample),
  );
  late final password = TextEditingController(
    text: _fixture('Hungry123', widget.sample, primary: false),
  );

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([email, password]),
    builder: (context, _) => _AuthLayout(
      'Login your account',
      fields: [
        HubField(
          'Email',
          controller: email,
          keyboard: TextInputType.emailAddress,
          highlight: widget.sample == 1,
        ),
        const SizedBox(height: 16),
        HubField(
          'Password',
          controller: password,
          password: true,
          reveal: widget.sample == 2,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.open(
              RecoveryPage(
                email: isValidEmail(email.text)
                    ? email.text.trim()
                    : context.hub.email,
              ),
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: orange),
            ),
          ),
        ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HubButton(
            'Login',
            onPressed: isValidEmail(email.text) && password.text.length >= 6
                ? () {
                    context.hub.updateAccount(email: email.text.trim());
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/browse', (_) => false);
                  }
                : null,
          ),
          _AuthLink(
            'Don’t have an account? ',
            'Create account',
            () => context.open(const SignUpPage()),
          ),
        ],
      ),
    ),
  );
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.sample = 0});
  final int sample;
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final name = TextEditingController(
    text: _fixture('William Chain', widget.sample),
  );
  late final email = TextEditingController(
    text: _fixture('william@example.com', widget.sample, primary: false),
  );
  late final password = TextEditingController(
    text: _fixture('Hungry123', widget.sample, primary: false),
  );
  bool accepted = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([name, email, password]),
    builder: (context, _) => _AuthLayout(
      'Create Your Account',
      fields: [
        HubField('Username', controller: name, highlight: widget.sample == 1),
        const SizedBox(height: 16),
        HubField(
          'Email',
          controller: email,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        HubField(
          'Password',
          controller: password,
          password: true,
          reveal: widget.sample == 2,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 28,
              child: Checkbox(
                value: accepted,
                activeColor: orange,
                onChanged: (value) => setState(() => accepted = value ?? false),
                semanticLabel: 'I agree to the Terms of Services',
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(color: context.muted),
                  children: const [
                    TextSpan(
                      text: 'Terms of Services',
                      style: TextStyle(color: orange),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HubButton(
            'Start',
            onPressed:
                accepted &&
                    name.text.trim().isNotEmpty &&
                    isValidEmail(email.text) &&
                    password.text.length >= 6
                ? () {
                    context.hub.updateAccount(
                      name: name.text.trim(),
                      email: email.text.trim(),
                    );
                    context.open(const PhonePage());
                  }
                : null,
          ),
          _AuthLink(
            'Already have an account? ',
            'LogIn',
            () => context.open(const LoginPage()),
          ),
        ],
      ),
    ),
  );
}

class PhonePage extends StatefulWidget {
  const PhonePage({super.key, this.sample = 0});
  final int sample;
  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  late final number = TextEditingController(
    text: _fixture('+21 568789798', widget.sample),
  );

  @override
  void dispose() {
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: number,
    builder: (context, _) => _AuthLayout(
      'Enter your Phone number',
      fields: [
        HubField(
          'Phone Number',
          controller: number,
          keyboard: TextInputType.phone,
          highlight: widget.sample == 1,
          prefix: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Label('🇦🇺', size: 18),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ),
      ],
      footer: HubButton(
        'Verify',
        onPressed: _validPhone(number.text)
            ? () {
                context.hub.updateAccount(phone: number.text.trim());
                context.open(
                  VerifyPage(
                    contact: number.text.trim(),
                    phone: true,
                    signUp: true,
                  ),
                );
              }
            : null,
      ),
    ),
  );
}

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key, required this.email, this.selected});
  final String email;
  final String? selected;
  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  late String? selected = widget.selected;
  @override
  Widget build(BuildContext context) => _AuthLayout(
    'Forget Password',
    subtitle:
        'Select which contact details should we use to reset your password',
    fields: [
      for (final option in ['Via Email', 'Via Phone Number']) ...[
        ChoiceRow(
          option,
          selected: selected == option,
          onTap: () => setState(() => selected = option),
        ),
        const SizedBox(height: 16),
      ],
    ],
    footer: HubButton(
      'Next',
      onPressed: selected == null
          ? null
          : () {
              final phone = selected == 'Via Phone Number';
              context.open(
                VerifyPage(
                  contact: phone ? context.hub.phone : widget.email,
                  phone: phone,
                ),
              );
            },
    ),
  );
}

class VerifyPage extends StatefulWidget {
  const VerifyPage({
    super.key,
    required this.contact,
    this.phone = false,
    this.signUp = false,
    this.filled = false,
  });
  final String contact;
  final bool phone, signUp, filled;
  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  late final code = TextEditingController(text: widget.filled ? '8806' : '');
  final focus = FocusNode();

  @override
  void dispose() {
    code.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([code, focus]),
    builder: (context, _) => _AuthLayout(
      widget.phone ? 'Verify Phone Number' : 'Verify email',
      subtitle: widget.phone
          ? 'Code has been sent to ${widget.contact}'
          : 'Code has been sent to your Email ${widget.contact}',
      fields: [
        Stack(
          children: [
            ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i != 0) const SizedBox(width: 12),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: context.soft.withValues(alpha: .35),
                            borderRadius: cardRadius,
                            border: Border.all(
                              color: focus.hasFocus && i == code.text.length
                                  ? orange
                                  : context.palette.outline,
                            ),
                          ),
                          child: Label(
                            i < code.text.length ? code.text[i] : '',
                            size: 36,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned.fill(
              child: TextField(
                key: const Key('verification-code'),
                controller: code,
                focusNode: focus,
                keyboardType: TextInputType.number,
                maxLength: 4,
                showCursor: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  semanticCounterText: '',
                  hintText: 'Verification code',
                  hintStyle: TextStyle(color: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
      ],
      footer: Row(
        children: [
          Expanded(
            child: HubButton(
              'Send again',
              outlined: true,
              onPressed: () =>
                  feedback(context, 'Demo verification code: 8806'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: HubButton(
              'Verify',
              onPressed: () {
                if (code.text != '8806') {
                  feedback(context, 'Enter demo code 8806.');
                } else if (widget.signUp) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/browse', (_) => false);
                } else {
                  context.open(const ResetPage());
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class ResetPage extends StatefulWidget {
  const ResetPage({super.key, this.sample = 0, this.fromProfile = false});
  final int sample;
  final bool fromProfile;
  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  late final password = TextEditingController(
    text: _fixture('Hungry123', widget.sample, primary: false),
  );
  late final confirm = TextEditingController(
    text: _fixture('Hungry123', widget.sample),
  );

  @override
  void dispose() {
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([password, confirm]),
    builder: (context, _) => _AuthLayout(
      'Reset Your Password',
      fields: [
        HubField(
          'Password',
          controller: password,
          password: true,
          reveal: widget.sample > 0,
        ),
        const SizedBox(height: 16),
        HubField(
          'Confirm Password',
          controller: confirm,
          password: true,
          reveal: widget.sample > 0,
          highlight: widget.sample == 1,
        ),
      ],
      footer: HubButton(
        'Reset Password',
        onPressed: password.text.length >= 6 && password.text == confirm.text
            ? () {
                if (widget.fromProfile) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/sign-in', (_) => false);
                }
                feedback(context, 'Password reset completed in demo.');
              }
            : null,
      ),
    ),
  );
}
