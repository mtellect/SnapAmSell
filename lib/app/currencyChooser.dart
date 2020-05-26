part of 'app.dart';

class CurrencyChooser extends StatefulWidget {
  @override
  _CurrencyChooserState createState() => _CurrencyChooserState();
}

class _CurrencyChooserState extends State<CurrencyChooser>
    with TickerProviderStateMixin {
  bool hasLoaded = true;
  List<Currencies> currenciesList = getCurrencies();
  List<Currencies> mainCurrenciesList = getCurrencies();
  var searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        title: Text(
          "Choose Currency",
          style: textStyle(true, 18, black),
        ),
        iconTheme: IconThemeData(color: black),
      ),
      body: Column(
        children: <Widget>[mainSearch(), mainPages()],
      ),
    );
  }

  mainSearch() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Column(
        children: <Widget>[
          TextField(
            controller: searchController,
            onChanged: performFilter,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: light_grey.withOpacity(.1), width: .7)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: light_grey.withOpacity(.1), width: .7)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: light_grey.withOpacity(.1), width: .7)),
                hintText: "Search",
                fillColor: light_grey,
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    filtering ? Icons.clear : Icons.search,
                    size: 30,
                    color: black.withOpacity(.3),
                  ),
                  onPressed: () {
                    if (filtering) {
                      currenciesList = mainCurrenciesList;
                      filtering = false;
                      searchController.clear();
                      setState(() {});
                      return;
                    }
                  },
                )),
          )
        ],
      ),
    );
  }

  bool filtering = false;

  void performFilter(String value) {
    String text = value.toLowerCase();
    currenciesList = mainCurrenciesList
        .where((b) => b.name.toLowerCase().startsWith(text))
        .toList();
    currenciesList.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      filtering = true;
    });
  }

  mainPages() {
    if (!hasLoaded)
      return Container(
        height: getScreenHeight(context) / 2,
        child: loadingLayout(),
      );

    if (!hasLoaded && currenciesList.isEmpty)
      return Container(
        height: getScreenHeight(context) / 2,
        child: emptyLayout(
            Icons.search, "No Result", "No search for country found"),
      );

    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: currenciesList.length,
        itemBuilder: (ctx, p) {
          return countryLayout(p);
        },
      ),
    );
  }

  countryLayout(int p) {
    Currencies theCountry = currenciesList[p];
    String name = theCountry.name;
    String sign = theCountry.symbol;
    String symbol = theCountry.code;

    return GestureDetector(
      onTap: () {
        print(name);
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.pop(context, theCountry);
      },
      child: Container(
        padding: EdgeInsets.all(14),
        color: white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: AppConfig.appColor,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              width: 60,
              child: Text(
                sign,
                style: textStyle(true, 16, black),
              ),
            ),
            addSpaceWidth(10),
            Flexible(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  textAlign: TextAlign.start,
                  style: textStyle(false, 16, black),
                ),
              ),
            ),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                  color: AppConfig.appColor,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              width: 60,
              child: Text(
                symbol,
                style: textStyle(true, 16, black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
