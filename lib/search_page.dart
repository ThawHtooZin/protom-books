import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'book_details.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchBooks(String query) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://protombook.protechmm.com/api/search?query=$query'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _searchResults =
            data.map((item) => item as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching search results: ${response.statusCode}');
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
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for books...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (query) {
                _searchBooks(query);
              },
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: _searchResults.isEmpty
                        ? const Center(
                            child: Text('No results found.'),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final book = _searchResults[index];
                              return ListTile(
                                leading: Image.network(
                                  'https://protombook.protechmm.com/${book['cover']}',
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
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
                                title: Text(book['title'] ?? 'Unknown Title'),
                                subtitle:
                                    Text(book['author'] ?? 'Unknown Author'),
                                onTap: () => _onBookTap(book),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
