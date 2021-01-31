import 'package:cleanenza/controllers/initial_services_controller/initialControllers.dart';
import 'package:cleanenza/controllers/reportController/reportController.dart';
import 'package:cleanenza/views/widgets/monthly_report.dart';
import 'package:cleanenza/views/widgets/weekly_report.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GenerateReport extends StatefulWidget {
  @override
  _GenerateReportState createState() => _GenerateReportState();
}

class _GenerateReportState extends State<GenerateReport>
    with SingleTickerProviderStateMixin {
  TabController controller;
  ReportController reportController = Get.put(ReportController());
  InitialController initialController = Get.find();

  @override
  void initState() {
    controller = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 107, 255, 1),
        title: Text(
          'Generate Report',
          style: GoogleFonts.manrope(),
        ),
        bottom: TabBar(
          controller: controller,
          indicatorWeight: 3,
          indicatorColor: Colors.amber,
          tabs: [
            Tab(
              icon: Icon(Icons.calendar_view_day),
              text: 'Weekly',
            ),
            Tab(
              icon: Icon(Icons.calendar_today_rounded),
              text: 'Monthly',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          WeeklyReport(),
          MonthlyReport(),
        ],
      ),
    );
  }
}
