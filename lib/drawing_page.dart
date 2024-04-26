import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:drawing_app/drawn_line.dart';
import 'package:drawing_app/sketcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:html' as html;

class UndoRedoButtons extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const UndoRedoButtons({
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: onUndo,
          tooltip: 'Undo',
        ),
        IconButton(
          icon: Icon(Icons.redo),
          onPressed: onRedo,
          tooltip: 'Redo',
        ),
      ],
    );
  }
}

class DrawingPage extends StatefulWidget {
  final String? backgroundImagePath; // Background image path

  DrawingPage({this.backgroundImagePath});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();
  final List<DrawnLine> lines = [];
  DrawnLine? line;
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  final StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  final StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  List<List<DrawnLine>> undoStack = [];
  List<List<DrawnLine>> redoStack = [];
  List<Offset> _points = <Offset>[];

  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }

  Future<void> save() async {
    try {
      if (_globalKey.currentContext != null) {
        RenderRepaintBoundary boundary = _globalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final Uint8List pngBytes = byteData.buffer.asUint8List();
          final blob = html.Blob([pngBytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);

          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", "drawing.png")
            ..click();

          html.Url.revokeObjectUrl(url);
          print("Image saved successfully");
        } else {
          print("Failed to save image: ByteData is null.");
        }
      } else {
        print("Failed to save image: RenderRepaintBoundary not found.");
      }
    } catch (e) {
      print("Error while saving image: $e");
    }
  }

  void clear() {
    setState(() {
      lines.clear();
      line?.path.clear(); // Clear the path if it's not null
      // Optionally, you can also set the canvas to a blank state here
      lines.addAll([]); //to reset the canvas
    });
  }

  void undo() {
    if (lines.isNotEmpty) {
      redoStack.add(List.from(lines));
      lines.clear();
      lines.addAll(undoStack.removeLast());
      linesStreamController.add(lines);
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.from(lines));
      lines.clear();
      lines.addAll(redoStack.removeLast());
      linesStreamController.add(lines);
    }
  }

  Widget _buildCurrentPath() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: RepaintBoundary(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return CustomPaint(
                  painter: Sketcher(
                    lines: [snapshot.data!],
                  ),
                );
              } else {
                return CustomPaint(
                  painter: Sketcher(lines: []),
                ); // Return empty CustomPaint if data is null
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAllPaths() {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Stack(
          children: [
            if (widget.backgroundImagePath != null) // Add the null check here
              Image.asset(
                widget.backgroundImagePath!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            StreamBuilder<List<DrawnLine>>(
              stream: linesStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CustomPaint(
                    painter: Sketcher(
                      lines: snapshot.data!,
                    ),
                  );
                } else {
                  return SizedBox(); // Return an empty widget if data is null
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final Offset point = box!.globalToLocal(details.globalPosition);
    line = DrawnLine([point], selectedColor, selectedWidth);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final Offset point = box!.globalToLocal(details.globalPosition);
    final List<Offset> path = List.from(line!.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line!);
  }

  void _onPanEnd(DragEndDetails details) {
    lines.add(line!);
    linesStreamController.add(lines);
  }

  Widget _buildStrokeToolbar() {
    return Positioned(
      bottom: 50.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _toggleStrokeWidthButtons();
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Icon(
                Icons.brush,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          if (showStrokeWidthButtons) ..._buildStrokeButtons(),
        ],
      ),
    );
  }

  List<Widget> _buildStrokeButtons() {
    return [
      _buildStrokeButton(5.0),
      _buildStrokeButton(10.0),
      _buildStrokeButton(15.0),
      _buildStrokeButton(25.0),
    ];
  }

  bool showStrokeWidthButtons = false;

  void _toggleStrokeWidthButtons() {
    setState(() {
      showStrokeWidthButtons = !showStrokeWidthButtons;
    });
  }

  Widget _buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWidth = strokeWidth;
          showStrokeWidthButtons = false;
        });
      },
      child: Container(
        width: strokeWidth * 2,
        height: strokeWidth * 2,
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: selectedColor,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          border: Border.all(
            color: selectedWidth == strokeWidth
                ? Colors.white
                : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  bool showColorButtons = false; // Define showColorButtons variable here

  void _toggleColorButtons() {
    setState(() {
      showColorButtons = !showColorButtons;
    });
  }

  Widget _buildColorToolbar() {
    return Positioned(
      top: 40.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              _toggleColorButtons();
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(
                Icons.palette,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          if (showColorButtons)
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildColorButtons(),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildColorButtons() {
    return [
      _buildColorButton(Colors.red),
      _buildColorButton(Colors.orange),
      _buildColorButton(Colors.yellow),
      _buildColorButton(Colors.green),
      _buildColorButton(Colors.blue),
      _buildColorButton(Colors.purple),
      // _buildColorButton(Colors.deepPurple),
      _buildColorButton(Colors.pink),
      _buildColorButton(Colors.brown),
      _buildColorButton(Colors.teal),
      _buildColorButton(Colors.indigo),
      _buildColorButton(Colors.grey),
      _buildColorButton(Colors.white),
      _buildColorButton(Colors.black),
    ];
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
          showColorButtons = false; // Hide color buttons after selection
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          border: Border.all(
            color: selectedColor == color ? Colors.white : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            color: Colors.white, // Set background color to white
            width: double.infinity,
            height: double.infinity,
          ),
          _buildAllPaths(),
          _buildCurrentPath(),
          _buildStrokeToolbar(),
          _buildColorToolbar(),
          if (widget.backgroundImagePath != null)
            Image.asset(
              widget.backgroundImagePath!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(top: 30.0, left: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    // Navigate to the home page
                    Navigator.pop(
                        context); // This pops the current route and goes back to the previous one (home page)
                  },
                  tooltip: 'Home',
                  child: Icon(Icons.home),
                ),
                SizedBox(width: 5.0),
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: save,
                  tooltip: 'Save',
                  child: Icon(Icons.save),
                ),
                SizedBox(width: 5.0),
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: clear,
                  tooltip: 'Clear',
                  child: Icon(Icons.clear),
                ),
                SizedBox(width: 5.0),
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: undo,
                  tooltip: 'Undo',
                  child: Icon(Icons.undo),
                ),
                SizedBox(width: 5.0),
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: redo,
                  tooltip: 'Redo',
                  child: Icon(Icons.redo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
