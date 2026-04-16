import 'package:flutter/material.dart';
import 'package:coinsight/models/dex_position.dart';
import 'package:coinsight/services/storage_service.dart';

class DexPositionScreen extends StatefulWidget {
  /// Pre-fill fields from a DEX signal
  final String? tokenSymbol;
  final String? tokenName;
  final String? contractAddress;
  final String? chainId;
  final String? dexName;
  final double? entryPrice;

  const DexPositionScreen({
    super.key,
    this.tokenSymbol,
    this.tokenName,
    this.contractAddress,
    this.chainId,
    this.dexName,
    this.entryPrice,
  });

  @override
  State<DexPositionScreen> createState() => _DexPositionScreenState();
}

class _DexPositionScreenState extends State<DexPositionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _symbolController;
  late final TextEditingController _nameController;
  late final TextEditingController _contractController;
  late final TextEditingController _dexNameController;
  late final TextEditingController _entryPriceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _entryAmountController;
  late final TextEditingController _slController;
  late final TextEditingController _tpController;

  String _selectedChain = 'ethereum';

  static const _chains = [
    'ethereum',
    'bsc',
    'solana',
    'polygon',
    'arbitrum',
    'base',
  ];

  @override
  void initState() {
    super.initState();
    _symbolController = TextEditingController(text: widget.tokenSymbol ?? '');
    _nameController = TextEditingController(text: widget.tokenName ?? '');
    _contractController =
        TextEditingController(text: widget.contractAddress ?? '');
    _dexNameController = TextEditingController(text: widget.dexName ?? '');
    _entryPriceController = TextEditingController(
        text: widget.entryPrice != null
            ? widget.entryPrice!.toStringAsFixed(8)
            : '');
    _quantityController = TextEditingController();
    _entryAmountController = TextEditingController();
    _slController = TextEditingController();
    _tpController = TextEditingController();

    if (widget.chainId != null && _chains.contains(widget.chainId)) {
      _selectedChain = widget.chainId!;
    }
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _contractController.dispose();
    _dexNameController.dispose();
    _entryPriceController.dispose();
    _quantityController.dispose();
    _entryAmountController.dispose();
    _slController.dispose();
    _tpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova DEX Pozicija')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Token Symbol
            TextFormField(
              controller: _symbolController,
              decoration: const InputDecoration(labelText: 'Token Symbol *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obavezno' : null,
            ),
            const SizedBox(height: 12),

            // Token Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Token Name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obavezno' : null,
            ),
            const SizedBox(height: 12),

            // Contract Address
            TextFormField(
              controller: _contractController,
              decoration:
                  const InputDecoration(labelText: 'Contract Address *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obavezno' : null,
            ),
            const SizedBox(height: 12),

            // Chain dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedChain,
              decoration: const InputDecoration(labelText: 'Chain'),
              items: _chains
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(c.toUpperCase())))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedChain = v);
              },
            ),
            const SizedBox(height: 12),

            // DEX Name
            TextFormField(
              controller: _dexNameController,
              decoration: const InputDecoration(
                  labelText: 'DEX Name',
                  hintText: 'Uniswap, PancakeSwap, Raydium...'),
            ),
            const SizedBox(height: 12),

            // Entry Price
            TextFormField(
              controller: _entryPriceController,
              decoration: const InputDecoration(labelText: 'Entry Price (USD) *'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obavezno';
                if (double.tryParse(v) == null) return 'Neispravan broj';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity *'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obavezno';
                if (double.tryParse(v) == null) return 'Neispravan broj';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Entry Amount USDT
            TextFormField(
              controller: _entryAmountController,
              decoration:
                  const InputDecoration(labelText: 'Entry Amount (USDT) *'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obavezno';
                if (double.tryParse(v) == null) return 'Neispravan broj';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Optional SL/TP
            Text('Opcionalno',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _slController,
                    decoration:
                        const InputDecoration(labelText: 'Stop Loss (\$)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                        return 'Neispravan';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _tpController,
                    decoration:
                        const InputDecoration(labelText: 'Take Profit (\$)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                        return 'Neispravan';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Spremi poziciju'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final walletAddress = StorageService.getWalletAddress() ?? '';
    final position = DexPosition(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tokenSymbol: _symbolController.text.trim().toUpperCase(),
      tokenName: _nameController.text.trim(),
      contractAddress: _contractController.text.trim(),
      chainId: _selectedChain,
      dexName: _dexNameController.text.trim(),
      walletAddress: walletAddress,
      entryPrice: double.parse(_entryPriceController.text.trim()),
      quantity: double.parse(_quantityController.text.trim()),
      entryAmountUsdt: double.parse(_entryAmountController.text.trim()),
      entryTime: DateTime.now(),
      stopLossPrice: _slController.text.trim().isNotEmpty
          ? double.tryParse(_slController.text.trim())
          : null,
      takeProfitPrice: _tpController.text.trim().isNotEmpty
          ? double.tryParse(_tpController.text.trim())
          : null,
    );

    await StorageService.saveDexPosition(position);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('DEX pozicija spremljena')),
    );
    Navigator.of(context).pop(true);
  }
}
