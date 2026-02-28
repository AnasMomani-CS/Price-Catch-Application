class AuthService {

  Future<void> login(String email, String password) async {
    // FirebaseAuth.instance.signInWithEmailAndPassword(...)
  }

  Future<void> registerUser(
      String name, String email, String password) async {
    // create user in firebase
  }

  Future<void> registerSeller(
      String storeName, String email, String password, String phone) async {
    // create seller in firebase
  }
}