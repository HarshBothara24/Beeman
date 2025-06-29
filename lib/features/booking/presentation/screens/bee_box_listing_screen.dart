import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/firestore_models.dart';
import '../providers/booking_provider.dart';
import '../widgets/bee_box_card.dart';

class BeeBoxListingScreen extends StatefulWidget {
  const BeeBoxListingScreen({Key? key}) : super(key: key);

  @override
  State<BeeBoxListingScreen> createState() => _BeeBoxListingScreenState();
}

class _BeeBoxListingScreenState extends State<BeeBoxListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize Firestore listeners when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().initializeFirestoreListeners();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Bee Boxes'),
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (bookingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${bookingProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      bookingProvider.clearError();
                      bookingProvider.initializeFirestoreListeners();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bee boxes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              bookingProvider.searchBeeBoxes('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    bookingProvider.searchBeeBoxes(value);
                  },
                ),
              ),
              
              // Bee Boxes List
              Expanded(
                child: bookingProvider.beeBoxes.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hive_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No bee boxes available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookingProvider.beeBoxes.length,
                        itemBuilder: (context, index) {
                          final beeBox = bookingProvider.beeBoxes[index];
                          return BeeBoxCard(
                            beeBox: beeBox,
                            onBookNow: () => _showBookingDialog(beeBox),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBookingDialog(BeeBoxModel beeBox) {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(beeBox: beeBox),
    );
  }
}

class BeeBoxCard extends StatelessWidget {
  final BeeBoxModel beeBox;
  final VoidCallback onBookNow;

  const BeeBoxCard({
    Key? key,
    required this.beeBox,
    required this.onBookNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hive,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beeBox.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        beeBox.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: beeBox.isAvailable
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    beeBox.isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: beeBox.isAvailable
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              beeBox.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${beeBox.pricePerDay.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'per day',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${beeBox.availableQuantity}/${beeBox.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'boxes available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: beeBox.isAvailable ? onBookNow : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingDialog extends StatefulWidget {
  final BeeBoxModel beeBox;

  const BookingDialog({
    Key? key,
    required this.beeBox,
  }) : super(key: key);

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Book ${widget.beeBox.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Number of Boxes',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  if (quantity > widget.beeBox.availableQuantity) {
                    return 'Only ${widget.beeBox.availableQuantity} boxes available';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Start Date
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(
                  _startDate != null
                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                      : 'Select start date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
              ),
              
              // End Date
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(
                  _endDate != null
                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                      : 'Select end date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  if (_startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select start date first'),
                      ),
                    );
                    return;
                  }
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate!,
                    firstDate: _startDate!,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              // Total Amount
              if (_startDate != null && _endDate != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${_calculateTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitBooking,
          child: const Text('Confirm Booking'),
        ),
      ],
    );
  }

  double _calculateTotal() {
    if (_startDate == null || _endDate == null) return 0;
    
    final days = _endDate!.difference(_startDate!).inDays + 1;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    
    return days * quantity * widget.beeBox.pricePerDay;
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
        ),
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);
    final totalAmount = _calculateTotal();

    // Here you would typically get the current user ID
    // For now, we'll use a placeholder
    const userId = 'current_user_id'; // Replace with actual user ID

    final success = await context.read<BookingProvider>().createFirestoreBooking(
      userId: userId,
      beeBoxId: widget.beeBox.id,
      startDate: _startDate!,
      endDate: _endDate!,
      quantity: quantity,
      totalAmount: totalAmount,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create booking: ${context.read<BookingProvider>().error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 