class CommentReplyRequest {
  final String username;
  final String content;
  final int? commentId;

  CommentReplyRequest({
    required this.username,
    required this.content,
    this.commentId,
  });

  Map<String, dynamic> toJson() {
    return {'username': username, 'content': content, 'commentId': commentId};
  }
}
