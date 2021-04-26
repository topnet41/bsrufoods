import 'package:bsrufoods/controller/report_sale.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class Report extends StatefulWidget {
  final String shopid ;
  Report(this.shopid);
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  ReportSale report_sale = ReportSale();

  @override
  void initState() {
    super.initState();
    report_sale.getdata(widget.shopid);
  }

  _getSeriesData(List data_report) {
    List<charts.Series<PopulationData, String>> series = [
      charts.Series(
        id: "Population",
        data: data_report,
        domainFn: (PopulationData series, _) => series.year.toString(),
        measureFn: (PopulationData series, _) => series.population,
        colorFn: (PopulationData series, _) => series.barColor
      )
    ];
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(),
      body: Center(child: 
        RaisedButton(
          child: Text("ดูรายวัน"),
          onPressed: (){
            report_sale.reportDaily("24/4/2021");
          },
        )
      ,),
    );
  }
}