import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'package:fluffy_bunny/db/model/Objective.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final Objective objective;

  const TakePictureScreen({
    Key key,
    @required this.camera,
    this.objective,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;


  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the provided directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getApplicationDocumentsDirectory()).path,
              // gli spazi gli danno fastidio.
              '${widget.objective.createdDate}+${DateTime.now()}'.replaceAll(" ", "") + '.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);


            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path, objective: widget.objective),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Objective objective;

  const DisplayPictureScreen({Key key, this.imagePath, this.objective}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
          child: Column(
        children: <Widget>[
          Container(
              height: 400, width: 400, child: Image.file(File(imagePath))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Do you like it?", style: TextStyle(fontSize: 22.0),),
          ),
          Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      var bp = BlocProvider(child: null, bloc: TaskBloc());
                      await bp.bloc.addPhoto(objective, imagePath);

                      print("seeee");
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }),
                IconButton(
                    icon: Icon(Icons.undo),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          )
        ],
      )),
    );
  }
}
