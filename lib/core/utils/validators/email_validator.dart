class EmailValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    const emailRegex =
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$';

    if (!RegExp(emailRegex).hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    if (value.length > 254) {
      return 'Email address is too long';
    }

    return null;
  }
}
