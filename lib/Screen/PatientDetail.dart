import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfhirapplication/Model/ColorGradient.dart';
import 'package:flutterfhirapplication/Model/Config.dart';
import 'package:flutterfhirapplication/Model/Patient.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
class PatientDetail extends StatefulWidget{
  final ColorGradient colorGradient;
  final Patient patient;
  PatientDetail({@required this.patient,@required this.colorGradient});
  @override
  State createState() {
    return _PatientDetail(patient: this.patient,color: this.colorGradient);
  }
}

class _PatientDetail extends State<PatientDetail>{
  _PatientDetail({@required this.patient,@required this.color});
  ColorGradient color;
  Patient patient;
  double width;
  double height;
  var observationData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterStatusbarcolor.setStatusBarColor(color.start.withOpacity(0.8));
    observationData = fetchData();
  }
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: color.start,
      drawerScrimColor: Colors.transparent,
      endDrawer: SafeArea(
      child:SizedBox(
        width: width*0.5,
          child:Drawer(
        child: ListView(
          children: <Widget>[
            new DrawerHeader(child: new Text('Header'),),
            new ListTile(
              title: new Text('First Menu Item'),
              onTap: () {},
            ),
            new ListTile(
              title: new Text('Second Menu Item'),
              onTap: () {},
            ),
            new Divider(),
            new ListTile(
              title: new Text('About'),
              onTap: () {},
            ),
          ],
        ),
      )
      ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: color.start,
            title: Text(getName()),
          ),
          FutureBuilder(
            future: observationData,
            builder:_futureBuilder ,
          )
        ],
      ),
    );
  }
  Widget getDelegateList(){
    return SliverList(delegate: SliverChildListDelegate(
        [
          getPatientDetail(),
          Divider()
        ]
    ));
  }
  Widget getCircularProgressIndicator(){
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child:CircularProgressIndicator()),
    );
  }
  Widget _futureBuilder(BuildContext buildContext,AsyncSnapshot asyncSnapshot){
    if(asyncSnapshot.connectionState ==ConnectionState.done){
      return getDelegateList();
    }else{
      return getCircularProgressIndicator();
    }
  }
  Widget getPatientDetail(){
    return Container(
      width: width*0.8,
      height: 600,
      margin: EdgeInsets.only(left:20,right: 20),
      decoration: new BoxDecoration(
        color: darken(color.start,12),
//          color: colors[index % colors.length],
        borderRadius: new BorderRadius.all(Radius.circular(20)),
//        gradient: ColorMap.getContainerGradient(index),
      ),
      child: Column(

      ),
    );
  }
  Future<Response> fetchData()async{
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
    return '${patient.names[0].prefix.length == 0? "" : patient.names[0].prefix[0]} ${patient.names[0].family} ${patient.names[0].given.length == 0? "" : patient.names[0].given[0]}';
  }
  Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
        c.alpha,
        (c.red * f).round(),
        (c.green  * f).round(),
        (c.blue * f).round()
    );
  }
}