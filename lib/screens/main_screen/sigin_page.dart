import 'package:app_5/helper/navigation_helper.dart';
import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/providers/connectivity_helper.dart';
import 'package:app_5/screens/main_screen/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_5/widgets/common_widgets/button.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:app_5/widgets/common_widgets/text_field_widget.dart';


class LoginPage extends StatefulWidget{
  const LoginPage({super.key,});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  String errorMessage = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _key = GlobalKey<FormState>();
  late String name = '';
  late String mail = '';
  late String mobileNo = '';
  bool isPassOpen = true;
  bool isLoading = false;
  final FocusNode passwordFocus = FocusNode();
  
 final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  
  @override
  Widget build(BuildContext context) {
    final appConnectivity = Provider.of<ConnectivityService>(context);
    Size size = MediaQuery.sizeOf(context);
      return !appConnectivity.isConnected
      ? Scaffold(
        // appBar: AppBar(),
        body: Center(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.25,),
                GestureDetector(
                  onTap: () =>  print('${size.height} ${size.width}'),
                  child: SizedBox(
                    height: size.height * 0.3,
                    width: size.width * 0.6,
                    child: Image.asset(
                      'assets/nointernet.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.005,),
                const TextWidget(text: 'OOPS!', fontWeight: FontWeight.w800, fontSize: 24),
                SizedBox(height: size.height * 0.005,),
                const TextWidget(text: 'NO INTERNET', fontWeight: FontWeight.w800, fontSize: 24),
                SizedBox(height: size.height * 0.01,),
                const TextWidget(text: 'Please check your internet connection.', fontWeight: FontWeight.w400, fontSize: 16),
                SizedBox(height: size.height * 0.02,),
                SizedBox(
                height: size.height * 0.06,
                width: size.width * 0.7,
                child: ButtonWidget(title: 'Try Again', onPressed: () => appConnectivity.isConnected ,)
                ),
                SizedBox(height: size.height * 0.22,),
              ],
            ),
          ),
      )
      : Consumer<ApiProvider>(
        builder: (context, provider, child) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                centerTitle: true,
                title: const Text('Delivery Executive Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
              ),
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading of the login page
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          'Welcome back !',
                          style: TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.w600,
                            letterSpacing: - 0.5
                          ),
                        ),
                          Text(
                            'Sign in to your account',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300,),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8,),
                      // phone text field
                      Form(
                        key: _key,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFields(
                              hintText: 'Enter your Email',
                              prefixIcon: const Icon(CupertinoIcons.mail),
                              textInputAction: TextInputAction.next,
                              isObseure: false,
                              borderColor: errorMessage == "Account not exist" ? Colors.red.shade500 : null,
                              controller: emailController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (emailRegex.hasMatch(value)) {
                                  return null; 
                                } else {
                                  return 'Invalid email';
                                }
                              },
                            ),
                            errorMessage == "Account not exist"
                            ? TextWidget(text: errorMessage, fontWeight: FontWeight.w400, fontSize: 12, fontColor: Colors.red.shade400,)
                            : Container(), 
                            const SizedBox(height: 20,),
                            TextFields(
                              hintText: 'Enter your Password',
                              prefixIcon: const Icon(CupertinoIcons.lock),
                              textInputAction: TextInputAction.done,
                              focusNode: passwordFocus,
                              suffixIcon: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    isPassOpen = !isPassOpen;
                                  });
                                  print('Pressed');
                                },
                                child: Icon(isPassOpen ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
                              ),
                              isObseure: isPassOpen,
                              borderColor: errorMessage == "Password Incorrect" ? Colors.red.shade400 : null,
                              controller: passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                            ),
                            errorMessage == "Password Incorrect"
                            ? TextWidget(text: errorMessage, fontWeight: FontWeight.w400, fontSize: 12, fontColor: Colors.red.shade400,)
                            : Container(), 
                            // const SizedBox(height: 20,),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15,),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          splashColor: Colors.transparent.withOpacity(0.1),
                          onTap: () {
                            Navigator.push(context, SideTransiion(screen: const ForgetPasswordScreen()));
                          },
                          child: const TextWidget(
                            text: "Forget password?", 
                            fontWeight: FontWeight.w400, 
                            fontSize: 13
                          ),
                        ),
                      ),
                      const SizedBox(height: 15,),
                      // Move to the other page and remove this page from the memory to avoid revoke
                      Center(
                        child: isLoading
                        ? LoadingButton(
                          width: size.width,
                        )
                        : ButtonWidget(
                          width: size.width,
                          title: 'Login', 
                          onPressed: () async{
                            FocusScope.of(context).unfocus();
                            if (_key.currentState!.validate()) {
                              Map<String, dynamic> loginData = {
                                "email": emailController.text, 
                                'password': passwordController.text
                              };
                              setState((){
                                isLoading = true;
                              });
                              try {
                                await provider.loginExecutive(context, loginData, size);
                              } catch (e) {
                                print("Login failed: $e");
                              } finally{
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                        )
                      )
                    ],
                  ),
                ),
              ),
            );
        }
      );
  }
  
}

