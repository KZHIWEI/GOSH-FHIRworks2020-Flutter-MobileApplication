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
String enumToString(value){
  return EnumToString.parse(value);
}
class PatientDetail extends StatefulWidget {
  final ColorGradient colorGradient;
  final Patient patient;

  PatientDetail({@required this.patient, @required this.colorGradient});

  @override
  State createState() {
    return _PatientDetail(patient: this.patient, color: this.colorGradient);
  }
}

class _PatientDetail extends State<PatientDetail> {
  _PatientDetail({@required this.patient, @required this.color});
  ScrollController scrollController;
  ColorGradient color;
  Patient patient;
  double width;
  double height;
  var observationData;
  List<Observation> observations;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterStatusbarcolor.setStatusBarColor(color.start.withOpacity(0.8));
    observationData = fetchData();
    scrollController = ScrollController();

  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: color.start,
//      drawerScrimColor: Colors.transparent,
//      endDrawer: SafeArea(
//        child: SizedBox(
//            width: width * 0.5,
//            child: Drawer(
//              child: ListView(
//                children: <Widget>[
//                  new DrawerHeader(
//                    child: new Text('Header'),
//                  ),
//                  new ListTile(
//                    title: new Text('First Menu Item'),
//                    onTap: () {},
//                  ),
//                  new ListTile(
//                    title: new Text('Second Menu Item'),
//                    onTap: () {},
//                  ),
//                  new Divider(),
//                  new ListTile(
//                    title: new Text('About'),
//                    onTap: () {},
//                  ),
//                ],
//              ),
//            )),
//      ),
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: color.start,
            title: GestureDetector(
                child:Text(getName()),
              onDoubleTap: (){
                  scrollController.animateTo(0.0, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
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
        delegate: SliverChildListDelegate([
          getPatientDetail(),
          getObservationList(response)
        ]));
  }
  Widget getObservationList(Response response){
    List<Widget> listview = [];
    for (Observation observation in observations){
      List<Widget> componetWidget = [];
      for(Component component in observation.components){
        componetWidget.addAll(
            [
              Text('${component.text}',
                style: TextStyle(
                    fontSize: 20,
                    color: color.end
                ),),
              Text('${component.value} ${component.unit}',
                style: TextStyle(
                  fontSize: 20,
                    color: color.end
                ),)
            ]
        );
      }
      listview.add(
        Container(
          width: width,
//      height: 600,
          margin: EdgeInsets.only(left: 20, right: 20,top: 30),
          decoration: new BoxDecoration(
            color: darken(color.start, 16),
//          color: colors[index % colors.length],
            borderRadius: new BorderRadius.all(Radius.circular(20)),
//        gradient: ColorMap.getContainerGradient(index),
          ),
          child: Container(
            margin: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                observation.issued != null && observation.issued != ""?
                Text(
                    'Issued ${observation.issued}',
                  style: TextStyle(
                      color: color.end
                  ),
                ):SizedBox.shrink(),
                Text(
                  'Category: ${observation.observationCategory}',
                  style: TextStyle(
                    color: color.end,
                    fontSize: 25,
                  ),
                ),
                Text(
                  'State: ${observation.state}',
                  style: TextStyle(
                      color: color.end,
                    fontSize: 25,
                  ),
                )
              ]..addAll(componetWidget),

            ),
          )
        ),
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

  Widget getPatientDetail() {
    return Container(
        width: width * 0.8,
//      height: 600,
        margin: EdgeInsets.only(left: 20, right: 20),
        decoration: new BoxDecoration(
          color: darken(color.start, 12),
//          color: colors[index % colors.length],
          borderRadius: new BorderRadius.all(Radius.circular(20)),
//        gradient: ColorMap.getContainerGradient(index),
        ),
        child: Container(
          margin: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                getName(),
                style: TextStyle(
                    color: color.end,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              Divider(
                height: 10,
                color: Colors.transparent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Gender: ',
                        style: TextStyle(
                            color: color.end,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        enumToString(patient.gender),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: color.end,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Age: ',
                        style: TextStyle(
                            color: color.end,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${calculateAge(patient.birthDate)}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: color.end,
                          fontSize: 20,
                        ),
                      )
                    ],
                  )
                ],
              ),
              Text(
                'Address:',
                style: TextStyle(
                    color: color.end,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
               padding: EdgeInsets.only(left: 10),
               child: Text(
                 '${getAddress()}',
                 textAlign: TextAlign.start,
                 style: TextStyle(
                   color: color.end,
                   fontSize: 20,
                 ),
               ),
              ),
              Text(
                'Birthdate:',
                style: TextStyle(
                    color: color.end,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child:Text(
                  '${DateFormat('yyyy-MM-dd').format(patient.birthDate)}',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: color.end,
                    fontSize: 20,
                  ),
                ) ,
              ),
              patient.maritalStatus != null  && patient.maritalStatus != "" ? Text(
                'Marital Status:',
                style: TextStyle(
                    color: color.end,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ):SizedBox.shrink(),
              patient.maritalStatus != null  && patient.maritalStatus != ""  ?
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      '${patient.maritalStatus}',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: color.end,
                        fontSize: 20,
                      ),
                    ),
                  ) :SizedBox.shrink(),
              patient.telecom.length != 0?Text(
                'TeleCom:',
                style: TextStyle(
                    color: color.end,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ):SizedBox.shrink(),
              patient.telecom.length != 0?
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: getTelecomList(),
                    ),
                  ) :SizedBox.shrink(),
              Text(
                'Language: ${patient.communications.join(" ")}',
                style: TextStyle(
                  color: color.end,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ));
  }
  List<Widget> getTelecomList(){
    List<Widget> result = <Widget>[];
    for(ContactPoint contactPoint in patient.telecom){
      result.addAll([
        Text(
          'System: ${enumToString(contactPoint.system)}',
          style: TextStyle(
            color: color.end,
              fontSize: 15
          ),
        ),
        Text(
            'use: ${enumToString(contactPoint.use)}',
          style: TextStyle(
              color: color.end,
              fontSize: 15
          ),
        ),
        Text(
            'Number: ${contactPoint.value}',
          style: TextStyle(
              color: color.end,
            fontSize: 15
          ),
        ),
      ]);
    }
    return result;
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
