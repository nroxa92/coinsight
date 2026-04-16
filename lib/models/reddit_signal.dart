/// Signal koji dolazi s Reddit javnih crypto subreddita
/// Reddit = retail community sentiment, malo kasni za smartim novcem
/// Ali visoka upvote velocity na nepoznatom coinu = pump počinje
class RedditSignal {
  final String postId;
  final String title;
  final String subreddit;
  final int upvotes;
  final int comments;
  final double upvoteRatio;
  final DateTime createdAt;
  final DateTime detectedAt;
  final List<String> mentionedSymbols;

  RedditSignal({
    required this.postId,
    required this.title,
    required this.subreddit,
    required this.upvotes,
    required this.comments,
    required this.upvoteRatio,
    required this.createdAt,
    required this.detectedAt,
    required this.mentionedSymbols,
  });

  int get ageHours => DateTime.now().difference(createdAt).inHours;

  bool get isFresh => ageHours <= 12;

  double get momentumScore =>
      (upvotes * upvoteRatio) / ageHours.clamp(1, 24);

  String toClaudeContext() {
    return '[REDDIT SIGNAL — r/$subreddit]\n'
        'Naslov: $title\n'
        'Upvotes: $upvotes (ratio: ${(upvoteRatio * 100).toStringAsFixed(0)}%)\n'
        'Komentari: $comments\n'
        'Starost: ${ageHours}h\n'
        'Momentum score: ${momentumScore.toStringAsFixed(1)}\n'
        'Spominjani simboli: ${mentionedSymbols.join(", ")}';
  }
}
