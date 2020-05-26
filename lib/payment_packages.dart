import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'AppEngine.dart';
import 'app/dotsIndicator.dart';
import 'app_config.dart';
import 'assets.dart';
import 'basemodel.dart';

class PaymentPackages extends StatefulWidget {
  @override
  _PaymentPackagesState createState() => _PaymentPackagesState();
}

class _PaymentPackagesState extends State<PaymentPackages> {
  static const String PLAN_FEATURES = "planFeatures";
  static const String PLAN_TYPE = "planType";
  static const String PLAN_PACKAGES = "planPackages";
  RandomColor randomColor = RandomColor();

  List<Color> colors = List.generate(
      15,
      (p) =>
          RandomColor().randomColor(colorBrightness: ColorBrightness.veryDark));

  bool reversing = false;
  final codeWheeler = CodeWheeler(milliseconds: 8000);

  final vp = PageController();
  final vpMain = PageController();

  int currentPlan = 0;

  @override
  initState() {
    super.initState();
    codeWheeler.run(pageWheeler);
  }

  @override
  void dispose() {
    codeWheeler?.close();
    super.dispose();
  }

  pageWheeler() {
    final model = paymentPlans[currentPlan];
    final features = model.getList(PLAN_FEATURES);

    if (null == vp || !mounted) return;
    if (currentFeature < features.length - 1 && !reversing) {
      reversing = false;
      if (mounted) setState(() {});
      vp.nextPage(duration: Duration(milliseconds: 12), curve: Curves.ease);
      return;
    }
    if (currentFeature == features.length - 1 && !reversing) {
      Future.delayed(Duration(seconds: 2), () {
        reversing = true;
        if (mounted) setState(() {});
        vp.previousPage(
            duration: Duration(milliseconds: 12), curve: Curves.ease);
      });
      return;
    }
    if (currentFeature == 0 && reversing) {
      Future.delayed(Duration(seconds: 2), () {
        reversing = false;
        if (mounted) setState(() {});
        vp.nextPage(duration: Duration(milliseconds: 12), curve: Curves.ease);
      });
      return;
    }

    if (currentFeature == 0 && !reversing) {
      Future.delayed(Duration(seconds: 2), () {
        reversing = false;
        if (mounted) setState(() {});
        vp.nextPage(duration: Duration(milliseconds: 12), curve: Curves.ease);
      });
      return;
    }

    if (currentFeature > 0 && reversing) {
      Future.delayed(Duration(seconds: 2), () {
        vp.previousPage(
            duration: Duration(milliseconds: 12), curve: Curves.ease);
      });
      return;
    }
  }

