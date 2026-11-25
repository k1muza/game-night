// Serializable single-device session state shared by all four games.
//
// Lifecycle:  (setup screen) → ready → playing → turnResults → ready … → gameResults
import '../model/cards.dart';
import '../model/game_kind.dart';

enum Phase { ready, playing, turnResults, gameResults }

enum Outcome {
  /// Guessed / answered correctly (+1).
  correct,

  /// Skipped (Charades, Forbidden) or not reached (Sprint) — 0.
  pass,

  /// Forbidden-word violation — −1.
  violation,

  /// Trivia: locked a wrong answer — 0.
  wrong,

  /// Trivia: time ran out with no answer — 0.
  timeout;

  int get points => switch (this) {
    correct => 1,
    violation => -1,
    _ => 0,
  };
}

enum EndReason { time, allFound, finished, questionsDone }

class Team {
  Team(this.name, this.paletteIndex);
  String name;

  /// Index into the design-system team palette (colour + shape), 0–5.
  final int paletteIndex;

  Map<String, dynamic> toJson() => {'n': name, 'p': paletteIndex};
  factory Team.fromJson(Map<String, dynamic> j) => Team(j['n'], j['p']);
}

class GameConfig {
  const GameConfig({
    required this.game,
    this.rounds = 5,
    int? seconds,
    this.questionsPerTurn = 5,
    this.difficulty,
  }) : seconds = seconds ?? 0;

  final GameKind game;
  final int rounds;

  /// Turn length (Sprint/Charades/Forbidden) or per-question length (Trivia).
  final int seconds;
  final int questionsPerTurn;

  /// null = mixed (the default).
  final Difficulty? difficulty;

  int get effectiveSeconds => seconds > 0 ? seconds : game.defaultSeconds;

  Map<String, dynamic> toJson() => {
    'g': game.name,
    'r': rounds,
    's': effectiveSeconds,
    'q': questionsPerTurn,
    'd': difficulty?.name,
  };

  factory GameConfig.fromJson(Map<String, dynamic> j) => GameConfig(
    game: GameKind.values.byName(j['g']),
    rounds: j['r'],
    seconds: j['s'],
    questionsPerTurn: j['q'],
    difficulty: j['d'] == null ? null : Difficulty.parse(j['d']),
  );
}

class TurnEvent {
  TurnEvent(this.cardId, this.outcome, {this.term, this.choice});
  final String cardId;
  final Outcome outcome;

  /// Sprint: index of the term on the card.
  final int? term;

  /// Trivia: option index chosen (0 = correct), null when unanswered.
  final int? choice;

  Map<String, dynamic> toJson() => {
    'c': cardId,
    'o': outcome.name,
    if (term != null) 't': term,
    if (choice != null) 'x': choice,
  };
  factory TurnEvent.fromJson(Map<String, dynamic> j) => TurnEvent(
    j['c'],
    Outcome.values.byName(j['o']),
    term: j['t'],
    choice: j['x'],
  );
}

/// The live turn. Exactly one of [deadlineMs] / [pausedRemainingMs] is set while the
/// clock is meaningful; both are null during a Trivia answer reveal.
class Turn {
  Turn({
    this.deadlineMs,
    this.pausedRemainingMs,
    List<TurnEvent>? events,
    this.cardId,
    Set<int>? marked,
    List<Difficulty>? slots,
    this.qIndex = 0,
    List<int>? optionOrder,
    this.selected,
    this.revealed = false,
    this.ended,
    this.skips = 0,
  }) : events = events ?? [],
       marked = marked ?? {},
       slots = slots ?? [],
       optionOrder = optionOrder ?? [];

  int? deadlineMs;
  int? pausedRemainingMs;
  final List<TurnEvent> events;

  /// Card on screen: Sprint card, Charades/Forbidden prompt or Trivia question.
  /// null when the deck ran out mid-turn.
  String? cardId;

  // Sprint
  final Set<int> marked;

  /// Sprint: cards skipped this turn (one allowed, before any term is ticked).
  int skips;

  // Trivia
  final List<Difficulty> slots;
  int qIndex;

  /// Display position → option index (0 = correct answer).
  List<int> optionOrder;

  /// Display position currently selected (not yet locked).
  int? selected;
  bool revealed;

  EndReason? ended;

  bool get paused => pausedRemainingMs != null;

  int get points => events.fold(0, (s, e) => s + e.outcome.points);
  int count(Outcome o) => events.where((e) => e.outcome == o).length;

  Map<String, dynamic> toJson() => {
    'dl': deadlineMs,
    'pr': pausedRemainingMs,
    'ev': events.map((e) => e.toJson()).toList(),
    'c': cardId,
    'm': marked.toList(),
    'sk': skips,
    'sl': slots.map((d) => d.name).toList(),
    'qi': qIndex,
    'oo': optionOrder,
    'se': selected,
    'rv': revealed,
    'en': ended?.name,
  };

