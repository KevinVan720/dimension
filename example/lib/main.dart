import 'package:dimension/dimension.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool toggle = true;

  late Dimension beginWidth;
  late Dimension beginHeight;
  late Dimension endWidth;
  late Dimension endHeight;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    beginWidth = Dimension.max(20.toPercentLength, 700.toPXLength);
    beginHeight = (90.toVHLength - 10.toPXLength);

    endWidth = Dimension.clamp(200.toPXLength, 40.toVWLength, 200.toPXLength);
    endHeight = 50.toVHLength +
        10.toPercentLength -
        Dimension.min(4.toPercentLength, 40.toPXLength);


    return Scaffold(
      appBar: AppBar(
        title: Text("Dimension Demo"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            toggle = !toggle;
          });
        },
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.green,
        child: AnimatedDimensionSizedBox(
          duration: Duration(seconds: 2),
          width: toggle ? beginWidth : endWidth,
          height: toggle ? beginHeight : endHeight,
          child: Container(
            alignment: Alignment.topCenter,
            color: Colors.amberAccent,
            child: DefaultTextStyle(
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Screen Size: " + screenSize.toString()),
                      Text("Begin Width: " + beginWidth.toString()),
                      Text("End Width: " + endWidth.toString()),
                      Text("Begin Width in PX: " +
                          beginWidth
                              .toPX(
                                  constraint: screenSize.width,
                                  screenSize: screenSize)
                              .toString() +
                          ", End Width in PX: " +
                          endWidth
                              .toPX(
                                  constraint: screenSize.width,
                                  screenSize: screenSize)
                              .toString()),
                      Text("Begin Height: " + beginHeight.toString()),
                      Text("End Height: " + endHeight.toString()),
                      Text("Begin Height in PX: " +
                          beginHeight
                              .toPX(
                                  constraint: screenSize.height,
                                  screenSize: screenSize)
                              .toString() +
                          ", End Height in PX: " +
                          endHeight
                              .toPX(
                                  constraint: screenSize.height,
                                  screenSize: screenSize)
                              .toString()),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DimensionSizedBox(
                          width: 50.toPercentLength,
                          height: 50.toPercentLength,
                          child: Container(
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
