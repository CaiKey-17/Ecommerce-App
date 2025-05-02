class CommentRequest {
  final String username;
  final String content;
  final int? productId;

  CommentRequest({
    required this.username,
    required this.content,
    this.productId,
  });

  Map<String, dynamic> toJson() {
    return {'username': username, 'content': content, 'productId': productId};
  }
}
