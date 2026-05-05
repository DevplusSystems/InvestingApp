import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alert.dart';
import '../../providers/alert_provider.dart';

class AlertBottomSheet extends ConsumerStatefulWidget {
  final String? symbol;
  final AlertModel? existingAlert;

  const AlertBottomSheet({
    super.key,
    this.symbol,
    this.existingAlert,
  });

  @override
  ConsumerState<AlertBottomSheet> createState() => _AlertBottomSheetState();
}

class _AlertBottomSheetState extends ConsumerState<AlertBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _targetPriceController = TextEditingController();
  final _targetPercentageController = TextEditingController();
  final _targetVolumeController = TextEditingController();
  final _notesController = TextEditingController();
  
  AlertType _selectedType = AlertType.price;
  AlertCondition _selectedCondition = AlertCondition.above;
  AlertFrequency _selectedFrequency = AlertFrequency.once;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing alert data or symbol
    if (widget.existingAlert != null) {
      final alert = widget.existingAlert!;
      _symbolController.text = alert.symbol;
      _selectedType = alert.alertType;
      _selectedCondition = alert.condition;
      _targetPriceController.text = alert.targetPrice.toString();
      _targetPercentageController.text = alert.targetPercentage.toString();
      _targetVolumeController.text = alert.targetVolume.toString();
      _notesController.text = alert.notes ?? '';
      _selectedFrequency = alert.frequency;
    } else if (widget.symbol != null) {
      _symbolController.text = widget.symbol!;
    }
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _targetPriceController.dispose();
    _targetPercentageController.dispose();
    _targetVolumeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.existingAlert != null ? 'Edit Alert' : 'Create Alert',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Symbol Input
              Text(
                'Symbol',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _symbolController,
                decoration: InputDecoration(
                  hintText: 'e.g., AAPL, GOOGL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a symbol';
                  }
                  return null;
                },
                enabled: widget.existingAlert == null,
              ),

              const SizedBox(height: 20),

              // Alert Type Selection
              Text(
                'Alert Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              _buildAlertTypeSelector(context),

              const SizedBox(height: 20),

              // Condition Selection
              Text(
                'Condition',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              _buildConditionSelector(context),

              const SizedBox(height: 20),

              // Target Value Input
              _buildTargetValueInput(context),

              const SizedBox(height: 20),

              // Frequency Selection
              Text(
                'Notification Frequency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              _buildFrequencySelector(context),

              const SizedBox(height: 20),

              // Notes Input
              Text(
                'Notes (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Add any notes about this alert...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAlert,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.existingAlert != null ? 'Update Alert' : 'Create Alert',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertTypeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: AlertType.values.map((type) {
          final isSelected = _selectedType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getAlertTypeDisplayName(type),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConditionSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: AlertCondition.values.map((condition) {
          final isSelected = _selectedCondition == condition;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCondition = condition),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  condition.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTargetValueInput(BuildContext context) {
    switch (_selectedType) {
      case AlertType.price:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Price (\$)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
          ],
        );
      case AlertType.percentage:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Percentage (%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetPercentageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target percentage';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid percentage';
                }
                return null;
              },
            ),
          ],
        );
      case AlertType.volume:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Volume',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetVolumeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target volume';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid volume';
                }
                return null;
              },
            ),
          ],
        );
    }
  }

  Widget _buildFrequencySelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: AlertFrequency.values.map((frequency) {
          final isSelected = _selectedFrequency == frequency;
          return GestureDetector(
            onTap: () => setState(() => _selectedFrequency = frequency),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected 
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).iconTheme.color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    frequency.displayName,
                    style: TextStyle(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getAlertTypeDisplayName(AlertType type) {
    switch (type) {
      case AlertType.price:
        return 'Price';
      case AlertType.percentage:
        return '% Change';
      case AlertType.volume:
        return 'Volume';
    }
  }

  void _saveAlert() {
    if (!_formKey.currentState!.validate()) return;

    final symbol = _symbolController.text.trim().toUpperCase();
    final targetPrice = double.tryParse(_targetPriceController.text) ?? 0.0;
    final targetPercentage = double.tryParse(_targetPercentageController.text) ?? 0.0;
    final targetVolume = double.tryParse(_targetVolumeController.text) ?? 0.0;
    final notes = _notesController.text.trim();

    final alert = AlertModel(
      id: widget.existingAlert?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      alertType: _selectedType,
      condition: _selectedCondition,
      targetPrice: targetPrice,
      targetPercentage: targetPercentage,
      targetVolume: targetVolume,
      createdAt: widget.existingAlert?.createdAt ?? DateTime.now(),
      isActive: true,
      isTriggered: false,
      lastNotifiedAt: null,
      notes: notes.isEmpty ? null : notes,
      frequency: _selectedFrequency,
    );

    if (widget.existingAlert != null) {
      ref.read(alertProvider.notifier).updateAlert(alert);
    } else {
      ref.read(alertProvider.notifier).addAlert(alert);
    }

    // Start alert checker if not already running
    ref.read(alertCheckerServiceProvider).startChecking();

    Navigator.of(context).pop();
  }
}
