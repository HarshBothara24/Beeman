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
  final Set<int> selectedBoxes = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bee Boxes'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Legend
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.grey, 'Not Available'),
                _buildLegendItem(Colors.green, 'Available'),
                _buildLegendItem(AppTheme.primaryColor, 'Selected'),
              ],
            ),
          ),
          // Grid of bee boxes
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                final isAvailable = index % 3 != 0;
                return _buildBeeBox(index, isAvailable);
              },
            ),
          ),
          // Bottom bar with selection info and proceed button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${selectedBoxes.length} Boxes Selected',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Total: ₹${selectedBoxes.length * 500}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: selectedBoxes.isNotEmpty
                      ? () {
                          final bookingProvider = Provider.of<BookingProvider>(
                            context, 
                            listen: false
                          );
                          final totalAmount = selectedBoxes.length * 500.0;
                          bookingProvider.setBookingDetails(
                            selectedBoxes,
                            totalAmount,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Proceed'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildBeeBox(int boxId, bool isAvailable) {
    final isSelected = selectedBoxes.contains(boxId);
    final color = !isAvailable
        ? Colors.grey
        : isSelected
            ? AppTheme.primaryColor
            : Colors.green;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                if (isSelected) {
                  selectedBoxes.remove(boxId);
                } else {
                  selectedBoxes.add(boxId);
                }
              });
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            boxId.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAvailable ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}