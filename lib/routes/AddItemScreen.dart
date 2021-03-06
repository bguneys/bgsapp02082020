import 'package:bgsapp02082020/data/AppStrings.dart';
import 'package:bgsapp02082020/data/CostType.dart';
import 'package:bgsapp02082020/data/Item.dart';
import 'package:bgsapp02082020/data/ItemRepository.dart';
import 'package:bgsapp02082020/data/Project.dart';
import 'package:bgsapp02082020/routes/ProjectDetailsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AddItemScreenViewModel.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class AddItemScreen extends StatefulWidget {
  final Project project;

  // In the constructor, we create an object with Project obtained from ProjectDetailsScreen
  AddItemScreen({Key key, @required this.project}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState(project: project);
}

class _AddItemScreenState extends State<AddItemScreen> {
  final Project project;

  // In constructor we create an object with Project obtained from AddItemScreen
  _AddItemScreenState({@required this.project});

  static final itemRepository = ItemRepository.getInstance();   // create ProjectDatabase through creating ItemRepository instance

  final addItemScreenViewModel = AddItemScreenViewModel(itemRepository);   // create ViewModel

  final _formKey = GlobalKey<FormState>();   // Global key for form

  String _totalCostString; // total cost calculated for each input

  int projectId;

  //TextEditControllers for each TextFormField
  final titleTextFieldController = TextEditingController();
  final hourlyCostTextFieldController = TextEditingController();
  final daysTextFieldController = TextEditingController();
  final workHoursADayTextFieldController = TextEditingController();
  final unitCostTextFieldController = TextEditingController();
  final onetimeCostTextFieldController = TextEditingController();
  final unitsTextFieldController = TextEditingController();

  var numberFormat; //2 decimals and thousand separator format for currencies

  CostType _selectedCostType = CostType.hourly;

  // booleans for widgets to change visibility depending on the cost type selected
  bool _isHourlyCostVisible = true;
  bool _isUnitCostVisible = false;
  bool _isUnitsVisible = false;
  bool _isOnetimeCostVisible = false;
  bool _isWorkHoursVisible = true;


