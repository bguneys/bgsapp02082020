import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:bgsapp02082020/data/Item.dart';
import 'package:bgsapp02082020/data/ItemRepository.dart';
import 'package:bgsapp02082020/data/Project.dart';
import 'package:bgsapp02082020/data/ProjectRepository.dart';
import 'package:bgsapp02082020/routes/ProjectDetailsScreenViewModel.dart';
import 'package:flutter/material.dart';

import 'MainScreen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  final String projectTitle;

  // In the constructor, we create an object with Project obtained from MainScreen
  ProjectDetailsScreen({Key key, @required this.projectId, @required this.projectTitle}) : super(key: key);

  @override
  // In createState() callback we create state class with project argument
  _ProjectDetailsScreenState createState() =>
      _ProjectDetailsScreenState(projectId: projectId, projectTitle: projectTitle);
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final int projectId;
  final String projectTitle;

  // In constructor we create an object with Project obtained from ProjectDetailsScreen
  _ProjectDetailsScreenState({@required this.projectId, @required this.projectTitle});

  // create ProjectDatabase through creating ItemRepository instance
  static final itemRepository = ItemRepository.getInstance();

  // create ProjectDatabase through creating ProjectRepository instance
  static final projectRepository = ProjectRepository.getInstance();

  // create ViewModel
  final projectDetailsScreenViewModel =
      ProjectDetailsScreenViewModel(itemRepository, projectRepository);

  //Item list variable to store Items from database
  List<Item> itemList = new List();

  Item longTappedItem; // Item to be used in _showDialog() method

  FocusNode _focusNode = new FocusNode(); // used to hide soft keyboard

  Project selectedProject;

  String projectCurrency;

  double totalProjectCost;
  int totalProjectDuration;
  double totalProjectHourlyCost;

  var numberFormat; //2 decimals and thousand separator format for currencies

  @override
  void initState() {
    super.initState();

    // find device local and declare NumberFormat using it
    findSystemLocale().then((locale) {
      print(locale);
      numberFormat = NumberFormat.currency(locale: locale, name: "");
    });

    populateItemList(); // Custom method for populating itemList variable from database.
    getProject(); // fetch Project chosen with project id and updated values.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,

      appBar: AppBar(
        title: Text(projectTitle, style: Theme.of(context).textTheme.headline6),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              projectDetailsScreenViewModel.navigateToEditProjectScreen(context, selectedProject);
            },
          ),

          PopupMenuButton<String>(
            onSelected: _handleAppBarClick,
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return {'Settings'}.map((String choice) {
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
        color: Theme.of(context).backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              //ListView
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: ListView.builder(itemBuilder: (context, index) {
                      if (index == itemList.length) {
                        return null;
                      }

                      return Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 2.0),
                           child: InkWell(
                             splashColor: Colors.blue.withAlpha(30),
                             onTap: () {
                               projectDetailsScreenViewModel.navigateToEditItemScreen(context, itemList[index], selectedProject);
                               //print('Item tapped.');
                             },
                             onLongPress: () {
                               _showDialog(); // custom method for showing AlertDialog
                               longTappedItem = itemList[index]; // Item to be used in _showDialog() method
                             },
                             child: Column(
                               mainAxisSize: MainAxisSize.max,
                               children: <Widget>[
                                 ListTile(
                                   title: Text(itemList[index].title, style: Theme.of(context).textTheme.subtitle1),
                                   trailing: Text("Duration: ${itemList[index].durationInDay.toString()} days\n"
                                       "Hourly Cost: ${numberFormat.format(itemList[index].hourlyCost).toString()} $projectCurrency\n"
                                       "Total Cost: ${numberFormat.format(itemList[index].cost).toString()} $projectCurrency",
                                       style: Theme.of(context).textTheme.headline5,
                                       textAlign: TextAlign.end),
                                 ),
                                 Divider(
                                   color: Theme.of(context).backgroundColor,
                                 ),
                               ],
                             )
                           ),
                        );
                    }),
                  ),
                ),
              ),

              // Bottom section
              Container(
                color: Theme.of(context).backgroundColor,
                width: double.infinity,
                //height: 200.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 8.0, 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget> [

                      //Project details Texts
                      Expanded(
                        child: Wrap(
                          direction: Axis.vertical,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                              child: Text("Total cost: ${numberFormat.format(totalProjectCost).toString()} $projectCurrency",
                                  style: Theme.of(context).textTheme.subtitle2),
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                              child: Text("Total hourly cost: ${numberFormat.format(totalProjectHourlyCost).toString()} $projectCurrency/h",
                                  style: Theme.of(context).textTheme.subtitle2),
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                              child: Text("Total duration: ${totalProjectDuration.toString()} days",
                                  style: Theme.of(context).textTheme.subtitle2),
                            ),
                          ],
                        ),
                      ),

                      //FAB
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 0.0),
                        child: Container(
                          child: FloatingActionButton(
                            backgroundColor: Color(0xFFFFc640),
                            foregroundColor: Theme.of(context).backgroundColor,
                            tooltip: 'Add Item',
                            child: Icon(Icons.add, size: 32.0),
                            onPressed: () {
                              projectDetailsScreenViewModel.navigateToAddItemScreen(context, selectedProject);
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

            ],
        ),
      ),

    );
  }

  /**
   * Custom method for handling clicks on AppBar OverFlow menu
   */
  void _handleAppBarClick(String value) {
    projectDetailsScreenViewModel.handleAppBarClick(value, context);
  }

  /**
   * Custom method for populating itemList variable from database.
   */
  void populateItemList() async {
    itemList.clear();

    await projectDetailsScreenViewModel.getItemWithProjectId(projectId).then((value) {

      totalProjectCost = 0.0;
      totalProjectDuration = 0;
      double totalProjectHours = 0.0;
      totalProjectHourlyCost = 0.0;

      setState(() {
        value.forEach((element) {
          itemList.add(Item(
              id: element.id,
              title: element.title,
              durationInDay: element.durationInDay,
              cost: element.cost,
              hourlyCost: element.hourlyCost,
              workHoursInADay: element.workHoursInADay));

          // calculate total cost, duration, hours for the project
          totalProjectCost = totalProjectCost + element.cost;
          totalProjectDuration = totalProjectDuration + element.durationInDay;
          totalProjectHours = totalProjectHours + (element.hourlyCost * element.durationInDay);
        });

        // calculate total hourly cost for the project via total cost and total hours
        totalProjectHourlyCost = totalProjectCost / totalProjectHours;

      });
    }).catchError((error) {
      print(error);
    });
  }

  /**
   * Custom method for fetching Project chosen with project id and updated values
   * for edited/ newly added items. If
   */
  void getProject() async {
    await projectDetailsScreenViewModel.getProjectWithId(projectId).then((projectList) {
      selectedProject = Project(
          id: projectList.first.id,
          title: projectList.first.title,
          cost: totalProjectCost,
          durationInDay: totalProjectDuration,
          hourlyCost: totalProjectHourlyCost,
          note: projectList.first.note,
          currency: projectList.first.currency);

      projectDetailsScreenViewModel.updateProject(selectedProject);

      setState(() {
        projectCurrency = projectList.first.currency;
      });

    }).catchError((error) {
      print(error);
    });
  }

  /**
   * Custom method for deleting an item from the list
   */
  void _deleteItem(Item item) async {
    await projectDetailsScreenViewModel.deleteItem(item);
  }

  /**
   * Custom method for showing AlertDialog
   */
  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item?', style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            FlatButton(
              child: Text('YES', style: Theme.of(context).textTheme.subtitle1),
              onPressed: () {
                _deleteItem(longTappedItem);
                populateItemList();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('NO', style: Theme.of(context).textTheme.bodyText1),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
