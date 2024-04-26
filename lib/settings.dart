import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the background color
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24, // Increase the font size for better visibility
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        centerTitle: true, // Center the title horizontally
        elevation: 0, // Remove the shadow
      ),
      body: ListView(
        children: <Widget>[
          _buildListItem(
            context,
            title: 'Feedback and Support',
            onTap: () => _showFeedbackDialog(context),
          ),
          Divider(),
          _buildListItem(
            context,
            title: 'About',
            onTap: () => _navigateToAboutPage(context),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context,
      {required String title, required Function onTap}) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onTap: () => onTap(),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    String userFeedback = ''; // Variable to store user's feedback

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Feedback and Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Please provide your feedback or report any issues:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    onChanged: (value) {
                      userFeedback =
                          value; // Update userFeedback variable when input changes
                    },
                    decoration: InputDecoration(
                      labelText: 'Your Feedback',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle form submission
                        // You can process the feedback here
                        print(
                            'User Feedback: $userFeedback'); // Print feedback to console
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToAboutPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutPage()),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the background color
        title: Text(
          'About',
          style: TextStyle(
            fontSize: 24, // Increase the font size for better visibility
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        centerTitle: true, // Center the title horizontally
        elevation: 0, // Remove the shadow
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Drawing Canvas',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Text(
              'Release Date: April 16th, 2024',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Text(
              'Developer: AAP',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            SizedBox(height: 24),
            Divider(color: Colors.grey[400]), // Add a divider for separation
            SizedBox(height: 24),
            Text(
              'Terms of Service',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 12),
            Text(
              // Add terms of service text here
              'Terms and Conditions applied',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
