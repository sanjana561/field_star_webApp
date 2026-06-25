import 'package:field_star/model/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  AppUser? _userFromSupabaseUser(User? user) {
    return user != null
        ? AppUser(
            uid: user.id,
            email: user.email ?? 'anonymous',
          )
        : null;
  }

  Stream<AppUser?> get user {
    return _supabase.auth.onAuthStateChange.map((data) {
      return _userFromSupabaseUser(data.session?.user);
    });
  }

  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return _userFromSupabaseUser(response.user);
    } on AuthException catch (e) {
      print("SignIn Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("SignIn Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}