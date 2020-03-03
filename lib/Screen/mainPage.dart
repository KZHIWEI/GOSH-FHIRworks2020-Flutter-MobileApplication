import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutterfhirapplication/Model/ColorGradient.dart';
import 'package:flutterfhirapplication/Model/Config.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutterfhirapplication/Model/Patient.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as rs;
class mainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _mainPage();
  }
}

class _mainPage extends State<mainPage> with SingleTickerProviderStateMixin {
  double width;
  double height;
  bool onFilter = false;
  var patientJson;
  List<Patient> displayPatients;
  Gender _gender = Gender.unknown;
  //unknown = 2
  //female = 0
  //male = 1
  double _maxRange = 100;
  bool onFetch = true;
  double _minRange = 0;
  AnimationController _fliterController;
  Animation<Offset> _fliteroffsetAnimation;
  ScrollController _filterScrollController;
  List<Patient> originPatients = [];
  TextEditingController _nameController;
  TextEditingController _addressController;
  TextEditingController _phoneController;
  final colors = <Color>[
    Colors.greenAccent,
    Colors.pink,
    Colors.yellow,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.lightBlueAccent,
    Colors.deepOrange
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    patientJson = fetchData();
    _fliterController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fliteroffsetAnimation = Tween<Offset>(
      end: Offset.zero,
      begin: const Offset(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _fliterController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: onFilter?Color.fromRGBO(112, 112, 112, 0.3):Colors.white,
          leading: Icon(
            Icons.refresh,
            color: Colors.grey.shade600,
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    onFilter = !onFilter;
                    if (onFilter) {
                      _fliterController.forward();
                    } else {
                      _fliterController.reverse();
                    }
                  });
                })
          ],
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Patients',
            style: TextStyle(
              color: Color.fromRGBO(
                112,
                112,
                112,
                1.0,
              ),
              fontSize: 20,
            ),
          ),
        ),
        body: WillPopScope(
          child:Material(
            child:Stack(
            children: <Widget>[
              RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      patientJson = fetchData();
                    });
                  },
                  child: Center(
                      child: Container(
                    child: FutureBuilder(
                      future: patientJson,
                      builder: _futureBuilder,
                    ),
                  ))),
              GestureDetector(
                onTap: (){
                  onSearch();
                  onHideFilter();
                },
//                child: SizedBox.expand(
                    child: AnimatedContainer(
                      duration: Duration(microseconds: 500),
                      width: onFilter?width:0,
                  height: onFilter?height:0,
                  color:onFilter?Color.fromRGBO(112, 112, 112, 0.3):Colors.transparent
                ),
              ),
              SlideTransition(
                position: _fliteroffsetAnimation,
                child: getFilter(),
              )
            ],
          ),
        ),
          onWillPop: () async {
            onRestore();
            onHideFilter();
            return false;
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: onFilter?FloatingActionButton(
          onPressed: (){
            onSearch();
            onHideFilter();
          },
        child: Icon(
          Icons.done
        ),
    ):SizedBox.shrink(),
    );
  }
  onHideFilter(){
    onFilter = false;
    _fliterController.reverse();
    setState(() {});
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
      '${Config.baseUrl}/api/Patient/',
    );

