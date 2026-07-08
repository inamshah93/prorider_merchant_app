import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velo_core/velo_core.dart';

import '../providers/app_providers.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  int _page = 1;
  String _status = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _load() async {
    final api = ref.read(apiProvider);
    final res = await api.get('/merchant/orders', query: {
      'page': _page,
      if (_status.isNotEmpty) 'status': _status,
      if (_search.text.trim().isNotEmpty) 'search': _search.text.trim(),
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      key: ValueKey('$_page-$_status-${_search.text.trim()}'),
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final orders = (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final meta = data['meta'] as Map<String, dynamic>? ?? {};
        final page = JsonNum.parseInt(meta['page']) ?? _page;
        final total = JsonNum.parseInt(meta['total']) ?? orders.length;
        final perPage = JsonNum.parseInt(meta['per_page']) ?? 20;
        final lastPage = total > 0 ? (total / perPage).ceil() : page;

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Orders', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search reference or customer',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() {
                      _page = 1;
                    }),
                  ),
                ),
                onSubmitted: (_) => setState(() => _page = 1),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _status.isEmpty ? null : _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All statuses')),
                  DropdownMenuItem(value: 'created', child: Text('Created')),
                  DropdownMenuItem(value: 'ready_to_ship', child: Text('Ready to ship')),
                  DropdownMenuItem(value: 'dispatched', child: Text('Dispatched')),
                  DropdownMenuItem(value: 'picked_up', child: Text('Picked up')),
                  DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (v) => setState(() {
                  _status = v ?? '';
                  _page = 1;
                }),
              ),
              const SizedBox(height: 12),
              Text('$total orders', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No orders found')),
                )
              else
                ...orders.map((order) {
                  return Card(
                    child: ListTile(
                      title: Text(order['order_reference_number']?.toString() ?? ''),
                      subtitle: Text('${order['customer_name'] ?? ''} · ${order['order_status'] ?? ''}'),
                      trailing: Text('₨ ${order['cod_amount'] ?? '0'}'),
                      onTap: () => context.push('/orders/${order['id']}'),
                    ),
                  );
                }),
              if (orders.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: page > 1 ? () => setState(() => _page = page - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('$page / $lastPage'),
                    IconButton(
                      onPressed: page < lastPage ? () => setState(() => _page = page + 1) : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
