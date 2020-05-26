part of 'app.dart';

class CountryChooser extends StatefulWidget {
  @override
  _CountryChooserState createState() => _CountryChooserState();
}

class _CountryChooserState extends State<CountryChooser>
    with TickerProviderStateMixin {
  bool hasLoaded = true;
  List<Countries> countriesList = getCountries();
  List<Countries> mainCountriesList = getCountries();
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
          "Choose  Country",
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
                      countriesList = mainCountriesList;
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
    countriesList = mainCountriesList
        .where((b) => b.countryName.toLowerCase().startsWith(text))
        .toList();
    countriesList.sort((a, b) => a.countryName.compareTo(b.countryName));

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

    if (!hasLoaded && countriesList.isEmpty)
      return Container(
        height: getScreenHeight(context) / 2,
        child: emptyLayout(
            Icons.search, "No Result", "No search for country found"),
      );

    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: countriesList.length,
        itemBuilder: (ctx, p) {
          return countryLayout(p);
        },
      ),
    );
  }

  countryLayout(int p) {
    Countries theCountry = countriesList[p];
    String country = theCountry.countryName;
    String countryFlag = theCountry.countryFlag;
    String countryCode = theCountry.countryCode;
    String currency =
        CurrencyPickerUtils.getCountryByIsoCode(countryCode).currencyCode;

    return GestureDetector(
      onTap: () {
        print(country);
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.pop(context, theCountry);
      },
      child: Container(
        padding: EdgeInsets.all(14),
        color: white,
        child: Row(
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  Container(
                    height: 40,
                    width: 60,
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(width: 1, color: light_grey)),
                    child: Image.asset(
                      countryFlag,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  addSpaceWidth(15),
                  Text(
                    country,
                    style: textStyle(true, 16, black),
                  ),
                ],
              ),
            ),
            Text(
              countryCode,
              style: textStyle(true, 16, black),
            ),
          ],
        ),
      ),
    );
  }
}