//    Response response = await Dio().get("www.google.com");
    return response;
  }

  Widget _futureBuilder(BuildContext buildContext, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return loadPatients(snapshot.data);
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  loadPatients(Response response) {
    var data = response.data;
    for (int i = 0; i < data.length; i++) {
      for(int entry = 0 ; entry < data[i]['entry'][entry].length;entry++){
        originPatients.add(Patient.getPatient(data[i]['entry'][entry]['resource']));
      }
    }
    return ListView.builder(
        itemCount: (displayPatients??originPatients).length,
        itemBuilder: (BuildContext ctxt, int index) {
          return _buildPatient((displayPatients??originPatients)[index],index);
        });
  }

  _buildPatient(Patient patient,index) {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: Container(
        decoration: new BoxDecoration(
//          color: colors[index % colors.length],
          borderRadius: new BorderRadius.all(Radius.circular(20)),
          gradient: ColorMap.getContainerGradient(index),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 15, // has the effect of softening the shadow
              spreadRadius: 5.0, // has the effect of extending the shadow
              offset: Offset(
                6.0, // horizontal, move right 10
                7.0, // vertical, move down 10
              ),
            )
          ],
        ),
        margin: EdgeInsets.only(left: 30, right: 30),
        width: width * 0.85,
        height: 200,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getName(patient),
              getBirthDateAndGender(patient),
            Text(
              'Address:',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
        fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.grey,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
              getAddress(patient),
              getLanguage(patient)
            ],
          ),
          margin: EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget getName(Patient patient) {
    return Text(
      '${patient.names[0].prefix.length == 0? "" : patient.names[0].prefix[0]} ${patient.names[0].family} ${patient.names[0].given.length == 0? "" : patient.names[0].given[0]}',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 5.0,
            color: Colors.grey,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
    );
  }
  String enumToString(value){
    return EnumToString.parse(value);
  }
  Widget getBirthDateAndGender(Patient patient){
    return Text(
      'Age:${calculateAge(patient.birthDate)}  Gender: ${enumToString(patient.gender)}',
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 5.0,
            color: Colors.grey,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
    );
  }
  Widget getAddress(Patient patient){
    return Text(
      '${patient.addresses[0]}',
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
//        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 2.0,
            color: Colors.grey,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
    );
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
  Widget getLanguage(Patient patient){
    return Text(
      'Language: ${patient.communications.join("")}',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 5.0,
            color: Colors.grey,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
    );
  }
  getFilter() {
    return DraggableScrollableSheet(
      minChildSize: 0.3,
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        _filterScrollController = scrollController;
        scrollController.addListener(() {
          print(scrollController.offset);
        });
        return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowGlow();
              return false;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                child: Container(
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 20.0,
                        // has the effect of softening the shadow
                        spreadRadius: 5.0,
                        // has the effect of extending the shadow
                        offset: Offset(
                          0.0, // horizontal, move right 10
                          12.0, // vertical, move down 10
                        ),
                      )
                    ],
                  ),
                  width: width,
                  height: 1800,
                  child: Container(
                    margin: EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child:InkWell(
                            child: Icon(
                              Icons.settings_backup_restore,
                              size: 30,
                            ),
                            splashColor: Colors.lightBlue,
                            onTap: (){
                              onRestore();
                            },
                          )
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 20,
                        ),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.black)),
                              labelText: "Name"),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 30,
                        ),
                        TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.black)),
                              labelText: "Address"),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 30,
                        ),
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.black)),
                              labelText: "Phone Number"),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 30,
                        ),
                        Text(
                          'Gender',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            color: Color.fromARGB(255, 112, 112, 112)
                          ),
                        ),
                        Container(
                          width: width*0.4,
                          child:DropdownButton(
                            focusColor: Colors.lightBlue,
                            isExpanded: true,
                            hint: new Text("Gender"),
                            value: _gender,
                            onChanged: (Gender gender) {
                              setState(() {
                                _gender = gender;
                              });
                            },
                            items:[
                              DropdownMenuItem(
                                value: Gender.unknown,
                                child: new Text(
                                  "Unknown",
                                  style: new TextStyle(color: Color.fromARGB(255, 80, 80, 80)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: Gender.male,
                                child: new Text(
                                  "Male",
                                  style: new TextStyle(color: Color.fromARGB(255, 80, 80, 80)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: Gender.female,
                                child: new Text(
                                  "Female",
                                  style: new TextStyle(color: Color.fromARGB(255, 80, 80, 80)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: Gender.other,
                                child: new Text(
                                  "Other",
                                  style: new TextStyle(color: Color.fromARGB(255, 80, 80, 80)),
                                ),
                              )
                            ] ,
                          ),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Age',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 112, 112, 112)
//                                  color: Colors.grey.shade800
                              ),
                            ),
                            Text(
                              '${_minRange.floor()} - ${_maxRange.floor()}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 112, 112, 112)
                              ),
                            )
                          ],
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 15,
                        ),
                        rs.RangeSlider(
                          min: 0,
                          max: 100,
                          lowerValue: _minRange,
                          upperValue: _maxRange,
//                          divisions: 100,
//                          showValueIndicator: true,
//                          valueIndicatorMaxDecimals: 0,
                          onChanged: (double newLowerValue, double newUpperValue) {
                            setState(() {
                              _minRange = newLowerValue;
                              _maxRange = newUpperValue;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                ),
                padding: EdgeInsets.only(top: 30),
              ),
            ));
      },
    );
  }
  onSearch(){
//    onFilter = false;
    FocusScope.of(context).unfocus();
    displayPatients = originPatients.where((element) {
//      return false;
      bool result = false;
      if(_nameController.text != ""){
        String nameText = _nameController.text.toLowerCase();
        for(HumanName name in element.names){
          result = result || name.given.any((element){
            return element.toLowerCase().contains(nameText);
          });
          result = result || name.prefix.any((element){
            return element.toLowerCase().contains(nameText);
          });
          result = result || name.suffix.any((element){
            return element.toLowerCase().contains(nameText);
          });
          result = result || name.family.toLowerCase().contains(nameText);
        }
      }
      if(_addressController.text != ""){
        String addressText = _addressController.text.toLowerCase();
        result = result || element.addresses.any((element){
          bool addressResult = false;
          addressResult = addressResult || element.lines.any((element){
            return element.toLowerCase().contains(addressText);
          });
          addressResult = addressResult || ((element.postalCode?.toLowerCase()?.contains(addressText))??false);
          addressResult = addressResult || ((element.city?.toLowerCase()?.contains(addressText))??false);
          addressResult = addressResult || ((element.state?.toLowerCase()?.contains(addressText))??false);
          addressResult = addressResult || ((element.country?.toLowerCase()?.contains(addressText))??false);
          return addressResult;
        });
      }
      if(_phoneController.text != ""){
        String numberText = _phoneController.text.replaceAll(RegExp(r"[^0-9]"), '');
        result = result || element.telecom.any((element){
//          print(numberText);
//          print(element.value.replaceAll(RegExp(r"[^0-9]"), ''));
          return element.value.replaceAll(RegExp(r"[^0-9]"), '').contains(numberText);
        });
      }
      if(_nameController.text == "" && _addressController.text == "" && _phoneController.text == ""){
        result = true;
      }
      if(_gender != Gender.unknown){
        result = result && _gender == element.gender;
      }
      result = result && (_minRange <= calculateAge(element.birthDate) &&  calculateAge(element.birthDate) <= _maxRange);
      return result;
    }).toList();
    onHideFilter();
    setState(() {

    });
  }
  onRestore(){
    _nameController.text = "";
    _minRange = 0;
    _maxRange = 100;
    _addressController.text = "";
    _phoneController.text = "";
    _gender = Gender.unknown;
    FocusScope.of(context).unfocus();
    displayPatients = originPatients;
//    onHideFilter();
    setState(() {

    });
  }
  @override
  void dispose() {
    super.dispose();
    _fliterController.dispose();
  }
}
