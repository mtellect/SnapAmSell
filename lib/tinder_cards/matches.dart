import 'package:flutter/widgets.dart';

import 'profiles.dart';

class MatchEngine extends ChangeNotifier {
  final List<DateMatch> _matches;
  int _currentMatchIndex;
  int _nextMatchIndex;

  MatchEngine({
    List<DateMatch> matches,
  }) : _matches = matches {
    _currentMatchIndex = 0;
    _nextMatchIndex = 1;
  }

  DateMatch get currentMatch => _matches[_currentMatchIndex];
  DateMatch get nextMatch => _matches[_nextMatchIndex];
  DateMatch get previousMatch =>
      _matches[_matches.length - 1 == 0 ? 0 : _matches.length - 1];

  void cycleMatch() {
    if (currentMatch.decision != Decision.undecided) {
      currentMatch.resetMatch();
      _currentMatchIndex = _nextMatchIndex;
      _nextMatchIndex =
          _nextMatchIndex < _matches.length - 1 ? _nextMatchIndex + 1 : 0;
      notifyListeners();
    }
  }
}

class DateMatch extends ChangeNotifier {
  final Profile profile;
  Decision decision = Decision.undecided;

  DateMatch({this.profile});
  void like() {
    if (decision == Decision.undecided) {
      decision = Decision.like;
      notifyListeners();
    }
  }

  void nope() {
    if (decision == Decision.undecided) {
      decision = Decision.nope;
      notifyListeners();
    }
  }

  void superLike() {
    if (decision == Decision.undecided) {
      decision = Decision.superLike;
      notifyListeners();
    }
  }

  void resetMatch() {
    if (decision != Decision.undecided) {
      decision = Decision.undecided;
      notifyListeners();
    }
  }
}

enum Decision {
  undecided,
  nope,
  like,
  superLike,
}
