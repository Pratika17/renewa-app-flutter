import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renewa/screens/newFeatures/plantdetails.dart';

class PlantPurchaseScreen extends StatelessWidget {
  const PlantPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plants Nursery"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Plants').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching plants'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No plants available'));
          }

          final plants = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantDetailScreen(plant: plant),
                    ),
                  );
                },
                child: PlantCard(plant: plant),
              );
            },
          );
        },
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final imageHeight = cardWidth * 0.6; // Dynamic image height

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image if available
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: plant["imagePath"] != null && plant["imagePath"].isNotEmpty
                    ? Image.network(
                        plant["imagePath"],
                        height: imageHeight, // Dynamic height
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: imageHeight, // Dynamic height
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant["name"] ?? "Unknown Plant",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: cardWidth * 0.08, // Dynamic font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap( // Use Wrap widget
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "₹ ${plant["price"]}",
                            style: TextStyle(
                              fontSize: cardWidth * 0.1, // Dynamic font size
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 51, 99, 53),
                            ),
                          ),
                          if (plant["originalPrice"] != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              "₹ ${plant["originalPrice"]}",
                              style: TextStyle(
                                fontSize: cardWidth * 0.06, // Dynamic font size
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              plant["discount"] ?? "",
                              style: TextStyle(
                                fontSize: cardWidth * 0.06, // Dynamic font size
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            plant["rating"].toString() ?? "",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "${plant["reviews"]} Reviews" ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          "Earliest Delivery: ${plant["delivery"]}" ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}