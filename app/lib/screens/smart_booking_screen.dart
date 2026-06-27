import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velo_core/velo_core.dart';

import '../providers/app_providers.dart';

class SmartBookingScreen extends ConsumerStatefulWidget {
  const SmartBookingScreen({super.key});

  @override
  ConsumerState<SmartBookingScreen> createState() => _SmartBookingScreenState();
}

class _SmartBookingScreenState extends ConsumerState<SmartBookingScreen> {
  final Map<String, int> _qty = {};
  final _customerName = TextEditingController();
  final _customerPhone = TextEditingController(text: '03001234567');
  final _address = TextEditingController(text: '123 Mall Road');
  final _city = TextEditingController(text: 'Lahore');

  @override
  Widget build(BuildContext context) {
    final api = ref.watch(apiProvider);

    return FutureBuilder(
      future: api.get('/merchant/catalog'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = (snapshot.data!.data['data'] as List?) ?? [];

        for (final item in items) {
          final sku = item['sku'] as String;
          _qty.putIfAbsent(sku, () => 0);
        }

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Smart booking', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...items.map((item) {
                final m = item as Map<String, dynamic>;
                final sku = m['sku'] as String;
                return Card(
                  child: ListTile(
                    title: Text(m['name'] ?? ''),
                    subtitle: Text('₨ ${m['price']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () => setState(() => _qty[sku] = ((_qty[sku] ?? 0) - 1).clamp(0, 99)), icon: const Icon(Icons.remove)),
                        Text('${_qty[sku]}'),
                        IconButton(onPressed: () => setState(() => _qty[sku] = (_qty[sku] ?? 0) + 1), icon: const Icon(Icons.add)),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              TextField(controller: _customerName, decoration: const InputDecoration(labelText: 'Customer name')),
              TextField(controller: _customerPhone, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _confirm(api, items),
                child: const Text('Confirm booking'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirm(ApiClient api, List items) async {
    final selected = <Map<String, dynamic>>[];
    var total = 0.0;
    for (final item in items) {
      final m = item as Map<String, dynamic>;
      final q = _qty[m['sku']] ?? 0;
      if (q > 0) {
        selected.add({...m, 'quantity': q});
        total += (m['price'] as num).toDouble() * q;
      }
    }

    final res = await api.post('/merchant/orders', data: {
      'customer_name': _customerName.text.isEmpty ? 'Walk-in Customer' : _customerName.text,
      'customer_phone': _customerPhone.text,
      'delivery_address': _address.text,
      'city_name': _city.text,
      'items': selected,
      'cod_amount': total,
    });

    final order = (res.data as Map)['data'] as Map<String, dynamic>;
    if (mounted) context.push('/orders/${order['id']}');
  }
}
