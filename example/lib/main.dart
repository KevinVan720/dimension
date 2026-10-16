import 'package:dimension/dimension.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool toggle = true;

  late Dimension beginWidth;
  late Dimension beginHeight;
  late Dimension endWidth;
  late Dimension endHeight;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    beginWidth = Dimension.max(20.toPercentLength, 700.toPXLength);
    beginHeight = (90.toVHLength - 10.toPXLength);

    endWidth = Dimension.clamp(200.toPXLength, 40.toVWLength, 200.toPXLength);
    endHeight = 50.toVHLength +
        10.toPercentLength -
        Dimension.min(4.toPercentLength, 40.toPXLength);

    final double beginWidthPX =
        beginWidth.toPX(constraint: screenSize.width, screenSize: screenSize);
    final double endWidthPX =
        endWidth.toPX(constraint: screenSize.width, screenSize: screenSize);
    final double beginHeightPX =
        beginHeight.toPX(constraint: screenSize.height, screenSize: screenSize);
    final double endHeightPX =
        endHeight.toPX(constraint: screenSize.height, screenSize: screenSize);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dimension Demo'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            toggle = !toggle;
          });
        },
        child: const Icon(Icons.refresh),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.green,
        child: AnimatedDimensionSizedBox(
          duration: const Duration(seconds: 2),
          width: toggle ? beginWidth : endWidth,
          height: toggle ? beginHeight : endHeight,
          child: Container(
            alignment: Alignment.topCenter,
            color: Colors.amberAccent,
            child: DefaultTextStyle(
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Screen Size: $screenSize'),
                      Text('Begin Width: $beginWidth'),
                      Text('End Width: $endWidth'),
                      Text('Begin Width in PX: $beginWidthPX, '
                          'End Width in PX: $endWidthPX'),
                      Text('Begin Height: $beginHeight'),
                      Text('End Height: $endHeight'),
                      Text('Begin Height in PX: $beginHeightPX, '
                          'End Height in PX: $endHeightPX'),
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
