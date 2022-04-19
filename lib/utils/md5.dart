import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

class Md5Hash {
  static String create(String text){
    var content = new Utf8Encoder().convert(text);
    var md5 = crypto.md5;
    return md5.convert(content).toString();
  }

}
