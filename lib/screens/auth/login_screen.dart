import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/update_service.dart';
import '../patient/add_patient_screen.dart';
import '../patient/patient_dashboard.dart';
import 'signup_screen.dart';

const Color _primary = Color(0xFF009E9A);
const Color _background = Color(0xFFF2FBFC);
const Color _darkText = Color(0xFF12324A);
const Color _mutedText = Color(0xFF71849A);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPhysio = true;
  bool _obscurePassword = true;
  bool _isSigningIn = false;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Check for APK updates in background without blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.instance.checkAndPromptUpdate(context, isManual: false);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // REAL LOGIN
  // Uses your existing AuthService().login()
  // ============================================================

  Future<void> _signIn() async {
    if (_isSigningIn) return;

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSigningIn = true);

    try {
      final user = await AuthService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Keep the existing project navigation.
      final isPhysioUser =
          user.role.toLowerCase().contains('physio') || _isPhysio;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => isPhysioUser
              ? const AddPatientScreen(isFirstTimeLogin: true)
              : const PatientDashboard(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty
                ? 'Unable to sign in. Please check your details.'
                : message,
          ),
          backgroundColor: const Color(0xFFD64545),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  // ============================================================
  // REAL CREATE ACCOUNT NAVIGATION
  // Opens your existing signup_screen.dart
  // ============================================================

  void _createAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset is not connected to the current backend yet.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _googleUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google sign-in is not connected yet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned(
            top: -120,
            left: -100,
            child: _Circle(
              size: 320,
              color: Color(0xFFDDF4F4),
            ),
          ),
          const Positioned(
            top: 100,
            right: -145,
            child: _Circle(
              size: 300,
              color: Color(0xFFE4F8F8),
            ),
          ),
          const Positioned(
            bottom: -110,
            right: -80,
            child: _Circle(
              size: 250,
              color: Color(0xFFDDF5F5),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .035),
                  end: Offset.zero,
                ).animate(fade),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 850;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 42 : 18,
                        vertical: 18,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1120,
                          ),
                          child: wide
                              ? _buildWideLayout()
                              : _buildMobileLayout(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHero(),
        const SizedBox(height: 22),
        _buildLoginCard(),
        const SizedBox(height: 18),
        _buildFooter(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 25),
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildHero()),
          const SizedBox(width: 38),
          Expanded(child: _buildLoginCard()),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Welcome Back 👋',
          style: TextStyle(
            color: _darkText,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to continue managing\nyour practice.',
          style: TextStyle(
            color: _mutedText,
            fontSize: 17,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),

        // RehabZ Official Logo Header
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            color: const Color(0xFFEAF8F8),
            child: Center(
              child: Image.asset(
                'assets/images/rehabz_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: _primary,
                      size: 72,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5960).withValues(alpha: .09),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sign in to RehabZ',
              style: TextStyle(
                color: _darkText,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Access your practice dashboard securely.',
              style: TextStyle(
                color: _mutedText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            _roleSelector(),

            const SizedBox(height: 20),

            _fieldLabel(
              Icons.mail_outline_rounded,
              'Email Address',
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: _inputDecoration(
                'Enter your email',
                Icons.mail_outline_rounded,
              ),
              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty) {
                  return 'Please enter your email';
                }

                final validEmail = RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(email);

                if (!validEmail) {
                  return 'Please enter a valid email';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            _fieldLabel(
              Icons.lock_outline_rounded,
              'Password',
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _signIn(),
              decoration: _inputDecoration(
                'Enter your password',
                Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF527083),
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'Please enter your password';
                }

                if ((value ?? '').length < 6) {
                  return 'Password must be at least 6 characters';
                }

                return null;
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: _primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 7,
                  ),
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSigningIn ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  disabledBackgroundColor: _primary.withValues(alpha: .55),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: _isSigningIn
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 23,
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: const Color(0xFFB9C9D5).withValues(alpha: .7),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: _mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: const Color(0xFFB9C9D5).withValues(alpha: .7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: _isSigningIn ? null : _googleUnavailable,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkText,
                  side: const BorderSide(
                    color: Color(0xFFD9E5EC),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 21),

            const Text(
              'New to RehabZ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _mutedText,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 3),

            TextButton(
              onPressed: _createAccount,
              style: TextButton.styleFrom(
                foregroundColor: _primary,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 7),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleSelector() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _roleButton(
              text: "I'm a Physio",
              selected: _isPhysio,
              onTap: () => setState(() => _isPhysio = true),
            ),
          ),
          Expanded(
            child: _roleButton(
              text: "I'm a Patient",
              selected: !_isPhysio,
              onTap: () => setState(() => _isPhysio = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? _primary : _mutedText,
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _darkText,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF91A2B5),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: _primary,
        size: 21,
      ),
      filled: true,
      fillColor: const Color(0xFFFCFEFF),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFDCE7EE),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFDCE7EE),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _primary,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE57373),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE57373),
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      'Secure access • Professional care • Better outcomes',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _mutedText,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