  factory Turn.fromJson(Map<String, dynamic> j) => Turn(
    deadlineMs: j['dl'],
    pausedRemainingMs: j['pr'],
    events: [for (final e in j['ev'] as List) TurnEvent.fromJson(e)],
    cardId: j['c'],
    marked: {...(j['m'] as List).cast<int>()},
    skips: j['sk'] ?? 0,
    slots: [for (final s in j['sl'] as List) Difficulty.parse(s)],
    qIndex: j['qi'],
    optionOrder: (j['oo'] as List).cast<int>(),
    selected: j['se'],
    revealed: j['rv'],
    ended: j['en'] == null ? null : EndReason.values.byName(j['en']),
  );
}

class TurnRecord {
  TurnRecord({
    required this.team,
    required this.round,
    required this.points,
    required this.events,
  });
  final int team;
  final int round;
  final int points;
  final List<TurnEvent> events;

  int count(Outcome o) => events.where((e) => e.outcome == o).length;

  Map<String, dynamic> toJson() => {
    't': team,
    'r': round,
    'p': points,
    'ev': events.map((e) => e.toJson()).toList(),
  };
  factory TurnRecord.fromJson(Map<String, dynamic> j) => TurnRecord(
    team: j['t'],
    round: j['r'],
    points: j['p'],
    events: [for (final e in j['ev'] as List) TurnEvent.fromJson(e)],
  );
}

class Session {
  Session({
    required this.config,
    required this.teams,
    required this.queues,
    required this.seed,
    required this.createdAt,
    List<int>? scores,
    this.round = 1,
    this.teamIndex = 0,
    this.phase = Phase.ready,
    Set<String>? used,
    this.turn,
    List<TurnRecord>? history,
    this.endedEarly = false,
    int? updatedAt,
    this.contentFingerprints,
  }) : scores = scores ?? List.filled(teams.length, 0),
       used = used ?? {},
       history = history ?? [],
       updatedAt = updatedAt ?? createdAt;

  final GameConfig config;
  final List<Team> teams;
  final List<int> scores;

  /// 1-based.
  int round;
  int teamIndex;
  Phase phase;

  /// Remaining draw order. Trivia keys by difficulty name; other games use 'main'.
  final Map<String, List<String>> queues;

  /// Card IDs dealt in this session (never dealt again unless explicitly reshuffled).
  final Set<String> used;
  Turn? turn;
  final List<TurnRecord> history;
  final int seed;
  final int createdAt;
  int updatedAt;
  bool endedEarly;
  final Map<String, String>? contentFingerprints;

  GameKind get game => config.game;
  Team get activeTeam => teams[teamIndex];
  int get completedTurns => history.length;
  int get totalTurns => config.rounds * teams.length;

  Map<String, dynamic> toJson() => {
    'v': 1,
    'cf': contentFingerprints,
    'cfg': config.toJson(),
    'teams': teams.map((t) => t.toJson()).toList(),
    'scores': scores,
    'round': round,
    'ti': teamIndex,
    'phase': phase.name,
    'q': queues,
    'used': used.toList(),
    'turn': turn?.toJson(),
    'hist': history.map((h) => h.toJson()).toList(),
    'seed': seed,
    'ca': createdAt,
    'ua': updatedAt,
    'ee': endedEarly,
  };

  factory Session.fromJson(Map<String, dynamic> j) {
    if (j['v'] != 1) throw const FormatException('Unsupported session version');
    return Session(
      config: GameConfig.fromJson(j['cfg']),
      teams: [for (final t in j['teams'] as List) Team.fromJson(t)],
      scores: (j['scores'] as List).cast<int>().toList(),
      round: j['round'],
      teamIndex: j['ti'],
      phase: Phase.values.byName(j['phase']),
      queues: {
        for (final e in (j['q'] as Map<String, dynamic>).entries)
          e.key: (e.value as List).cast<String>().toList(),
      },
      used: {...(j['used'] as List).cast<String>()},
      turn: j['turn'] == null ? null : Turn.fromJson(j['turn']),
      history: [for (final h in j['hist'] as List) TurnRecord.fromJson(h)],
      seed: j['seed'],
      createdAt: j['ca'],
      updatedAt: j['ua'],
      endedEarly: j['ee'] ?? false,
      contentFingerprints: j['cf'] == null
          ? null
          : (j['cf'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
    );
  }
}

/// A team's place in the standings. Tied teams share a rank.
class Standing {
  Standing(this.team, this.score, this.rank, this.tied);
  final int team;
  final int score;
  final int rank;
  final bool tied;
}

List<Standing> standingsFor(List<int> scores) {
  final order = List.generate(scores.length, (i) => i)
    ..sort((a, b) => scores[b] != scores[a] ? scores[b] - scores[a] : a - b);
  return [
    for (final i in order)
      Standing(
        i,
        scores[i],
        1 + scores.where((s) => s > scores[i]).length,
        scores.where((s) => s == scores[i]).length > 1,
      ),
  ];
}
