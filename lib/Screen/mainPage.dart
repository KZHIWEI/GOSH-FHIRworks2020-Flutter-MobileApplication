import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutterfhirapplication/Model/Config.dart';

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
  int _filterSex = 2;
  //unknown = 2
  //female = 0
  //male = 1
  AnimationController _fliterController;
  Animation<Offset> _fliteroffsetAnimation;
  ScrollController _filterScrollController;
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
          backgroundColor: Colors.white,
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
          child: Stack(
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
          onWillPop: () async {
            onHideFilter();
            return false;
          },
        ));
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
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext ctxt, int index) {
          var widgetList = <Widget>[];
          for (int i = 0; i < data[index]["entry"].length; i++) {
            widgetList.add(_buildList(ctxt, i, data[index]["entry"][i]));
          }
          return Column(
            children: widgetList,
          );
//          return ListView.builder(
//            itemCount: data[index]["entry"].length,
//              itemBuilder: (BuildContext ctxtx, int indexi){
//                return _buildList(ctxt, index, data);
//          });
        });
  }

  _buildList(BuildContext ctxt, int index, data) {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: Container(
        decoration: new BoxDecoration(
          color: colors[index % colors.length],
          borderRadius: new BorderRadius.all(Radius.circular(20)),
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
            children: <Widget>[getName(data)],
          ),
          margin: EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget getName(data) {
    var name = data["resource"]["name"][0];
    return Text(
      '${name["prefix"] == null ? "" : name["prefix"][0]} ${name["family"]} ${name["given"][0]}',
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
                        TextField(
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
                            color: Colors.grey.shade800
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Unknown',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Checkbox(
                                  value: _filterSex == 2,
                                  activeColor: Colors.blue,
                                  onChanged:(value){
                                    setState(() {
                                      _filterSex=2;
                                    });
                                  } ,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Female',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Checkbox(
                                  value: _filterSex == 0,
                                  activeColor: Colors.blue,
                                  onChanged:(value){
                                    setState(() {
                                      _filterSex=0;
                                    });
                                  } ,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Male',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                  ),
                                ),
                                Checkbox(
                                  value: _filterSex == 1,
                                  activeColor: Colors.blue,
                                  onChanged:(value){
                                    setState(() {
                                      _filterSex=1;
                                    });
                                  } ,
                                )
                              ],
                            )
                          ],
                        )
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

  @override
  void dispose() {
    super.dispose();
    _fliterController.dispose();
  }
}
