import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app_5/encrypt_decrypt.dart';
import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/model/customer_address_model.dart';
import 'package:app_5/model/delivery_products_model.dart';
import 'package:app_5/model/leaves_model.dart';
import 'package:app_5/model/ordered_products_model.dart';
import 'package:app_5/model/products_model.dart';
import 'package:app_5/model/sku_additional_pickup_model.dart';
import 'package:app_5/model/sku_products_list_model.dart';
import 'package:app_5/repository/app_repository.dart';
import 'package:app_5/screens/main_screen/sigin_page.dart';
import 'package:app_5/service/api_service.dart';
import 'package:app_5/service/background_service.dart';
import 'package:app_5/service/firebase_service.dart';
import 'package:app_5/service/notification_service.dart';
import 'package:app_5/widgets/common_widgets/snackbar_message.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:app_5/helper/navigation_helper.dart';
import 'package:app_5/screens/main_screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider extends ChangeNotifier{
  AppRepository apiRespository = AppRepository(ApiService(baseUrl: "https://maduraimarket.in/api"));
  // AppRepository apiRespository = AppRepository(ApiService(baseUrl: "http://192.168.1.19/pasumaibhoomi-latest/public/api"));
  SharedPreferences prefs = SharedpreferenceHelper.getInstance;
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService.instance;
  // Skupick up list API Data
  List<SkuProduct> skuPickList = [];
  List<ProductsModel> allProducts = [];
  List<OrderedProductsModel> orderedProducts = [];
  Map<int, int> additonalSkuQuantities = {};
  Map<int, int> additionalProductQuantities = {};
  List<int> orderedProductsAdditionalQuantities = [];
  List<SkuAdditionalPickupModel> additionalPickupData = [];
  bool isPicking = false;
  int _messageCount = 0;
  String _token = "cBPTkNbZSZWYU0hmUSz9mR:APA91bF5g0rOLuS94qi2-VVk5P68Ri-GbY7WCL7o8qVtFPDYiNo9BmdjsKiPvPgxMWUtvtU6p8VT2BUPGH7l2q7Jx5dUIt-k5GswJpDnoQc9hr48gZ7ScLI";
  // Leaves Data
  List<LeavesModel> leavesList = [];
  bool notSet = false;
  // Customer Location data
  List<DeliveryProducts> deliveryProductsList = [];
  List<OrderedProductsModel> customerOrderProducts = [];


  // Customer Addresses List
  List<CustomerAddress> addressList = [];

  // Edit Leaves
  DateTime? updatedStartTime;
  DateTime? updatedEndTime;

  void validate(bool isOk){
    notSet = true;
    notifyListeners();
  }

  void updateEditLeave(DateTime? date, bool isStart){
    if (isStart) {
      updatedStartTime = date;
    }else{
      updatedEndTime = date;
    }
    notifyListeners();
  }
  
  /// API CALLS ///

   Future<void> sendPushMessage() async {

    try {
      final response = await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent! ${response.body}');
    } catch (e) {
      print(e);
    }
  }
  String constructFCMPayload(String? token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }
  // Login Delivery executive
  Future<void> loginExecutive(BuildContext context,  Map<String, dynamic> loginData, Size size) async {
    final response = await apiRespository.login(loginData);
    final decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    final decodedResponse = json.decode(decryptedResponse);
    print('Login Response Data: $decodedResponse, Status Code: ${response.statusCode}');
    final loginMessgae = snackBarMessage(
      context: context, 
      message: decodedResponse['message'], 
      backgroundColor: const Color(0xFF60B47B), 
      sidePadding: size.width * 0.1,
      bottomPadding:  size.height * 0.05
    );
    if(response.statusCode == 200 && decodedResponse["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(loginMessgae).closed.then((value) async{
        await getProfile();
        await _firebaseService.sendLocationToFirebase();
        await BackgroundService.initializeService();
      },);
      await prefs.setString('executiveId', decodedResponse['deliveryexecutive_id'].toString());
      await prefs.setBool('${decodedResponse['deliveryexecutive_id']}isLogged', true);
      print("Stored: ${prefs.getBool("${prefs.getString("executiveId")}isLogged")}");
        Navigator.pushReplacement(context, SideTransiion(screen: const HomeScreen(), ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(loginMessgae);
      print("Error: $decodedResponse");
    }
    notifyListeners();
  }

  Future<bool> isloggedIn() async {
    print("Executive ID: ${prefs.getString('executiveId')}");
    bool logged = prefs.getBool('${prefs.getString('executiveId')}isLogged') ?? false;
    print("Logging : $logged");
    if(logged) {
      await getProfile();
      // await _firebaseService.sendLocationToFirebase();
      // await BackgroundService.initializeService();
      return true;
    }
    return false;
  }

  // Forget password
  Future<void> forgetPassword(BuildContext context,  Map<String, dynamic> forgetPasswordData, Size size) async {
    final response = await apiRespository.forgetPassword(forgetPasswordData);
    final decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    final decodedResponse = json.decode(decryptedResponse);
    print('Forget password response data: $decodedResponse, Status Code: ${response.statusCode}');
    final forgetMessage = snackBarMessage(
      context: context, 
      message: decodedResponse['message'], 
      backgroundColor: const Color(0xFF60B47B), 
      sidePadding: size.width * 0.1,
      bottomPadding:  size.height * 0.05
    );
    if(response.statusCode == 200 && decodedResponse["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(forgetMessage).closed.then((value){
        Navigator.pop(context);
      },);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(forgetMessage);
      print("Error: $decodedResponse");
    }
    notifyListeners();
  }

  // Executive Profile
  Future<void> getProfile() async {
    Map<String, dynamic> profileData = {
      'deliveryexecutive_id': prefs.getString('executiveId'),
    };
    final response = await apiRespository.executiveProfile(profileData);
    String decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    final decodedResponse = json.decode(decryptedResponse);
    print('Executive Profile Response: $decodedResponse, Stauts Code: ${response.statusCode}');
    if (response.statusCode == 200 && decodedResponse['status'] == 'success') {
      prefs.setString('executiveName', decodedResponse['results']['name']);
      prefs.setString('executiveEmail', decodedResponse['results']['email']);
      prefs.setString('executiveMobile', decodedResponse['results']['mobile_no']);
      notifyListeners();
    } else {
      print('Failed to fetch profile data. Status code: ${response.statusCode}');
    }
}

  // Sku pickup list for Executive
  Future<void> skuListAPI() async {
    Map<String, dynamic> skuPickListData = {'deliveryexecutive_id': prefs.getString('executiveId') };
    
    final response = await apiRespository.skupickuplist(skuPickListData);
    String decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    final decodedResponse = json.decode(decryptedResponse);
    debugPrint('SKu pickup list data: $decodedResponse',wrapWidth: 1064);
   
    if(response.statusCode == 200){

      List<dynamic> responseList = decodedResponse['results'] as List;
      List<dynamic> productsList = decodedResponse['product_list'] as List;
      List<dynamic> additionalProducts = decodedResponse['additional_order_products'] as List;
        skuPickList.clear();
        allProducts.clear();
        orderedProducts.clear();
        try {
          skuPickList = responseList.map((json) {
            try {
              return SkuProduct.fromJson(json);
            } catch (e, st) {
              log("Error parsing skuproducts", error: e.toString(), stackTrace: st);
              return null; 
            }
          }).whereType<SkuProduct>().toList();
          allProducts = productsList.map((json){
            try {
              return ProductsModel.fromMap(json);
            } catch (e, st) {
              log("Error parsing products", error: e.toString(), stackTrace: st);
              return null;
            }
          }).whereType<ProductsModel>().toList();
          orderedProducts = additionalProducts.map((json) => OrderedProductsModel.fromMap(json)).toList();
        } on Exception catch (e, st) {
          log("Sku pickuplist log: ", error: e.toString, stackTrace: st);
        }
        // skuPickList.addAll(tempList);
        // allProducts.addAll(products);
        // orderedProducts.addAll(additionalProductsList);
        for (var i = 0; i < skuPickList.length; i++) {
          additonalSkuQuantities.addAll({skuPickList[i].productId: 0});
        }
        for (var i = 0; i < allProducts.length; i++) {
          additionalProductQuantities.addAll({allProducts[i].id: 0});
        }
        orderedProductsAdditionalQuantities = List.generate(orderedProducts.length, (index) => 0,);
      prefs.setString('calledToday', DateTime(DateTime.now().day).toString());
    }
    notifyListeners();
  }

  void picked(bool isPicked){
    isPicking= isPicked;
    notifyListeners();
  }

  // Increase and decrease oprations
  void additionalSku(int productId, bool isAdd){
    if (isAdd) {
      additonalSkuQuantities[productId] = additonalSkuQuantities[productId]! + 1;
    }else{
      if (additonalSkuQuantities[productId]! > 0) {
      additonalSkuQuantities[productId] = additonalSkuQuantities[productId]! - 1;
      }
    }
    notifyListeners();
  }

  // Increase and decrease oprations
  void additionalOrder(int index, bool isAdd){
    if (isAdd) {
      orderedProductsAdditionalQuantities[index] = orderedProductsAdditionalQuantities[index] + 1;
    }else{
      if (orderedProductsAdditionalQuantities[index] > 0) {
        orderedProductsAdditionalQuantities[index] = orderedProductsAdditionalQuantities[index] - 1;
      }
    }
    notifyListeners();
  }

  // Increase and decrease oprations
  void additionalProduct(int id, bool isAdd){
    if (isAdd) {
      additionalProductQuantities[id] = additionalProductQuantities[id]! + 1;
    }else{
      if (additionalProductQuantities[id]! > 0) {
        additionalProductQuantities[id] = additionalProductQuantities[id]! - 1;
      }
    }
    notifyListeners();
  }

  // Update Picked up inventry list
  Future<void> pickupList(Size size, BuildContext context) async {
      additionalPickupData.clear();
      // Add all the Subscribed products (sku)
      for (var i = 0; i < skuPickList.length; i++) {
        additionalPickupData.add(
          SkuAdditionalPickupModel(
            productId: skuPickList[i].productId, 
            executiveid: int.parse(prefs.getString('executiveId') ?? "0"), 
            skuPickupQunatity: skuPickList[i].mrgQty + skuPickList[i].evgQty, 
            additionalquantity: additonalSkuQuantities[skuPickList[i].productId]!, 
            date: DateFormat("yyyy-MM-dd").format(DateTime.now())
          )
        );
      }
      // Add all the ordered products 
      for (var i = 0; i < orderedProducts.length; i++) {
        additionalPickupData.add(
          SkuAdditionalPickupModel(
            productId: orderedProducts[i].productId, 
            executiveid: int.parse(prefs.getString('executiveId') ?? "0"), 
            skuPickupQunatity: int.parse(orderedProducts[i].quantity), 
            additionalquantity: orderedProductsAdditionalQuantities[i], 
            date: DateFormat("yyyy-MM-dd").format(DateTime.now())
          )
        );
      }
      // Add all additional products 
      for (var i = 0; i <  allProducts.length; i++) {
        additionalProductQuantities[allProducts[i].id]! > 0
          ? additionalPickupData.add(
              SkuAdditionalPickupModel(
              productId: allProducts[i].id, 
              executiveid: int.parse(prefs.getString('executiveId') ?? "0"), 
              skuPickupQunatity: 0, 
              additionalquantity: additionalProductQuantities[allProducts[i].id]!, 
              date: DateFormat("yyyy-MM-dd").format(DateTime.now())
            )
          )
          : null;
      }
                
    print('Length : ${additionalPickupData.length}');
    final convertPickupDataToJson = additionalPickupData.map((map) => map.toMap(),).toList();
    Map<String, dynamic> pickupData = {'product_data':  convertPickupDataToJson};
    // String jsonData = convertPickupDataToJson.map((map) => json.encode(map),).toString();
    final response = await apiRespository.skuadditionalpickup(pickupData);
      
    String decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), "");
    final decodedReponse = json.decode(decryptedResponse);
    print('Pick up list update Response: $decodedReponse, Status code: ${response.statusCode}, ');
    final pickupMessage = snackBarMessage(
      context: context, 
      message: decodedReponse['message'], 
      backgroundColor: Theme.of(context).primaryColor,
      bottomPadding: size.height * 0.12,
      sidePadding: size.width * 0.08
    );
    if (response.statusCode == 200 && decodedReponse['status'] == "success") {
      _notificationService.showNotifiation("Pickup list are updated", "Products picked", "Picked the products for delivery", "payload");
      ScaffoldMessenger.of(context).showSnackBar(pickupMessage).closed.then((value) {
        for (var i = 0; i < skuPickList.length; i++) {
          additonalSkuQuantities.addAll({skuPickList[i].productId: 0});
        }
        for (var i = 0; i < allProducts.length; i++) {
          additionalProductQuantities.addAll({allProducts[i].id: 0});
        }
        orderedProductsAdditionalQuantities = List.generate(orderedProducts.length, (index) => orderedProductsAdditionalQuantities[index] = 0,);
        notifyListeners();
      },);
    } else {
      print('Add Pickup list Error: $decodedReponse');
    }
    notifyListeners();
  }

  // Leave history API
  Future<void> leavesListAPI(BuildContext context)async {
    Map<String, dynamic> leaveData = {'delivery_executive_id': prefs.getString("executiveId")};
    final response = await apiRespository.leavesList(leaveData);
    final decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), "");
    final decodedResponse = json.decode(decryptedResponse);
    print('Leave History Response: $decodedResponse, Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      List<dynamic> leaveHistory = decodedResponse['results'] as List;
      leavesList = leaveHistory.map((map) => LeavesModel.fromMap(map),).toList().reversed.toList();
      notifyListeners();
    }else{
      print("Error: $decodedResponse");
    }
    notifyListeners();
  }

  // Delete Leave
  Future<void> deleteLeave(int leaveId, Size size, int index, BuildContext context) async {
    Map<String, dynamic> deleteData = {"leave_id": leaveId};
    final response = await apiRespository.deleteLeave(deleteData);
    final decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), "");
    final decodedResponse = json.decode(decryptedResponse);
    print('Delete Leave Response: $decodedResponse, Status Code: ${response.statusCode}');
    final deleteLeaveMessage = snackBarMessage(
      context: context, 
      message: decodedResponse['message'], 
      backgroundColor: const Color(0xFF60B47B), 
      sidePadding: size.width * 0.1, 
      bottomPadding: size.height * 0.05
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(deleteLeaveMessage).closed.then((value) {
        leavesList.removeAt(index);
  
        leavesListAPI(context);
      },);
    }else{
        ScaffoldMessenger.of(context).showSnackBar(deleteLeaveMessage);
      print('Error: $decodedResponse');
    }
  
  }
  
  Future<void> editLeaveAPi({required int index, required int leaveId, 
    required Size size, 
    required String startDate, 
    required String endDate,
    required BuildContext context, 
    required String comments}) async {
    Map<String, dynamic> updateLeaveData = {
      "delivery_executive_id": prefs.getString("executiveId"),
      "leave_id": leaveId,
      "start_date": startDate,
      "end_date": endDate,
      "comments": comments
    };
    final response = await apiRespository.updateLeave(updateLeaveData);
    final decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), "");
    final decodedResponse = json.decode(decryptedResponse);
    print('Update Leave Response: $decodedResponse, Status Code: ${response.statusCode}');
    final updateLeaveMessage = snackBarMessage(
      context: context, 
      message: decodedResponse['message'], 
      backgroundColor: const Color(0xFF60B47B), 
      sidePadding: size.width * 0.1, 
      bottomPadding: size.height * 0.05
    );
    if (response.statusCode == 200 && decodedResponse['status'] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(updateLeaveMessage).closed.then((value) async {
        await leavesListAPI(context);
      },);
      notifyListeners();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(updateLeaveMessage);
      print('Error: $decodedResponse');
    }
    notifyListeners();
  }

  // Delivery list Screen and Customer location APi
  Future<void> deliverListAPi() async {
    Map<String, dynamic> customerData = {
      'deliveryexecutive_id': prefs.getString('executiveId')
    };
    final response = await apiRespository.customerLocations(customerData);
    final decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    final decodedResponse = json.decode(decryptedResponse);
    debugPrint('Delivery List Response: $decodedResponse, Status code: ${response.statusCode}', wrapWidth: 1064);
    if(response.statusCode == 200 && decodedResponse["status"] == "success"){
      if (decodedResponse["location_data"].isEmpty) {
        throw const HttpException("Delivery data is empty");
      }else{
        List<dynamic> results = decodedResponse['location_data'] as List;
        deliveryProductsList.clear();
        deliveryProductsList = results.map((result) => DeliveryProducts.fromJson(result)).toList();
        throw Exception("Data found");
      }
    }else{ 
      print('Error in customer Location $decodedResponse');
    }
    notifyListeners();
  }

  // Get Customer Location
  Future<void> customerAddressList() async {
    Map<String, dynamic> userData = {
      'deliveryexecutive_id': prefs.getString('executiveId') 
    };
    final response = await apiRespository.decustomerList(userData);
    final decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    final decodedResponse = json.decode(decryptedResponse);
    debugPrint('Update Customer Location Response: $decodedResponse, Status code: ${response.statusCode}', wrapWidth: 1064);
    if(response.statusCode == 200){
      List<dynamic> responseList = decodedResponse['results'] as List;
      addressList.clear();
      addressList = responseList.map((json) => CustomerAddress.fromJson(json)).toList();
    }
    notifyListeners();
  }

  void clearUserSession(BuildContext context){
     for (var i = 0; i < skuPickList.length; i++) {
      additonalSkuQuantities.addAll({skuPickList[i].productId: 0});
    }
    for (var i = 0; i < allProducts.length; i++) {
      additionalProductQuantities.addAll({allProducts[i].id: 0});
    }
    orderedProductsAdditionalQuantities = List.generate(orderedProducts.length, (index) => orderedProductsAdditionalQuantities[index] = 0,);
        
    additionalPickupData.clear();
    addressList.clear();
    customerOrderProducts.clear();
    deliveryProductsList.clear();
    orderedProducts.clear();
    customerOrderProducts.clear();
    leavesList.clear();
    skuPickList.clear();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage(),), (route)=> false);
    notifyListeners();
  }

  // confirm logout
  void confirmLogout(BuildContext context, Size size){
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set your desired border radius
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            // padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 180,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Center(
                        child: TextWidget(text: "Logout", fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 16,),
                      Center(
                        child: Text(
                           "Do you want logout?",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400
                           ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero
                      ),
                      backgroundColor: Colors.transparent.withValues(alpha: 0.0),
                      shadowColor: Colors.transparent.withValues(alpha: 0.0),
                      elevation: 0,
                      overlayColor: Colors.transparent.withValues(alpha: 0.1)
                    ),
                    onPressed: () async{
                      Navigator.pop(context);
                      // Clear User identity
                      await prefs.clear();
                      print("${prefs.getString("customerId")}");
                      clearUserSession(context);
                    }, 
                    child: const TextWidget(
                      text: "Confirm", 
                      fontSize: 14, fontWeight: FontWeight.w400, 
                      fontColor: Colors.red,)
                  )
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent.withValues(alpha: 0.0),
                      shadowColor: Colors.transparent.withValues(alpha: 0.0),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero
                      ),
                      overlayColor: Colors.transparent.withValues(alpha: 0.1)
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }, 
                    child: const TextWidget(text: "Cancel", fontSize: 14, fontWeight: FontWeight.w400, fontColor: Colors.grey,)
                  ),
                ),
                const SizedBox(height: 10,)
              ],
            ),
          )
        );
      },
    );
  
  }

  // Confirm Delete Leave
  void confirmDeleteLeave(BuildContext context, Size size, int leaveId, int index){
    showDialog(
      context: context,
      builder: (builderContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set your desired border radius
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            // padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 180,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Center(
                        child: TextWidget(text: "Delete Leave", fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 16,),
                      Center(
                        child: Text(
                           "Do you want delete this leave?",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400
                           ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero
                      ),
                      backgroundColor: Colors.transparent.withValues(alpha: 0.0),
                      shadowColor: Colors.transparent.withValues(alpha: 0.0),
                      elevation: 0,
                      overlayColor: Colors.transparent.withValues(alpha: 0.1)
                    ),
                    onPressed: () async{
                      Navigator.pop(builderContext);
                      await deleteLeave(leaveId, size, index, context);
                      
                    }, 
                    child: const TextWidget(
                      text: "Confirm", 
                      fontSize: 14, fontWeight: FontWeight.w400, 
                      fontColor: Colors.red,)
                  )
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent.withValues(alpha: 0.0),
                      shadowColor: Colors.transparent.withValues(alpha: 0.0),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero
                      ),
                      overlayColor: Colors.transparent.withValues(alpha: 0.1)
                    ),
                    onPressed: () {
                      Navigator.pop(builderContext);
                    }, 
                    child: const TextWidget(text: "Cancel", fontSize: 14, fontWeight: FontWeight.w400, fontColor: Colors.grey,)
                  ),
                ),
                const SizedBox(height: 10,)
              ],
            ),
          )
        );
      },
    );
  
  }
    
  void messagePopup(BuildContext context, Size size, String image, String message){
    showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          // backgroundColor: Colors.transparent.withValues(alpha: 0.1),
          child: SizedBox(
            height: size.height * 0.3,
            // width: size.width * 0.,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 30,),
                Center(
                  child: SizedBox(
                    height: size.height * 0.1,
                    width:  size.width * 0.2,
                    child: Image.asset(
                      "assets/happy-face.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                TextWidget(text: "Order Placed Successfully", fontSize: 20, fontWeight: FontWeight.w500, fontColor: Theme.of(context).primaryColorDark,),
                // const SizedBox(height: 10,),
                TextWidget(text: "Thank you!", fontSize: 16, fontWeight: FontWeight.w400, fontColor: Theme.of(context).primaryColorDark,),
                const SizedBox(height: 30,),
              ],
            ),
          ),
        );
      },
    );
  }

}
