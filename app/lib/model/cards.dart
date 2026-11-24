import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

import 'game_kind.dart';

enum Difficulty {
  easy,
  medium,
  hard,
  expert;

  static Difficulty parse(String s) => Difficulty.values.byName(s);

  String get label => '${name[0].toUpperCase()}${name.substring(1)}';
}

class SprintTerm {
  const SprintTerm(this.text, this.difficulty, [this.context]);
  final String text;
  final Difficulty difficulty;

  /// Optional disambiguation label supplied by the dataset (e.g. "Biblical king").
  final String? context;
}

class SprintCard {
  const SprintCard(this.id, this.terms);
  final String id;
  final List<SprintTerm> terms;
}

class CharadesCard {
  const CharadesCard(this.id, this.prompt, this.category, this.difficulty);
  final String id;
  final String prompt;
  final String category;
  final Difficulty difficulty;
}

class TriviaCard {
  const TriviaCard(this.id, this.question, this.answer, this.distractors, this.explanation,
      this.difficulty, this.category);
  final String id;
  final String question;
  final String answer;
  final List<String> distractors;
  final String explanation;
  final Difficulty difficulty;
  final String category;

  /// Option 0 is always the correct answer; display order is shuffled per question.
  List<String> get options => [answer, ...distractors];
}

class ForbiddenCard {
  const ForbiddenCard(this.id, this.target, this.clues, this.difficulty, this.category);
  final String id;
  final String target;
  final List<String> clues;
  final Difficulty difficulty;
  final String category;
}

/// Runtime card library built from the slim decks produced by
/// `tool/build_content.dart`. Contains no editorial metadata.
class ContentLibrary {
  ContentLibrary({
    required List<SprintCard> sprint,
    required List<CharadesCard> charades,
    required List<TriviaCard> trivia,
    required List<ForbiddenCard> forbidden,
  })  : sprint = {for (final c in sprint) c.id: c},
        charades = {for (final c in charades) c.id: c},
        trivia = {for (final c in trivia) c.id: c},
        forbidden = {for (final c in forbidden) c.id: c};

  final Map<String, SprintCard> sprint;
  final Map<String, CharadesCard> charades;
  final Map<String, TriviaCard> trivia;
  final Map<String, ForbiddenCard> forbidden;

  static Future<ContentLibrary> load(AssetBundle bundle) async {
    Future<String> read(String n) => bundle.loadString('assets/decks/$n.json');
    final parts = await Future.wait([read('sprint'), read('charades'), read('trivia'), read('forbidden')]);
    return ContentLibrary.fromJson(
        sprint: parts[0], charades: parts[1], trivia: parts[2], forbidden: parts[3]);
  }

  factory ContentLibrary.fromJson({
    required String sprint,
    required String charades,
    required String trivia,
    required String forbidden,
  }) {
    List<Map<String, dynamic>> rows(String s) => (jsonDecode(s) as List).cast<Map<String, dynamic>>();
    return ContentLibrary(
      sprint: [
        for (final r in rows(sprint))
          SprintCard(r['id'], [
            for (final t in (r['terms'] as List).cast<Map<String, dynamic>>())
              SprintTerm(t['t'], Difficulty.parse(t['d']), t['c'] as String?)
          ])
      ],
      charades: [
        for (final r in rows(charades)) CharadesCard(r['id'], r['p'], r['c'], Difficulty.parse(r['d']))
      ],
      trivia: [
        for (final r in rows(trivia))
          TriviaCard(r['id'], r['q'], r['a'], (r['x'] as List).cast<String>(), r['e'],
              Difficulty.parse(r['d']), r['c'])
      ],
      forbidden: [
        for (final r in rows(forbidden))
          ForbiddenCard(r['id'], r['t'], (r['f'] as List).cast<String>(), Difficulty.parse(r['d']), r['c'])
      ],
    );
  }

  List<String> ids(GameKind g) => switch (g) {
        GameKind.sprint => sprint.keys.toList(),
        GameKind.charades => charades.keys.toList(),
        GameKind.trivia => trivia.keys.toList(),
        GameKind.forbidden => forbidden.keys.toList(),
      };

  int count(GameKind g) => switch (g) {
        GameKind.sprint => sprint.length,
        GameKind.charades => charades.length,
        GameKind.trivia => trivia.length,
        GameKind.forbidden => forbidden.length,
      };

  /// Sprint cards are pre-balanced (2 easy / 2 medium / 1 hard), so they report medium.
  Difficulty difficultyOf(GameKind g, String id) => switch (g) {
        GameKind.sprint => Difficulty.medium,
        GameKind.charades => charades[id]!.difficulty,
        GameKind.trivia => trivia[id]!.difficulty,
        GameKind.forbidden => forbidden[id]!.difficulty,
      };

  String categoryOf(GameKind g, String id) => switch (g) {
        GameKind.sprint => '',
        GameKind.charades => charades[id]!.category,
        GameKind.trivia => trivia[id]!.category,
        GameKind.forbidden => forbidden[id]!.category,
      };

  /// Short text used in turn summaries.
  String labelOf(GameKind g, String id) => switch (g) {
        GameKind.sprint => sprint[id]!.terms.map((t) => t.text).join(' · '),
        GameKind.charades => charades[id]!.prompt,
        GameKind.trivia => trivia[id]!.question,
        GameKind.forbidden => forbidden[id]!.target,
      };
}
