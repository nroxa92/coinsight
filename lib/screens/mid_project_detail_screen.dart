import 'package:flutter/material.dart';
import 'package:coinsight/models/mid_term_project.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/github_intelligence.dart';
import 'package:coinsight/models/github_signal.dart';
import 'package:provider/provider.dart';

class MidProjectDetailScreen extends StatefulWidget {
  final MidTermProject? project;
  const MidProjectDetailScreen({super.key, this.project});

  @override
  State<MidProjectDetailScreen> createState() => _MidProjectDetailScreenState();
}

class _MidProjectDetailScreenState extends State<MidProjectDetailScreen> {
  late MidTermProject _project;
  bool _isNew = false;
  bool _isSaving = false;
  bool _isFetchingGithub = false;
  GitHubSignal? _githubData;

  // Controllers za editable polja
  late TextEditingController _symbolController;
  late TextEditingController _nameController;
  late TextEditingController _githubRepoController;
  late TextEditingController _thesisController;
  late TextEditingController _entryPriceController;
  late TextEditingController _entryAmountController;
  late TextEditingController _stopLossController;
  late TextEditingController _takeProfitController;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isNew = widget.project == null;
    _project = widget.project ?? MidTermProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: '',
      name: '',
      discoveredAt: DateTime.now(),
      status: MidTermStatus.researching,
    );

    _symbolController = TextEditingController(text: _project.symbol);
    _nameController = TextEditingController(text: _project.name);
    _githubRepoController = TextEditingController(text: _project.githubRepo);
    _thesisController = TextEditingController(text: _project.thesis);
    _entryPriceController = TextEditingController(
        text: _project.entryPriceTarget?.toString() ?? '');
    _entryAmountController = TextEditingController(
        text: _project.entryAmountUsdt?.toString() ?? '');
    _stopLossController = TextEditingController(
        text: _project.stopLossPrice?.toString() ?? '');
    _takeProfitController = TextEditingController(
        text: _project.takeProfitPrice?.toString() ?? '');
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _githubRepoController.dispose();
    _thesisController.dispose();
    _entryPriceController.dispose();
    _entryAmountController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew
            ? 'Novi MID projekt'
            : _project.symbol.isEmpty
                ? 'MID projekt'
                : _project.symbol.toUpperCase()),
        actions: [
          if (!_isNew)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'watching',
                    child: Text('\u2192 Prebaci na WATCHING')),
                const PopupMenuItem(value: 'entered',
                    child: Text('\u2192 Prebaci na ENTERED')),
                const PopupMenuItem(value: 'exited',
                    child: Text('\u2192 Prebaci na EXITED')),
                const PopupMenuItem(value: 'abandoned',
                    child: Text('\u2192 Odustani od projekta')),
                const PopupMenuItem(value: 'delete',
                    child: Text('Obri\u0161i projekt',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            onPressed: _isSaving ? null : _save,
            tooltip: 'Spremi',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            if (!_isNew)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _project.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_project.status.label,
                    style: TextStyle(
                        color: _project.status.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            const SizedBox(height: 16),

            // --- Osnovni podaci ---
            _sectionTitle('Projekt'),
            _buildTextField(_symbolController,
                label: 'Simbol (npr. LINK)',
                hint: 'TOKENX',
                caps: true),
            const SizedBox(height: 12),
            _buildTextField(_nameController,
                label: 'Puni naziv',
                hint: 'Token X Protocol'),
            const SizedBox(height: 24),

            // --- GitHub ---
            _sectionTitle('GitHub'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildTextField(_githubRepoController,
                      label: 'GitHub repo (username/repo)',
                      hint: 'chainlink-labs/chainlink'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03DAC6),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                  onPressed: _isFetchingGithub ? null : _fetchGithubData,
                  child: _isFetchingGithub
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.search, size: 18),
                ),
              ],
            ),
            if (_githubData != null) ...[
              const SizedBox(height: 12),
              _buildGithubDataCard(_githubData!),
            ],
            const SizedBox(height: 24),

            // --- Teza ---
            _sectionTitle('Investment Thesis'),
            TextField(
              controller: _thesisController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Za\u0161to vjeruje\u0161 u ovaj projekt? '
                    'Koji problem rje\u0161ava? Za\u0161to sada?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            // Gumb za AI analizu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Analiziraj s Claude MID promptom'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF03DAC6),
                  side: const BorderSide(color: Color(0xFF03DAC6)),
                ),
                onPressed: _analyzeWithClaude,
              ),
            ),
            if (_project.lastClaudeAnalysis != null) ...[
              const SizedBox(height: 12),
              _buildLastAnalysisCard(),
            ],
            const SizedBox(height: 24),

            // --- Entry Plan ---
            _sectionTitle('Entry Plan'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_entryPriceController,
                      label: 'Target entry (\$)',
                      hint: '0.0234',
                      numeric: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(_entryAmountController,
                      label: 'Iznos (USDT)',
                      hint: '50',
                      numeric: true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_stopLossController,
                      label: 'Stop-Loss (\$)',
                      hint: '0.0199',
                      numeric: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(_takeProfitController,
                      label: 'Take-Profit (\$)',
                      hint: '0.0702',
                      numeric: true),
                ),
              ],
            ),
            // Prikazi potencijalni return ako su uneseni podaci
            if (_entryPriceController.text.isNotEmpty &&
                _takeProfitController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildReturnPreview(),
              ),
            const SizedBox(height: 24),

            // --- Notes Timeline ---
            _sectionTitle('Bilje\u0161ke'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Dodaj bilje\u0161ku...',
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF03DAC6),
                  onPressed: _addNote,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_project.notes.isEmpty)
              Text('Nema bilje\u0161ki.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13))
            else
              ..._project.notes.reversed.map(_buildNoteCard),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
            letterSpacing: 0.5)),
  );

  Widget _buildTextField(TextEditingController controller, {
    required String label,
    String? hint,
    bool numeric = false,
    bool caps = false,
  }) =>
      TextField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textCapitalization: caps
            ? TextCapitalization.characters
            : TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      );

  Widget _buildGithubDataCard(GitHubSignal github) => Card(
    color: const Color(0xFF03DAC6).withValues(alpha: 0.08),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, size: 16, color: Color(0xFF03DAC6)),
              const SizedBox(width: 6),
              Text(github.repoName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          _row('Stars', '${github.stars} (+${github.starsToday} danas)'),
          _row('Zadnji commit', _formatRelative(github.pushedAt)),
          _row('Jezik', github.language),
          _row('Star velocity',
              '${(github.starVelocity * 100).toStringAsFixed(1)}%'),
          _row('Crypto relevantno',
              github.hasCryptoTopics ? 'Da' : 'Niska'),
          if (github.topics.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              children: github.topics.take(5).map((t) => Chip(
                label: Text(t, style: const TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              )).toList(),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildLastAnalysisCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16,
                  color: Color(0xFF03DAC6)),
              const SizedBox(width: 6),
              Text('Claude analiza \u2014 '
                  '${_formatRelative(_project.lastAnalysisDate!)}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _project.lastClaudeAnalysis!.length > 300
                ? '${_project.lastClaudeAnalysis!.substring(0, 300)}...'
                : _project.lastClaudeAnalysis!,
            style: TextStyle(color: Colors.grey[300], fontSize: 12),
          ),
        ],
      ),
    ),
  );

  Widget _buildReturnPreview() {
    final entry = double.tryParse(_entryPriceController.text);
    final tp = double.tryParse(_takeProfitController.text);
    final sl = double.tryParse(_stopLossController.text);
    if (entry == null || entry <= 0 || tp == null) {
      return const SizedBox.shrink();
    }
    final returnPct = ((tp - entry) / entry * 100);
    final slPct = sl != null
        ? ((sl - entry) / entry * 100)
        : null;
    return Row(
      children: [
        const Icon(Icons.trending_up, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Text('TP: +${returnPct.toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.green, fontSize: 12)),
        if (slPct != null) ...[
          const SizedBox(width: 16),
          const Icon(Icons.trending_down, size: 14, color: Colors.red),
          const SizedBox(width: 4),
          Text('SL: ${slPct.toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildNoteCard(MidTermNote note) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF03DAC6),
              ),
            ),
            Container(
              width: 2, height: 40,
              color: Colors.grey[800],
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatRelative(note.timestamp),
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(note.content,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[300])),
              if (note.claudeSnippet != null) ...[
                const SizedBox(height: 4),
                Text(note.claudeSnippet!,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500],
                        fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
            color: Colors.grey[400], fontSize: 12)),
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

  // ═══════════════════════════════════════════
  // Actions
  // ═══════════════════════════════════════════

  Future<void> _fetchGithubData() async {
    final repo = _githubRepoController.text.trim();
    if (repo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesi GitHub repo')));
      return;
    }
    setState(() => _isFetchingGithub = true);
    final github = GitHubIntelligence();
    final symbol = _symbolController.text.trim().isNotEmpty
        ? _symbolController.text.trim()
        : repo.split('/').last;
    final result = await github.searchByCoinName(symbol);
    if (!mounted) return;
    setState(() {
      _githubData = result;
      _isFetchingGithub = false;
    });
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GitHub repo nije prona\u0111en')));
    }
  }

  Future<void> _analyzeWithClaude() async {
    // Spremi prvo da imamo sve podatke
    await _save(showSnackbar: false);
    if (!mounted) return;

    final symbol = _symbolController.text.trim();
    if (symbol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesi simbol projekta')));
      return;
    }

    // Postavi MID tier i otvori Analysis screen
    final analysisProvider = context.read<AnalysisProvider>();
    await analysisProvider.gatherIntelligenceForCoin(symbol);

    if (!mounted) return;
    // Prebaci na Analysis tab (index 1 u bottom nav)
    Navigator.of(context).pop({'action': 'openAnalysis', 'symbol': symbol});
  }

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    final note = MidTermNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      content: text,
    );

    setState(() {
      _project = _project.copyWith(
        notes: [..._project.notes, note],
      );
      _noteController.clear();
    });

    StorageService.saveMidProject(_project);
  }

  Future<void> _save({bool showSnackbar = true}) async {
    setState(() => _isSaving = true);

    _project = _project.copyWith(
      symbol: _symbolController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      githubRepo: _githubRepoController.text.trim(),
      thesis: _thesisController.text.trim(),
      entryPriceTarget: double.tryParse(_entryPriceController.text),
      entryAmountUsdt: double.tryParse(_entryAmountController.text),
      stopLossPrice: double.tryParse(_stopLossController.text),
      takeProfitPrice: double.tryParse(_takeProfitController.text),
    );

    await StorageService.saveMidProject(_project);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (showSnackbar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            '${_project.symbol.isEmpty ? "Projekt" : _project.symbol} '
            'spremljen')),
      );
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'watching':
        _updateStatus(MidTermStatus.watching);
        break;
      case 'entered':
        _updateStatus(MidTermStatus.entered);
        break;
      case 'exited':
        _updateStatus(MidTermStatus.exited);
        break;
      case 'abandoned':
        _updateStatus(MidTermStatus.abandoned);
        break;
      case 'delete':
        await _confirmDelete();
        break;
    }
  }

  Future<void> _updateStatus(MidTermStatus newStatus) async {
    setState(() => _project = _project.copyWith(status: newStatus));
    await StorageService.saveMidProject(_project);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status \u2192 ${newStatus.label}')));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Obri\u0161i projekt?'),
        content: Text('Brisanje projekta '
            '${_project.symbol} je nepovratno.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Obri\u0161i',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await StorageService.deleteMidProject(_project.id);
    if (!mounted) return;
    Navigator.of(context).pop({'action': 'deleted'});
  }
}
