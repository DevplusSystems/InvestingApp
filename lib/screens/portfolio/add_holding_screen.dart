import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/portfolio_transaction.dart';
import '../../providers/portfolio_provider.dart';

class AddHoldingScreen extends ConsumerStatefulWidget {
  const AddHoldingScreen({super.key});

  @override
  ConsumerState<AddHoldingScreen> createState() => _AddHoldingScreenState();
}

class _AddHoldingScreenState extends ConsumerState<AddHoldingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Form controllers for BUY tab
  final _buySymbolController = TextEditingController();
  final _buyQuantityController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _buyCommissionController = TextEditingController();
  final _buyNotesController = TextEditingController();
  final _buyFormKey = GlobalKey<FormState>();
  DateTime _buyDate = DateTime.now();
  String? _selectedBuyStock;
  
  // Form controllers for SELL tab
  final _sellSymbolController = TextEditingController();
  final _sellQuantityController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _sellCommissionController = TextEditingController();
  final _sellNotesController = TextEditingController();
  final _sellFormKey = GlobalKey<FormState>();
  DateTime _sellDate = DateTime.now();
  String? _selectedSellStock;
  int _availableQuantity = 0;
  double _avgPrice = 0.0;

  // Sample stocks for demo - in real app, this would come from an API
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    
    // Dispose BUY controllers
    _buySymbolController.dispose();
    _buyQuantityController.dispose();
    _buyPriceController.dispose();
    _buyCommissionController.dispose();
    _buyNotesController.dispose();
    
    // Dispose SELL controllers
    _sellSymbolController.dispose();
    _sellQuantityController.dispose();
    _sellPriceController.dispose();
    _sellCommissionController.dispose();
    _sellNotesController.dispose();
    
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'BUY', icon: Icon(Icons.add_shopping_cart)),
                Tab(text: 'SELL', icon: Icon(Icons.sell)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBuyTab(),
                _buildSellTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyTab() {
    return Form(
      key: _buyFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stock Selection
            _buildStockSelection(
              title: 'Select Stock',
              controller: _buySymbolController,
              selectedStock: _selectedBuyStock,
              onStockSelected: (stock) {
                setState(() {
                  _selectedBuyStock = stock;
                  _buySymbolController.text = stock;
                });
              },
              isSellTab: false,
            ),
            
            const SizedBox(height: 16),
            
            // Quantity and Price Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buyQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter quantity';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Enter valid quantity';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _buyPriceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price per Share',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Date Selection
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Transaction Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_buyDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectBuyDate,
            ),
            
            const SizedBox(height: 16),
            
            // Commission (Optional)
            TextFormField(
              controller: _buyCommissionController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Commission (Optional)',
                border: OutlineInputBorder(),
                prefixText: '\$',
                prefixIcon: Icon(Icons.receipt_long),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final commission = double.tryParse(value);
                  if (commission == null || commission < 0) {
                    return 'Enter valid commission';
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Notes (Optional)
            TextFormField(
              controller: _buyNotesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            
            const Spacer(),
            
            // Save Button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveBuyTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'SAVE BUY TRANSACTION',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellTab() {
    return Form(
      key: _sellFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stock Selection (Portfolio stocks only)
            _buildStockSelection(
              title: 'Select Stock to Sell',
              controller: _sellSymbolController,
              selectedStock: _selectedSellStock,
              onStockSelected: (stock) {
                setState(() {
                  _selectedSellStock = stock;
                  _sellSymbolController.text = stock;
                  _loadStockInfo(stock);
                });
              },
              isSellTab: true,
            ),
            
            if (_selectedSellStock != null) ...[
              const SizedBox(height: 16),
              
              // Stock Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available Quantity:'),
                        Text(
                          '$_availableQuantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Average Price:'),
                        Text(
                          '\$${_avgPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Sell Quantity and Price Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sellQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sell Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter quantity';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Enter valid quantity';
                      }
                      if (_selectedSellStock != null && quantity > _availableQuantity) {
                        return 'Cannot exceed available quantity';
                      }
                      return null;
                    },
                    enabled: _selectedSellStock != null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sellPriceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Sell Price per Share',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                    enabled: _selectedSellStock != null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Date Selection
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Transaction Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_sellDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectSellDate,
            ),
            
            const SizedBox(height: 16),
            
            // Commission (Optional)
            TextFormField(
              controller: _sellCommissionController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Commission (Optional)',
                border: OutlineInputBorder(),
                prefixText: '\$',
                prefixIcon: Icon(Icons.receipt_long),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final commission = double.tryParse(value);
                  if (commission == null || commission < 0) {
                    return 'Enter valid commission';
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Notes (Optional)
            TextFormField(
              controller: _sellNotesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            
            const Spacer(),
            
            // Save Button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedSellStock != null ? _saveSellTransaction : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'SAVE SELL TRANSACTION',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSelection({
    required String title,
    required TextEditingController controller,
    required String? selectedStock,
    required Function(String) onStockSelected,
    required bool isSellTab,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showStockSelectionDialog(isSellTab, onStockSelected),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedStock ?? 'Search and select stock',
                    style: TextStyle(
                      color: selectedStock != null ? Colors.black : Colors.grey.shade600,
                      fontWeight: selectedStock != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showStockSelectionDialog(bool isSellTab, Function(String) onStockSelected) {
    final stocks = isSellTab ? _getPortfolioStocks() : _availableStocks;
    
    if (stocks.isEmpty && isSellTab) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No stocks available in portfolio to sell'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSellTab ? 'Select Stock to Sell' : 'Select Stock to Buy'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return ListTile(
                title: Text(stock),
                onTap: () {
                  Navigator.of(context).pop();
                  onStockSelected(stock);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  List<String> _getPortfolioStocks() {
    final portfolioAsync = ref.read(portfolioProvider);
    return portfolioAsync.maybeWhen(
      data: (transactions) {
        // Get unique symbols from portfolio
        final symbols = transactions.map((t) => t.symbol).toSet().toList();
        return symbols;
      },
      orElse: () => [],
    );
  }

  void _loadStockInfo(String symbol) {
    final portfolioAsync = ref.read(portfolioProvider);
    portfolioAsync.maybeWhen(
      data: (transactions) {
        // Calculate total quantity and average price for the selected stock
        final stockTransactions = transactions.where((t) => t.symbol == symbol).toList();
        
        int totalQuantity = 0;
        double totalCost = 0.0;
        
        for (final transaction in stockTransactions) {
          if (transaction.type == TransactionType.buy) {
            totalQuantity += transaction.quantity;
            totalCost += transaction.totalCost;
          } else if (transaction.type == TransactionType.sell) {
            totalQuantity -= transaction.quantity;
            totalCost -= (transaction.quantity * transaction.price) + transaction.commission;
          }
        }
        
        setState(() {
          _availableQuantity = totalQuantity;
          _avgPrice = totalQuantity > 0 ? totalCost / totalQuantity : 0.0;
        });
      },
      orElse: () {},
    );
  }

  Future<void> _selectBuyDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _buyDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _buyDate) {
      setState(() {
        _buyDate = picked;
      });
    }
  }

  Future<void> _selectSellDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sellDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _sellDate) {
      setState(() {
        _sellDate = picked;
      });
    }
  }

  void _saveBuyTransaction() {
    if (!_buyFormKey.currentState!.validate() || _selectedBuyStock == null) {
      return;
    }

    final quantity = int.parse(_buyQuantityController.text);
    final price = double.parse(_buyPriceController.text);
    final commission = _buyCommissionController.text.isNotEmpty
        ? double.parse(_buyCommissionController.text)
        : 0.0;
    final notes = _buyNotesController.text.trim();

    final transaction = PortfolioTransaction(
      type: TransactionType.buy,
      symbol: _selectedBuyStock!,
      quantity: quantity,
      price: price,
      commission: commission,
      date: _buyDate,
      notes: notes.isNotEmpty ? notes : null,
    );

    // Add transaction to portfolio
    ref.read(portfolioProvider.notifier).addTransaction(transaction);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buy transaction added successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Close screen
    Navigator.of(context).pop();
  }

  void _saveSellTransaction() {
    if (!_sellFormKey.currentState!.validate() || _selectedSellStock == null) {
      return;
    }

    final quantity = int.parse(_sellQuantityController.text);
    final price = double.parse(_sellPriceController.text);
    final commission = _sellCommissionController.text.isNotEmpty
        ? double.parse(_sellCommissionController.text)
        : 0.0;
    final notes = _sellNotesController.text.trim();

    final transaction = PortfolioTransaction(
      type: TransactionType.sell,
      symbol: _selectedSellStock!,
      quantity: quantity,
      price: price,
      commission: commission,
      date: _sellDate,
      notes: notes.isNotEmpty ? notes : null,
    );

    // Add transaction to portfolio
    ref.read(portfolioProvider.notifier).addTransaction(transaction);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sell transaction added successfully!'),
        backgroundColor: Colors.red,
      ),
    );

    // Close screen
    Navigator.of(context).pop();
  }
}
