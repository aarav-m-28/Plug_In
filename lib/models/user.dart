class User {
  final String id;
  final String username;
  final String email;
  final String role; // e.g. 'lead', 'member', 'admin'

  User({required this.id, required this.username, required this.email, required this.role});
}
