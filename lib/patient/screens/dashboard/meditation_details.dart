import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MeditationGuideScreen extends StatelessWidget {
  final String videoUrl = "https://www.youtube.com/watch?v=inpok4MKVLM";

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    return Scaffold(
      appBar: AppBar(title: const Text("Meditation Guide")),
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
              "Meditation is a great way to relieve stress and improve mental clarity. Follow along with the guided session above.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