  @override
  void initState() {
    super.initState();

    // find device local and declare NumberFormat using it
    findSystemLocale().then((locale) {
      print(locale);
      numberFormat = NumberFormat.currency(locale: locale, name: "");
    });

    projectId = project.id;

    _totalCostString = "${AppStrings.totalCostZero} ${project.currency}";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(AppStrings.addItemScreenTitle, style: Theme.of(context).textTheme.headline6),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            addItemScreenViewModel.navigateToProjectDetailsScreen(context, project.id, project.title);
          },
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleAppBarClick,
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return {AppStrings.aboutOptionsMenuLabel}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),

      body: Container(
        height: double.infinity,
        color: Theme.of(context).backgroundColor,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(AppStrings.titleLabel, style: Theme.of(context).textTheme.headline4),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Theme(
                                  data: ThemeData(primaryColor: Color(0xFFFAFAFA), hintColor: Color.fromARGB(100, 255, 255, 255)),
                                  child: TextFormField(
                                      style: Theme.of(context).textTheme.bodyText2,
                                      controller: titleTextFieldController,
                                      maxLength: 50,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return AppStrings.enterValueMessage;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        counterText: '',
                                        counterStyle: TextStyle(fontSize: 0),
                                        hintText: AppStrings.itemTitleHintText,
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                                        errorStyle: TextStyle(color: Theme.of(context).errorColor),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                      ),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 0.0, 0.0),
                            child: Text(AppStrings.costTypeLabel, style: Theme.of(context).textTheme.headline4),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 12.0, 0.0),
                                child: Row(
                                  children: <Widget>[
                                    Theme(
                                      data: ThemeData(unselectedWidgetColor: Theme.of(context).cardColor),
                                      child: Radio(
                                        value: CostType.hourly,
                                        groupValue: _selectedCostType,
                                        activeColor: Color(0xFFFFc640),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        onChanged: (CostType value) {
                                          setState(() {
                                            _selectedCostType = value;

                                            // change visibility of the widgets accordingly
                                            _isHourlyCostVisible = true;
                                            _isUnitCostVisible = false;
                                            _isOnetimeCostVisible = false;
                                            _isWorkHoursVisible = true;
                                            _isUnitsVisible = false;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(AppStrings.hourlyOptionLabel, style: Theme.of(context).textTheme.bodyText2)
                                  ],
                                )
                              ),

                              Padding(
                                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 0.0),
                                  child: Row(
                                    children: <Widget>[
                                      Theme(
                                        data: ThemeData(unselectedWidgetColor: Theme.of(context).cardColor),
                                        child: Radio(
                                          value: CostType.unit,
                                          groupValue: _selectedCostType,
                                          activeColor: Color(0xFFFFc640),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (CostType value) {
                                            setState(() {
                                              _selectedCostType = value;

                                              // change visibility of the widgets accordingly
                                              _isHourlyCostVisible = false;
                                              _isUnitCostVisible = true;
                                              _isOnetimeCostVisible = false;
                                              _isWorkHoursVisible = false;
                                              _isUnitsVisible = true;
                                            });
                                          },
                                        ),
                                      ),
                                      Text(AppStrings.unitOptionLabel)
                                    ],
                                  )
                              ),

                              Padding(
                                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                                  child: Row(
                                    children: <Widget>[
                                      Theme(
                                        data: ThemeData(unselectedWidgetColor: Theme.of(context).cardColor),
                                        child: Radio(
                                          value: CostType.oneTime,
                                          groupValue: _selectedCostType,
                                          activeColor: Color(0xFFFFc640),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (CostType value) {
                                            setState(() {
                                              _selectedCostType = value;

                                              // change visibility of the widgets accordingly
                                              _isHourlyCostVisible = false;
                                              _isUnitCostVisible = false;
                                              _isOnetimeCostVisible = true;
                                              _isWorkHoursVisible = false;
                                              _isUnitsVisible = false;
                                            });
                                          },
                                        ),
                                      ),
                                      Text(AppStrings.onetimeOptionLabel)
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Visibility(
                      visible: _isHourlyCostVisible,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("${AppStrings.hourlyCostText} (${project.currency}):", style: Theme.of(context).textTheme.headline4),
                            Row(
                              children: <Widget>[
                                  Expanded(
                                      child: Theme(
                                        data: ThemeData(primaryColor: Color(0xFFFAFAFA), hintColor: Color.fromARGB(100, 255, 255, 255)),
                                        child: TextFormField(
                                            style: Theme.of(context).textTheme.bodyText2,
                                            controller: hourlyCostTextFieldController,
                                            keyboardType: TextInputType.number,
                                            maxLength: 12,
                                            onChanged: _calculateTotalCost,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return AppStrings.enterValueMessage;
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context).cardColor
                                                  ),
                                                  borderRadius: BorderRadius.all(Radius.circular(45)),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context).cardColor
                                                  ),
                                                  borderRadius: BorderRadius.all(Radius.circular(45)),
                                                ),
                                                counterText: '',
                                                counterStyle: TextStyle(fontSize: 0),
                                                hintText: AppStrings.hourlyCostHintText,
                                                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                                                errorStyle: TextStyle(color: Theme.of(context).errorColor),
                                                errorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context).errorColor),
                                                        borderRadius: BorderRadius.all(Radius.circular(45))
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context).errorColor),
                                                        borderRadius: BorderRadius.all(Radius.circular(45))
                                                ),
                                            ),
                                          ),
                                      ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Visibility(
                      visible: _isUnitCostVisible,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("${AppStrings.unitCostText} (${project.currency}):", style: Theme.of(context).textTheme.headline4),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Theme(
                                    data: ThemeData(primaryColor: Color(0xFFFAFAFA), hintColor: Color.fromARGB(100, 255, 255, 255)),
                                    child: TextFormField(
                                      style: Theme.of(context).textTheme.bodyText2,
                                      controller: unitCostTextFieldController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 12,
                                      onChanged: _calculateTotalCost,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return AppStrings.enterValueMessage;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        counterText: '',
                                        counterStyle: TextStyle(fontSize: 0),
                                        hintText: AppStrings.unitCostHintText,
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                                        errorStyle: TextStyle(color: Theme.of(context).errorColor),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Visibility(
                      visible: _isOnetimeCostVisible,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("${AppStrings.onetimeCostText} (${project.currency}):", style: Theme.of(context).textTheme.headline4),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Theme(
                                    data: ThemeData(primaryColor: Color(0xFFFAFAFA), hintColor: Color.fromARGB(100, 255, 255, 255)),
                                    child: TextFormField(
                                      style: Theme.of(context).textTheme.bodyText2,
                                      controller: onetimeCostTextFieldController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 12,
                                      onChanged: _calculateTotalCost,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return AppStrings.enterValueMessage;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        counterText: '',
                                        counterStyle: TextStyle(fontSize: 0),
                                        hintText: AppStrings.onetimeCostHintText,
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                                        errorStyle: TextStyle(color: Theme.of(context).errorColor),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Visibility(
                      visible: _isUnitsVisible,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(AppStrings.unitsLabel, style: Theme.of(context).textTheme.headline4),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Theme(
                                    data: ThemeData(primaryColor: Color(0xFFFAFAFA), hintColor: Color.fromARGB(100, 255, 255, 255)),
                                    child: TextFormField(
                                      style: Theme.of(context).textTheme.bodyText2,
                                      controller: unitsTextFieldController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 7,
                                      inputFormatters: <TextInputFormatter>[
                                        WhitelistingTextInputFormatter.digitsOnly
                                      ],
                                      onChanged: _calculateTotalCost,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return AppStrings.enterValueMessage;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        counterText: '',
                                        counterStyle: TextStyle(fontSize: 0),
                                        hintText: AppStrings.unitsHintText,
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                                        errorStyle: TextStyle(color: Theme.of(context).errorColor),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Visibility(
                      visible: _isWorkHoursVisible,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(AppStrings.workHoursLabel, style: Theme.of(context).textTheme.headline4),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Theme(
                                    data: ThemeData(primaryColor: Color(0xFFFAFAFA), hintColor: Color.fromARGB(100, 255, 255, 255)),
                                    child: TextFormField(
                                      style: Theme.of(context).textTheme.bodyText2,
                                      controller: workHoursADayTextFieldController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      onChanged: _calculateTotalCost,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return AppStrings.enterValueMessage;
                                        } else if (double.parse(value) > 24) {
                                          return AppStrings.workHoursAbove24HoursMessage;
                                        }

                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context).cardColor
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(45)),
                                        ),
                                        counterText: '',
                                        counterStyle: TextStyle(fontSize: 0),
                                        hintText: AppStrings.workHoursHintText,
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                                        errorStyle: TextStyle(color: Theme.of(context).errorColor),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(AppStrings.durationDaysLabel, style: Theme.of(context).textTheme.headline4),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Theme(
                                  data: ThemeData(primaryColor: Color(0xFFFAFAFA), hintColor: Color.fromARGB(100, 255, 255, 255)),
                                  child: TextFormField(
                                      style: Theme.of(context).textTheme.bodyText2,
                                      controller: daysTextFieldController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 4,
                                      inputFormatters: <TextInputFormatter>[
                                        WhitelistingTextInputFormatter.digitsOnly
                                      ],
                                      onChanged: _calculateTotalCost,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return AppStrings.enterValueMessage;

                                        }else if (double.parse(value) < 0) {
                                          return AppStrings.durationAboveZeroMessage;
                                        }

                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).cardColor
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(45)),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).cardColor
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(45)),
                                          ),
                                          counterText: '',
                                          counterStyle: TextStyle(fontSize: 0),
                                          hintText: AppStrings.durationHintText,
                                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                                        errorStyle: TextStyle(color: Theme.of(context).errorColor),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).errorColor),
                                                borderRadius: BorderRadius.all(Radius.circular(45))
                                        ),
                                      ),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
                      child: Text(_totalCostString,
                          style: Theme.of(context).textTheme.headline4),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
                        child: RaisedButton(
                          child: Text(AppStrings.addButtonLabel, style: Theme.of(context).textTheme.subtitle1),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {

                              // create item depending on the cost type selected
                              Item item;

                              if (_selectedCostType == CostType.hourly) {
                                // calculate total cost from inputs
                                String titleString = titleTextFieldController.text;
                                String hourlyCostString = hourlyCostTextFieldController.text;
                                String daysString = daysTextFieldController.text;
                                String workHoursInADayString = workHoursADayTextFieldController.text;

                                double hourlyCost = numberFormat.parse(hourlyCostString);
                                int days = int.parse(daysString);
                                double workHoursInADay = numberFormat.parse(workHoursInADayString);

                                double totalCost = (hourlyCost * workHoursInADay) * days;

                                // insert Item to the database
                                item = Item(title: titleString,
                                    hourlyCost: hourlyCost,
                                    durationInDay: days,
                                    cost: totalCost,
                                    unitCost: 0.0,
                                    onetimeCost: 0.0,
                                    units: 0,
                                    workHoursInADay: workHoursInADay,
                                    costType: CostType.hourly.index,
                                    projectId: projectId);

                              } else if(_selectedCostType == CostType.unit) {
                                // calculate total cost from inputs
                                String titleString = titleTextFieldController.text;
                                String unitCostString = unitCostTextFieldController.text;
                                String daysString = daysTextFieldController.text;
                                String unitsString = unitsTextFieldController.text;

                                double unitCost = numberFormat.parse(unitCostString);
                                int days = int.parse(daysString);
                                int units = int.parse(unitsString);

                                double totalCost = (unitCost * units);

                                // insert Item to the database
                                item = Item(title: titleString,
                                    hourlyCost: 0.0,
                                    durationInDay: days,
                                    cost: totalCost,
                                    unitCost: unitCost,
                                    onetimeCost: 0.0,
                                    units: units,
                                    workHoursInADay: 0.0,
                                    costType: CostType.unit.index,
                                    projectId: projectId);

                              } else if(_selectedCostType == CostType.oneTime) {
                                // calculate total cost from inputs
                                String titleString = titleTextFieldController.text;
                                String onetimeCostString = onetimeCostTextFieldController.text;
                                String daysString = daysTextFieldController.text;

                                double onetimeCost = numberFormat.parse(onetimeCostString);
                                int days = int.parse(daysString);

                                double totalCost = onetimeCost;

                                // insert Item to the database
                                item = Item(title: titleString,
                                    hourlyCost: 0.0,
                                    durationInDay: days,
                                    cost: totalCost,
                                    unitCost: 0.0,
                                    onetimeCost: onetimeCost,
                                    units: 0,
                                    workHoursInADay: 0.0,
                                    costType: CostType.oneTime.index,
                                    projectId: projectId);
                              }

                              await addItemScreenViewModel.insertItem(item);

                              // go to ProjectDetailsScreen after inserting Item into database
                              addItemScreenViewModel.navigateToProjectDetailsScreen(context, project.id, project.title);
                            }
                          }
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            ),
      ),
    );
  }


  @override
  void dispose() {
    titleTextFieldController.dispose();
    hourlyCostTextFieldController.dispose();
    daysTextFieldController.dispose();
    workHoursADayTextFieldController.dispose();
    unitCostTextFieldController.dispose();
    onetimeCostTextFieldController.dispose();
    unitsTextFieldController.dispose();
    
    super.dispose();

  }

  /**
   * Custom method for handling clicks on AppBar OverFlow menu
   */
  void _handleAppBarClick(String value) {
    addItemScreenViewModel.handleAppBarClick(value, context);
  }

  /**
   * Custom method for calculatig total cost.
   * If one of the TextFormField is empty then totalCost String is shown zero
   */
  void _calculateTotalCost(String value) {

    if (_selectedCostType == CostType.hourly) {
      // calculate total cost from inputs
      String hourlyCostString = hourlyCostTextFieldController.text;
      String daysString = daysTextFieldController.text;
      String workHoursInADayString = workHoursADayTextFieldController.text;

      setState(() {

        if (hourlyCostString.isEmpty || daysString.isEmpty || workHoursInADayString.isEmpty) {
          //do nothing
          _totalCostString = "${numberFormat.format(0).toString()} ${project.currency}" ; // if not all fields entered then total cost shown zero

        } else {
          double hourlyCost = double.parse(hourlyCostString);
          int days = int.parse(daysString);
          double workHoursInADay = double.parse(workHoursInADayString);

          double totalCost = (hourlyCost * workHoursInADay) * days;

          _totalCostString = "${AppStrings.totalCostLabel} ${numberFormat.format(totalCost).toString()} ${project.currency}";
        }
      });

    } else if(_selectedCostType == CostType.unit) {
      // calculate total cost from inputs
      String unitCostString = unitCostTextFieldController.text;
      //String daysString = daysTextFieldController.text;
      String unitsString = unitsTextFieldController.text;

      setState(() {

        if (unitCostString.isEmpty || unitsString.isEmpty) {
          //do nothing
          _totalCostString = "${numberFormat.format(0).toString()} ${project.currency}" ; // if not all fields entered then total cost shown zero

        } else {
          double unitCost = double.parse(unitCostString);
          //int days = int.parse(daysString);
          int units = int.parse(unitsString);

          double totalCost = (unitCost * units);

          _totalCostString = "${AppStrings.totalCostLabel} ${numberFormat.format(totalCost).toString()} ${project.currency}";
        }
      });

    } else if(_selectedCostType == CostType.oneTime) {
      // calculate total cost from inputs
      String onetimeCostString = onetimeCostTextFieldController.text;
      //String daysString = daysTextFieldController.text;

      setState(() {

        if (onetimeCostString.isEmpty) {
          //do nothing
          _totalCostString = "${numberFormat.format(0).toString()} ${project.currency}" ; // if not all fields entered then total cost shown zero

        } else {
          double onetimeCost = double.parse(onetimeCostString);
          //int days = int.parse(daysString);

          double totalCost = onetimeCost;

          _totalCostString = "${AppStrings.totalCostLabel} ${numberFormat.format(totalCost).toString()} ${project.currency}";
        }
      });

    }
  }

  /**
   * Custom method for determining locale of the device
   */
  Future<String> findSystemLocale() {
    try {
      Intl.systemLocale = Intl.canonicalizedLocale(Platform.localeName);
    } catch (e) {
      return Future.value();
    }
    return Future.value(Intl.systemLocale);
  }

}
