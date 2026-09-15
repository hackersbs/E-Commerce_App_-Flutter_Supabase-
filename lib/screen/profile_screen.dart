import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy user data
    const String userName = 'John Doe';
    const String phoneNumber = '+1 234 567 8900';
    const String address = '123 Main Street, Cityville, Country';
    const String orderDetails = 'Order #12345 - Shipped\nOrder #12344 - Delivered';
    final String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Text(
                firstLetter,
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Phone Number
            _buildInfoCard(Icons.phone, 'Phone Number', phoneNumber),
            const SizedBox(height: 16),
            // Address
            _buildInfoCard(Icons.location_on, 'Address', address),
            const SizedBox(height: 16),
            // Order Details
            _buildInfoCard(Icons.shopping_bag, 'Order Details', orderDetails),
            const SizedBox(height: 40),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle logout action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logging out...')),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
