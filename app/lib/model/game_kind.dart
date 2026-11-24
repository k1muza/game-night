import 'cards.dart';

enum GameKind {
  sprint(
    title: '30-Second Sprint',
    tagline: 'Five terms. Thirty seconds. Talk fast.',
    defaultSeconds: 30,
    timerOptions: [30, 45, 60],
    difficulties: [],
  ),
  charades(
    title: 'Charades',
    tagline: 'No words. Just very big gestures.',
    defaultSeconds: 60,
    timerOptions: [45, 60, 90],
    difficulties: [Difficulty.easy, Difficulty.medium, Difficulty.hard],
  ),
  trivia(
    title: 'Trivia Challenge',
    tagline: 'Four options. One answer. Argue fast.',
    defaultSeconds: 20,
    timerOptions: [15, 20, 30],
    difficulties: [Difficulty.easy, Difficulty.medium, Difficulty.hard, Difficulty.expert],
  ),
  forbidden(
    title: 'Forbidden Words',
    tagline: 'Say everything except the obvious.',
    defaultSeconds: 60,
    timerOptions: [45, 60, 90],
    difficulties: [Difficulty.easy, Difficulty.medium, Difficulty.hard],
  );

  const GameKind({
    required this.title,
    required this.tagline,
    required this.defaultSeconds,
    required this.timerOptions,
    required this.difficulties,
  });

  final String title;
  final String tagline;

  final int defaultSeconds;
  final List<int> timerOptions;

  /// Difficulty filters offered in setup (empty = no filter; deck is pre-balanced).
  final List<Difficulty> difficulties;

  /// Whether the card must be hidden from the guessing team.
  bool get hiddenCard => this != GameKind.trivia;

  /// Trivia's timer runs per question; other games run per turn.
  bool get perQuestionTimer => this == GameKind.trivia;

}
