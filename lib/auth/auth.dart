import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_model/main_model.dart';

enum AuthMode { Signup, Login }

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, dynamic> _formData = {
    'firstName': null,
    'lastName': null,
    'email': null,
    'password': null,
    'acceptTerms': false
  };
  // Add text input controller to reuse the value within AuthPage
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
      image: AssetImage('assets/choc.png'),
    );
  }

  Widget _buildFirstNameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'First Name', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.text,
      validator: (String value) {},
      onSaved: (String value) {
        _formData['firstName'] = value;
      },
    );
  }

  Widget _buildLastNameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Last Name', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.text,
      validator: (String value) {},
      onSaved: (String value) {
        _formData['lastName'] = value;
      },
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      controller: _passwordController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password invalid';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (_passwordController.text != value) {
          return 'Password do not match!';
        }
      },
    );
  }

  Widget _buildModeSwitch() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlatButton(
              child: Text(
                  'Swich to ${_authMode == AuthMode.Login ? 'SignUp' : 'Login'}'),
              onPressed: () {
                setState(() {
                  _authMode = _authMode == AuthMode.Login
                      ? AuthMode.Signup
                      : AuthMode.Login;
                });
              })
        ]);
  }

  void _submitForm(MainModel model) async {
    Map<String, dynamic> successInformation;

    // Check Validation
    if (!_formKey.currentState.validate()) {
      return;
    }
    // Save current state of form
    _formKey.currentState.save();

    // Check Login
    if (_authMode == AuthMode.Login) {
      successInformation =
          await model.login(_formData['email'], _formData['password']);
    } else {
      // else chekc signup
      successInformation = await model.signup(_formData['firstName'],
          _formData['lastName'], _formData['email'], _formData['password']);
    }

    // if login or signup success redirect to product page.
    if (successInformation['success']) {
    //  Navigator.pushReplacementNamed(context, '/');  
    //  Auto navigation is handled in main.dart file.
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Something went wrong!'),
                content: Text('Please try again'),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Okay'))
                ]);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildFirstNameTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildLastNameTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildEmailTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildEmailTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildPasswordTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _authMode == AuthMode.Signup
                        ? _buildConfirmPasswordTextField()
                        : Container(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildModeSwitch(),
                    SizedBox(
                      height: 10.0,
                    ),
                    ScopedModelDescendant<MainModel>(builder:
                        (BuildContext context, Widget child, MainModel model) {
                      return model.isLoading
                          ? CircularProgressIndicator()
                          : RaisedButton(
                              textColor: Colors.white,
                              child: Text(_authMode == AuthMode.Login
                                  ? 'LOGIN'
                                  : 'SIGNUP'),
                              onPressed: () {
                                _submitForm(model);
                              },
                            );
                    })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
