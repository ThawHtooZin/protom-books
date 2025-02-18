import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'audio_player_page.dart';
import 'membership_page.dart';

class BookDetailsPage extends StatefulWidget {
  final String bookTitle;
  final String author;
  final String coverUrl;
  final String description;
  final double price;
  final int bookId;

  const BookDetailsPage({
    super.key,
    required this.bookTitle,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.price,
    required this.bookId,
  });

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool _hasAudio = false;

  @override
  void initState() {
    super.initState();
    _fetchAudio();
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
          _hasAudio = true;
        });
      }
    } else {
      debugPrint("Error fetching audio: ${response.statusCode}");
    }
  }

  void _navigateToAudioPlayer(BuildContext context) {
    if (widget.price == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioPlayerPage(
            bookId: widget.bookId,
            bookTitle: widget.bookTitle,
            coverUrl: widget.coverUrl,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MembershipPage(),
        ),
      );
    }
  }

  void _readPDF() {
    if (widget.price == 0) {
      print('Clicked');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MembershipPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.bookTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'by ${widget.author}',
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (widget.price == 0)
                Column(
                  children: <Widget>[
                    if (_hasAudio)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _navigateToAudioPlayer(context),
                          child: const Text('Play Audio'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _readPDF(),
                        child: const Text('Read'),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MembershipPage(),
                            ),
                          );
                        },
                        child: const Text('Buy Membership to Read'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
