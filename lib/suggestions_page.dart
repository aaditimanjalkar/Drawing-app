import 'package:flutter/material.dart';
import 'drawing_page.dart';
import 'TracingPage.dart';

class SuggestionsPage extends StatelessWidget {
  // Dummy list of pre-drawn image paths
  final List<String> preDrawnImagePaths = [
    'assets/simage1.jpg',
    'assets/simage2.jpg',
    'assets/simage3.jpg',
    'assets/simage4.jpg',
    // Add more pre-drawn image paths as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the background color
        title: Text(
          'Suggestions Page',
          style: TextStyle(
            fontSize: 24, // Increase the font size for better visibility
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        centerTitle: true, // Center the title horizontally
        elevation: 0, // Remove the shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            mainAxisSpacing: 8, // Spacing between rows
            crossAxisSpacing: 8, // Spacing between columns
            childAspectRatio: 0.7, // Aspect ratio of grid items
          ),
          itemCount: preDrawnImagePaths.length,
          itemBuilder: (context, index) {
            // Get the pre-drawn image path
            String preDrawnImagePath = preDrawnImagePaths[index];

            // Return a widget for each grid item
            return GestureDetector(
              onTap: () {
                // Handle image tap by navigating to TracingPage with the selected background image
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TracingPage(
                      backgroundImagePath: preDrawnImagePath,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    preDrawnImagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
