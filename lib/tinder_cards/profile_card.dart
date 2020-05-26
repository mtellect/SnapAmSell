import 'package:Strokes/AppEngine.dart';
import 'package:Strokes/app_config.dart';
import 'package:Strokes/assets.dart';
import 'package:flutter/material.dart';

import 'draggable_card.dart';
import 'matches.dart';
import 'photo_browser.dart';
import 'profiles.dart';

class ProfileCard extends StatefulWidget {
  final Profile profile;
  final Decision decision;
  final SlideRegion region;
  final bool isDraggable;
  const ProfileCard({
    Key key,
    this.profile,
    this.decision,
    this.region,
    this.isDraggable = true,
  }) : super(key: key);
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  Widget _buildPhotos() {
    return new PhotoBrowser(
        photoAssetPaths: widget.profile.photos, visiblePhotoIndex: 0);
  }

  Widget _buildProfileSynopsis() {
    return new Align(
     alignment: Alignment.bottomCenter,
      child: new Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),

        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
//          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.profile.isAds) ...[
              new Text(widget.profile.name, style: textStyle(true, 25, white)),
              addSpace(10),
              Container(
                decoration: BoxDecoration(
                    color: red, borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.vpn_lock,
                      color: white,
                      size: 18,
                    ),
                    addSpaceWidth(5),
                    Text(
                      "Sponsored",
                      style: textStyle(true, 13, white),
                    )
                  ],
                ),
              ),
              addSpace(10),
              FlatButton(
                onPressed: () {
                  openLink(widget.profile.urlLink);
                  widget.profile.user
                    ..putInList(CLICKS, userModel.getUserId(), true)
                    ..updateItems();
                },
                color: AppConfig.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Container(
                  //alignment: Alignment.centerLeft,
                  child: Text(
                    "See Profile ",
                    style: textStyle(true, 13, white),
                  ),
                ),
              ),
            ] else
              new Text(
                  "${widget.profile.name.split(" ")[0]}, ${widget.profile.age}",
                  style: textStyle(true, 25, white)),
            if(widget.profile.bio.isNotEmpty) Text(widget.profile.bio, style: textStyle(false, 16, white.withOpacity(.5))),
            if(widget.profile.location.isNotEmpty) Row(
              children: [
                Icon(Icons.place,color: AppConfig.appColor,size: 14,),
                addSpaceWidth(5),
                Text(widget.profile.location,
                    style: textStyle(false, 14, AppConfig.appColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10.0), boxShadow: [
        new BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 5.0,
            spreadRadius: 2.0)
      ]),
      child: new ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: new Material(
          child: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildPhotos(),
             Align(
               alignment: Alignment.bottomCenter,
               child: Container(height: 200,child:  gradientLine(alpha: .5),),
             ),

              _buildProfileSynopsis(),
              // widget.isDraggable == false
              //     ? new Container(
              //         color: Colors.transparent,
              //       )
              //     : _buildRegionIndicator(),
              // widget.isDraggable == false
              //     ? new Container(
              //         color: Colors.transparent,
              //       )
              //     : _buildDecisionIndicator(),
              if (null != widget.region && widget.isDraggable
//                  && !widget.profile.isAds
              ) ...[_buildRegionIndicator()],
              if (null != widget.decision &&
                  widget.decision != Decision.undecided &&
                  widget.isDraggable
//                  &&  !widget.profile.isAds
              )
                _buildDecisionIndicator()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionIndicator() {
    switch (widget.region) {
      case SlideRegion.inNopeRegion:
        return _nopeIndicator();
        break;
      case SlideRegion.inLikeRegion:
        return _likeIndicator();
        break;
      case SlideRegion.inSuperLikeRegion:
        return _superLikeIndicator();
        break;
      default:
        return new Container(
          color: Colors.transparent,
        );
    }
  }

  Widget _buildDecisionIndicator() {
    switch (widget.decision) {
      case Decision.nope:
        return _nopeIndicator();
        break;
      case Decision.like:
        return _likeIndicator();
        break;
      case Decision.superLike:
        return _superLikeIndicator();
        break;
      default:
        return new Container(
          color: Colors.transparent,
        );
    }
  }

  Widget _nopeIndicator() {
    return new Align(
      alignment: Alignment.topRight,
      child: new Transform.rotate(
        angle: 270.0,
        origin: Offset(0.0, 0.0),
        child: new Container(
          height: 80.0,
          width: 150.0,
          margin: const EdgeInsets.all(16.0),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.red, width: 5.0)),
          child: Center(
              child: new Text("NAH", style: textStyle(true, 30, Colors.red))),
        ),
      ),
    );
  }

  Widget _likeIndicator() {
    return new Align(
      alignment: Alignment.topLeft,
      child: new Transform.rotate(
        angle: 270.0,
        origin: Offset(0.0, 0.0),
        child: new Container(
          height: 80.0,
          width: 150.0,
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 5.0)),
          child: Center(
              child:
                  new Text("YEAH", style: textStyle(true, 30, Colors.green))),
        ),
      ),
    );
  }

  Widget _superLikeIndicator() {
    return new Align(
      alignment: Alignment.bottomCenter,
      child: new Container(
        height: 150.0,
        width: 150.0,
        margin: const EdgeInsets.only(bottom: 100.0),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.blue, width: 5.0)),
        child: Center(
            child: new Text("SUPER YEAH",
                textAlign: TextAlign.center,
                style: textStyle(true, 30, Colors.blue))),
      ),
    );
  }
}
