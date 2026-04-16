import 'package:flutter/material.dart';

class ApiSettingsTab extends StatelessWidget {
  final TextEditingController apiKeyController;
  final bool obscureKey;
  final VoidCallback onToggleObscureKey;
  final VoidCallback onSaveApiKey;
  final VoidCallback onRemoveApiKey;
  final bool hasApiKey;

  final TextEditingController binanceKeyController;
  final TextEditingController binanceSecretController;
  final bool obscureBinanceKey;
  final bool obscureBinanceSecret;
  final VoidCallback onToggleBinanceKey;
  final VoidCallback onToggleBinanceSecret;
  final bool binanceTestnet;
  final bool binanceConfigured;
  final bool testingBinance;
  final VoidCallback onSaveBinance;
  final VoidCallback onTestBinance;
  final VoidCallback onRemoveBinance;
  final ValueChanged<bool> onToggleTestnet;

  final TextEditingController githubTokenController;
  final bool obscureGithubToken;
  final VoidCallback onToggleGithubToken;
  final bool githubConfigured;
  final VoidCallback onSaveGithubToken;
  final VoidCallback onRemoveGithubToken;

  const ApiSettingsTab({
    super.key,
    required this.apiKeyController,
    required this.obscureKey,
    required this.onToggleObscureKey,
    required this.onSaveApiKey,
    required this.onRemoveApiKey,
    required this.hasApiKey,
    required this.binanceKeyController,
    required this.binanceSecretController,
    required this.obscureBinanceKey,
    required this.obscureBinanceSecret,
    required this.onToggleBinanceKey,
    required this.onToggleBinanceSecret,
    required this.binanceTestnet,
    required this.binanceConfigured,
    required this.testingBinance,
    required this.onSaveBinance,
    required this.onTestBinance,
    required this.onRemoveBinance,
    required this.onToggleTestnet,
    required this.githubTokenController,
    required this.obscureGithubToken,
    required this.onToggleGithubToken,
    required this.githubConfigured,
    required this.onSaveGithubToken,
    required this.onRemoveGithubToken,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(context),
        const SizedBox(height: 16),
        _buildAnthropicSection(context),
        const SizedBox(height: 16),
        _buildBinanceSection(context),
        const SizedBox(height: 16),
        _buildGithubSection(context),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, Icons.dashboard_outlined, 'API Status'),
            const SizedBox(height: 12),
            _statusRow(
              'Claude AI',
              hasApiKey ? 'Active' : 'Not configured',
              hasApiKey,
            ),
            const SizedBox(height: 8),
            _statusRow(
              'Binance',
              binanceConfigured
                  ? (binanceTestnet ? 'Active (Testnet)' : 'Active (LIVE)')
                  : 'Not configured',
              binanceConfigured,
            ),
            const SizedBox(height: 8),
            _statusRow(
              'GitHub',
              githubConfigured ? 'Authenticated' : 'Public (60 req/h)',
              githubConfigured,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, String status, bool active) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnthropicSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, Icons.key, 'Anthropic API Key',
                statusLabel: hasApiKey ? 'Active' : 'Not set',
                statusActive: hasApiKey),
            const SizedBox(height: 12),
            Text(
              'Required for AI analysis. Get your key from console.anthropic.com',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apiKeyController,
              obscureText: obscureKey,
              onTap: () {
                if (apiKeyController.text.startsWith('••')) {
                  apiKeyController.clear();
                }
              },
              decoration: InputDecoration(
                hintText: 'sk-ant-...',
                suffixIcon: IconButton(
                  icon: Icon(
                      obscureKey ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: Colors.grey[600]),
                  onPressed: onToggleObscureKey,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSaveApiKey,
                    child: const Text('Save Key'),
                  ),
                ),
                if (hasApiKey) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onRemoveApiKey,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
                    child: const Text('Remove'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBinanceSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, Icons.currency_bitcoin, 'Binance API',
                statusLabel: binanceConfigured ? 'Active' : 'Not set',
                statusActive: binanceConfigured),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️  Osiguraj da API ključ NEMA dozvolu za Withdrawal.',
                style: TextStyle(color: Colors.orange[300], fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: binanceKeyController,
              obscureText: obscureBinanceKey,
              onTap: () {
                if (binanceKeyController.text.startsWith('••')) {
                  binanceKeyController.clear();
                }
              },
              decoration: InputDecoration(
                labelText: 'API Key',
                suffixIcon: IconButton(
                  icon: Icon(
                      obscureBinanceKey
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: Colors.grey[600]),
                  onPressed: onToggleBinanceKey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: binanceSecretController,
              obscureText: obscureBinanceSecret,
              onTap: () {
                if (binanceSecretController.text.startsWith('••')) {
                  binanceSecretController.clear();
                }
              },
              decoration: InputDecoration(
                labelText: 'API Secret',
                suffixIcon: IconButton(
                  icon: Icon(
                      obscureBinanceSecret
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: Colors.grey[600]),
                  onPressed: onToggleBinanceSecret,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Testnet mode'),
              subtitle: Text(
                binanceTestnet
                    ? 'Paper trading — nema pravog novca'
                    : '⚠️  LIVE — pravi novac na kocki',
                style: TextStyle(
                    fontSize: 12,
                    color: binanceTestnet ? Colors.grey[500] : Colors.orange),
              ),
              value: binanceTestnet,
              onChanged: onToggleTestnet,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSaveBinance,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: testingBinance ? null : onTestBinance,
                    child: testingBinance
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Test'),
                  ),
                ),
                if (binanceConfigured) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onRemoveBinance,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
                    child: const Text('Remove'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGithubSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, Icons.code, 'GitHub API (Opcionalno)',
                statusLabel: githubConfigured ? 'Authenticated' : 'Public (60 req/h)',
                statusActive: githubConfigured),
            const SizedBox(height: 8),
            Text(
              'Personal Access Token pove\u0107ava rate limit sa 60 na 5000 req/h. '
              'Generiraj na github.com/settings/tokens (scope: public_repo)',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: githubTokenController,
              obscureText: obscureGithubToken,
              decoration: InputDecoration(
                labelText: 'GitHub Token (ghp_...)',
                suffixIcon: IconButton(
                  icon: Icon(
                      obscureGithubToken ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: Colors.grey[600]),
                  onPressed: onToggleGithubToken,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSaveGithubToken,
                    child: const Text('Save'),
                  ),
                ),
                if (githubConfigured) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onRemoveGithubToken,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
                    child: const Text('Remove'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title,
      {String? statusLabel, bool statusActive = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        if (statusLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusActive
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                color: statusActive ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
