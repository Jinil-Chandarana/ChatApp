import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  //keys
  static String userLonggedInKey = 'LOGGEDINKEY';
  static String userNameKey = 'USERNAMEKEY';
  static String userEmailKey = 'USEREMAILKEY';

  // saving data to SF
  // getting data from SF

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLonggedInKey);
  }
}
