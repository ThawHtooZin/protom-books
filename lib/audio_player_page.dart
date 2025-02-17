import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AudioPlayerPage extends StatefulWidget {
  final int bookId;
  final String bookTitle;
  final String coverUrl;

  const AudioPlayerPage({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.coverUrl,
  });

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final player = AudioPlayer();
  String? _audioUrl;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchAudio();
    player.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
    player.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });
  }

  Future<void> _fetchAudio() async {
    final response = await http.get(
      Uri.parse(
          'https://protombook.protechmm.com/api/books/${widget.bookId}/audios'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          _audioUrl =
              'https://protombook.protechmm.com${data[0]['audio_file']}';
        });
      }
    } else {
      debugPrint("Error fetching audio: ${response.statusCode}");
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        playAudio();
      } else {
        pauseAudio();
      }
    });
  }

  void playAudio() {
    player.play(UrlSource(_audioUrl!));
  }

  void pauseAudio() {
    player.pause();
  }

  void seekForward() async {
    final currentPosition = await player.getCurrentPosition();
    final newPosition = currentPosition! + const Duration(seconds: 10);
    player.seek(newPosition);
  }

  void seekBackward() async {
    final currentPosition = await player.getCurrentPosition();
    final newPosition = currentPosition! - const Duration(seconds: 10);
    player.seek(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Image.network(
                widget.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.bookTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_audioUrl != null)
              Column(
                children: <Widget>[
                  Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (value) {
                      final newPosition = Duration(seconds: value.toInt());
                      player.seek(newPosition);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_currentPosition)),
                      Text(_formatDuration(_totalDuration)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 64,
                    onPressed: _togglePlayPause,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        iconSize: 32,
                        onPressed: seekBackward,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        iconSize: 32,
                        onPressed: seekForward,
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
