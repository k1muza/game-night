import 'dart:math';

import '../model/cards.dart';
import '../model/game_kind.dart';

/// Builds draw orders for a session. Pure functions; the caller owns the [Random].
class DeckPlanner {
  /// Default mixed-deck difficulty weights. Keeps Charades and Forbidden Words
  /// approachable without concentrating hard or specialist cards.
  static const Map<GameKind, Map<Difficulty, double>> mixedWeights = {
    GameKind.charades: {Difficulty.easy: 0.5, Difficulty.medium: 0.38, Difficulty.hard: 0.12},
    GameKind.forbidden: {Difficulty.easy: 0.4, Difficulty.medium: 0.45, Difficulty.hard: 0.15},
  };

  /// Shuffles [ids], putting cards not yet seen on this device first so that
  /// consecutive game nights don't replay the same cards.
  static List<String> freshShuffle(Iterable<String> ids, Random r, Set<String> seen) {
    final unseen = ids.where((id) => !seen.contains(id)).toList()..shuffle(r);
    final seenList = ids.where(seen.contains).toList()..shuffle(r);
    return [...unseen, ...seenList];
  }

  /// Interleaves difficulty buckets by weight (smooth weighted round-robin), so a
  /// mixed deck spreads hard cards evenly instead of clustering them.
  static List<String> stratified(
      Map<Difficulty, List<String>> buckets, Map<Difficulty, double> weights) {
    final queues = {for (final e in buckets.entries) e.key: List.of(e.value)};
    final credit = {for (final k in queues.keys) k: 0.0};
    final out = <String>[];
    while (true) {
      final live = queues.keys.where((k) => queues[k]!.isNotEmpty).toList();
      if (live.isEmpty) break;
      var total = 0.0;
      for (final k in live) {
        final w = weights[k] ?? 0.0001;
        credit[k] = credit[k]! + w;
        total += w;
      }
      live.sort((a, b) => credit[b]!.compareTo(credit[a]!));
      final pick = live.first;
      credit[pick] = credit[pick]! - total;
      out.add(queues[pick]!.removeAt(0));
    }
    return out;
  }

  /// Builds the session's draw queues.
  static Map<String, List<String>> buildQueues(
    ContentLibrary lib,
    GameKind game,
    Difficulty? filter,
    Random r,
    Set<String> seen, {
    Set<String> exclude = const {},
  }) {
    final ids = lib.ids(game).where((id) => !exclude.contains(id));
    if (game == GameKind.sprint) {
      return {'main': freshShuffle(ids, r, seen)};
    }
    final buckets = <Difficulty, List<String>>{};
    for (final id in ids) {
      final d = lib.difficultyOf(game, id);
      if (filter != null && d != filter) continue;
      buckets.putIfAbsent(d, () => []).add(id);
    }
    for (final k in buckets.keys) {
      buckets[k] = freshShuffle(buckets[k]!, r, seen);
    }
    if (game == GameKind.trivia) {
      return {for (final e in buckets.entries) e.key.name: e.value};
    }
    return {'main': stratified(buckets, mixedWeights[game]!)};
  }

  /// Difficulty slots for one Trivia turn. Every team in the same round gets the
  /// same slots, so no team is handed an easier set. Mixed default: mostly
  /// medium and hard, with an easy warm-up on odd rounds and an expert finale on
  /// even rounds. Ordered easiest → hardest.
  static List<Difficulty> triviaSlots(int n, int round, Difficulty? filter) {
    if (filter != null) return List.filled(n, filter);
    if (n <= 0) return const [];
    final rest = n - 1;
    final medium = (rest + 1) ~/ 2;
    final hard = rest ~/ 2;
    final wildcard = round.isOdd ? Difficulty.easy : Difficulty.expert;
    return [
      ...List.filled(medium, Difficulty.medium),
      ...List.filled(hard, Difficulty.hard),
      wildcard,
    ]..sort((a, b) => a.index - b.index);
  }

  /// Fallback order when a Trivia difficulty bucket runs dry.
  static List<Difficulty> nearest(Difficulty d) {
    final all = List.of(Difficulty.values)
      ..sort((a, b) {
        final da = (a.index - d.index).abs(), db = (b.index - d.index).abs();
        return da != db ? da - db : b.index - a.index; // prefer harder on ties
      });
    return all;
  }
}
