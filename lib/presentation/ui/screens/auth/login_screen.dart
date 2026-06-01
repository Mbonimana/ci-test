import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/env_config.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/providers/auth/auth_provider.dart';
import 'package:street_team/presentation/ui/screens/home_screen.dart';
import 'package:street_team/presentation/ui/widgets/loading_states/loading_indicator.dart';
import 'package:street_team/presentation/ui/widgets/murugo_elements/murugo_clouds.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_text_field.dart';
import 'package:street_team/presentation/ui/widgets/shared/feedback_widgets/app_dialoge.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _launchForgotPassword() async {
    final Uri url = Uri.parse(EnvConfig.murugoPasswordResetUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchRegister() async {
    final Uri url = Uri.parse(EnvConfig.murugoRegisterUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    final result = await ref
        .read(authProvider.notifier)
        .login(email: email, password: password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      return;
    }

    await AppDialog.show(
      context: context,
      title: 'Login Failed',
      message: result.message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: Stack(
          children: [
            Column(
              children: [
                const MurugoCloudsUI(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,

                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          // LOGO
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/sta_icon.png',
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.contain,
                                ),
                                Text(
                                  'Street Team is part of the Murugo Cloud',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.placeholderText.withAlpha(
                                      250,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          AppTextField(
                            controller: _emailController,
                            hint: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          AppTextField(
                            controller: _passwordController,
                            hint: 'Password',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              // if (value.length < 6) {
                              //   return 'Password must be at least 6 characters';
                              // }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          AppButton(text: 'Login', onPressed: _onLoginPressed),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: _launchRegister,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Create Account?',
                                    style: TextStyle(
                                      color: AppColors.brandPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              InkWell(
                                onTap: _launchForgotPassword,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.brandPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.transparent,
                  child: LoadingIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
