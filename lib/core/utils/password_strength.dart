class PasswordStrength {
  static int score(String password) {
    int s = 0;
    if (password.length >= 8) s += 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) s += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) s += 1;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) s += 1;
    return s; 
  }

  static String label(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
      default:
        return 'Strong';
    }
  }
}
