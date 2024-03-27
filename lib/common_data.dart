import 'package:encrypt/encrypt.dart' as encrypt;

class UserId{
  static int? _userId;
  static int? _agentId; 
  static String? _productId;
  static String? _subId;

  static void setAgentId(int agentId){
    _agentId = agentId;
  }
  static int? getAgentId(){
    return _agentId;
  }
  static void setUserId(int userId) {
    _userId = userId;
  }

  static int? getUserId() {
    return _userId;
  }
  static void setSubId(String subId) {
    _subId = subId;
  }

  static String? getSubId() {
    return _subId;
  }
  static void setproductId(String productId) {
    _productId = productId;
  }

  static String? getproductId() {
    return _productId;
  }
}

// Key and Iv
String key = '3mtree8u51n33ss501ut10nm33n6v33r';
String iv = 'm33n6v33r6561r6w';

// Encryption method 
String encryptAES(String textToEncrypt){
  final secertKey = encrypt.Key.fromUtf8(key);
  final ivKey = encrypt.IV.fromUtf8(iv);
  final encrypter = encrypt.Encrypter(encrypt.AES(secertKey, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(textToEncrypt, iv: ivKey);
  return encrypted.base64;
}

String decryptAES(String encryptedData,)  {
  try{
  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key), mode: encrypt.AESMode.cbc, padding: null));
  final encryptedBytes = encrypter.decrypt64(encryptedData, iv: encrypt.IV.fromUtf8(iv));
  return encryptedBytes;
  }catch(e){
    return 'null';
  }
}


class ProductDetails {
  final int productId;
  final String productName;
  final String quantity;
  final int mrngQty;
  final int evgQty;
  final String productPrice;

  ProductDetails({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.mrngQty,
    required this.evgQty,
    required this.productPrice,
  });
}

