import 'package:Strokes/assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'selected_photo_indicator.dart';

class PhotoBrowser extends StatefulWidget {
  final List<String> photoAssetPaths;
  final int visiblePhotoIndex;

  const PhotoBrowser({this.photoAssetPaths, this.visiblePhotoIndex});
  @override
  _PhotoBrowserState createState() => _PhotoBrowserState();
}

class _PhotoBrowserState extends State<PhotoBrowser> {
  int visiblePhotoIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    visiblePhotoIndex = widget.visiblePhotoIndex;
  }

  @override
  void didUpdateWidget(PhotoBrowser oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.visiblePhotoIndex != oldWidget.visiblePhotoIndex) {
      setState(() {
        visiblePhotoIndex = widget.visiblePhotoIndex;
      });
    }
  }

  void _previousImage() {
    setState(() {
      visiblePhotoIndex = visiblePhotoIndex > 0 ? visiblePhotoIndex - 1 : 0;
    });
  }

  void _nextImage() {
    setState(() {
      visiblePhotoIndex = visiblePhotoIndex < widget.photoAssetPaths.length - 1
          ? visiblePhotoIndex + 1
          : visiblePhotoIndex;
    });
  }

  Widget _buildPhotoControls() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new GestureDetector(
          onTap: _previousImage,
          child: new FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: Alignment.topLeft,
            child: Container(
              color: transparent,
            ),
          ),
        ),
        new GestureDetector(
          onTap: _nextImage,
          child: new FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: Alignment.topRight,
            child: Container(color: transparent),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        //photo
        // new Image.asset(
        //   widget.photoAssetPaths[visiblePhotoIndex],
        //   fit: BoxFit.cover,
        // ),

        CachedNetworkImage(
          imageUrl: widget.photoAssetPaths[visiblePhotoIndex],
          fit: BoxFit.cover,
          placeholder: (c, s) {
            return Container(
                height: double.infinity,
                width: double.infinity,
                child: Center(
                    child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )),
                decoration: BoxDecoration(
                    color: black.withOpacity(.09),
                    ));
          },
        ),

        //photo indicator
        new Positioned(
            top: 0.0,
            right: 0.0,
            left: 0.0,
            child: new SelectedPhotoIndicator(
                photoCount: widget.photoAssetPaths.length,
                visiblePhotoIndex: visiblePhotoIndex)),

        //photo controls
        _buildPhotoControls()
      ],
    );
  }
}
