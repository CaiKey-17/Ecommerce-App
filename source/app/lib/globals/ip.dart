class ApiConfig {
  // static const String ip = "172.16.10.26";
  // static const String ip = "172.20.10.3";

  // static const String ip = "192.168.1.181";
  static const String ip = "192.168.70.182";

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
