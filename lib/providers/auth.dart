import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:max_shop/models/http_exception.dart';

class Auth with ChangeNotifier {

  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth{
    return token != null;
  }

  String get token{
    if(_token != null && _expiryDate != null && _expiryDate.isAfter(DateTime.now())){
      return _token;
    }
    return null;
  }

  static const String apiKey = 'AIzaSyDT_GhqVH4jHE49ZJQKSqI3MeE3B4sD0iU';

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$apiKey';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
//      _userId = responseData['idToken'];

      print('Id Token >>>> ${responseData['idToken']}');
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }
}
