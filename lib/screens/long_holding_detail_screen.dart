import 'package:flutter/material.dart';
import 'package:coinsight/models/long_term_holding.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:provider/provider.dart';

class LongHoldingDetailScreen extends StatefulWidget {
  final LongTermHolding? holding;
  const LongHoldingDetailScreen({super.key, this.holding});

  @override
  State<LongHoldingDetailScreen> createState() =>
      _LongHoldingDetailScreenState();
}

class _LongHoldingDetailScreenState extends State<LongHoldingDetailScreen>
    with SingleTickerProviderStateMixin {
  late LongTermHolding _holding;
  bool _isNew = false;
  bool _isSaving = false;
  late TabController _tabController;

  // Basic info controllers
  late TextEditingController _symbolController;
  late TextEditingController _nameController;
  late TextEditingController _coinGeckoIdController;
  late TextEditingController _thesisController;
  late TextEditingController _targetMinController;
  late TextEditingController _targetMaxController;
  late TextEditingController _confidenceController;

  // Fundamentals controllers
  late TextEditingController _teamController;
  late TextEditingController _investorsController;
  late TextEditingController _partnershipsController;
  late TextEditingController _useCaseController;
  late TextEditingController _tokenomicsController;
  late TextEditingController _competitorController;
  late TextEditingController _roadmapController;

  // DCA controllers
  final TextEditingController _dcaPriceController = TextEditingController();
  final TextEditingController _dcaQtyController = TextEditingController();
  final TextEditingController _dcaAmountController = TextEditingController();
  final TextEditingController _dcaNoteController = TextEditingController();

  // Note controller
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isNew = widget.holding == null;
    _tabController = TabController(length: 4, vsync: this);

    _holding = widget.holding ?? LongTermHolding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: '',
      name: '',
      firstResearchDate: DateTime.now(),
      status: LongTermStatus.researching,
      targetPriceMin: 0,
      targetPriceMax: 0,
    );

    // Init basic controllers
    _symbolController = TextEditingController(text: _holding.symbol);
    _nameController = TextEditingController(text: _holding.name);
    _coinGeckoIdController = TextEditingController(text: _holding.coinGeckoId);
    _thesisController = TextEditingController(text: _holding.investmentThesis);
    _targetMinController = TextEditingController(
        text: _holding.targetPriceMin > 0
            ? _holding.targetPriceMin.toString() : '');
    _targetMaxController = TextEditingController(
        text: _holding.targetPriceMax > 0
            ? _holding.targetPriceMax.toString() : '');
    _confidenceController = TextEditingController(
        text: _holding.claudeConfidenceScore?.toString() ?? '');

    // Init fundamentals controllers
    final f = _holding.fundamentals;
    _teamController = TextEditingController(text: f?.teamBackground ?? '');
    _investorsController = TextEditingController(text: f?.investors ?? '');
    _partnershipsController = TextEditingController(
        text: f?.partnerships ?? '');
    _useCaseController = TextEditingController(
        text: f?.realWorldUseCase ?? '');
    _tokenomicsController = TextEditingController(text: f?.tokenomics ?? '');
    _competitorController = TextEditingController(
        text: f?.competitorAnalysis ?? '');
    _roadmapController = TextEditingController(
        text: f?.roadmapAssessment ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _symbolController, _nameController, _coinGeckoIdController,
      _thesisController, _targetMinController, _targetMaxController,
      _confidenceController, _teamController, _investorsController,
      _partnershipsController, _useCaseController, _tokenomicsController,
      _competitorController, _roadmapController, _dcaPriceController,
      _dcaQtyController, _dcaAmountController, _dcaNoteController,
      _noteController,
    ]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew
            ? 'Novi LONG holding'
            : _holding.symbol.isEmpty
                ? 'LONG holding'
                : _holding.symbol.toUpperCase()),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFD700),
          indicatorColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Osnove'),
            Tab(text: 'Fundamentali'),
            Tab(text: 'DCA'),
            Tab(text: 'Bilje\u0161ke'),
          ],
        ),
        actions: [
          if (!_isNew)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'accumulating',
                    child: Text('\u2192 Akumulacija')),
                const PopupMenuItem(value: 'holding',
                    child: Text('\u2192 Holding')),
                const PopupMenuItem(value: 'distributing',
                    child: Text('\u2192 Distribucija')),
                const PopupMenuItem(value: 'closed',
                    child: Text('\u2192 Zatvori')),
                const PopupMenuItem(value: 'delete',
                    child: Text('Obri\u0161i holding',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicsTab(),
          _buildFundamentalsTab(),
          _buildDcaTab(),
          _buildNotesTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Tab 1 — Osnove
  // ═══════════════════════════════════════════
  Widget _buildBasicsTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status
        if (!_isNew)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _holding.status.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_holding.status.label,
                style: TextStyle(color: _holding.status.color,
                    fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        const SizedBox(height: 16),

        _sectionTitle('Identifikacija'),
        _buildTextField(_symbolController, label: 'Simbol (npr. LINK)', caps: true),
        const SizedBox(height: 12),
        _buildTextField(_nameController, label: 'Naziv projekta'),
        const SizedBox(height: 12),
        _buildTextField(_coinGeckoIdController,
            label: 'CoinGecko ID (opcionalno)',
            hint: 'chainlink'),
        const SizedBox(height: 24),

        _sectionTitle('Investment Thesis'),
        TextField(
          controller: _thesisController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Za\u0161to je ovo LONG holding? '
                'Koji fundamentalni problem rje\u0161ava?',
          ),
        ),
        const SizedBox(height: 24),

        _sectionTitle('Target Cijene'),
        Row(
          children: [
            Expanded(child: _buildTextField(_targetMinController,
                label: 'Min target (\$)', numeric: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_targetMaxController,
                label: 'Max target (\$)', numeric: true)),
          ],
        ),
        const SizedBox(height: 12),

        // DCA summary (readonly ovdje)
        if (_holding.purchases.isNotEmpty) ...[
          _sectionTitle('DCA Summary'),
          Card(
            color: const Color(0xFFFFD700).withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _row('Kupnji', '${_holding.purchases.length}'),
                  _row('Avg entry', '\$${_holding.averageEntryPrice
                      .toStringAsFixed(_holding.averageEntryPrice >= 1 ? 4 : 8)}'),
                  _row('Total invested',
                      '\$${_holding.totalInvested.toStringAsFixed(2)} USDT'),
                  _row('Total qty',
                      '${_holding.totalQuantity.toStringAsFixed(6)} '
                      '${_holding.symbol.toUpperCase()}'),
                  if (_holding.potentialReturnMinPercent != 0)
                    _row('Potencijalni return',
                        '+${_holding.potentialReturnMinPercent
                            .toStringAsFixed(0)}% ~ '
                        '+${_holding.potentialReturnMaxPercent
                            .toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        _sectionTitle('Claude Confidence Score'),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: double.tryParse(_confidenceController.text) ?? 5,
                min: 1, max: 10, divisions: 9,
                activeColor: const Color(0xFFFFD700),
                onChanged: (v) => setState(() =>
                    _confidenceController.text = v.round().toString()),
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '${_confidenceController.text}/10',
                style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Analyze gumb
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Analiziraj s Claude LONG promptom'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFD700),
              side: const BorderSide(color: Color(0xFFFFD700)),
            ),
            onPressed: _analyzeWithClaude,
          ),
        ),
        const SizedBox(height: 32),
      ],
    ),
  );

  // ═══════════════════════════════════════════
  // Tab 2 — Fundamentali
  // ═══════════════════════════════════════════
  Widget _buildFundamentalsTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due diligence checklist \u2014 ispuni koliko mo\u017Ee\u0161. '
          'Nepotpuni fundamentali = ni\u017Ei confidence score.',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(height: 20),

        _fundamentalField(_teamController,
          icon: Icons.people_outline,
          label: 'Tim i osniva\u010Di',
          hint: 'Tko stoji iza projekta? Jesu li javno poznati? '
              'Prethodna iskustva?'),
        _fundamentalField(_investorsController,
          icon: Icons.business_center_outlined,
          label: 'Investitori i VC-evi',
          hint: 'a16z, Paradigm, Sequoia Crypto... '
              'Tier-1 investitori su bitan signal.'),
        _fundamentalField(_partnershipsController,
          icon: Icons.handshake_outlined,
          label: 'Partnerstva',
          hint: 'Korporativna i tehnolo\u0161ka partnerstva.'),
        _fundamentalField(_useCaseController,
          icon: Icons.lightbulb_outline,
          label: 'Real-world use case',
          hint: '\u0160to konkretno rje\u0161ava? Postoji li produkt u produkciji? '
              'TVL, transakcijski volumen?'),
        _fundamentalField(_tokenomicsController,
          icon: Icons.pie_chart_outline,
          label: 'Tokenomics',
          hint: 'Supply, distribucija, vesting schedule, '
              'inflatoran/deflatoran model.'),
        _fundamentalField(_competitorController,
          icon: Icons.compare_arrows,
          label: 'Konkurenti i competitive moat',
          hint: 'Tko su direktni konkurenti? '
              'Za\u0161to je ovaj projekt bolji/druga\u010Diji?'),
        _fundamentalField(_roadmapController,
          icon: Icons.map_outlined,
          label: 'Roadmap procjena',
          hint: 'Je li roadmap realan? '
              'Jesu li dosad ispunjavali obe\u0107anja?'),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            onPressed: _save,
            child: const Text('SPREMI FUNDAMENTALE'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    ),
  );

  Widget _fundamentalField(TextEditingController controller, {
    required IconData icon,
    required String label,
    required String hint,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFFFFD700)),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(hintText: hint),
            ),
          ],
        ),
      );

  // ═══════════════════════════════════════════
  // Tab 3 — DCA History
  // ═══════════════════════════════════════════
  Widget _buildDcaTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add new purchase
        _sectionTitle('Dodaj kupnju'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField(_dcaPriceController,
                        label: 'Cijena (\$)', numeric: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField(_dcaAmountController,
                        label: 'USDT', numeric: true)),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextField(_dcaQtyController,
                    label: 'Koli\u010Dina tokena (opciono)', numeric: true),
                const SizedBox(height: 8),
                TextField(
                  controller: _dcaNoteController,
                  decoration: const InputDecoration(
                    labelText: 'Bilje\u0161ka (opciono)',
                    hintText: 'Za\u0161to sada? DCA na dipu...',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _addPurchase,
                    child: const Text('DODAJ KUPNJU'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // DCA summary
        if (_holding.purchases.isNotEmpty) ...[
          _sectionTitle('DCA History'),
          Card(
            color: const Color(0xFFFFD700).withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _row('Prosje\u010Dna cijena',
                      '\$${_holding.averageEntryPrice.toStringAsFixed(
                          _holding.averageEntryPrice >= 1 ? 4 : 8)}'),
                  _row('Ukupno ulo\u017Eeno',
                      '\$${_holding.totalInvested.toStringAsFixed(2)}'),
                  _row('Ukupna koli\u010Dina',
                      _holding.totalQuantity.toStringAsFixed(6)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Purchase list — newest first
          ..._holding.purchases.reversed.map(_buildPurchaseCard),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Nema kupnji.\nDodaj prvu DCA kupnju gore.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
            ),
          ),
      ],
    ),
  );

  Widget _buildPurchaseCard(LongTermPurchase purchase) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${purchase.price.toStringAsFixed(
                      purchase.price >= 1 ? 4 : 8)} \u00D7 '
                  '${purchase.quantity.toStringAsFixed(4)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${purchase.amountUsdt.toStringAsFixed(2)} USDT',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                if (purchase.note != null && purchase.note!.isNotEmpty)
                  Text(purchase.note!,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Text(
            '${purchase.date.day}.${purchase.date.month}.'
            '${purchase.date.year}',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    ),
  );

  // ═══════════════════════════════════════════
  // Tab 4 — Notes
  // ═══════════════════════════════════════════
  Widget _buildNotesTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add note
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Nova bilje\u0161ka \u2014 vijest, opservacija, '
                      'promjena fundamentala...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Color(0xFFFFD700)),
                  onPressed: () => _addNote('observation'),
                  tooltip: 'Opservacija',
                ),
                IconButton(
                  icon: const Icon(Icons.newspaper_outlined,
                      color: Colors.blue),
                  onPressed: () => _addNote('news'),
                  tooltip: 'Vijest',
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome_outlined,
                      color: Color(0xFF03DAC6)),
                  onPressed: () => _addNote('analysis'),
                  tooltip: 'Analiza',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Notes timeline
        if (_holding.notes.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Nema bilje\u0161ki.',
                style: TextStyle(color: Colors.grey[500])),
          ))
        else
          ..._holding.notes.reversed.map(_buildLongNoteCard),
      ],
    ),
  );

  Widget _buildLongNoteCard(LongTermNote note) {
    Color noteColor;
    IconData noteIcon;
    switch (note.noteType) {
      case 'news':     noteColor = Colors.blue;
                       noteIcon = Icons.newspaper_outlined; break;
      case 'analysis': noteColor = const Color(0xFF03DAC6);
                       noteIcon = Icons.auto_awesome_outlined; break;
      case 'decision': noteColor = const Color(0xFFFFD700);
                       noteIcon = Icons.flag_outlined; break;
      default:         noteColor = Colors.grey;
                       noteIcon = Icons.circle_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(noteIcon, size: 16, color: noteColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(note.noteType,
                        style: TextStyle(
                            color: noteColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(_formatRelative(note.timestamp),
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(note.content,
                    style: TextStyle(
                        color: Colors.grey[300], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Actions
  // ═══════════════════════════════════════════
  Future<void> _addPurchase() async {
    final price = double.tryParse(_dcaPriceController.text);
    final amount = double.tryParse(_dcaAmountController.text);
    if (price == null || price <= 0 || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesi cijenu i iznos')));
      return;
    }

    // Ako qty nije unesen, izracunaj iz price i amount
    final qty = double.tryParse(_dcaQtyController.text) ?? (amount / price);

    final purchase = LongTermPurchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      price: price,
      quantity: qty,
      amountUsdt: amount,
      note: _dcaNoteController.text.trim().isEmpty
          ? null : _dcaNoteController.text.trim(),
    );

    setState(() {
      _holding = _holding.copyWith(
        purchases: [..._holding.purchases, purchase],
      );
      _dcaPriceController.clear();
      _dcaQtyController.clear();
      _dcaAmountController.clear();
      _dcaNoteController.clear();
    });

    await StorageService.saveLongHolding(_holding);
  }

  void _addNote(String noteType) {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    final note = LongTermNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      content: text,
      noteType: noteType,
    );

    setState(() {
      _holding = _holding.copyWith(
        notes: [..._holding.notes, note],
      );
      _noteController.clear();
    });

    StorageService.saveLongHolding(_holding);
  }

  Future<void> _analyzeWithClaude() async {
    await _save(showSnackbar: false);
    if (!mounted) return;
    final symbol = _symbolController.text.trim();
    if (symbol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesi simbol')));
      return;
    }
    context.read<AnalysisProvider>().gatherIntelligenceForCoin(symbol);
    Navigator.of(context).pop({'action': 'openAnalysis', 'symbol': symbol});
  }

  Future<void> _save({bool showSnackbar = true}) async {
    setState(() => _isSaving = true);

    final fundamentals = LongTermFundamentals(
      teamBackground: _teamController.text.trim(),
      investors: _investorsController.text.trim(),
      partnerships: _partnershipsController.text.trim(),
      realWorldUseCase: _useCaseController.text.trim(),
      tokenomics: _tokenomicsController.text.trim(),
      competitorAnalysis: _competitorController.text.trim(),
      roadmapAssessment: _roadmapController.text.trim(),
      lastUpdated: DateTime.now(),
    );

    _holding = _holding.copyWith(
      symbol: _symbolController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      investmentThesis: _thesisController.text.trim(),
      targetPriceMin: double.tryParse(_targetMinController.text) ?? 0,
      targetPriceMax: double.tryParse(_targetMaxController.text) ?? 0,
      claudeConfidenceScore: int.tryParse(_confidenceController.text),
      fundamentals: fundamentals,
    );

    await StorageService.saveLongHolding(_holding);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (showSnackbar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            '${_holding.symbol.isEmpty ? "Holding" : _holding.symbol} '
            'spremljen')));
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'accumulating':
        _updateStatus(LongTermStatus.accumulating); break;
      case 'holding':
        _updateStatus(LongTermStatus.holding); break;
      case 'distributing':
        _updateStatus(LongTermStatus.distributing); break;
      case 'closed':
        _updateStatus(LongTermStatus.closed); break;
      case 'delete':
        await _confirmDelete(); break;
    }
  }

  Future<void> _updateStatus(LongTermStatus newStatus) async {
    setState(() => _holding = _holding.copyWith(status: newStatus));
    await StorageService.saveLongHolding(_holding);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status \u2192 ${newStatus.label}')));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Obri\u0161i holding?'),
        content: Text(
            'Brisanje ${_holding.symbol} holdinga je nepovratno.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Odustani')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Obri\u0161i',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await StorageService.deleteLongHolding(_holding.id);
    if (!mounted) return;
    Navigator.of(context).pop({'action': 'deleted'});
  }

  // ═══════════════════════════════════════════
  // Shared helpers
  // ═══════════════════════════════════════════
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: Colors.grey[400], letterSpacing: 0.5)),
  );

  Widget _buildTextField(TextEditingController c, {
    required String label, String? hint,
    bool numeric = false, bool caps = false,
  }) =>
      TextField(
        controller: c,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textCapitalization: caps
            ? TextCapitalization.characters
            : TextCapitalization.none,
        decoration: InputDecoration(labelText: label, hintText: hint),
      );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        Text(value, style: const TextStyle(
            fontWeight: FontWeight.w500, fontSize: 12)),
      ],
    ),
  );

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'prije ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'prije ${diff.inHours}h';
    if (diff.inDays < 7) return 'prije ${diff.inDays}d';
    return '${dt.day}.${dt.month}.${dt.year}';
  }
}
