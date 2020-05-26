import 'package:Strokes/assets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AppEngine.dart';

class BaseModel {
  Map<String, Object> items = new Map();
  Map<String, Object> itemUpdate = new Map();
  Map<String, Map> itemUpdateList = new Map();
  Map<String, Map> itemUpdateMap = new Map();

  BaseModel({Map items, DocumentSnapshot doc}) {
    if (items != null) {
      Map<String, Object> theItems = Map.from(items);
      this.items = theItems;
    }
    if (doc != null && doc.exists) {
      this.items = doc.data;
      this.items[OBJECT_ID] = doc.documentID;
    }
  }

  void put(String key, Object value) {
    items[key] = value;
    itemUpdate[key] = value;
  }

  void putInList(String key, Object value, bool add) {
    List itemsInList = items[key] == null ? List() : List.from(items[key]);
    if (add) {
      if (value is Map && value[OBJECT_ID] != null) {
        int index =
            itemsInList.indexWhere((m) => m[OBJECT_ID] == value[OBJECT_ID]);
        if (index == -1) itemsInList.add(value);
      } else {
        if (!itemsInList.contains(value)) itemsInList.add(value);
      }
    } else {
      if (value is Map && value[OBJECT_ID] != null) {
        int index =
            itemsInList.indexWhere((m) => m[OBJECT_ID] == value[OBJECT_ID]);
        if (index != -1) itemsInList.removeAt(index);
      } else {
        itemsInList.removeWhere((E) => E == value);
      }
    }
    items[key] = itemsInList;

    Map update = Map();
    update[ADD] = add;
    update[VALUE] = value;

    itemUpdateList[key] = update;
  }

  void putInMap(String mapKey, String itemKey, Object itemValue, bool add) {
    Map itemsInList = items[mapKey] == null ? Map() : Map.from(items[mapKey]);
    if (add) {
      itemsInList[itemKey] = itemValue;
    } else {
      itemsInList.remove(itemKey);
    }
    items[mapKey] = itemsInList;

    Map update = Map();
    update[ADD] = add;
    update[KEY] = itemKey;
    update[VALUE] = itemValue;

    itemUpdateMap[mapKey] = update;
  }

  void remove(String key) {
    items.remove(key);
    itemUpdate[key] = null;
  }

  String getObjectId() {
    Object value = items[OBJECT_ID];
    return value == null || !(value is String) ? "" : value.toString();
  }

