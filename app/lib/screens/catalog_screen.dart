import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _price = TextEditingController();
  final _weight = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _price.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ref.read(apiProvider).get('/merchant/catalog');
    final raw = (res.data['data'] as List?) ?? [];
    setState(() {
      _items = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _loading = false;
    });
  }

  Future<void> _save() async {
    await ref.read(apiProvider).put('/merchant/catalog', data: {'items': _items});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catalog saved')));
  }

  void _addItem() {
    if (_name.text.trim().isEmpty) return;
    setState(() {
      _items.add({
        'sku': _sku.text.trim().isEmpty ? _name.text.trim().toLowerCase().replaceAll(' ', '-') : _sku.text.trim(),
        'name': _name.text.trim(),
        'price': double.tryParse(_price.text) ?? 0,
        'weight': double.tryParse(_weight.text) ?? 0,
      });
      _name.clear();
      _sku.clear();
      _price.clear();
      _weight.clear();
    });
  }

  void _remove(int index) {
    setState(() => _items.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product catalog'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Product name')),
                        const SizedBox(height: 12),
                        TextField(controller: _sku, decoration: const InputDecoration(labelText: 'SKU (optional)')),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 360) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price')),
                                  const SizedBox(height: 12),
                                  TextField(controller: _weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight kg')),
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price'))),
                                const SizedBox(width: 12),
                                Expanded(child: TextField(controller: _weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight kg'))),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _addItem, child: const Text('Add item')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._items.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          title: Text(e.value['name']?.toString() ?? 'Item'),
                          subtitle: Text('SKU ${e.value['sku']} · ₨${e.value['price']} · ${e.value['weight']}kg'),
                          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(e.key)),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
