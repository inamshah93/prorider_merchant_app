import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velo_core/velo_core.dart';

import '../providers/app_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiProvider);

    return FutureBuilder(
      future: api.get('/merchant/dashboard'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!.data as Map<String, dynamic>;
        final orders = (data['recent_orders'] as List?) ?? [];

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'Delivered today', value: '${data['delivered_today']}')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Payables', value: '₨ ${data['account_payables']}')),
                ],
              ),
              const SizedBox(height: 24),
              Text('Recent orders', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...orders.map((o) {
                final order = o as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(order['order_reference_number'] ?? ''),
                    subtitle: Text(order['order_status'] ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/orders/${order['id']}'),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
