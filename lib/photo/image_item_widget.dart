import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/photo/lru_map.dart';
import 'package:photo_manager/photo_manager.dart';

import '../assets.dart';
import 'video_widget.dart';

class ImageItemWidget extends StatefulWidget {
  final AssetEntity entity;

  const ImageItemWidget({
    Key key,
    this.entity,
  }) : super(key: key);
  @override
  _ImageItemWidgetState createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  @override
  Widget build(BuildContext context) {
    final item = widget.entity;
    final size = 300;

    final isVideo = widget.entity.type == AssetType.video;

    if (isVideo) {
      return VideoWidget(entity: item);
    }

    final u8List = ImageLruCache.getData(item, size);

    Widget image;

    if (u8List != null) {
      return Image.memory(
        u8List,
        width: size.toDouble(),
        height: size.toDouble(),
        fit: BoxFit.cover,
      );
    } else {
      image = FutureBuilder<Uint8List>(
        future: item.thumbDataWithSize(size, size),
        builder: (context, snapshot) {
          Widget w;
          if (snapshot.hasError) {
            w = Center(
              child: Text(
                "Loading Error!",
                style: textStyle(true, 12, black.withOpacity(.5)),
              ),
            );
          }
          if (snapshot.hasData) {
            ImageLruCache.setData(item, size, snapshot.data);
            w = Image.memory(
              snapshot.data,
              fit: BoxFit.cover,
            );
          } else {
            w = Center(
              child: Icon(
                Icons.image,
                color: black.withOpacity(.3),
              ),
            );
          }

          return w;
        },
      );
    }

    return image;
  }

  @override
  void didUpdateWidget(ImageItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entity.id != oldWidget.entity.id) {
      setState(() {});
    }
  }
}
