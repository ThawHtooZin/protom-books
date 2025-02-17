import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:protom_books/category_detail.dart';
import 'package:protom_books/profile.dart';
import 'package:protom_books/search_page.dart';
import 'package:protom_books/notifications_page.dart';
import 'dart:convert';
import 'book_details.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> _categories = [];
  List<dynamic> _latestBooks = [];
  List<dynamic> _popularBooks = [];
  List<dynamic> _freeBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchCategories(),
      _fetchLatestBooks(),
      _fetchPopularBooks(),
      _fetchFreeBooks(),
    ]);
  }

  Future<void> _fetchCategories() async {
    final response = await http
        .get(Uri.parse('https://protombook.protechmm.com/api/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _categories = [
              {
                'id': '1',
                'name': 'Free Books',
              }
            ] +
            data.map((category) {
              return {
                'id': category['id']?.toString() ?? 'unknown', // Prevent null
                'name': category['name']?.toString() ?? 'Unknown Category'
              };
            }).toList();
      });

      debugPrint("Final categories: $_categories");
    } else {
      debugPrint("Failed to fetch categories");
    }
  }

  Future<void> _fetchLatestBooks() async {
    final response = await http
        .get(Uri.parse('https://protombook.protechmm.com/api/latest-books'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _latestBooks = data.take(8).toList();
      });
    } else {
      // Handle error
    }
  }

  Future<void> _fetchFreeBooks() async {
    final response = await http
        .get(Uri.parse('https://protombook.protechmm.com/api/free-books'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _freeBooks = data.take(8).toList();
      });
    } else {
      // Handle error
    }
  }

  Future<void> _fetchPopularBooks() async {
    final response = await http
        .get(Uri.parse('https://protombook.protechmm.com/api/popular-books'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _popularBooks = data.take(8).toList();
      });
    } else {
      // Handle error
    }
  }

  void _onCategoryTap(String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategoryBookListPage(categoryId: categoryId.toString()),
      ),
    );
  }

  void _onBookTap(Map<String, dynamic> book, userId) async {
    int bookId = book['id'];

    // Send the API request to trigger the view record
    final response = await http.post(
      Uri.parse('https://protombook.protechmm.com/api/books/$bookId/show'),
      body: {
        'userId': userId.toString(), // Ensure it's a string
      },
      headers: {
        'Content-Type':
            'application/x-www-form-urlencoded', // ✅ Required for form data
        'Accept': 'application/json', // ✅ Ensure Laravel processes it correctly
      },
    );

    debugPrint('Response Status Code: ${response.statusCode}');

    // Navigate to book details page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          bookTitle: book['title'],
          author: book['author'],
          coverUrl: 'https://protombook.protechmm.com/${book['cover']}',
          description: book['description'],
          price: book['price'].toDouble(),
          bookId: bookId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show custom alert before going back
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Exit ProTom Books?"),
              content: const Text("Are you sure you want to exit the app?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // No
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Yes
                  },
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        );

        // If Yes, quit the app
        if (shouldExit) {
          SystemNavigator.pop(); // This will close the app
        }
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove the back arrow
          backgroundColor: Colors.blue, // Home theme color
          title:
              const Text('ProTom Books', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: const BorderSide(color: Colors.blue),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: const BorderSide(color: Colors.blue),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchCategories();
            await _fetchLatestBooks();
            await _fetchFreeBooks();
            await _fetchPopularBooks();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Books Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Blueberry theme
                        ),
                      ),
                      Icon(Icons.arrow_forward,
                          color: Colors.blue), // Blueberry theme
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio:
                          3 / 1, // Adjust aspect ratio to make boxes smaller
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () =>
                            _onCategoryTap(_categories[index]['id'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _categories[index]['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Latest Books',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Blueberry theme
                        ),
                      ),
                      Icon(Icons.arrow_forward,
                          color: Colors.blue), // Blueberry theme
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200, // Adjust height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _latestBooks.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _onBookTap(_latestBooks[index], widget.userId),
                          child: Container(
                            width: 120, // Adjust width as needed
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    'https://protombook.protechmm.com/${_latestBooks[index]['cover']}',
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _latestBooks[index]['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Popular Books',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Blueberry theme
                        ),
                      ),
                      Icon(Icons.arrow_forward,
                          color: Colors.blue), // Blueberry theme
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200, // Adjust height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _popularBooks.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _onBookTap(_popularBooks[index], widget.userId),
                          child: Container(
                            width: 120, // Adjust width as needed
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    'https://protombook.protechmm.com/${_popularBooks[index]['cover']}',
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _popularBooks[index]['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Free Books',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Blueberry theme
                        ),
                      ),
                      Icon(Icons.arrow_forward,
                          color: Colors.blue), // Blueberry theme
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200, // Adjust height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _freeBooks.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _onBookTap(_freeBooks[index], widget.userId),
                          child: Container(
                            width: 120, // Adjust width as needed
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    'https://protombook.protechmm.com/${_freeBooks[index]['cover']}',
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _freeBooks[index]['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: 0, // Set to 0 for Home, 1 for Profile
          selectedItemColor: Colors.blue[900],
          onTap: (index) {
            if (index == 1) {
              // Navigate to the profile screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: widget.userId),
                ),
              ).then((_) {
                _fetchAllData();
              });
            }
          },
        ),
      ),
    );
  }
}
