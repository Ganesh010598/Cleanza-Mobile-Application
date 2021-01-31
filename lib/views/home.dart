import 'dart:io';
import 'dart:math';
import 'package:cleanenza/controllers/auth_controller/auth_controller.dart';
import 'package:cleanenza/controllers/initial_services_controller/initialControllers.dart';
import 'package:cleanenza/controllers/notification_controller/notification_contoller.dart';
import 'package:cleanenza/controllers/service_controllers/service_controllers.dart';
import 'package:cleanenza/helpers/constants.dart';
import 'package:cleanenza/helpers/extra_services.dart';
import 'package:cleanenza/views/account.dart';
import 'package:cleanenza/views/attendence.dart';
import 'package:cleanenza/views/functions.dart';
import 'package:cleanenza/views/generate_report.dart';
import 'package:cleanenza/views/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Home extends StatefulWidget {
  final List<Color> availableColors = [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  final GlobalKey<AnimatedCircularChartState> _chartKey2 =
      new GlobalKey<AnimatedCircularChartState>();

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  final Color barBackgroundColor = const Color.fromRGBO(3, 127, 252, 1);
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex;

  double rating = 3.5;
  int currentPage = 0;
  List<Tabs> tabs = new List();
  List<CircularStackEntry> data = <CircularStackEntry>[
    new CircularStackEntry(
      <CircularSegmentEntry>[
        new CircularSegmentEntry(500.0, Colors.red[200], rankKey: 'Q1'),
        new CircularSegmentEntry(1000.0, Colors.green[200], rankKey: 'Q2'),
        new CircularSegmentEntry(2000.0, Colors.blue[200], rankKey: 'Q3'),
        new CircularSegmentEntry(1000.0, Colors.yellow[200], rankKey: 'Q4'),
      ],
      rankKey: 'Quarterly Profits',
    ),
  ];

  // Keeps record of pages on the bottom app bar

  List<Widget> pageMain = [Container(), Functions(), Accounts()];

  // Initialized Service controller
  ServiceController serviceController = Get.put(ServiceController());
  NotificationController notificationController =
      Get.put(NotificationController());
  InitialController initialController = Get.put(InitialController());
  AuthController authController = Get.find();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      print(token);
      authController.setFCM(token: token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        notificationController.saveNotification(
            title: message['notification']['title'],
            message: message['notification']['body'],
            time: DateTime.now());
      },
      onResume: (Map<String, dynamic> message) async {
        print(message['data']['title']);
        print(message['data']['body']);
        notificationController.saveNotification(
            title: message['data']['title'],
            message: message['data']['body'],
            time: DateTime.now());
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        notificationController.saveNotification(
            title: message['data']['title'],
            message: message['data']['body'],
            time: DateTime.now());
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

// This function will be called just before app Exits just formarking the user offline

  Future<bool> changeUserStatus() async {
    Get.defaultDialog(
        title: 'Exiting App',
        middleText: 'Are you sure you want to exit?',
        confirm: TextButton(
          child: Text('Yes'),
          onPressed: () async {
            await authController.markOffline();
            SystemNavigator.pop();
            return true;
          },
        ),
        cancel: TextButton(
          child: Text('No'),
          onPressed: () => Navigator.of(context).pop(false),
        ));
  }

  @override
  void initState() {
    firebaseCloudMessaging_Listeners();
    authController.markOnline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => changeUserStatus(),
      child: Scaffold(
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: currentPage,
          onTap: (index) {
            setState(() {
              currentPage = index;
            });
          },
          items: [
            SalomonBottomBarItem(icon: Icon(Icons.home), title: Text('Home')),
            SalomonBottomBarItem(
                icon: Icon(Icons.settings), title: Text('Details')),
            SalomonBottomBarItem(
                icon: Icon(Icons.person), title: Text('Account')),
          ],
        ),
        body: currentPage == 0
            ? CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    leading: Stack(
                      children: [
                        Center(
                          child: IconButton(
                            onPressed: () {
                              Get.to(Notifications());
                            },
                            icon: Icon(
                              FeatherIcons.bell,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Obx(() => authController.isLoading.value
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                ),
                              )
                            : Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle),
                                ),
                              )),
                      ],
                    ),
                    title: Text(
                      "CLEANZA",
                      style: GoogleFonts.montserrat(
                          color: Color.fromRGBO(18, 18, 18, 1),
                          fontSize: 19,
                          fontWeight: FontWeight.w600),
                    ),
                    elevation: 3,
                    backgroundColor: Colors.white,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(Accounts(),
                                transition: Transition.cupertino);
                          },
                          child: CircleAvatar(
                            backgroundColor: Color.fromRGBO(18, 18, 18, 1),
                            backgroundImage: FirebaseAuth
                                        .instance.currentUser.photoURL ==
                                    null
                                ? NetworkImage(authController.photoURL.value)
                                : NetworkImage(
                                    FirebaseAuth.instance.currentUser.photoURL),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, bottom: 10, top: 10),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Good Morning",
                                    style: GoogleFonts.poppins(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    FirebaseAuth.instance.currentUser
                                                .displayName ==
                                            null
                                        ? 'User'
                                        : FirebaseAuth
                                            .instance.currentUser.displayName,
                                    style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Container(
                                child: Image.asset(
                                  'assets/images/chill.png',
                                  scale: (Get.width * 0.022),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder(
                            stream: serviceController.databaseReference.onValue,
                            builder: (context, snap) {
                              if (snap.hasData & !snap.hasError) {
                                serviceController.checkPost(_chartKey);
                                return Obx(() => Container(
                                      child: SfRadialGauge(
                                          enableLoadingAnimation: true,
                                          axes: <RadialAxis>[
                                            RadialAxis(
                                              minimum: 0,
                                              maximum: 100,
                                              showLabels: false,
                                              showTicks: false,
                                              radiusFactor: 0.6,
                                              axisLineStyle: AxisLineStyle(
                                                  cornerStyle:
                                                      CornerStyle.bothFlat,
                                                  color: Colors.black12,
                                                  thickness: 12),
                                              annotations: [
                                                GaugeAnnotation(
                                                    verticalAlignment:
                                                        GaugeAlignment.near,
                                                    widget: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 15, bottom: 20),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                serviceController
                                                                    .airData
                                                                    .value
                                                                    .toString(),
                                                                style: GoogleFonts.montserrat(
                                                                    fontSize:
                                                                        50,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Text(
                                                                "%",
                                                                style: GoogleFonts.montserrat(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            "Smell Meter",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              ],
                                              pointers: <GaugePointer>[
                                                RangePointer(
                                                  cornerStyle:
                                                      CornerStyle.bothFlat,
                                                  width: 12,
                                                  value: serviceController
                                                          .airData.value +
                                                      0.1,
                                                  sizeUnit: GaugeSizeUnit
                                                      .logicalPixel,
                                                  color: getmeterAmbientColor(
                                                      value: serviceController
                                                              .airData.value +
                                                          0.1),
                                                ),
                                                MarkerPointer(
                                                    markerHeight: 20,
                                                    value: serviceController
                                                            .airData.value +
                                                        0.1,
                                                    markerWidth: 20,
                                                    markerType:
                                                        MarkerType.circle,
                                                    color: getmeterColor(
                                                        value: serviceController
                                                                .airData.value +
                                                            0.01),
                                                    borderWidth: 2,
                                                    borderColor: Colors.white54)
                                              ],
                                            )
                                          ]),
                                    ));
                              } else {
                                return Container(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 6,
                                    color: Color.fromRGBO(0, 107, 255, 1),
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: Get.width * 0.1,
                                          bottom: Get.width * 0.1),
                                      width: Get.width,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              StreamBuilder(
                                                stream: serviceController
                                                    .databaseReference.onValue,
                                                builder: (context, snap) {
                                                  if (snap.hasData &
                                                      !snap.hasError) {
                                                    // serviceController.checkData(
                                                    //     snap.data.snapshot
                                                    //             .value[
                                                    //         'total_people']);
                                                    serviceController
                                                        .getToiletData();
                                                    return Obx(() => Text(
                                                          serviceController
                                                              .peopleIn.value
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 45,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ));
                                                  } else {
                                                    return Container(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                },
                                              ),
                                              Icon(
                                                FeatherIcons.arrowUp,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "People Inside",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                color: Colors.white,
                                                height: 2,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Card(
                                    elevation: 6,
                                    color: Color.fromRGBO(55, 153, 46, 1),
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: Get.width * 0.1,
                                          bottom: Get.width * 0.1),
                                      width: Get.width,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Obx(() => Text(
                                                    serviceController.peopleIn
                                                                .value <
                                                            maxPeople
                                                        ? (30 -
                                                                serviceController
                                                                    .peopleIn
                                                                    .value)
                                                            .toString()
                                                        : 0.toString(),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 45,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                  )),
                                            ],
                                          ),
                                          Text(
                                            "Available space",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                color: Colors.white,
                                                height: 2,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Get.height * 0.02,
                          ),
                          Card(
                            elevation: 4,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Average",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "Cleanliness",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                StreamBuilder(
                                  stream: serviceController
                                      .databaseReference.onValue,
                                  builder: (context, snap) {
                                    if (snap.hasData & !snap.hasError) {
                                      serviceController.getToiletData();
                                      return Obx(() => Container(
                                              child: AnimatedCircularChart(
                                            key: _chartKey,
                                            size: Size(100, 100),
                                            initialChartData: <
                                                CircularStackEntry>[
                                              new CircularStackEntry(
                                                <CircularSegmentEntry>[
                                                  new CircularSegmentEntry(
                                                    serviceController
                                                            .peopleIn.value *
                                                        3.33,
                                                    Colors.green,
                                                    rankKey: 'completed',
                                                  ),
                                                  new CircularSegmentEntry(
                                                    100 -
                                                        (serviceController
                                                                .peopleIn
                                                                .value *
                                                            3.33),
                                                    Colors.blueGrey[600],
                                                    rankKey: 'remaining',
                                                  ),
                                                ],
                                                rankKey: 'progress',
                                              ),
                                            ],
                                            chartType: CircularChartType.Radial,
                                            percentageValues: true,
                                            holeLabel: (serviceController
                                                            .peopleIn.value *
                                                        3.33)
                                                    .toString()
                                                    .substring(0, 2) +
                                                "%",
                                            edgeStyle: SegmentEdgeStyle.round,
                                            labelStyle: GoogleFonts.montserrat(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 24.0,
                                            ),
                                          )));
                                    } else {
                                      return Container(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Get.height * 0.01,
                          ),
                          Card(
                            elevation: 4,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Cleaners",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "on duty",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    child: AnimatedCircularChart(
                                  key: _chartKey2,
                                  size: Size(100, 100),
                                  initialChartData: <CircularStackEntry>[
                                    new CircularStackEntry(
                                      <CircularSegmentEntry>[
                                        new CircularSegmentEntry(
                                          30.0,
                                          Colors.blue,
                                          rankKey: 'completed',
                                        ),
                                        new CircularSegmentEntry(
                                          70.0,
                                          Colors.blueGrey[600],
                                          rankKey: 'remaining',
                                        ),
                                      ],
                                      rankKey: 'progress',
                                    ),
                                  ],
                                  chartType: CircularChartType.Radial,
                                  percentageValues: true,
                                  holeLabel: '30%',
                                  edgeStyle: SegmentEdgeStyle.round,
                                  labelStyle: GoogleFonts.montserrat(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24.0,
                                  ),
                                ))
                              ],
                            ),
                          ),
                          Container(
                              height: 150,
                              margin: EdgeInsets.only(top: Get.height * 0.03),
                              width: Get.width,
                              decoration:
                                  BoxDecoration(color: Colors.grey[200]),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Card(
                                      child: Container(
                                    height: 150,
                                    width: 150,
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 7,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                StreamBuilder(
                                                  stream: serviceController
                                                      .databaseReference
                                                      .onValue,
                                                  builder: (context, snap) {
                                                    if (snap.hasData &
                                                        !snap.hasError) {
                                                      // serviceController
                                                      //     .checkData(snap
                                                      //             .data
                                                      //             .snapshot
                                                      //             .value[
                                                      //         'total_people']);
                                                      serviceController
                                                          .getToiletData();
                                                      return Obx(() => Text(
                                                            serviceController
                                                                .totalPeople
                                                                .value
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        Get.width *
                                                                            0.12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                          ));
                                                    } else {
                                                      return Container(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            )),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "People visited",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  Obx(() => initialController.isAdmin.value
                                      ? GestureDetector(
                                          onTap: () {
                                            Get.to(GenerateReport(),
                                                transition:
                                                    Transition.cupertino);
                                          },
                                          child: Card(
                                              child: Container(
                                            height: 150,
                                            width: 150,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 7,
                                                  child: Icon(
                                                    Icons.book,
                                                    size: Get.width * 0.12,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Report",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                        )
                                      : Container()),
                                  Obx(() => initialController.isAdmin.value
                                      ? GestureDetector(
                                          onTap: () {
                                            Get.to(Attendence(),
                                                transition:
                                                    Transition.cupertino);
                                          },
                                          child: Card(
                                              child: Container(
                                            height: 150,
                                            width: 150,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 7,
                                                  child: Icon(
                                                    Icons.group,
                                                    size: Get.width * 0.12,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Attendence",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                        )
                                      : Container()),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(Accounts(),
                                          transition: Transition.cupertino);
                                    },
                                    child: Card(
                                        child: Container(
                                      height: 150,
                                      width: 150,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: Icon(
                                              Icons.settings,
                                              size: Get.width * 0.12,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "Settings",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ),
                                ],
                              )),
                          Container(
                            height: Get.height * 0.65,
                            width: Get.width,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: Get.height * 0.05),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Daily visitors",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 13),
                                            child: Card(
                                              color: Color.fromRGBO(
                                                  0, 107, 255, 1),
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 20,
                                                    left: 30,
                                                    right: 30),
                                                child: BarChart(
                                                  mainBarData(),
                                                  swapAnimationDuration:
                                                      animDuration,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: Get.height * 0.05),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Monthly Report",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 13),
                                            child: Card(
                                              color:
                                                  Color.fromRGBO(18, 18, 18, 1),
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 20,
                                                    left: 30,
                                                    right: 30),
                                                child: LineChart(
                                                  mainData(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "User reviews",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )),
                          Obx(() => Container(
                                height: 200,
                                width: Get.width,
                                child: PageView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      serviceController.reviewsStore.length != 0
                                          ? serviceController
                                              .reviewsStore.length
                                          : 0,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      color: Colors.deepOrange,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 12,
                                            bottom: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              serviceController
                                                      .reviewsStore[index]
                                                  ['workerName'],
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20),
                                            ),
                                            SizedBox(
                                              height: Get.height * 0.01,
                                            ),
                                            SmoothStarRating(
                                                allowHalfRating: true,
                                                onRated: (v) {
                                                  setState(() {
                                                    rating = v;
                                                  });
                                                },
                                                starCount: 5,
                                                rating: serviceController
                                                        .reviewsStore[index]
                                                    ['rating'],
                                                size: 40.0,
                                                isReadOnly: true,
                                                filledIconData: Icons.star,
                                                halfFilledIconData:
                                                    Icons.star_half_rounded,
                                                color: Colors.grey[200],
                                                borderColor: Colors.grey[300],
                                                spacing: 0.0),
                                            SizedBox(
                                              height: Get.height * 0.01,
                                            ),
                                            Text(
                                              serviceController
                                                      .reviewsStore[index]
                                                  ['comment'],
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
                          Container(
                            height: Get.height * 0.16,
                            width: Get.width,
                            margin: EdgeInsets.only(top: Get.height * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Feedback",
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SmoothStarRating(
                                    allowHalfRating: true,
                                    onRated: (v) {
                                      setState(() {
                                        rating = v;
                                      });
                                    },
                                    starCount: 5,
                                    rating: rating,
                                    size: 40.0,
                                    isReadOnly: false,
                                    filledIconData: Icons.star,
                                    halfFilledIconData: Icons.star_half_rounded,
                                    color: Colors.green,
                                    borderColor: Colors.green,
                                    spacing: 0.0),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Want to say anything?',
                                  hintStyle:
                                      GoogleFonts.montserrat(fontSize: 14),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(18, 18, 18, 1)))),
                              onFieldSubmitted: (review) async {
                                if (review.length < 1) {
                                  Get.rawSnackbar(
                                      title: 'Too short!',
                                      message: 'Try adding a comment',
                                      duration: Duration(seconds: 1));
                                } else {
                                  await serviceController.addReview(
                                      rating: rating, comment: review);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : pageMain[currentPage],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 6.5, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 7.5, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 9, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 11.5, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 6.5, isTouched: i == touchedIndex);
          default:
            return null;
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'Monday';
                  break;
                case 1:
                  weekDay = 'Tuesday';
                  break;
                case 2:
                  weekDay = 'Wednesday';
                  break;
                case 3:
                  weekDay = 'Thursday';
                  break;
                case 4:
                  weekDay = 'Friday';
                  break;
                case 5:
                  weekDay = 'Saturday';
                  break;
                case 6:
                  weekDay = 'Sunday';
                  break;
              }
              return BarTooltipItem(weekDay + '\n' + (rod.y - 1).toString(),
                  TextStyle(color: Colors.yellow));
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! FlPanEnd &&
                barTouchResponse.touchInput is! FlLongPressEnd) {
              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[
                    Random().nextInt(widget.availableColors.length)]);
          case 1:
            return makeGroupData(1, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[
                    Random().nextInt(widget.availableColors.length)]);
          case 2:
            return makeGroupData(2, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[
                    Random().nextInt(widget.availableColors.length)]);
          case 3:
            return makeGroupData(3, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[
                    Random().nextInt(widget.availableColors.length)]);
          case 4:
            return makeGroupData(4, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[
                    Random().nextInt(widget.availableColors.length)]);
          case 5:
            return makeGroupData(5, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[
                    Random().nextInt(widget.availableColors.length)]);
          case 6:
            return makeGroupData(6, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[
                    Random().nextInt(widget.availableColors.length)]);
          default:
            return null;
        }
      }),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
        animDuration + const Duration(milliseconds: 50));
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1';
              case 3:
                return '3';
              case 5:
                return '5';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '10';
              case 3:
                return '30';
              case 5:
                return '50';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2),
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2),
          ],
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(show: true, colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)
                .withOpacity(0.1),
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)
                .withOpacity(0.1),
          ]),
        ),
      ],
    );
  }
}

class Tabs {
  final IconData icon;
  final String title;
  final Color color;
  final Gradient gradient;

  Tabs(this.icon, this.title, this.color, this.gradient);
}

getGradient(Color color) {
  return LinearGradient(
      colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
      stops: [0.0, 0.7]);
}
