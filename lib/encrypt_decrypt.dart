import 'package:encrypt/encrypt.dart' as encrypt;

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
