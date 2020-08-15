import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/dialogs/listDialog.dart';

class ShowUsers extends StatefulWidget {
  final List<BaseModel> users;
  final String title;

  const ShowUsers({Key key, this.users, this.title}) : super(key: key);
  @override
  _ShowUsersState createState() => _ShowUsersState();
}

class _ShowUsersState extends State<ShowUsers> {
  TextEditingController searchController = TextEditingController();
  bool _showCancel = false;
  FocusNode focusSearch = FocusNode();
  List usersList = [];

  reload() async {
    usersList.clear();
    String search = searchController.text.toString().toLowerCase().trim();
    for (BaseModel model in widget.users) {
      String contactName = model.getString(NAME).toLowerCase().trim();
      String number = model.getString(PHONE_NUMBER).toLowerCase().trim();
      if (search.isNotEmpty) {
        if (!contactName.contains(search)) {
          if (!number.contains(search)) continue;
        }
      }
      usersList.add(model);
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
            color: white,
            child: Row(
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 50,
                      height: 30,
                      child: Center(
                          child: Icon(
                        Icons.arrow_back_ios,
                        color: black,
                        size: 20,
                      )),
                    )),
                Flexible(
                    child: GestureDetector(
                  onTap: () {},
                  child: Center(
                      child: Text(
                          "${widget.title ?? "Users"} ${usersList.length}",
                          style: textStyle(true, 20, black))),
                )),
                addSpaceWidth(10),
                new Container(
                  height: 30,
                  width: 50,
                  child: new FlatButton(
                      padding: EdgeInsets.all(0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {},
                      child: Center(
                          child: Icon(
                        Icons.more_vert,
                        color: black,
                      ))),
                ),
              ],
            ),
          ),
          Container(
            height: 45,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: black.withOpacity(0.2), width: 1)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                addSpaceWidth(10),
                Icon(
                  Icons.search,
                  color: black.withOpacity(.5),
                  size: 17,
                ),
                addSpaceWidth(10),
                new Flexible(
                  flex: 1,
                  child: new TextField(
                    textInputAction: TextInputAction.search,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: false,
                    onSubmitted: (_) {
                      //reload();
                    },
                    decoration: InputDecoration(
                        hintText: "Search by name",
                        hintStyle: textStyle(
                          false,
                          18,
                          black.withOpacity(.5),
                        ),
                        border: InputBorder.none,
                        isDense: true),
                    style: textStyle(false, 16, black),
                    controller: searchController,
                    cursorColor: black,
                    cursorWidth: 1,
                    focusNode: focusSearch,
                    keyboardType: TextInputType.text,
                    onChanged: (s) {
                      _showCancel = s.trim().isNotEmpty;
                      setState(() {});
                      reload();
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      focusSearch.unfocus();
                      _showCancel = false;
                      searchController.text = "";
                    });
                    reload();
                  },
                  child: _showCancel
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                          child: Icon(
                            Icons.close,
                            color: black,
                            size: 20,
                          ),
                        )
                      : new Container(),
                )
              ],
            ),
          ),
//          addSpace(10),
          Expanded(
              flex: 1,
              child: Builder(builder: (ctx) {
                //if (!contactSetup) return loadingLayout();
                if (usersList.isEmpty)
                  return emptyLayout(Icons.person, "No User Yet", "");

                return Container(
                    child: ListView.builder(
                  itemBuilder: (c, p) {
                    return contactItem(p);
                  },
                  shrinkWrap: true,
                  itemCount: usersList.length,
                  padding: EdgeInsets.only(top: 10),
                ));
              }))
        ],
      ),
    );
  }

  contactItem(int p) {
    BaseModel model = usersList[p];
    bool banned = model.getBoolean(BANNED);
    //String initials = model.getString(INITIALS);
    String name =
        model.signUpCompleted ? model.getString(NAME) : "Incomplete SignUp";
    String image =
        model.profilePhotos.isEmpty ? "" : model.profilePhotos[0].imageUrl;

    bool isAdmin = model.getBoolean(IS_ADMIN);
    bool isPremium = model.isPremium;
    String keyAdmin = isAdmin ? "DeActivate" : "Activate";
    String keyPremium = isPremium ? "DeActivate" : "Activate";

    return GestureDetector(
      onLongPress: () {
        if (model.isDeveloper()) return;
        pushAndResult(
            context,
            listDialog(
                ["$keyAdmin Admin", "$keyPremium Premium", "Delete User"]),
            result: (_) {
          if (null == _) return;

          if (_ == "$keyAdmin Admin")
            model
              ..put(IS_ADMIN, !isAdmin)
              ..updateItems();
          if (_ == "$keyPremium Premium")
            model
              ..put(ACCOUNT_TYPE, isPremium ? 0 : 1)
              ..updateItems();

          if (_ == "Delete User") {
            //FirebaseAuth.instance.currentUser().then((value) => value.delete());
          }

          setState(() {});
        }, depend: false);
      },
      child: Container(
        decoration: BoxDecoration(color: white, boxShadow: [
          //BoxShadow(color: black.withOpacity(.3), blurRadius: 5)
        ]),
        padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        margin: EdgeInsets.fromLTRB(0, .5, 0, 0),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
              width: 60,
              height: 60,
              child: Card(
                color: black.withOpacity(.1),
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                shape: CircleBorder(
                    side: BorderSide(color: black.withOpacity(.2), width: .9)),
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  placeholder: (c, s) {
                    return Container(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Icon(Icons.account_circle),
                      ),
                    );
                  },
                ),
              ),
            ),
            addSpaceWidth(10),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textStyle(true, 18, black),
                  ),
                  if (model.isDeveloper())
                    Text(
                      "DevTeam",
                      style: textStyle(false, 14, black),
                    )
                ],
              ),
            ),
//            if (!isConvas)
            //if (!model.isDeveloper())
            FlatButton(
              onPressed: () {
//              if (isConvas) {
//                showListDialog(context, ["Normal Chat", "Encrypted Chat"], (_) {
//                  if (_ == 0) {
//                    clickChat(
//                      context,
//                      CHAT_MODE_REGULAR,
//                      model,
//                    );
//                  }
//                  if (_ == 1) {
//                    clickChat(
//                      context,
//                      CHAT_MODE_ENCRYPT,
//                      model,
//                    );
//                  }
//                }, showTitle: false);
//              } else {}
              },
              padding: EdgeInsets.all(0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              color: banned ? blue6 : red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block,
                    color: white,
                    size: 14,
                  ),
                  addSpaceWidth(5),
                  Text(
                    banned ? "UnBan" : "Ban",
                    style: textStyle(true, 14, white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