  List<BaseModel> paymentPlans = [
    BaseModel()
      ..put(TITLE, "GET STROCK GOLD")
      ..put(PLAN_TYPE, 0)
      ..put(PLAN_PACKAGES, [
        {
          "month": "12",
          "fee": "1,462.17",
        },
        {
          "month": "6",
          "fee": "1,462.17",
        },
        {
          "month": "1",
          "fee": "1,462.17",
        },
      ])
      ..put(PLAN_FEATURES, [
        {
          "icon": "",
          "title": "See  who likes you",
          "description": "Match with them instantly."
        },
        {
          "icon": "",
          "title": "Swipe on every Top Pick, every day",
          "description":
              "Get full access to top picks, likes you, unlimited swipes and more."
        },
        {
          "icon": "",
          "title": "Unlimited Likes",
          "description": "Swipe right as much as you want."
        },
        {
          "icon": "",
          "title": "Get 1 free Boost every month",
          "description": "Skip the queue and get more matches!"
        },
        {
          "icon": "",
          "title": "Choose Who Sees You",
          "description": "Only Be Shown To People You've Liked."
        },
        {
          "icon": "",
          "title": "Control Your Profile",
          "description": "Limit What Others See With Strock Plus"
        },
        {
          "icon": "",
          "title": "5 super likes everyday",
          "description": "You are 3 times more likely to get a match!"
        },
        {
          "icon": "",
          "title": "Swipe around the world!",
          "description": "Passport to anywhere"
        },
        {
          "icon": "",
          "title": "See  who likes you",
          "description": "Match with them instantly."
        },
        {
          "icon": "",
          "title": "Unlimited Rewinds",
          "description": "Go back and swipe again!"
        },
        {
          "icon": "",
          "title": "Turn Off Ads",
          "description": "Have fun swiping"
        },
      ]),
    BaseModel()
      ..put(TITLE, "GET STROCK PLUS")
      ..put(PLAN_TYPE, 0)
      ..put(PLAN_PACKAGES, [
        {
          "month": "12",
          "fee": "1,462.17",
        },
        {
          "month": "6",
          "fee": "1,462.17",
        },
        {
          "month": "1",
          "fee": "1,462.17",
        },
      ])
      ..put(PLAN_FEATURES, [
        {
          "icon": "",
          "title": "Unlimited Likes",
          "description": "Swipe right as much as you want."
        },
        {
          "icon": "",
          "title": "Get 1 free Boost every month",
          "description": "Skip the queue and get more matches!"
        },

        {
          "icon": "",
          "title": "Choose Who Sees You",
          "description": "Only Be Shown To People You've Liked."
        },

        {
          "icon": "",
          "title": "Control Your Profile",
          "description": "Limit What Others See With Strock Plus"
        },

        {
          "icon": "",
          "title": "5 super likes everyday",
          "description": "You are 3 times more likely to get a match!"
        },

        {
          "icon": "",
          "title": "Swipe around the world!",
          "description": "Passport to anywhere"
        },

        {
          "icon": "",
          "title": "Unlimited Rewinds",
          "description": "Go back and swipe again!"
        },

        {
          "icon": "",
          "title": "Turn Off Ads",
          "description": "Have fun swiping"
        },

        // {
        //   "icon": "",
        //   "title": "See  who likes you",
        //   "description": "Match with them instantly."
        // },
        //   {
        //   "icon": "",
        //   "title": "Swipe on every Top Pick, every day",
        //   "description": "Get full access to top picks, likes you, unlimited swipes and more."
        // },

        //      {
        //   "icon": "",
        //   "title": "See  who likes you",
        //   "description": "Match with them instantly."
        // },
      ])
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: black.withOpacity(.8),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      //height: MediaQuery.of(context).size.height * 0.6,
                      margin: EdgeInsets.only(top: 40, right: 15, left: 15),
                      child: PageView.builder(
                          itemCount: paymentPlans.length,
                          onPageChanged: (p) {
                            setState(() {
                              currentPlan = p;
                            });
                          },
                          itemBuilder: (ctx, p) {
                            return page(p);
                          })),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(1),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppConfig.appColor),
                      child: DotsIndicator(
                        dotsCount: paymentPlans.length,
                        position: currentPlan,
                        decorator: DotsDecorator(
                          size: const Size.square(5.0),
                          color: white,
                          activeColor: black,
                          activeSize: const Size(10.0, 7.0),
                          activeShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            "Recurring billing,cancel anytime.",
                            textAlign: TextAlign.center,
                            style: textStyle(true, 15, white),
                          ),
                          addSpace(10),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text:
                                        'By Clicking on "Continue", Your payment will be charged to your ',
                                    style: textStyle(false, 13, white)),
                                TextSpan(
                                    text: 'Google Play Account',
                                    style: textStyle(
                                        true, 14, AppConfig.appColor)),
                                TextSpan(
                                    text:
                                        ' and your subscription will automatically renew for this same package length a the same price until you cancel in settings. Buy tapping "Continue, you agree to our "',
                                    style: textStyle(false, 12, white)),
                                TextSpan(
                                    text: 'Terms of Service',
                                    style: textStyle(
                                        true, 14, AppConfig.appColor)),
                              ],
                            ),
                            //textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              addSpace(40)
            ],
          ),
        ],
      ),
    );
  }

  int selectedPlan = 1;
  int currentFeature = 0;

  page(int p) {
    final model = paymentPlans[p];
    final title = model.getString(TITLE);
    final plans = model.getList(PLAN_PACKAGES);
    final features = model.getList(PLAN_FEATURES);
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                        controller: vp,
                        itemCount: features.length,
                        onPageChanged: (p) {
                          setState(() {
                            currentFeature = p;
                          });
                        },
                        itemBuilder: (ctx, p) {
                          final feature = features[p];
                          String title = feature["title"];
                          String description = feature["description"];
                          return Container(
                              decoration: BoxDecoration(
                                  color: colors[p],
                                  gradient: LinearGradient(
                                      colors: [
                                        colors[p].withOpacity(.9),
                                        colors[p].withOpacity(.8),
                                        //colors[p],
                                      ],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    padding: EdgeInsets.all(14),
                                    child: Image.asset(
                                      "assets/tinder/heart.png",
                                      color: colors[p],
                                    ),
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          blurRadius: 10,
                                          color: black.withOpacity(.5))
                                    ], color: white, shape: BoxShape.circle),
                                  ),
                                  addSpace(10),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: textStyle(true, 20, white),
                                  ),
                                  Text(
                                    description,
                                    textAlign: TextAlign.center,
                                    style: textStyle(false, 17, white),
                                  )
                                ],
                              ));
                        }),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        alignment: Alignment.center,
                        height: 60,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textStyle(true, 20, white),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(1),
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: black.withOpacity(.7)),
                      child: DotsIndicator(
                        dotsCount: features.length,
                        position: currentFeature,
                        decorator: DotsDecorator(
                          size: const Size.square(5.0),
                          color: white,
                          activeColor: AppConfig.appColor,
                          activeSize: const Size(10.0, 7.0),
                          activeShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                        ),
                      ),
                    ),
                  ],
                ),
                //color: white,
              ),
            ),
            Container(
              color: black.withOpacity(.02),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(plans.length, (p) {
                    return packages(p);
                  })),
            ),
            Container(
              padding: EdgeInsets.all(25),
              child: FlatButton(
                onPressed: () {},
                color: colors[currentFeature],
                //color: AppConfig.appColor,
                padding: EdgeInsets.all(18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Center(
                    child: Text(
                  "CONTINUE",
                  style: textStyle(true, 16, white),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  packages(int p) {
    final model = paymentPlans[0];
    final plans = model.getList(PLAN_PACKAGES);

    Map<String, String> plan = plans[p];
    String month = plan["month"];
    String fee = plan["fee"];
    bool active = selectedPlan == p;
    double mSize = active ? 30 : 20;
    double fSize = active ? 20 : 16;

    return Flexible(
        child: GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = p;
        });
      },
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: active ? white : black.withOpacity(.04),
            border: Border.all(
                width: active ? 3 : 1,
                color: active ? AppConfig.appColor : black.withOpacity(.1))),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month,
              style: textStyle(true, mSize,
                  active ? AppConfig.appColor : black.withOpacity(.7)),
            ),
            Text("Months"),
            addSpace(10),
            Text(
              fee,
              style: textStyle(true, fSize,
                  active ? AppConfig.appColor : black.withOpacity(.7)),
            ),
            Text(
              "(NGN)",
            ),
          ],
        ),
      ),
    ));
  }
}
