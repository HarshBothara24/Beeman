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
  String? _selectedBoxTypeId;
  String? _selectedBeeSpecies;
  List<Map<String, dynamic>> _beeBoxTypes = [];
  bool _loadingTypes = true;

  static const int _gridColumns = 15;
  static const int _gridRows = 10;

  String _getSpeciesLabel(Map<String, dynamic> type) {
    return '${type['species_en'] ?? ''} (${type['species_sci'] ?? ''})';
  }

  @override
  void initState() {
    super.initState();
    _fetchBeeBoxTypes();
  }

  Future<void> _fetchBeeBoxTypes() async {
    setState(() { _loadingTypes = true; });
    final snapshot = await FirebaseFirestore.instance.collection('bee_boxes').get();
    _beeBoxTypes = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = data['id'] ?? doc.id;
      return data;
    }).toList();
    setState(() { _loadingTypes = false; });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bee Boxes'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loadingTypes
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bee box type dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedBoxTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Select Bee Box Species',
                      border: OutlineInputBorder(),
                    ),
                    items: _beeBoxTypes.map((type) => DropdownMenuItem<String>(
                      value: type['id'].toString(),
                      child: Text(_getSpeciesLabel(type)),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBoxTypeId = value;
                        selectedBoxes.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedBoxTypeId != null)
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('status', whereIn: ['active', 'pending'])
                .orderBy('createdAt', descending: true)
                .limit(100)
                .snapshots(),
            builder: (context, bookingSnapshot) {
              if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (bookingSnapshot.hasError) {
                return Center(child: Text('Error loading bookings'));
              }
                          // Find the selected box type
                          final boxType = _beeBoxTypes.firstWhere((t) => t['id'].toString() == _selectedBoxTypeId);
                  final boxTypeId = boxType['id'].toString();
                  final totalCount = boxType['count'] ?? 0;
                  // Get bookedIndexes from bee_boxes document
                  final List<int> adminBookedIndexes = (boxType['bookedIndexes'] as List?)?.map((e) => int.tryParse(e.toString()) ?? -1).where((e) => e >= 0).toList() ?? [];
                  // Find booked boxes for this type from bookings
                  final Set<int> bookedIndexes = {};
                  for (var booking in bookingSnapshot.data!.docs) {
                    final data = booking.data() as Map<String, dynamic>;
                    if ((data['boxTypeId']?.toString() ?? data['id']?.toString() ?? '') == boxTypeId) {
                      final boxNumbers = (data['boxNumbers'] as List?)?.map((e) => int.tryParse(e.toString()) ?? -1).where((e) => e >= 0).toList() ?? [];
                      bookedIndexes.addAll(boxNumbers);
                    }
                  }
                  // Merge admin and real-time booked indexes
                  final Set<int> allBookedIndexes = {...bookedIndexes, ...adminBookedIndexes};
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem(Colors.red, 'Booked'),
                                    _buildLegendItem(Colors.yellow[700]!, 'Selected'),
                                    _buildLegendItem(Colors.green, 'Available'),
                                  ],
                                ),
                              ),
                               Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Center(
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: _gridColumns,
                                          childAspectRatio: 0.8,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                        itemCount: totalCount,
                                        itemBuilder: (context, index) {
                                          final isBooked = allBookedIndexes.contains(index);
                                          final isSelected = selectedBoxes.contains('${boxTypeId}_$index');
                                          Color fillColor = Colors.transparent;
                                          Color borderColor = Colors.grey[400]!;
                                          if (isBooked) {
                                            fillColor = Colors.red;
                                            borderColor = Colors.red;
                                          } else if (isSelected) {
                                            fillColor = Colors.yellow[700]!;
                                            borderColor = Colors.yellow[700]!;
                                          } else {
                                            fillColor = Colors.green;
                                            borderColor = Colors.green;
                                          }
                                          return GestureDetector(
                                            onTap: isBooked
                                                ? null
                                                : () {
                                                    setState(() {
                                                      if (isSelected) {
                                                        selectedBoxes.remove('${boxTypeId}_$index');
                                                      } else {
                                                        selectedBoxes.add('${boxTypeId}_$index');
                                                      }
                                                    });
                                                  },
                                            child: Container(
                                              margin: const EdgeInsets.all(2),
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: fillColor,
                                                border: Border.all(color: borderColor, width: 2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color: isBooked || isSelected || fillColor != Colors.transparent ? Colors.white : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                },
                      ),
                    ),
                ],
              ),
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
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 16),
      ],
    );
  }
}