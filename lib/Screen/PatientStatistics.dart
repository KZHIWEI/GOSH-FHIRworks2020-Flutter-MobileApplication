import 'package:flutterfhirapplication/Model/Patient.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PatientStatistics extends StatefulWidget {
  List<Patient> patients;

  @override
  State<StatefulWidget> createState() {
    return _PatientStatistics(patients);
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
        body: SafeArea(child:PageView(

          children: <Widget>[
            charts.PieChart(_createGenderSampleData(),
                animate: true,
                defaultRenderer: new charts.ArcRendererConfig(
                    arcRendererDecorators: [new charts.ArcLabelDecorator()])),
    charts.LineChart(
      _createAgeSampleData(),
    domainAxis: new charts.NumericAxisSpec(
      showAxisLine: true,
    // Set the initial viewport by providing a new AxisSpec with the
    // desired viewport, in NumericExtents.
    viewport: new charts.NumericExtents(1920, 2020)),
    animate: true,
    )
          ],
        )));
  }

  List<charts.Series<GenderPortion, String>> _createGenderSampleData() {
    final data = calculateGenderPortion();

    return [
      new charts.Series<GenderPortion, String>(
        id: 'Gender',
        domainFn: (GenderPortion _gender, _) => _gender.title,
        measureFn: (GenderPortion _gender, _) => _gender.number,
        data: data,
        labelAccessorFn: (GenderPortion row, _) =>
            '${row.title}: ${((row.number / row.sum) * 100).toStringAsFixed(2)}%',
      ),
    ];
  }

  List<charts.Series<BirthdayPortion, int>> _createAgeSampleData() {
    final data = calculateAgePortion();

    return [
      new charts.Series<BirthdayPortion, int>(
        id: 'Birthday',
        domainFn: (BirthdayPortion _birthday, _) => _birthday.birthday,
        measureFn: (BirthdayPortion _birthday, _) => _birthday.number,
        data: data,

        labelAccessorFn: (BirthdayPortion row, _) =>
            '${row.birthday}: ${row.number }',
      ),
    ];
  }

  calculateGenderPortion() {
    int male = 0;
    int female = 0;
    int unknown = 0;
    int other = 0;
    int sum = 0;
    for (Patient patient in this.patients) {
      switch (patient.gender) {
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
    sum = male + female + unknown + other;
    return [
      GenderPortion('other', other, sum),
      GenderPortion('unknown', unknown, sum),
      GenderPortion('female', female, sum),
      GenderPortion('male', male, sum),
    ];
  }

  calculateAgePortion() {
    var result = List<BirthdayPortion>();
    Map birthdate = Map<int,int>();
    for (Patient patient in patients){
      if(birthdate.containsKey(patient.birthDate.year)){
        birthdate[patient.birthDate.year] = birthdate[patient.birthDate.year] + 1;
      }else{
        birthdate[patient.birthDate.year] = 1;
      }

    }
    var keys = birthdate.keys.toList();
    keys.sort();
    for(int date in keys){
      result.add(BirthdayPortion(date,birthdate[date]));
    }
    return result;
  }
}

class GenderPortion {
  String title;
  int number;
  int sum;

  GenderPortion(this.title, this.number, this.sum);
}

class BirthdayPortion {

  int birthday;
  int number;

  BirthdayPortion(this.birthday, this.number);
}
