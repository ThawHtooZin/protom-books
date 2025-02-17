import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:protom_books/book_details.dart';

class CategoryBookListPage extends StatefulWidget {
  final String categoryId;

  const CategoryBookListPage({super.key, required this.categoryId});

  @override
  _CategoryBookListPageState createState() => _CategoryBookListPageState();
}

class _CategoryBookListPageState extends State<CategoryBookListPage> {
  List<Map<String, dynamic>> books = []; // Store full book data

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    String categoryId = widget.categoryId;
    final response = await http.get(Uri.parse(
        'https://protombook.protechmm.com/api/books/$categoryId/show'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        books = data.map((item) => item as Map<String, dynamic>).toList();
      });
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: books.isEmpty
            ? const Center(
                child: Text(
                  'No books currently in the category',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 books per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onBookTap(books[index]), // Navigate on tap
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