  List getList(String key) {
    Object value = items[key];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List<Object> addToList(String key, Object value, bool add) {
    List<Object> list = items[key];
    list = list == null ? new List<Object>() : list;
    if (add) {
      if (!list.contains(value)) list.add(value);
    } else {
      list.remove(value);
    }
    put(key, list);
    return list;
  }

  /* List<Map<String, Object>> addOnceToMap(
      String mapName, BaseModel bm, bool add) {
    List<Map<String, Object>> maps = items[mapName];
    maps = maps == null ? new List<Map<String, Object>>() : maps;
    bool canAdd = true;
    for (Map<String, Object> theMap in maps) {
      BaseModel model = new BaseModel(items: theMap);
      if (model.getString(OBJECT_ID) == (bm.getString(OBJECT_ID))) {
        canAdd = false;
        if (!add) maps.remove(theMap);
        break;
      }
    }
    if (canAdd && add) {
      maps.add(bm.items);
    }

    put(mapName, maps);
    return maps;
  }

  bool hasMap(String mapName, BaseModel bm) {
    List<Map<String, Object>> maps = items[mapName];
    maps = maps == null ? new List<Map<String, Object>>() : maps;
    for (Map<String, Object> theMap in maps) {
      BaseModel model = new BaseModel(items: theMap);
      if (model.getString(OBJECT_ID) == (bm.getString(OBJECT_ID))) {
        return true;
      }
    }
    return false;
  }*/

  Map getMap(String key) {
    Object value = items[key];
    return value == null || !(value is Map)
        ? new Map<String, String>()
        : Map.from(value);
  }

  Object get(String key) {
    return items[key];
  }

  String getUserId() {
    Object value = items[USER_ID];

    return value == null || !(value is String) ? "" : value.toString();
  }

  String getUserName() {
    Object value = items[USERNAME];
    String name = value == null || !(value is String) ? "" : value.toString();
    if (name.length > 2) {
      name = name.substring(0, 1).toUpperCase() + name.substring(1);
    }
    return name;
  }

  String getString(String key) {
    Object value = items[key];

    return value == null || !(value is String) ? "" : value.toString();
  }

  String getEmail() {
    Object value = items[EMAIL];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getPassword() {
    Object value = items[PASSWORD];
    return value == null || !(value is String) ? "" : value.toString();
  }

  /*int getCreatedAt() {
    Object value = items[CREATED_AT];
    return value == null || !(value is DateTime)
        ? 0
        : (value as DateTime).millisecond;
  }

  DateTime getCreatedAtDate() {
    Object value = items[CREATED_AT];
    return value == null || !(value is DateTime) ? new DateTime.now() : (value);
  }

  DateTime getUpdatedAtDate() {
    Object value = items[UPDATED_AT];
    return value == null || !(value is DateTime) ? new DateTime.now() : (value);
  }

  int getUpdatedAt() {
    Object value = items[UPDATED_AT];
    return value == null || !(value is Timestamp)
        ? 0
        : (value as Timestamp).millisecondsSinceEpoch;
  }*/

  /*bool isRead({String userId}) {
    List<String> readBy = List.from(getList(READ_BY));
    return readBy.contains(userId != null ? userId : userModel.getObjectId());
  }*/

  bool isMuted(String chatId) {
    List<String> readBy = getList(MUTED);
    return readBy.contains(chatId);
  }

  bool isRated(String chatId) {
    List<String> readBy = getList(HAS_RATED);
    return readBy.contains(chatId);
  }

  bool isSilenced() {
    List<String> silence = getList(SILENCED);
    return silence.contains(userModel.getObjectId());
  }

  bool isKicked() {
    List<String> readBy = getList(KICKED_OUT);
    return readBy.contains(userModel.getObjectId());
  }

  bool isMale() {
    return getInt(GENDER) == 0;
  }

  /*void setRead() {
    List<String> readBy = getList(READ_BY);
    if (!readBy.contains(userModel.getObjectId())) {
      readBy.add(userModel.getObjectId());
      put(READ_BY, readBy);
    }
    updateItem();
  }*/

  /*void setUnRead() {
    List<String> readBy = getList(READ_BY);
    readBy.remove(userModel.getObjectId());
    updateItem();
  }*/

  bool hasItem(String key) {
    return items[key] != null;
  }

  bool myItem() {
    return getUserId() == (userModel.getUserId());
  }

  bool mySentChat() {
    return getBoolean(MY_SENT_CHAT);
  }

  bool isHidden() {
    List<String> readBy = getList(HIDDEN);
    return readBy.contains(userModel.getObjectId());
  }

  int getInt(String key) {
    Object value = items[key];
    return value == null || !(value is int) ? 0 : (value);
  }

  int getType() {
    Object value = items[TYPE];
    return value == null || !(value is int) ? 0 : value;
  }

  double getDouble(String key) {
    Object value = items[key];
    return value == null || !(value is double) ? 0 : value;
  }

  int getTime() {
    Object value = items[TIME];
    return value == null || !(value is int) ? 0 : value;
  }

  /*int getLong(String key) {
    Object value = items[key];
    return value == null || !(value is int) ? 0 : value;
  }*/

  bool getBoolean(String key) {
    Object value = items[key];
    return value == null || !(value is bool) ? false : value;
  }

  bool isAdminItem() {
    return getBoolean(IS_ADMIN);
  }

  bool isLeader() {
    return getBoolean(IS_LEADER);
  }

  bool isJohn() {
    return getEmail() == ("johnebere58@gmail.com");
  }

  bool isMaugost() {
    return getEmail() == ("ammaugost@gmail.com");
  }

  bool isDeveloper() {
    return isJohn() || isMaugost();
  }

  /*void updateItems({onComplete, bool updateTime = true}) {
    String dName = items[DATABASE_NAME];
    //if(dName==null ||dName.isEmpty())return;

    String id = items[OBJECT_ID];

    if (updateTime) {
      items[UPDATED_AT] = FieldValue.serverTimestamp();
      items[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
    }

    Firestore db = Firestore.instance;
    db.collection(dName).document(id).setData(items).whenComplete(onComplete);
  }*/

  /*void updateItems({bool updateTime = true}) async {
    String dName = items[DATABASE_NAME];
    String id = items[OBJECT_ID];

    Firestore.instance.runTransaction((tran) async {
      DocumentReference ref = Firestore.instance.collection(dName).document(id);
      DocumentSnapshot doc = await tran.get(ref);
      if (doc == null) return;
      if (!doc.exists) return;

      Map data = doc.data;
      for (String k in itemUpdate.keys) {
        data[k] = itemUpdate[k];
      }
      for (String k in itemUpdateList.keys) {
        Map update = itemUpdateList[k];
        bool add = update[ADD];
        var value = update[VALUE];

        List dataList = data[k] == null ? List() : List.from(data[k]);
        if (add) {
          if (!dataList.contains(value)) dataList.add(value);
        } else {
          dataList.removeWhere((E) => E == value);
        }
        data[k] = dataList;
      }

      if (updateTime) {
        data[UPDATED_AT] = FieldValue.serverTimestamp();
        data[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
      }
      await tran.update(ref, data);
    });
  }*/

  void updateItems({bool updateTime = true, int delaySeconds = 0}) async {
    Future.delayed(Duration(seconds: delaySeconds), () async {
      //bool connected = await isConnected();
      /*if (!connected) {
        delaySeconds = delaySeconds + 10;
        delaySeconds = delaySeconds >= 60 ? 0 : delaySeconds;
        print("not connected retrying in $delaySeconds seconds");
        updateItems(updateTime: updateTime, delaySeconds: delaySeconds);
        return;
      }*/

      String dName = items[DATABASE_NAME];
      String id = items[OBJECT_ID];

      DocumentSnapshot doc = await Firestore.instance
          .collection(dName)
          .document(id)
          .get(source: Source.server)
          .catchError((error) {
        delaySeconds = delaySeconds + 10;
        delaySeconds = delaySeconds >= 60 ? 0 : delaySeconds;
        print("$error... retrying in $delaySeconds seconds");
        updateItems(updateTime: updateTime, delaySeconds: delaySeconds);
        return;
      });
      if (doc == null) return;
      if (!doc.exists) return;

      Map data = doc.data;
      for (String k in itemUpdate.keys) {
        data[k] = itemUpdate[k];
      }
      for (String k in itemUpdateList.keys) {
        Map update = itemUpdateList[k];
        bool add = update[ADD];
        var value = update[VALUE];

        List dataList = data[k] == null ? List() : List.from(data[k]);
        if (add) {
          if (value is Map && value[OBJECT_ID] != null) {
            int index =
                dataList.indexWhere((m) => m[OBJECT_ID] == value[OBJECT_ID]);
            if (index == -1) dataList.add(value);
          } else {
            if (!dataList.contains(value)) dataList.add(value);
          }
        } else {
          dataList.removeWhere((E) => E == value);
        }
        data[k] = dataList;
      }
      for (String k in itemUpdateMap.keys) {
        Map update = itemUpdateMap[k];
        bool add = update[ADD];
        var itemKey = update[KEY];
        var itemValue = update[VALUE];

        Map dataList = data[k] == null ? Map() : Map.from(data[k]);
        if (add) {
          dataList[itemKey] = itemValue;
        } else {
          dataList.remove(itemKey);
        }
        data[k] = dataList;
      }

      if (updateTime) {
        data[UPDATED_AT] = FieldValue.serverTimestamp();
        data[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
      }

      doc.reference.setData(data);
    });
  }

  void updateCountItem(String key, bool increase,
      {bool updateTime = true, int delaySeconds = 0}) async {
    Future.delayed(Duration(seconds: 1), () async {
      /*bool connected = await isConnected();
      if (!connected) {
        delaySeconds = delaySeconds + 10;
        delaySeconds = delaySeconds >= 60 ? 0 : delaySeconds;
        updateCountItem(key, increase,
            updateTime: updateTime, delaySeconds: delaySeconds);
        return;
      }*/

      String dName = items[DATABASE_NAME];
      String id = items[OBJECT_ID];

      DocumentSnapshot doc = await Firestore.instance
          .collection(dName)
          .document(id)
          .get(source: Source.server)
          .catchError((error) {
        delaySeconds = delaySeconds + 10;
        delaySeconds = delaySeconds >= 60 ? 0 : delaySeconds;
        updateCountItem(key, increase,
            updateTime: updateTime, delaySeconds: delaySeconds);
        return;
      });
      if (doc == null) return;
      if (!doc.exists) return;

      Map data = doc.data;
      var item = data[key] ?? 0;
      if (increase) {
        item = item + 1;
      } else {
        item = item - 1;
      }
      data[key] = item;

      if (updateTime) {
        data[UPDATED_AT] = FieldValue.serverTimestamp();
        data[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
      }

      doc.reference.setData(data);
    });
  }

  void deleteItem() {
    String dName = items[DATABASE_NAME];
    String id = items[OBJECT_ID];

    Firestore db = Firestore.instance;
    db.collection(dName).document(id).delete();
  }

  processSave(String name, bool addMyInfo) {
    items[VISIBILITY] = PUBLIC;
    items[DATABASE_NAME] = name;
    items[UPDATED_AT] = FieldValue.serverTimestamp();
    items[CREATED_AT] = FieldValue.serverTimestamp();
    items[TIME] = DateTime.now().millisecondsSinceEpoch;
    items[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
    if (name != (USER_BASE) &&
        name != (APP_SETTINGS_BASE) &&
        name != (NOTIFY_BASE)) {
      if (addMyInfo) addMyDetails(addMyInfo);
    }

    if (name == VOICE_BASE || name == POSTS_BASE) {
      items[FOLLOWERS] = userModel.getList(FOLLOWERS);
    }
  }

  void addMyDetails(bool addMyInfo) {
    items[USER_ID] = userModel.getUserId();
    items[USER_IMAGE] = getFirstPhoto(userModel.getList(PROFILE_PHOTOS));
    items[USERNAME] = userModel.getUserName();
    items[NAME] = userModel.getString(NAME);
//    items[LAST_NAME] = userModel.getString(LAST_NAME);
    items[BY_ADMIN] = userModel.isAdminItem();
    items[GENDER] = userModel.getInt(GENDER);
//    items[CITY] = userModel.getString(CITY);
    items[EMAIL] = userModel.getString(EMAIL);
    items[PHONE_NUMBER] = userModel.getString(PHONE_NUMBER);
    items[DEVICE_ID] = userModel.getString(DEVICE_ID);
  }

  void saveItem(String name, bool addMyInfo, {document, onComplete}) {
    processSave(name, addMyInfo);
    if (document == null) {
      Firestore.instance.collection(name).add(items).whenComplete(() {
        if (onComplete != null) onComplete();
      });
    } else {
      items[OBJECT_ID] = document;
      Firestore.instance
          .collection(name)
          .document(document)
          .setData(items)
          .whenComplete(() {
        if (onComplete != null) onComplete();
      });
    }
  }

/*void saveItemManually(String name, String document, bool addMyInfo,
      onComplete, bool isUpdating) {
    if (!isUpdating) {
      processSave(name, addMyInfo);
    } else {
      items[UPDATED_AT] = FieldValue.serverTimestamp();
      items[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
    }

    bool hasError = false;

    Firestore.instance
        .collection(name)
        .document(document)
        .setData(items)
        .timeout(Duration(seconds: 15), onTimeout: () {
      onComplete(null, "Error, Timeout");
      hasError = true;
    }).then((void _) {
      if (!hasError) onComplete(_, null);
    }, onError: (error) {
      onComplete(null, error);
    });
  }*/
  /* void justUpdate({onComplete, bool updateTime = true}) {
    String dName = items[DATABASE_NAME];
    //if(dName==null ||dName.isEmpty())return;

    String id = items[OBJECT_ID];

    if (updateTime) {
      items[UPDATED_AT] = FieldValue.serverTimestamp();
      items[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
    }

    Firestore db = Firestore.instance;
    db.collection(dName).document(id).setData(items).whenComplete(onComplete);
  }*/

  BaseModel getModel(String key) {
    return BaseModel(items: getMap(key));
  }

  List<BaseModel> getListModel(String key) {
    return getList(key).map((e) => BaseModel(items: e)).toList();
  }

  List<BaseModel> get profilePhotos => getListModel(PROFILE_PHOTOS);
  List<BaseModel> get hookUpPhotos => getListModel(HOOKUP_PHOTOS);

  bool get isHookUps => selectedQuickHookUp == 0;

  bool get emailNotification => getBoolean(EMAIL_NOTIFICATION);
  bool get pushNotification => getBoolean(PUSH_NOTIFICATION);
  bool get isVideo => getBoolean(IS_VIDEO);
  bool get isLocal => !(getString(IMAGE_URL).startsWith("https://") ||
      getString(IMAGE_URL).startsWith("http://"));
  bool get signUpCompleted => getBoolean(SIGNUP_COMPLETED);
  bool get isPremium => getInt(ACCOUNT_TYPE) == 1;

  String get package => isPremium ? FEATURES_PREMIUM : FEATURES_REGULAR;
  String get birthDate => getString(BIRTH_DATE);
  String get imageUrl => getString(IMAGE_URL);
  String get thumbnailUrl => getString(THUMBNAIL_URL);
  String get imagesPath => getString(IMAGE_PATH);
  String get userImage => getString(USER_IMAGE);
  String get firstName => getString(NAME).split(" ")[0];

  String get gender => genderType[selectedGender];
  String get ethnicity => ethnicityType[selectedEthnicity];
  String get preference => preferenceType[selectedPreference];
  String get relationship => relationshipType[selectedRelationship];
  String get quickHookUp => quickHookUps[selectedQuickHookUp];

  int get selectedGender => get(GENDER) == null ? -1 : getInt(GENDER);
  int get selectedEthnicity => get(ETHNICITY) == null ? -1 : getInt(ETHNICITY);
  int get selectedPreference =>
      get(PREFERENCE) == null ? -1 : getInt(PREFERENCE);
  int get selectedRelationship =>
      get(RELATIONSHIP) == null ? -1 : getInt(RELATIONSHIP);
  int get selectedQuickHookUp =>
      get(QUICK_HOOKUP) == null ? -1 : getInt(QUICK_HOOKUP);
}
