import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/booking_provider.dart';
import './booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeeBoxSelectionScreen extends StatefulWidget {
  const BeeBoxSelectionScreen({super.key});

  @override
  State<BeeBoxSelectionScreen> createState() => _BeeBoxSelectionScreenState();
}

class _BeeBoxSelectionScreenState extends State<BeeBoxSelectionScreen> {
  final Set<String> selectedBoxes = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bee Boxes'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bee_boxes').snapshots(),
        builder: (context, beeBoxSnapshot) {
          if (beeBoxSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (beeBoxSnapshot.hasError) {
            return Center(child: Text('Error loading bee boxes'));
          }
          final beeBoxes = beeBoxSnapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = data['id'] ?? doc.id;
            return data;
          }).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('status', whereIn: ['active', 'pending'])
                .snapshots(),
            builder: (context, bookingSnapshot) {
              if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (bookingSnapshot.hasError) {
                return Center(child: Text('Error loading bookings'));
              }
              // 1. Build a map of boxTypeId -> total booked from bookings
              final Map<String, int> bookedCountByType = {};
              for (var booking in bookingSnapshot.data!.docs) {
                final data = booking.data() as Map<String, dynamic>;
                final boxTypeId = (data['boxTypeId'] ?? data['id'] ?? '').toString();
                // Ensure quantity is int
                final quantityRaw = data['quantity'] ?? (data['boxNumbers']?.length ?? 0);
                final quantity = (quantityRaw is int) ? quantityRaw : int.tryParse(quantityRaw.toString()) ?? 0;
                if (boxTypeId.isNotEmpty) {
                  bookedCountByType[boxTypeId] = (bookedCountByType[boxTypeId] ?? 0) + quantity;
                }
              }

              return ListView.builder(
                itemCount: beeBoxes.length,
                itemBuilder: (context, boxTypeIndex) {
                  final boxType = beeBoxes[boxTypeIndex];
                  final boxTypeId = boxType['id'].toString();
                  final boxTypeName = boxType['name'] ?? 'Box';
                  final totalCount = boxType['count'] ?? 0;
                  final bookedCount = bookedCountByType[boxTypeId] ?? 0;
                  final availableCount = totalCount - bookedCount;

                  // Show as many boxes as 'count' for this type
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text('$boxTypeId - $boxTypeName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: totalCount,
                        itemBuilder: (context, index) {
                          final isBooked = index < bookedCount;
                          final isSelected = selectedBoxes.contains('${boxTypeId}_$index');
                          Color color;
                          if (isBooked) {
                            color = Colors.red;
                          } else if (isSelected) {
                            color = Colors.orange;
                          } else {
                            color = Colors.green;
                          }
                          return GestureDetector(
                            onTap: isBooked
                                ? null
                                : () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedBoxes.remove('${boxTypeId}_$index');
                                      } else if (selectedBoxes.where((s) => s.startsWith('${boxTypeId}_')).length < availableCount) {
                                        selectedBoxes.add('${boxTypeId}_$index');
                                      }
                                    });
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: selectedBoxes.isNotEmpty
              ? () {
                  // Group selectedBoxes by boxTypeId
                  final Map<String, List<int>> selectedByType = {};
                  for (final s in selectedBoxes) {
                    final parts = s.split('_');
                    if (parts.length == 2) {
                      final typeId = parts[0];
                      final idx = int.tryParse(parts[1]) ?? 0;
                      selectedByType.putIfAbsent(typeId, () => []).add(idx);
                    }
                  }
                  // Pass selectedByType to BookingScreen (modify as needed)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        selectedBoxes: selectedByType,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text('Proceed'),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchBeeBoxesAndBookings() async {
    try {
      // Fetch bee boxes
      final beeBoxSnapshot = await FirebaseFirestore.instance.collection('bee_boxes').get();
      final beeBoxes = beeBoxSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Use doc.id as fallback if 'id' is missing
        data['id'] = data['id'] ?? doc.id;
        return data;
      }).toList();
      // Fetch all bookings with status active or pending
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', whereIn: ['active', 'pending'])
          .get();
      final bookedBoxIds = <String>{};
      for (var booking in bookingSnapshot.docs) {
        final data = booking.data() as Map<String, dynamic>;
        if (data['boxIds'] != null) {
          for (var id in List.from(data['boxIds'])) {
            bookedBoxIds.add(id.toString());
          }
        }
      }
      return {
        'beeBoxes': beeBoxes,
        'bookedBoxIds': bookedBoxIds,
      };
    } catch (e, st) {
      print('Error fetching bee boxes: $e\n$st');
      throw Exception('Error loading bee boxes');
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}