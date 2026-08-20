import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../patient/add_patient_screen.dart';
import '../patient/patient_dashboard.dart';
import 'signup_screen.dart';

const _loginBlue = Color(0xFF10B981);
const _loginBackground = Color(0xFF0F1F17);
const _loginBorder = Color(0xFF254B37);
const _loginText = Color(0xFFF8FAFC);
const _loginMuted = Color(0xFFA7F3D0);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPhysio = true;
  bool _obscurePassword = true;
  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isSigningIn || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSigningIn = true);
    try {
      final user = await AuthService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      
      final isPhysioUser = user.role.contains('physio') || _isPhysio;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => isPhysioUser ? const AddPatientScreen(isFirstTimeLogin: true) : const PatientDashboard(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }


  void _showUnavailableMessage(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is not available yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _loginBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              color: _loginBackground,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const _LoginHero(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(17, 24, 17, 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildRoleSelector(),
                            const SizedBox(height: 18),
                            _buildLabel('Email address'),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                hintText: 'you@example.com',
                                prefixIcon: Icons.person_outline_rounded,
                              ),
                              validator: (value) {
                                final email = value?.trim() ?? '';
                                if (email.isEmpty || !email.contains('@')) {
                                  return 'Enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Password'),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _signIn(),
                              decoration: _inputDecoration(
                                hintText: 'Enter your password',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: _loginMuted,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if ((value?.length ?? 0) < 6) {
                                  return 'Password must be at least 6 characters.';
                                }
                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    _showUnavailableMessage('Password reset'),
                                style: TextButton.styleFrom(
                                  foregroundColor: _loginBlue,
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 10,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 43,
                              child: FilledButton(
                                onPressed: _isSigningIn ? null : _signIn,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _loginBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: _isSigningIn
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const _DividerLabel(label: 'or continue with'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _SocialButton(
                                    label: 'Google',
                                    icon: const Text(
                                      'G',
                                      style: TextStyle(
                                        color: Color(0xFF4285F4),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showUnavailableMessage('Google'),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: _SocialButton(
                                    label: 'WhatsApp',
                                    icon: const Icon(
                                      Icons.chat_bubble_outline,
                                      size: 15,
                                      color: Color(0xFF7E57C2),
                                    ),
                                    onPressed: () =>
                                        _showUnavailableMessage('WhatsApp'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 17),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _loginMuted,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _loginBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      height: 35,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          _RoleOption(
            label: "I'm a Physio",
            selected: _isPhysio,
            onTap: () => setState(() => _isPhysio = true),
          ),
          _RoleOption(
            label: "I'm a Patient",
            selected: !_isPhysio,
            onTap: () => setState(() => _isPhysio = false),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: _loginText,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: _loginBorder),
      borderRadius: BorderRadius.circular(6),
    );
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9AA9B8), fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      prefixIcon: Icon(prefixIcon, size: 16, color: _loginMuted),
      suffixIcon: suffix,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: _loginBlue, width: 1.3),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Color(0xFFE74C3C)),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Color(0xFFE74C3C)),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 182,
      width: double.infinity,
      color: _loginBlue,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned(top: -88, right: -35, child: _HeroCircle(size: 192)),
          const Positioned(
            bottom: -45,
            left: -21,
            child: _HeroCircle(size: 135),
          ),
          const Positioned(top: 13, right: 12, child: _LoginPill()),
          Center(
            child: Transform.translate(
              offset: const Offset(0, 15),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PvMark(),
                  SizedBox(height: 16),
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Sign in to continue to PhysioVerse',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PvMark extends StatelessWidget {
  const _PvMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 47,
      height: 47,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Text(
        'PV',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0x332A88DE),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LoginPill extends StatelessWidget {
  const _LoginPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0874D8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33004488),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 5, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 13,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            alignment: Alignment.center,
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x220E355C),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  )
                : null,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? _loginBlue : _loginMuted,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: _loginBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, color: _loginMuted),
          ),
        ),
        const Expanded(child: Divider(color: _loginBorder)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _loginText,
          side: const BorderSide(color: _loginBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
