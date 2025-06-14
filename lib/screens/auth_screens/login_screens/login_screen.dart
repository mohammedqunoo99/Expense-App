import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tasty_booking/fb_controller/fb_auth_controller.dart';
import 'package:tasty_booking/fb_controller/fb_firestore.dart';
import 'package:tasty_booking/fb_controller/fb_notifications.dart';
import 'package:tasty_booking/model/fb_response.dart';
import 'package:tasty_booking/screens/auth_screens/create_new_account_screens/create_new_account_screen.dart';
import 'package:tasty_booking/screens/home_screens/bottom_navigation_bar.dart';
import 'package:tasty_booking/shared_preferences/shared_prefrences_controller.dart';
import 'package:tasty_booking/style/app_colors.dart';
import 'package:tasty_booking/utils/helpers.dart';
import 'package:tasty_booking/utils/notification_helper.dart';
import 'package:tasty_booking/wdgets/app_elevated_button.dart';
import 'package:tasty_booking/wdgets/app_text.dart';
import 'package:tasty_booking/wdgets/app_text_field.dart';
import 'package:tasty_booking/wdgets/custom_app_loading.dart';
import 'package:tasty_booking/wdgets/outside_button_with_icons.dart';

import '../../../wdgets/app_back_button.dart';
import 'package:timezone/data/latest.dart' as tz;

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> with FbNotifications{
  Country country = CountryParser.parseCountryCode('SA');
  late TextEditingController _phoneEditingController;
  late TextEditingController _emailEditingController;
  late TextEditingController _passwordEditingController;
  bool obscure = true;
  bool isLoading = false;
  String? phoneError;
  String? passwordIsError;
  String countryCode = '+966';
  String? countryFlag;
  String? emailIsError;

  @override
  void initState() {
    super.initState();
    requestNotificationPermissions();
    initializeForegroundNotificationForAndroid();
    manageNotificationAction();
    tz.initializeTimeZones();
    _phoneEditingController = TextEditingController();
    _emailEditingController = TextEditingController();
    _passwordEditingController = TextEditingController();

  }
  @override
  void dispose() {
    _phoneEditingController.dispose();
    _emailEditingController.dispose();
    _passwordEditingController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w,vertical: 0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 68.h,),

                    // AppBackButton(onTap: () => Navigator.pop(context),),

                    SizedBox(height: 100.h,),
                    AppText(text: context.localizations.login,fontSize: 32,fontWeight: FontWeight.bold,fontFamily: 'DINNextLTArabic_bold',),
                    SizedBox(height: 40.h,),
                    AppTextField(
                      controller: _emailEditingController,
                      errorText: emailIsError,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (p0) {
                        if(emailIsError != null){
                          setState(() {
                            emailIsError = null;
                          });
                        }},
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        child: Icon(Icons.email_outlined,size: 24.sp,color: Color(0XFF353A62),),
                      ),
                      hintText: context.localizations.email,
                    ),
                    SizedBox(height: 16.h,),
                    AppTextField(
                      controller: _passwordEditingController,
                      prefixIcon: Padding(
                        padding:  EdgeInsets.symmetric(vertical: 18.h),
                        child: SvgPicture.asset('assets/images/lockIcon.svg',height: 24.h,width: 24.w,),
                      ),
                      hintText: context.localizations.password,
                      obscure: obscure,
                      maxLines: 1,
                      errorText: passwordIsError,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric( vertical: 16.h),
                          child: SvgPicture.asset(
                            obscure?'assets/images/eyeClosed.svg':'assets/images/eyeOutline.svg',
                            height: 24.h,
                            //eyeClosed
                            width: 24.w,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (p0) {
                        if(passwordIsError != null){
                          setState(() {
                            passwordIsError = null;
                          });
                        }
                      },
                    ),
                    // Align(
                    //   alignment: AlignmentDirectional.centerEnd,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPasswordScreen(),));
                    //     },
                    //     child: AppText(text: context.localizations.forget_password,fontWeight: FontWeight.w500,color: AppColors.primaryColor,),
                    //   ),
                    // ),
                    SizedBox(height: 40.h,),
                    AppElevatedButton(text: context.localizations.login,
                      onPressed: () async {
                        /*NotificationService.showInstantNotification(
                            "Instant Notification", "This shows an instant notifications");*/
                        /*DateTime scheduledDate = DateTime.now().add( const Duration(seconds: 5));
                        NotificationService().scheduleNotification(
                          10,
                          "Scheduled Notification",
                          "This notification is scheduled to appear after 5 seconds",
                          scheduledDate,
                        );*/
                         setState(() {
                                isLoading = true;
                              });
                              await _performLogin();
                              setState(() {
                                isLoading = false;
                              });
                      },
                    ),

                    SizedBox(height: 24.h,),

                    const Spacer(),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        onTap: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionDetilesScreen(),));
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateNewAccountScreen(),));
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: context.localizations.have_no_account,
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'DINNextLTArabic_Light'
                                ),
                              ),
                              TextSpan(
                                text: " ${context.localizations.create_new_account}",
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'DINNextLTArabic_Light'
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 33.h,),
                  ],
                ),
              ),

              Visibility(
                  visible: isLoading == true,
                  child: const CustomAppLoading()),
            ],
          )


      ),
    );
  }
  Future<void> _performLogin() async {
    if (_checkData()) {

      await _login();

    }
  }

  bool _checkData() {
    if (
    _emailEditingController.text.isNotEmpty &&
        _passwordEditingController.text.isNotEmpty ) {
     return true;
    }else{

      if(_emailEditingController.text.isEmpty){
        setState(() {
          emailIsError = '';
        });
      }
      if(_passwordEditingController.text.isEmpty){
        setState(() {
          passwordIsError = '';
        });
      }
      context.showSnackBar(
          message: context.localizations.enter_required_data, error: true);
      return false;
    }
  }

  Future<void> _login() async {

    FbResponse fbResponse = await FbAuthController().signIn(email:_emailEditingController.text,password: _passwordEditingController.text );
    if(fbResponse.success){
      User? user = FirebaseAuth.instance.currentUser;
      if(user != null){
        try{
          await _getToken();
          await FbFirestoreController().getUserData(doc: user.uid);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => BottomNavigationScreen(),), (route) => false,);
          context.showSnackBar(message: fbResponse.message,);
        }catch(e){
          context.showSnackBar(message: 'حدث خطأ ما ! الرجاء المحاولة مرة اخرى', error: !fbResponse.success);

        }
        print('000${SharedPrefController().getValueFor(key: PrefKeys.userArea.name)}');
      }else{
        context.showSnackBar(message: 'حدث خطأ ما ! الرجاء المحاولة مرة اخرى', error: !fbResponse.success);
      }
    }else{
      context.showSnackBar(message: fbResponse.message, error: !fbResponse.success);

    }
  }

  Future<void> _getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if(token != null){
      SharedPrefController().saveDeviceToken(token);
      print("Device Token: $token");
    }

    // قم بتخزين التوكن في Firestore أو قاعدة بيانات أخرى
  }


  void showPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
          bottomSheetHeight: 600.h,
          inputDecoration: InputDecoration(
              constraints: BoxConstraints(maxHeight: 60.h),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 2.w, color:  AppColors.primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 0.50.w, color:  AppColors.secondGrayColor,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(width: 0.50.w, color:  AppColors.secondGrayColor),
              ),
              prefixIcon: const Icon(Icons.search)
          )
      ),
      onSelect: (Country country) {
        setState(() {
          countryCode = '+${country.phoneCode}';
          countryFlag = country.flagEmoji;
        });
      },
    );
  }

}




