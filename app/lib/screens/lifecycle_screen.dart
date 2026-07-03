import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velo_core/velo_core.dart';

import '../providers/app_providers.dart';
import '../widgets/slide_to_ship.dart';

class LifecycleScreen extends ConsumerStatefulWidget {
  const LifecycleScreen({super.key, required this.orderId});
  final int orderId;

  @override
  ConsumerState<LifecycleScreen> createState() => _LifecycleScreenState();
}

class _LifecycleScreenState extends ConsumerState<LifecycleScreen> {
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ref.read(apiProvider).get('/merchant/orders/${widget.orderId}');
    setState(() => _order = (res.data as Map)['data'] as Map<String, dynamic>);
  }

  Future<void> _action(String endpoint) async {
    await ref.read(apiProvider).post('/merchant/orders/${widget.orderId}/$endpoint');
    await _load();
  }

  Future<void> _shareLabel() async {
    final res = await ref.read(apiProvider).get('/merchant/orders/${widget.orderId}/label');
    final data = (res.data as Map)['data'] as Map<String, dynamic>;
    await Share.share(data['label_text']?.toString() ?? 'Shipping label');
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final prep = _order!['merchant_prep_status'] as String? ?? 'created';
    final status = _order!['order_status'] as String? ?? 'created';

    return Scaffold(
      appBar: AppBar(title: Text(_order!['order_reference_number'] ?? 'Order')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StepTile(title: 'Order created', done: true),
          _StepTile(title: 'Label printed', done: prep != 'created', action: prep == 'created' ? () => _action('generate-label') : null),
          if (prep != 'created' && _order!['awb_number'] != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: _shareLabel, icon: const Icon(Icons.share_outlined), label: const Text('Share / print label')),
          ],
          _StepTile(title: 'Packed', done: prep == 'packed' || prep == 'label_generated' && status != 'created', action: prep == 'label_generated' ? () => _action('mark-packed') : null),
          _StepTile(title: 'Ready to ship', done: status != 'created', action: null),
          if (prep == 'packed' && status == 'created') ...[
            const SizedBox(height: 24),
            SlideToShip(onComplete: () => _action('ready-to-ship')),
          ],
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.title, required this.done, this.action});
  final String title;
  final bool done;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? AppTheme.success : Colors.grey),
        title: Text(title),
        trailing: action != null ? TextButton(onPressed: action, child: const Text('Mark')) : null,
      ),
    );
  }
}
