library app;

import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:currency_pickers/currency_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/app/currencies.dart';
import 'package:maugost_apps/assets.dart';
import 'package:photo/photo.dart';

import 'countries.dart';

part 'countryChooser.dart';
part 'currencyChooser.dart';
part 'rating.dart';
// part 'unicons.dart';

class Countries {
  final String countryName;
  final String countryFlag;
  final String countryCode;

  Countries({this.countryName, this.countryFlag, this.countryCode});
}

class Currencies {
  final String symbol;
  final String name;
  final String symbolNative;
  final int decimalDigits;
  final rounding;
  final String code;
  final String namePlural;

  Currencies(
      {this.symbol,
      this.name,
      this.symbolNative,
      this.decimalDigits,
      this.rounding,
      this.code,
      this.namePlural});
}

List<Currencies> getCurrencies() {
  return currenciesMap.values
      .map((e) => Currencies(
          code: e["code"],
          decimalDigits: e["decimal_digits"],
          name: e["name"],
          namePlural: e["name_plural"],
          rounding: e["rounding"],
          symbol: e["symbol"],
          symbolNative: e["symbol_native"]))
      .toList();
}

List<Countries> getCountries() {
  return countryMap
      .map((c) => Countries(
          countryName: c["Name"],
          countryCode: '+${c["Code"]}',
          countryFlag: 'flags/${c["ISO"]}.png'))
      .toList();
}

Countries country =
    getCountries().singleWhere((e) => e.countryName == 'Nigeria');
List<CameraDescription> cameras = [];

openGallery(BuildContext context,
    {bool singleMode = false,
    PickType type = PickType.all,
    //GalleryMode galleryMode = GalleryMode.image,
    int maxSelection,
    @required onPicked(List<PhotoGallery> _)}) {
//  ImagePickers.pickerPaths(
//          galleryMode: galleryMode,
//          selectCount: singleMode ? 1 : maxSelection,
//          showCamera: true,
//          compressSize: 500,
//          uiConfig: UIConfig(uiThemeColor: Color(0xffff0f50)),
//          cropConfig: CropConfig(enableCrop: true, width: 2, height: 1))
//      .then((value) async {
//    List<PhotoGallery> paths = [];
//    for (var v in value) {
//      final gallery = PhotoGallery(
//          galleryId: v.path.hashCode.toString(),
//          file: File(v.path),
//          thumbFilePath: File(v.thumbPath));
//      paths.add(gallery);
//    }
//    if (paths.length == value.length) onPicked(paths);
//  });
//  return;
  PhotoPicker.pickAsset(
          thumbSize: 250,
          //textColor: white,
          context: context,
          provider: I18nProvider.english,
          pickType: type,
          themeColor: AppConfig.appColor,
          maxSelected: singleMode ? 1 : maxSelection,
          rowCount: 3)
      .then((value) async {
    List<PhotoGallery> paths = [];
    for (var v in value) {
      File file = await v.originFile;
      final gallery = PhotoGallery(galleryId: v.id, file: file);
      paths.add(gallery);
    }
    if (paths.length == value.length) onPicked(paths);
  });
}

class PhotoGallery {
  final String galleryId;
  final File file;
  final File thumbFilePath;
  final bool isVideo;

  PhotoGallery({
    @required this.galleryId,
    @required this.file,
    this.isVideo,
    this.thumbFilePath,
  });
}
