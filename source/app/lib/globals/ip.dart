class ApiConfig {
  // static const String ip = "192.168.70.182";
  static const String ip = "192.168.100.228";

  static const String baseUrlSentiment = "http://$ip:5001";
  static const String baseUrlAPI = "http://$ip:8080/api";
  static const String baseUrlDetect = "http://$ip:5002/detect/";
  static const String baseUrlWsc = "http://$ip:8080/ws";
  static const String baseUrlWscHistory = "http://$ip:8080/api";

  static Uri getChatMessages(int senderId, int receiverId) {
    return Uri.parse('$baseUrlWscHistory/chat/messages/$senderId/$receiverId');
  }

  static Uri getChatContact(int currentUserId) {
    return Uri.parse('$baseUrlWscHistory/chat/contacts/$currentUserId');
  }
}
