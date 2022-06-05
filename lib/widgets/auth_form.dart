import 'dart:io';

import 'package:chat_app/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function({
    required String email,
    required String password,
    required String userName,
    required File? image,
    required bool isLogin,
    required BuildContext context,
  }) onSubmit;
  final bool isLoading;
  const AuthForm({Key? key, required this.onSubmit, required this.isLoading})
      : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail = "";
  String _userPassword = "";
  String _userName = "";
  bool _isLogin = true;
  File? _userImageFile;

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please pick an image'),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      widget.onSubmit(
          userName: _userName.trim(),
          email: _userEmail.trim(),
          password: _userPassword.trim(),
          image: _userImageFile,
          isLogin: _isLogin,
          context: context);
    }
  }

  bool _isEmailFormat(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void _pickImage(File image) async {
    _userImageFile = image;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (!_isLogin)
                UserImagePicker(
                  imagePickFn: _pickImage,
                ),
              TextFormField(
                key: const ValueKey("email"),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                ),
                onSaved: ((newValue) {
                  _userEmail = newValue!;
                }),
                validator: (value) {
                  if (value!.isEmpty || !_isEmailFormat(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              if (!_isLogin)
                TextFormField(
                  key: const ValueKey("userName"),
                  autocorrect: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Username'),
                  onSaved: ((newValue) {
                    _userName = newValue!;
                  }),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 4) {
                      return 'Please enter atlease 4 characters';
                    }
                    return null;
                  },
                ),
              TextFormField(
                key: const ValueKey("password"),
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                onSaved: ((newValue) {
                  _userPassword = newValue!;
                }),
                validator: (value) {
                  if (value!.isEmpty || value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(
                height: 12,
              ),
              if (widget.isLoading) const CircularProgressIndicator(),
              if (!widget.isLoading)
                ElevatedButton(
                    onPressed: _trySubmit,
                    child: Text(_isLogin ? 'Login' : 'Sign Up')),
              if (!widget.isLoading)
                TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin ? 'Create new account' : 'Login')),
            ]),
          ),
        )),
      ),
    );
  }
}
