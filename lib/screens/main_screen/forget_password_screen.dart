import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/widgets/common_widgets/button.dart';
import 'package:app_5/widgets/common_widgets/text_field_widget.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool passwordNotMatch = false;
  bool isPassOpen = true;
  bool isConfirmPassOpen = true;
  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Executive Login', 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w400
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(text: "Email", fontWeight: FontWeight.w500, fontSize: 15),
              const SizedBox(height: 12,),
              TextFields(
                isObseure: false, 
                hintText: "Email",
                textInputAction: TextInputAction.next,
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
                }
              ),
              const SizedBox(height: 16,),
              const TextWidget(text: "New password", fontWeight: FontWeight.w500, fontSize: 15),
              const SizedBox(height: 12,),
              TextFields(
                isObseure: isPassOpen, 
                hintText: "New password",
                textInputAction: TextInputAction.next,
                controller: newPasswordController,
                suffixIcon: GestureDetector(
                  onTap: (){
                    setState(() {
                      isPassOpen = !isPassOpen;
                    });
                    print('Pressed');
                  },
                  child: Icon(isPassOpen ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16,),
              const TextWidget(text: "Confirm new password", fontWeight: FontWeight.w500, fontSize: 15),
              const SizedBox(height: 12,),
              TextFields(
                isObseure: isConfirmPassOpen, 
                hintText: "Confirm new password",
                textInputAction: TextInputAction.next,
                controller: confirmNewPasswordController,
                suffixIcon: GestureDetector(
                  onTap: (){
                    setState(() {
                      isConfirmPassOpen = !isConfirmPassOpen;
                    });
                    print('Pressed');
                  },
                  child: Icon(isConfirmPassOpen ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16,),
              Consumer<ApiProvider>(
                builder: (context, provider, child) {
                  return isLoading 
                  ? const LoadingButton(width: double.infinity,)
                  : ButtonWidget(
                    width: double.infinity,
                    title: "Update", 
                    onPressed: () async {
                     setState(() {
                       isLoading = true;
                     });
                     try {
                      FocusScope.of(context).unfocus();
                      if (formKey.currentState!.validate()) {
                         if(newPasswordController.text != confirmNewPasswordController.text){
                          setState(() {
                            passwordNotMatch = true;
                          });
                         }else{
                           setState(() {
                              passwordNotMatch = false;
                            });
                           Map<String, dynamic> updatePasswordData = {
                            "email": emailController.text,
                            "new_password": newPasswordController.text,
                            "confirm_password": confirmNewPasswordController.text,
                          };
                          await provider.forgetPassword(context, updatePasswordData, size);
                         }
                      }
                     } catch (e) {
                       print("Can't update password: $e");
                     } finally {
                        setState(() {
                          isLoading = false;
                        });
                     }
                    },
                  );
                }
              ),
              passwordNotMatch
              ? const Column(
                  children: [
                    SizedBox(height: 5,),
                    TextWidget(
                      text: "* New password and Confirm new password should be same", 
                      fontWeight: FontWeight.w400, 
                      fontSize: 12,
                      fontColor: Colors.red,
                    ),
                  ],
                )
              : Container(),
            ],
          ),
        ),
      ),
    );
  }
}


// $per = (($product->price-$product->final_price)/$product->price)*100;
// 												$percentage = round($per); 
