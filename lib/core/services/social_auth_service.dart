// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class SocialAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     clientId:
//         "694896701610-5ql9bohohl6b7sq4jghhs37fqs3b727b.apps.googleusercontent.com",
//   );

//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // Trigger the authentication flow
//       print("👉 Starting Google Sign-In...");

//       // Force account picker by signing out first
//       await _googleSignIn.signOut();

//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) {
//         print("❌ Google Sign-In canceled by user.");
//         return null;
//       }

//       print("👉 User picked account: ${googleUser.email}");

//       // Obtain the auth details from the request
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       print("👉 Obtained Google Auth tokens.");

//       // Create a new credential
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       print("👉 Signing in to Firebase with credential...");
//       // Once signed in, return the UserCredential
//       final userCredential = await _auth.signInWithCredential(credential);
//       print("✅ Firebase Sign-In successful: ${userCredential.user?.email}");
//       return userCredential;
//     } catch (e, stack) {
//       print('❌ Error during Google Sign-In: $e');
//       print(stack);
//       rethrow; // Rethrow so the provider can catch and show the actual error
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }
