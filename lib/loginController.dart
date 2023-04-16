import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';


/* Class responsible for tehe state of login controller (signIn, signOut) */
class LoginController extends GetxController {
  var _googleSignin = GoogleSignIn();
  var googleAccount = Rx<GoogleSignInAccount?>(null);

  login() async {
    googleAccount.value = await _googleSignin.signIn();
  }

  logout() async {
    googleAccount.value = await _googleSignin.signOut();
  }
}