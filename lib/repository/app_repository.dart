import 'package:app_5/service/api_service.dart';
import 'package:http/http.dart' as http;

class AppRepository{
  final ApiService apiService;
 
  AppRepository(this.apiService);
  
  // Login 
  Future<http.Response> login(Map<String, dynamic> body) async
    => await apiService.post('/deliveryexecutivelogin', body);

  // Executive Profile
  Future<http.Response> executiveProfile(Map<String, dynamic> body) async
    => await apiService.post('/deliveryexecutiveprofile', body);

  // SKU pickuplist API
  Future<http.Response> skupickuplist(Map<String, dynamic> body) async 
    => await apiService.post('/skupickuplist', body);

  // SKU Additional pickuplist API
  Future<http.Response> skuadditionalpickup(Map<String, dynamic> body) async 
    => await apiService.post('/skuadditionalpickup', body);

  // Customer Location
  Future<http.Response> customerLocations(Map<String, dynamic> body) async
    => await apiService.post('/customerlocation', body);

  // Deliverty Location of Customer
  Future<http.Response> decustomerList(Map<String, dynamic> body) async
    => await apiService.post('/decustomerlist', body);

  // Delivery Executive Leave
  Future<http.Response> leavesList(Map<String, dynamic> body) async 
    => await apiService.post('/deleave', body);

  // Delivery Executive Leave Apply
  Future<http.Response> applyLeave(Map<String, dynamic> body) async
    => await apiService.post('/deleaveadd', body);

  // Update a Leave
  Future<http.Response> updateLeave(Map<String, dynamic> body) async
    => await apiService.post('/deleaveupdate', body);
  
  // Delete a Leave 
  Future<http.Response> deleteLeave(Map<String, dynamic> body) async
    => await apiService.post('/deleavedelete', body);

  // Update user current lat lang 
  Future<http.Response> updateLatLang(Map<String, dynamic> body) async
    => await apiService.post('/updatelatlong', body);
  
  // Update Delivery or Deliver the Products
  Future<http.Response> updateDelivery(Map<String, dynamic> body) async
    => await apiService.post('/updatedelivery', body);
}

