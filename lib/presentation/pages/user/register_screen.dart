// lib/ui/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:ppx_client/presentation/pages/user/user_list_page.dart';
import 'package:provider/provider.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _submitRegister(AuthViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final success = await viewModel.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const UserListPage()),
          (route) => false, // 移除所有先前的路由
        );
      } else {
        if (viewModel.errorMessage != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('创建账户'),
        elevation: 0,
        backgroundColor: Colors.transparent, // 使背景渐变可见
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).primaryColorDark
              : Colors.white,
        ),
      ),
      extendBodyBehindAppBar: true, // 使内容延伸到 AppBar 后面
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColorLight.withOpacity(0.8),
              Theme.of(context).primaryColorDark.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24.0,
              kToolbarHeight + 40,
              24.0,
              24.0,
            ), // 留出 AppBar 空间
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '加入我们',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '填写以下信息以创建账户',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: _nameController,
                        hintText: '你的名字',
                        prefixIcon: Icons.person_outline,
                        focusNode: _nameFocus,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocus),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '请输入你的名字';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        hintText: '邮箱',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: _emailFocus,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '请输入邮箱';
                          if (!value.contains('@')) return '请输入有效的邮箱';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: '密码',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        focusNode: _passwordFocus,
                        onFieldSubmitted: (_) => FocusScope.of(
                          context,
                        ).requestFocus(_confirmPasswordFocus),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '请输入密码';
                          if (value.length < 6) return '密码至少需要6位';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: '确认密码',
                        prefixIcon: Icons.lock_clock_outlined,
                        obscureText: true,
                        focusNode: _confirmPasswordFocus,
                        onFieldSubmitted: (_) => _submitRegister(authViewModel),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '请再次输入密码';
                          if (value != _passwordController.text)
                            return '两次输入的密码不一致';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: '注册',
                        isLoading:
                            authViewModel.registerStatus == AuthStatus.loading,
                        onPressed: () => _submitRegister(authViewModel),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          '已有账户? 返回登录',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
