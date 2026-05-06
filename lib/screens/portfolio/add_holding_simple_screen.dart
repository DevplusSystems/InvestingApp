import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/portfolio_transaction.dart';
import '../../providers/portfolio_provider.dart';

class AddHoldingSimpleScreen extends ConsumerStatefulWidget {
  const AddHoldingSimpleScreen({super.key});

  @override
  ConsumerState<AddHoldingSimpleScreen> createState() => _AddHoldingSimpleScreenState();
}

class _AddHoldingSimpleScreenState extends ConsumerState<AddHoldingSimpleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _commissionController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isBuyTransaction = true;

  // Sample stocks for demo
  final List<String> _availableStocks = [
    'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA', 'META', 'NVDA', 'JPM',
    'JNJ', 'V', 'PG', 'UNH', 'HD', 'MA', 'BAC', 'XOM', 'CVX', 'LLY',
    'ABBV', 'PFE', 'KO', 'PEP', 'TMO', 'COST', 'AVGO', 'LIN',
    'NKE', 'DIS', 'DHR', 'CMCSA', 'VZ', 'ADBE', 'NFLX', 'CRM',
    'PYPL', 'ACN', 'INTC', 'WMT', 'CSCO', 'TXN', 'HON', 'QCOM',
    'MDT', 'NEE', 'ABT', 'CRM', 'IBM', 'GE', 'ORCL', 'BA',
    'CAT', 'DE', 'GS', 'MS', 'BLK', 'SPGI', 'ICE', 'CME',
    'CB', 'AIG', 'TRV', 'ALL', 'MET', 'PRU', 'HIG', 'LNC'
  ];

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _commissionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _showStockSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final notifier = ref.read(portfolioProvider.notifier);
          final holdings = notifier.getCurrentHoldings();
          
          // For SELL mode, only show stocks that user owns
          final stocksToShow = _isBuyTransaction 
              ? _availableStocks 
              : holdings.keys.where((symbol) => holdings[symbol]!['quantity'] > 0).toList();
          
          return AlertDialog(
            title: Text(_isBuyTransaction ? 'Select Stock to Buy' : 'Select Stock to Sell'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: stocksToShow.isEmpty
                  ? Center(
                      child: Text(
                        _isBuyTransaction 
                            ? 'No stocks available to buy' 
                            : 'You don\'t own any stocks to sell',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: stocksToShow.length,
                      itemBuilder: (context, index) {
                        final stock = stocksToShow[index];
                        final availableQuantity = holdings[stock]?['quantity'] ?? 0;
                        
                        return ListTile(
                          title: Text(stock),
                          subtitle: !_isBuyTransaction 
                              ? Text('Available: $availableQuantity shares')
                              : null,
                          onTap: () {
                            Navigator.of(context).pop();
                            _symbolController.text = stock;
                          },
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final symbol = _symbolController.text.trim().toUpperCase();
    final quantity = int.parse(_quantityController.text);

    // For SELL transactions, validate that user has enough stocks
    if (!_isBuyTransaction) {
      final notifier = ref.read(portfolioProvider.notifier);
      if (!notifier.canSellStock(symbol, quantity)) {
        final available = notifier.getAvailableQuantity(symbol);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot sell $quantity shares of $symbol. You only own $available shares.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final transaction = PortfolioTransaction(
      type: _isBuyTransaction ? TransactionType.buy : TransactionType.sell,
      symbol: symbol,
      quantity: quantity,
      price: double.parse(_priceController.text),
      commission: double.tryParse(_commissionController.text) ?? 0.0,
      date: _date,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    ref.read(portfolioProvider.notifier).addTransaction(transaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_isBuyTransaction ? 'BUY' : 'SELL'} transaction saved successfully!'),
        backgroundColor: _isBuyTransaction ? Colors.green : Colors.red,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_isBuyTransaction ? 'BUY' : 'SELL'} Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transaction Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isBuyTransaction = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isBuyTransaction ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BUY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isBuyTransaction ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isBuyTransaction = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isBuyTransaction ? Colors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SELL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isBuyTransaction ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stock Selection
              GestureDetector(
                onTap: _showStockSelectionDialog,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _symbolController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Symbol',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a stock symbol';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {}); // Refresh to show available quantity
                    },
                  ),
                ),
              ),
              
              // Show available quantity for SELL transactions
              if (!_isBuyTransaction && _symbolController.text.trim().isNotEmpty)
                Consumer(
                  builder: (context, ref, child) {
                    final notifier = ref.read(portfolioProvider.notifier);
                    final available = notifier.getAvailableQuantity(_symbolController.text.trim().toUpperCase());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: available > 0 ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: available > 0 ? Colors.green.shade200 : Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              available > 0 ? Icons.check_circle : Icons.warning,
                              color: available > 0 ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Available: $available shares',
                              style: TextStyle(
                                color: available > 0 ? Colors.green.shade800 : Colors.red.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Share',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Commission (Optional)
              TextFormField(
                controller: _commissionController,
                decoration: const InputDecoration(
                  labelText: 'Commission (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Date
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Transaction Date',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('MMM dd, yyyy').format(_date),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes (Optional)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isBuyTransaction ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'SAVE ${_isBuyTransaction ? 'BUY' : 'SELL'} TRANSACTION',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
