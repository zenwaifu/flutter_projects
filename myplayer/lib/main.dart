import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audio Player',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme:  AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: MyPlayer(),
    );
  }
}

class MyPlayer extends StatefulWidget {
  const MyPlayer({super.key});

  @override
  State<MyPlayer> createState() => _MyPlayerState();
}

class _MyPlayerState extends State<MyPlayer> {
  late AudioPlayer player =  AudioPlayer();
  AudioCache audioCache = AudioCache();
  String status = 'Not Playing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Audio Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Playing Audio from Assets', 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    iconSize: 48,
                    onPressed: stopMe,
                    icon: Icon(Icons.stop),
                  ),
                  IconButton(
                    iconSize: 48,
                    onPressed: playMe,
                    icon: Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    iconSize: 48,
                    onPressed: pauseMe,
                    icon: Icon(Icons.pause),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Status: $status', 
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text('Playing from online URL', 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    iconSize: 48,
                    onPressed: stopMe,
                    icon: Icon(Icons.stop),
                  ),
                  IconButton(
                    iconSize: 48,
                    onPressed: playMeURL,
                    icon: Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    iconSize: 48,
                    onPressed: pauseMe,
                    icon: Icon(Icons.pause),
                  ),
                ],
              ),
            ),
          ],
      ),
      )
    );

  }

  void playMe() {
    player.play(AssetSource('bell.mp3'));
    //player.play(AssetSource('sonne.mp3'));
    setState(() {
      status = 'Playing from Assets';
    });
  }

  void stopMe() {
    player.stop();
    setState(() {
      status = 'Stop';
    });
  }

  void pauseMe() {
    player.pause();
    setState(() {
      status = 'Pause';
    });
  }

  /// Play a song from a URL.
  ///
  /// This function plays the song located at the provided URL.
  ///
  /// The URL must be a valid URL pointing to a file that can be played
  /// by the player (e.g. an MP3 file).
  ///
  /// The function will also update the status of the player to reflect
  /// the current state of the player.
  void playMeURL() {
    /// Play the song from the URL
    player.play(UrlSource('https://codeskulptor-demos.commondatastorage.googleapis.com/pang/paza-moduless.mp3'));

    /// Update the status of the player
    setState(() {
      status = 'Playing from URL';
    });
  }
}
