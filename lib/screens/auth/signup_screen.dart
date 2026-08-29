import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

const Color _primary = Color(0xFF079E9B);
const Color _primaryDark = Color(0xFF087F7C);
const Color _background = Color(0xFFF2FBFB);
const Color _textDark = Color(0xFF123047);
const Color _textMuted = Color(0xFF71869A);
const Color _border = Color(0xFFDCE8ED);
const Color _softTeal = Color(0xFFE8F7F7);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _clinicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPhysio = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _acceptedTerms = false;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _clinicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _onPasswordChanged() {
    final password = _passwordController.text;

    if (!mounted) return;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'\d'));
      _hasSpecialChar =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  double get _passwordStrength {
    int count = 0;

    if (_hasMinLength) count++;
    if (_hasUppercase) count++;
    if (_hasNumber) count++;
    if (_hasSpecialChar) count++;

    return count / 4;
  }

  Color get _strengthColor {
    final strength = _passwordStrength;

    if (strength <= 0.25) return Colors.redAccent;
    if (strength <= 0.50) return Colors.orange;
    if (strength <= 0.75) return Colors.amber.shade700;

    return Colors.green;
  }

  Future<void> _submitSignup() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_acceptedTerms) {
      _showMessage(
        'Please accept the Terms & Privacy Policy.',
        isError: true,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage(
        'Passwords do not match.',
        isError: true,
      );
      return;
    }

    if (_passwordStrength < 1) {
      _showMessage(
        'Please meet all password requirements.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final nameParts =
          _nameController.text.trim().split(RegExp(r'\s+'));

      final firstName = nameParts.first;

      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : 'User';

      await AuthService().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
        phone: _phoneController.text.trim(),
        role: _isPhysio ? 'physiotherapist' : 'patient',
      );

      if (!mounted) return;

      _showMessage(
        'Account created successfully! Please sign in.',
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Registration failed: '
        '${error.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? const Color(0xFFE74C3C) : _primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _showUnavailable(String provider) {
    _showMessage(
      '$provider sign-up will be available soon.',
      isError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundDecoration(),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                28 + bottomInset,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        _buildTopBar(),

                        const SizedBox(height: 20),

                        _buildTitleSection(),

                        const SizedBox(height: 22),

                        _buildSignupCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BACKGROUND
  // ------------------------------------------------------------

  Widget _buildBackgroundDecoration() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -110,
            left: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFFDDF5F5),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: -120,
            bottom: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFDDF5F5),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 24,
            top: 105,
            child: _buildDotPattern(),
          ),
        ],
      ),
    );
  }

  Widget _buildDotPattern() {
    return SizedBox(
      width: 58,
      height: 58,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 9,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 9,
          crossAxisSpacing: 9,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFB9E7E7),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP BAR
  // ------------------------------------------------------------

  Widget _buildTopBar() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 1,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.all(11),
              child: Icon(
                Icons.arrow_back_rounded,
                color: _textDark,
                size: 21,
              ),
            ),
          ),
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Professional care',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TITLE
  // ------------------------------------------------------------

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create your account 👋',
          style: TextStyle(
            color: _textDark,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Join RehabZ and manage your practice, '
          'patients and appointments smarter.',
          style: TextStyle(
            color: _textMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // MAIN CARD
  // ------------------------------------------------------------

  Widget _buildSignupCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFEAF1F4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRoleSelector(),

          const SizedBox(height: 22),

          _buildLabel('Full Name'),

          const SizedBox(height: 7),

          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: _isPhysio
                  ? 'Dr. Arjun Kapoor'
                  : 'Rahul Sharma',
              icon: Icons.person_outline_rounded,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().length < 2) {
                return 'Enter your full name';
              }

              return null;
            },
          ),

          const SizedBox(height: 17),

          _buildLabel('Email Address'),

          const SizedBox(height: 7),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'you@example.com',
              icon: Icons.email_outlined,
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              final emailRegex = RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              );

              if (!emailRegex.hasMatch(email)) {
                return 'Enter a valid email address';
              }

              return null;
            },
          ),

          const SizedBox(height: 17),

          _buildLabel('Phone Number'),

          const SizedBox(height: 7),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: '+91 98765 43210',
              icon: Icons.phone_outlined,
            ),
            validator: (value) {
              final digits =
                  (value ?? '').replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );

              if (digits.length < 10) {
                return 'Enter a valid phone number';
              }

              return null;
            },
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _isPhysio
                ? Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 17),

                      _buildLabel(
                        'Clinic / Practice Name',
                        optional: true,
                      ),

                      const SizedBox(height: 7),

                      TextFormField(
                        controller: _clinicController,
                        textCapitalization:
                            TextCapitalization.words,
                        textInputAction:
                            TextInputAction.next,
                        decoration: _inputDecoration(
                          hintText:
                              'Your clinic name',
                          icon: Icons
                              .local_hospital_outlined,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 17),

          _buildLabel('Password'),

          const SizedBox(height: 7),

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'Create a strong password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                splashRadius: 20,
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword =
                        !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Enter a password';
              }

              if ((value ?? '').length < 8) {
                return 'Password must contain at least 8 characters';
              }

              return null;
            },
          ),

          const SizedBox(height: 10),

          _buildPasswordStrength(),

          const SizedBox(height: 17),

          _buildLabel('Confirm Password'),

          const SizedBox(height: 7),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitSignup(),
            decoration: _inputDecoration(
              hintText: 'Re-enter your password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                splashRadius: 20,
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword =
                        !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm your password';
              }

              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildTerms(),

          const SizedBox(height: 18),

          _buildCreateAccountButton(),

          const SizedBox(height: 20),

          _buildDivider(),

          const SizedBox(height: 18),

          _buildGoogleButton(),

          const SizedBox(height: 22),

          _buildLoginLink(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ROLE SELECTOR
  // ------------------------------------------------------------

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleButton(
              icon: Icons.medical_services_outlined,
              label: 'Physiotherapist',
              selected: _isPhysio,
              onTap: () {
                setState(() {
                  _isPhysio = true;
                });
              },
            ),
          ),

          Expanded(
            child: _RoleButton(
              icon: Icons.accessibility_new_rounded,
              label: 'Patient',
              selected: !_isPhysio,
              onTap: () {
                setState(() {
                  _isPhysio = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PASSWORD STRENGTH
  // ------------------------------------------------------------

  Widget _buildPasswordStrength() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  minHeight: 5,
                  backgroundColor:
                      const Color(0xFFE7EFF2),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(
                    _strengthColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Text(
              _passwordStrength == 0
                  ? 'Weak'
                  : _passwordStrength <= 0.5
                      ? 'Fair'
                      : _passwordStrength <= 0.75
                          ? 'Good'
                          : 'Strong',
              style: TextStyle(
                color: _strengthColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Wrap(
          spacing: 10,
          runSpacing: 5,
          children: [
            _Requirement(
              text: '8+ characters',
              active: _hasMinLength,
            ),
            _Requirement(
              text: 'Uppercase',
              active: _hasUppercase,
            ),
            _Requirement(
              text: 'Number',
              active: _hasNumber,
            ),
            _Requirement(
              text: 'Special character',
              active: _hasSpecialChar,
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TERMS
  // ------------------------------------------------------------

  Widget _buildTerms() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _acceptedTerms = !_acceptedTerms;
        });
      },
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: _acceptedTerms,
              activeColor: _primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                });
              },
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: _primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: _primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CREATE ACCOUNT BUTTON
  // ------------------------------------------------------------

  Widget _buildCreateAccountButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed:
            _isSubmitting ? null : _submitSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor:
              _primary.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSubmitting
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 23,
                  height: 23,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('button'),
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 22,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DIVIDER
  // ------------------------------------------------------------

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: _border,
            thickness: 1,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          child: Text(
            'or',
            style: TextStyle(
              color: _textMuted.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const Expanded(
          child: Divider(
            color: _border,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // GOOGLE
  // ------------------------------------------------------------

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 53,
      child: OutlinedButton(
        onPressed: () => _showUnavailable('Google'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _textDark,
          side: const BorderSide(
            color: _border,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 27,
              height: 27,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(7),
              ),
              child: const Text(
                'G',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4285F4),
                ),
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LOGIN LINK
  // ------------------------------------------------------------

  Widget _buildLoginLink() {
    return Column(
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(
            color: _textMuted,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 7),

        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                  color: _primaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                color: _primaryDark,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // LABEL
  // ------------------------------------------------------------

  Widget _buildLabel(
    String label, {
    bool optional = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textDark,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),

        if (optional) ...[
          const SizedBox(width: 5),
          const Text(
            'Optional',
            style: TextStyle(
              color: _textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------
  // INPUT DECORATION
  // ------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        color: Color(0xFF9AAABD),
        fontSize: 13,
      ),

      filled: true,
      fillColor: const Color(0xFFFBFDFD),

      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _softTeal,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: _primaryDark,
          size: 19,
        ),
      ),

      suffixIcon: suffix,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _primary,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE74C3C),
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE74C3C),
          width: 1.5,
        ),
      ),
    );
  }
}

// ============================================================
// ROLE BUTTON
// ============================================================

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: 48,
      decoration: BoxDecoration(
        color: selected
            ? Colors.white
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? _primaryDark
                    : _textMuted,
              ),

              const SizedBox(width: 7),

              Flexible(
                child: Text(
                  label,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? _primaryDark
                        : _textMuted,
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PASSWORD REQUIREMENT
// ============================================================

class _Requirement extends StatelessWidget {
  const _Requirement({
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          active
              ? Icons.check_circle_rounded
              : Icons.circle_outlined,
          size: 13,
          color: active
              ? Colors.green
              : _textMuted,
        ),

        const SizedBox(width: 4),

        Text(
          text,
          style: TextStyle(
            color: active
                ? Colors.green.shade700
                : _textMuted,
            fontSize: 10,
            fontWeight: active
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}