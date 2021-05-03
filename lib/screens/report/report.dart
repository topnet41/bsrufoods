import 'package:bsrufoods/controller/report_sale.dart';
import 'package:bsrufoods/widget-picker/widget-cupertino-picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Report extends StatefulWidget {
  final String shopid;
  Report(this.shopid);
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  ReportSale report_sale = ReportSale();
  String year_report;
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
  List moth = [
    "มกราคม",
    "กุมภาพันธ์",
    "มีนาคม",
    "เมษายน",
    "พฤษภาคม",
    "มิถุนายน",
    "กรกฎาคม",
    "สิงหาคม",
    "กันยายน",
    "ตุลาคม",
    "พฤศจิกายน",
    "ธันวาคม"
  ];
  String dataReport;
  List reportDiary = [];
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
        maxTime: DateTime(2035, 6, 7), onChanged: (date) {
      dataReport = "${date.day}/${date.month}/${date.year}";
      print(dataReport);
      report_sale.reportDaily(dataReport).then((value) => reportDiary = value);
      setState(() {});
    }, onConfirm: (date) {
      dataReport = "${date.day}/${date.month}/${date.year}";
      setState(() {});
    }, currentTime: DateTime.now(), locale: LocaleType.th);
  }

  Widget chartsReport(String year) {
    return Container(
      height: 300,
      child: charts.BarChart(_getSeriesData(year),
          animate: true,
          domainAxis: charts.OrdinalAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(labelRotation: 0),
              showAxisLine: true)),
    );
  }

  Widget picker() {
    return Container(
      height: 50,
      width: 100,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.red),
      child: CupertinoPicker(
        children: List.generate(year.length, (index) {
          return Text("${year[index]}",style: TextStyle(color:Colors.white),);
        }),
        magnification: 1.5,
        itemExtent: 25,
        // backgroundColor: Colors.red,
        onSelectedItemChanged: (int index) {
          print("${year[index]}");
          year_report = year[index];
          setState(() {});
        },
      ),
    );
  }

  Widget reportdiary() {
    num _total = 0;
    reportDiary.map((price){
      _total = _total + (price["price"]*price["count_report"]);
    }).toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top:23)),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text("เลือกวันที่เพื่อดูยอดขาย",style: TextStyle(fontSize:20),),
              Padding(padding: EdgeInsets.only(right:10)),
              Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.red,),
                
                child: InkWell(
                    onTap: () => showdate(),
                    child: Center(
                        child: dataReport == null
                            ? Text("กดเพื่อเลือกวันที่",style: TextStyle(color:Colors.white,fontSize: 18))
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(dataReport,style: TextStyle(color:Colors.white,fontSize: 18),),
                                Icon(Icons.arrow_drop_down,size: 30,color: Colors.white,)
                              ],
                            ))),
              )
            ]),
          ),
          Padding(padding: EdgeInsets.only(bottom:10)),
          reportDiary.length > 0 ? 
            Text("ยอดขายรวมทั้งหมด \n ${NumberFormat.simpleCurrency(name: '').format(_total)} บาท",style: TextStyle(fontSize:18),textAlign: TextAlign.center,)
           : Text(""),
          Padding(padding: EdgeInsets.only(bottom:10)),
          Card(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(child: Text("ชื่อเมนู",textAlign: TextAlign.left,style: TextStyle(fontSize:18)),),
                      Expanded(child: Text("จำนวน",textAlign: TextAlign.right,style: TextStyle(fontSize:18))),
                      Expanded(child: Text("หน่วยละ",textAlign: TextAlign.right,style: TextStyle(fontSize:18))),
                      Expanded(child: Text("รวม",textAlign: TextAlign.right,style: TextStyle(fontSize:18))),
                    ],
                  ),
                ),
                
              ),
          ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              
              return Card(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(child: Text("${reportDiary[index]["name"]} ",textAlign: TextAlign.left,style: TextStyle(fontSize:18)),),
                      Expanded(child: Text("${reportDiary[index]["count_report"]}",textAlign: TextAlign.right,style: TextStyle(fontSize:18))),
                      Expanded(child: Text("${reportDiary[index]["price"]}",textAlign: TextAlign.right,style: TextStyle(fontSize:18))),
                      Expanded(child: Text("${NumberFormat.simpleCurrency(name: '').format((reportDiary[index]["price"]*reportDiary[index]["count_report"]))}",textAlign: TextAlign.right,style: TextStyle(fontSize:18))),
                    ],
                  ),
                ),
                
              );
            },
            separatorBuilder: (context, index) =>
                Padding(padding: EdgeInsets.only(bottom: 5)),
            itemCount: reportDiary.length,
          )
        ],
      ),
    );
  }

  Widget reportyear(){
    List _data = report_sale.reportYear(year_report);
    num _total = 0;
    _data.map((e){
      _total = _total + e.price;
      
    }).toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top:23)),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text("เลือกปีเพื่อดูยอดขาย",style: TextStyle(fontSize:20),),
              Padding(padding: EdgeInsets.only(right:10)),
              Container(
                
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                
                child: Row(
                  children: [
                    picker(),
                    Column(children: [
                      Icon(Icons.arrow_drop_up),
                      Icon(Icons.arrow_drop_down)
                    ],)
                  ],
                ),
              )
            ]),
          ),
          Text("ยอดขายรวมทั้งหมด \n ${NumberFormat.simpleCurrency(name: '').format(_total)} บาท",style: TextStyle(fontSize:18),textAlign: TextAlign.center,),
          chartsReport(year_report),
          Column(
            children: List.generate(_data.length, (index){
              return Card(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${moth[index]}",style: TextStyle(fontSize:20),),
                      Text("${NumberFormat.simpleCurrency(name: '').format(_data[index].price)} บาท",style: TextStyle(fontSize:20),)
                    ],
                  ),
                ),
              );
            })
          ,)
        ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              title: Text("รายงานยอดขาย"),
              bottom: TabBar(
                labelStyle: TextStyle(fontSize: 18),
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    text: "ดูยอดรายวัน",
                  ),
                  Tab(
                    text: "ดูยอดรายปี",
                  )
                ],
              )),
          body: TabBarView(children: [
            reportdiary(),
            reportyear()
          ])),
    );
  }
}
