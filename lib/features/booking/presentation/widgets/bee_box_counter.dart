import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class BeeBoxCounter extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;
  final String selectedLanguage;

  const BeeBoxCounter({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.selectedLanguage,
  });

  @override
  State<BeeBoxCounter> createState() => _BeeBoxCounterState();
}

class _BeeBoxCounterState extends State<BeeBoxCounter> {
  late int _value;
  final int _minValue = 1;
  final int _maxValue = 20;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getBoxCountText(widget.selectedLanguage),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Row(
                children: [
                  _buildCounterButton(
                    icon: Icons.remove,
                    onPressed: _value > _minValue
                        ? () {
                            setState(() {
                              _value--;
                              widget.onChanged(_value);
                            });
                          }
                        : null,
                  ),
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Text(
                      _value.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  _buildCounterButton(
                    icon: Icons.add,
                    onPressed: _value < _maxValue
                        ? () {
                            setState(() {
                              _value++;
                              widget.onChanged(_value);
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPriceInfoText(widget.selectedLanguage),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: onPressed != null ? AppTheme.primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.grey.shade500,
          size: 18,
        ),
        onPressed: onPressed,
      ),
    );
  }

  // Multilingual text getters
  String _getBoxCountText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खी के बक्सों की संख्या';
      case AppConstants.marathi:
        return 'मधमाशांच्या बॉक्सची संख्या';
      default:
        return 'Number of Bee Boxes';
    }
  }

  String _getPriceInfoText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'प्रति बक्सा प्रति दिन ₹${AppConstants.dailyRentPerBox} की दर से';
      case AppConstants.marathi:
        return 'प्रति बॉक्स प्रति दिवस ₹${AppConstants.dailyRentPerBox} दराने';
      default:
        return '₹${AppConstants.dailyRentPerBox} per box per day';
    }
  }
}