import 'package:Strokes/basemodel.dart';

class Profile {
  final List<String> photos;
  final String name;
  final int age;
  final String bio;
  final String location;
  final BaseModel user;
  final String objectId;
  final bool isAds;
  final String urlLink;

  Profile(
      {this.photos,
      this.name,
      this.age = 0,
      this.bio = "",
      this.location = "",
      this.urlLink = "",
      this.user,
      this.objectId,
      this.isAds = false});
}
