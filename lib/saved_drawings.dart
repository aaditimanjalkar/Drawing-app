import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedDrawings extends StatefulWidget {
  @override
  _SavedDrawingsState createState() => _SavedDrawingsState();
}

class _SavedDrawingsState extends State<SavedDrawings> {
  // Dummy list of image paths (replace with actual paths)
  final List<String> imagePaths = [
    'assets/image1.jpg',
    'assets/image2.jpg',
    'assets/image3.jpg',
    'assets/image4.jpg',
    'assets/image5.jpg',
    'assets/image6.jpg',
    // Add more image paths as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the background color
        title: Text(
          'Saved Drawings',
          style: TextStyle(
            fontSize: 24, // Increase the font size for better visibility
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        centerTitle: true, // Center the title horizontally
        elevation: 0, // Remove the shadow
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          mainAxisSpacing: 8, // Spacing between rows
          crossAxisSpacing: 8, // Spacing between columns
          childAspectRatio: 0.7, // Aspect ratio of grid items
        ),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          // Get the image path and name
          String imagePath = imagePaths[index];
          String imageName =
              'Image ${index + 1}'; // Example: Image 1, Image 2, ...

          // Return a widget for each grid item
          return GestureDetector(
            onTap: () {
              // Handle image tap (e.g., open image in full screen)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(imagePath),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            imageName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Implement delete functionality here
                              setState(() {
                                // Remove the image path from the list
                                imagePaths.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  FullScreenImage(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the background color
        title: Text(
          'Full Screen Image',
          style: TextStyle(
            fontSize: 24, // Increase the font size for better visibility
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
      ),
      body: Center(
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain, // Adjust the fit as needed
        ),
      ),
    );
  }
}
