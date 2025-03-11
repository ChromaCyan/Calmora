import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class BreathingGuideScreen extends StatelessWidget {
  final String videoUrl = "https://www.youtube.com/watch?v=sJ04nsiz_M0";

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    return Scaffold(
      appBar: AppBar(title: const Text("Breathing Exercise Guide")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId!,
                flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
              ),
              showVideoProgressIndicator: true,
            ),
            const SizedBox(height: 20),
            const Text(
              "Controlled breathing exercises can help reduce stress and promote relaxation. Follow along with the guided session above.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
