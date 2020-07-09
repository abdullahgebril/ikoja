import 'package:deliveryfood/utilities/cart_pref.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';

class PrefsUtil {
  static void init() {
    UserPrefs.init();
    CartPref.init();
  }
}
