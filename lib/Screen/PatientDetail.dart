import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfhirapplication/Model/ColorGradient.dart';
import 'package:flutterfhirapplication/Model/Config.dart';
import 'package:flutterfhirapplication/Model/Observation.dart';
import 'package:flutterfhirapplication/Model/Patient.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:intl/intl.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_icons/flutter_icons.dart';

String enumToString(value) {
  return EnumToString.parse(value);
}

class PatientDetail extends StatefulWidget {
  final Patient patient;

  PatientDetail({@required this.patient});

  @override
  State createState() {
    return _PatientDetail(patient: this.patient);
  }
}

class _PatientDetail extends State<PatientDetail> {
  _PatientDetail({@required this.patient});

  ScrollController scrollController;
  Patient patient;
  double width;
  double height;
  var observationData;
  List<Observation> observations;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    observationData = fetchData();
    scrollController = ScrollController();
    FlutterStatusbarcolor.setStatusBarColor(darken(Color.fromARGB(255, 83, 90, 118),40));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 83, 90, 118),
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: darken(Color.fromARGB(255, 83, 90, 118),20),
            title: GestureDetector(
              child: Text(getName()),
              onDoubleTap: () {
                scrollController.animateTo(0.0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn);
              },
            ),
            pinned: true,
            floating: true,
//            flexibleSpace: Placeholder(),
          ),
          FutureBuilder(
            future: observationData,
            builder: _futureBuilder,
          )
        ],
      ),
    );
  }

  Widget getDelegateList(Response response) {
    return SliverList(
        delegate: SliverChildListDelegate(
            [getPatientDetail(), getObservationList(response)]));
  }

  Widget getObservationList(Response response) {
    List<Widget> listview = [];
    for (Observation observation in observations) {
      List<Widget> componetWidget = [];
      int i = 0;
      for (Component component in observation.components) {
        componetWidget.addAll([
          Divider(
            thickness: 2,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(MaterialIcons.subtitles),
            title: Text('${component.text}'),
          ),
          ListTile(
            leading: Icon(MaterialIcons.details),
            title: Text('${component.value} ${component.unit}'),
          ),
        ]);
        i++;
      }
      listview.add(
        Card(
            margin: EdgeInsets.only(left: 20, right: 20, top: 30),
            child: Container(
              margin: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  observation.issued != null && observation.issued != ""
                      ? ListTile(
                          leading: Icon(AntDesign.calendar),
                          title: Text('${observation.issued}'),
                        )
                      : SizedBox.shrink(),
                  ListTile(
                    leading: Icon(MaterialCommunityIcons.format_list_bulleted_type),
                    title: Text('${observation.observationCategory}'),
                  ),
                  ListTile(
                    leading: Icon(MaterialIcons.data_usage),
                    title: Text('${observation.state}'),
                  ),
                ]..addAll(componetWidget),
              ),
            )),
      );
    }
    return Column(
      children: listview,
    );
  }

  Widget getCircularProgressIndicator() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _futureBuilder(
      BuildContext buildContext, AsyncSnapshot asyncSnapshot) {
    if (asyncSnapshot.connectionState == ConnectionState.done) {
      observations = Observation.getObservations(asyncSnapshot.data.data);
      return getDelegateList(asyncSnapshot.data);
    } else {
      return getCircularProgressIndicator();
    }
  }

  IconData getGenderIcon(gender) {
    switch (gender) {
      case Gender.male:
        return FontAwesome.male;
      case Gender.female:
        return FontAwesome.female;
      case Gender.unknown:
        return AntDesign.questioncircle;
      case Gender.other:
        return AntDesign.questioncircle;
    }
  }

  Widget getPatientDetail() {
    return Card(
        margin: EdgeInsets.only(left: 20, right: 20, top: 30),
        child: Container(
          margin: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Icon(getGenderIcon(patient.gender)),
                title: Text(getName()),
              ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text(
                    '${DateFormat('yyyy-MM-dd').format(patient.birthDate)}           ${calculateAge(patient.birthDate)}'),
              ),
              ListTile(
                leading: Icon(FontAwesome.address_book),
                title: Text('${getAddress()}'),
              ),
              patient.maritalStatus != null && patient.maritalStatus != ""
                  ? ListTile(
                      leading: Icon(MaterialCommunityIcons.human_male_female),
                      title: Text('${patient.maritalStatus}'),
                    )
                  : SizedBox.shrink(),
              patient.telecom.length != 0
                  ? ListTile(
                      leading: Icon(Foundation.telephone),
                      title: Text('${patient.telecom[0].value}'),
                    )
                  : SizedBox.shrink(),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('${patient.communications.join(" ")}'),
              ),
            ],
          ),
        ));
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  Future<Response> fetchData() async {
    Dio dio = new Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    Response response = await dio.get(
      '${Config.baseUrl}/api/Observation/${patient.id}',
    );
    return response;
  }

  String getName() {
    return '${patient.names[0].prefix.length == 0 ? "" : patient.names[0].prefix[0]} ${patient.names[0].family} ${patient.names[0].given.length == 0 ? "" : patient.names[0].given[0]}';
  }

  Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
        (c.blue * f).round());
  }

  String getAddress() {
    return '${patient.addresses[0]}';
  }
}
