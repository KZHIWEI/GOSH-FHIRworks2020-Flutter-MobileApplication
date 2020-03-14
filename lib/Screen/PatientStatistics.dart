import 'package:flutterfhirapplication/Model/Patient.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PatientStatistics extends StatefulWidget {
  List<Patient> patients;

  @override
  State<StatefulWidget> createState() {
    return _PatientStatistics();
  }

  PatientStatistics(this.patients);
}

class _PatientStatistics extends State<PatientStatistics> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterStatusbarcolor.setStatusBarColor(Colors.blue.shade800);
  }
  List<Patient> patients;

  _PatientStatistics(this.patients);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Statistics'),
      ),
      body: Column(
        children: <Widget>[
        charts.PieChart(seriesList,
        animate: animate,
        defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
          new charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.outside)
        ]
        ))
        ],
      ),
    );
  }
  List<charts.Series<String, int>> _createSampleData() {
    final data = calculateGenderPortion();

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearSales row, _) => '${row.year}: ${row.sales}',
      )
    ];
  }
  calculateGenderPortion(){
    int male = 0;
    int female= 0;
    int unknown= 0;
    int other= 0;
    for (Patient patient in this.patients){
      switch (patient.gender){
        case Gender.other:
          other++;
          break;
        case Gender.unknown:
          unknown++;
          break;
        case Gender.female:
          female++;
          break;
        case Gender.male:
          male++;
          break;
      }
    }
    return [
      GenderPortion('other',other),
      GenderPortion('unknown',unknown),
      GenderPortion('female',female),
      GenderPortion('male',male),
    ];
  }
}

class GenderPortion{
  String title;
  int number;

  GenderPortion(this.title, this.number);

}
