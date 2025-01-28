import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;

  // Function to handle date picking
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to save the order to Firestore
  Future<void> _saveOrder() async {
    if (_locationController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a location and select a delivery date."),
        ),
      );
      return;
    }

    try {
      final orderId = const Uuid().v4(); // Generate a unique ID for the order
      final now = DateTime.now(); // Current timestamp

      // Order details to store
      final orderData = {
        "location": _locationController.text,
        "delivery_date": _selectedDate?.toUtc(),
        "name": widget.plant["name"] ?? "Unknown Plant",
        "price": widget.plant["price"] ?? 0,
        "order_placed": now.toUtc(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection("Orders")
          .doc(orderId)
          .set(orderData);

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );

      // Clear input fields after placing the order
      setState(() {
        _locationController.clear();
        _selectedDate = null;
      });
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          plant["name"] ?? "Plant Details",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                plant["imagePath"] ?? "",
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant Name
                  Text(
                    plant["name"] ?? "Unknown Plant",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price Section
                  Text(
                    "₹${plant["price"]}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 44, 96, 45),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Inclusive of all taxes",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Location and Date Section
                  const Text(
                    "Delivery Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: "Enter your location",
                      prefixIcon: const Icon(Icons.location_on, color: Color.fromARGB(255, 39, 95, 41)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? "Select a delivery date"
                                : DateFormat('dd MMM, yyyy').format(_selectedDate!),
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const Icon(Icons.calendar_today, color: Color.fromARGB(255, 44, 109, 46)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Care Instructions Section
                  const Text(
                    "Care Instructions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant["careInstructions"] ??
                        ' • Keep plants in medium light locations, out of direct sunlight.\n • Natural light is best, but some plants can also thrive in office fluorescent light.\n • Plant soil should be kept moist at all time.\n • Be careful to avoid overwatering.\n • Do not allow plants to stand in water.\n • Avoid wetting plant leaves excessively.\n • A spray of water should help in case of flowering plants.\n • Plants should be kept in a cool spot (between 18-28Â°C).\n • Remove waste leaves and stems from time to time.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Buy Now Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 39, 86, 41),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saveOrder,
          child: const Text(
            "Buy Now",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
