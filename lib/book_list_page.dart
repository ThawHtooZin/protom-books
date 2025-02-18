import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'book_details.dart';

class BookListPage extends StatefulWidget {
  final String title;
  final String apiUrl;

  const BookListPage({super.key, required this.title, required this.apiUrl});

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<Map<String, dynamic>> books = [];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse(widget.apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        books = data.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      debugPrint('Failed to fetch books: ${response.statusCode}');
    }
  }

  void _onBookTap(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          bookTitle: book['title'] ?? 'Unknown Title',
          author: book['author'] ?? 'Unknown Author',
          coverUrl: 'https://protombook.protechmm.com/${book['cover']}',
          description: book['description'] ?? 'No description available.',
          price: double.tryParse(book['price'].toString()) ?? 0.0,
          bookId: book['id'] ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: books.isEmpty
            ? const Center(
                child: Text(
                  'No books available',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onBookTap(books[index]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://protombook.protechmm.com/${books[index]['cover']}',
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
                  );
                },
              ),
      ),
    );
  }
}
