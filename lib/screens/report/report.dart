import 'package:bsrufoods/controller/report_sale.dart';
import 'package:bsrufoods/widget-picker/widget-cupertino-picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

class Report extends StatefulWidget {
  final String shopid;
  Report(this.shopid);
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  ReportSale report_sale = ReportSale();
  List year = [
    "2020",
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
    "2026",
    "2027",
    "2028",
    "2029",
    "2030"
  ];
  String dataReport;

  @override
  void initState() {
    super.initState();
    report_sale.getdata(widget.shopid);
  }

  _getSeriesData(String data_report) {
    List _data = report_sale.reportYear(data_report);
    setState(() {});
    List<charts.Series<PopulationData, String>> series = [
      charts.Series(
          id: "Population",
          data: _data,
          domainFn: (PopulationData series, _) => series.moth,
          measureFn: (PopulationData series, _) => series.price,
          colorFn: (PopulationData series, _) => series.barColor)
    ];
    return series;
  }

  showdate() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(2019, 1, 5),
        maxTime: DateTime(2035, 6, 7),
        onChanged: (date) {
      dataReport = "${date.day}/${date.month}/${date.year}";
      print(dataReport);
    }, onConfirm: (date) {
      dataReport = "${date.day}/${date.month}/${date.year}";
    }, currentTime: DateTime.now(), locale: LocaleType.th);
  }

  Widget chartsReport() {
    return Container(
      height: 500,
      child: charts.BarChart(_getSeriesData("2021"),
          animate: true,
          domainAxis: charts.OrdinalAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(labelRotation: 0),
              showAxisLine: true)),
    );
  }

  Widget picker() {
    return Container(
      height: 70,
      width: 100,
      child: CupertinoPicker(
        children: List.generate(year.length, (index) {
          return Text("${year[index]}");
        }),
        magnification: 2,
        itemExtent: 25,
        backgroundColor: Colors.white,
        onSelectedItemChanged: (int index) {
          print("${year[index]}");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(children: [
          chartsReport(),
          RaisedButton(
            child: Text("ดูรายเดือน"),
            onPressed: () {
              showdate();
              // print(dataReport);
            },
          ),
          RaisedButton(
            child: Text("ดูรายวัน"),
            onPressed: () {
              report_sale.reportDaily("24/4/2021");
            },
          )
        ]));
  }
}
