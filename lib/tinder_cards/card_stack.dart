import 'package:flutter/material.dart';

import 'draggable_card.dart';
import 'matches.dart';
import 'profile_card.dart';

class CardStack extends StatefulWidget {
  final MatchEngine matchEngine;
  final callback;
  final bool showOverlay;
  CardStack(
      {Key key,
      this.matchEngine,
      this.callback(DateMatch currentMatch, int direction),
      this.showOverlay = true});
  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  Key _frontCard;
  DateMatch _currentMatch;
  double _nextCardScale = 0.9;
  SlideRegion slideRegion;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.matchEngine.addListener(_onMatchEngineChange);
    _currentMatch = widget.matchEngine.currentMatch;
    _currentMatch.addListener(_onMatchChange);
    _frontCard = new Key(_currentMatch.profile.name);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_currentMatch != null) {
      _currentMatch.removeListener(_onMatchChange);
    }
    widget.matchEngine.removeListener(_onMatchEngineChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(CardStack oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.matchEngine != oldWidget.matchEngine) {
      oldWidget.matchEngine.removeListener(_onMatchEngineChange);
      widget.matchEngine.addListener(_onMatchEngineChange);
    }
    if (_currentMatch != null) {
      _currentMatch.removeListener(_onMatchChange);
    }
    _currentMatch = widget.matchEngine.currentMatch;
    if (_currentMatch != null) {
      _currentMatch.addListener(_onMatchChange);
    }
  }

  void _onMatchEngineChange() {
    setState(() {
      if (_currentMatch != null) {
        _currentMatch.removeListener(_onMatchChange);
      }
      _currentMatch = widget.matchEngine.currentMatch;
      if (_currentMatch != null) {
        _currentMatch.addListener(_onMatchChange);
      }
      _frontCard = new Key(_currentMatch.profile.name);
    });
  }

  void _onMatchChange() {
    setState(() {
      //match has been changed
    });
  }

  Widget _buildFrontCard() {
    return new ProfileCard(
        key: _frontCard,
        profile: widget.matchEngine.currentMatch.profile,
        decision: widget.matchEngine.currentMatch.decision,
        region: slideRegion);
  }

  Widget _buildBackCard({bool isDraggable: false}) {
    return new Transform(
      transform: new Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: new ProfileCard(
          profile: widget.matchEngine.nextMatch.profile,
          decision: widget.matchEngine.nextMatch.decision,
          region: slideRegion,
          isDraggable: false),
    );
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideRegion(SlideRegion region) {
    setState(() {
      slideRegion = region;
    });
  }

  void _onSlideOutComplete(SlideDirection direction) {
    DateMatch currentMatch = widget.matchEngine.currentMatch;

    switch (direction) {
      case SlideDirection.left:
        widget.callback(currentMatch, 0);
        currentMatch.nope();

        break;
      case SlideDirection.right:
        widget.callback(currentMatch, 1);

        currentMatch.like();
        break;
      case SlideDirection.up:
        widget.callback(currentMatch, 2);
        currentMatch.superLike();

        break;
      case SlideDirection.rewind:
        // TODO: Handle this case.
        widget.callback(currentMatch, 3);
        break;
    }

    widget.matchEngine.cycleMatch();
  }

  SlideDirection _desiredSlideOutDirection() {
    switch (widget.matchEngine.currentMatch.decision) {
      case Decision.nope:
        return SlideDirection.left;
      case Decision.like:
        return SlideDirection.right;
      case Decision.superLike:
        return SlideDirection.up;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new DraggableCard(
            showOverlay: widget.showOverlay,
            isDraggable: false,
            card: _buildBackCard()),
        new DraggableCard(
          showOverlay: widget.showOverlay,
          card: _buildFrontCard(),
          slideTo: _desiredSlideOutDirection(),
          onSlideUpdate: _onSlideUpdate,
          onSlideRegionUpdate: _onSlideRegion,
          onSlideOutComplete: _onSlideOutComplete,
        )
      ],
    );
  }
}
