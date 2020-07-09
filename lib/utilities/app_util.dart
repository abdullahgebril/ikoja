class AppUtil {
  static String generateUniqueId() {
    return new DateTime.now().millisecondsSinceEpoch.toString();
  }
}
