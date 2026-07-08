import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    try {
      final res = await ref.read(apiProvider).get('/merchant/orders/${widget.orderId}');
      if (!mounted) return;
      setState(() => _order = (res.data as Map)['data'] as Map<String, dynamic>);
    } catch (e) {
      if (!mounted || silent) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order: $e')),
      );
    }
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
    final delivery = _deliveryLocation(_order!);
    final rider = _riderInfo(_order!);

    return Scaffold(
      appBar: AppBar(title: Text(_order!['order_reference_number'] ?? 'Order')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TrackingSection(
            delivery: delivery,
            rider: rider,
          ),
          const SizedBox(height: 16),
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

class _TrackingSection extends StatelessWidget {
  const _TrackingSection({
    required this.delivery,
    required this.rider,
  });

  final _DeliveryLocation delivery;
  final _RiderInfo rider;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Live tracking',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (delivery.hasLatLng)
                  TextButton.icon(
                    onPressed: () => _openInMaps(delivery),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Open in Maps'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _RiderInfoTile(rider: rider),
            const SizedBox(height: 12),
            _MapCard(delivery: delivery, rider: rider),
            if (!delivery.hasLatLng) ...[
              const SizedBox(height: 12),
              _InlineNotice(text: 'Customer location not set.'),
            ],
            if (rider.assigned && !rider.hasLatLng) ...[
              const SizedBox(height: 8),
              _InlineNotice(text: 'Rider location missing.'),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _openInMaps(_DeliveryLocation delivery) async {
    if (!delivery.hasLatLng) return;

    final lat = delivery.lat!;
    final lng = delivery.lng!;
    final query = Uri.encodeComponent('${delivery.address ?? ''} ($lat,$lng)'.trim());
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // ignore: avoid_print
      debugPrint('Could not launch maps URL: $url');
    }
  }
}

class _RiderInfoTile extends StatelessWidget {
  const _RiderInfoTile({required this.rider});
  final _RiderInfo rider;

  @override
  Widget build(BuildContext context) {
    if (!rider.assigned) {
      return const _InlineNotice(text: 'No rider assigned yet.');
    }

    return Row(
      children: [
        const Icon(Icons.delivery_dining, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rider.name ?? 'Assigned rider', style: const TextStyle(fontWeight: FontWeight.w600)),
              if (rider.phone != null && rider.phone!.trim().isNotEmpty)
                Text(rider.phone!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

class _MapCard extends StatefulWidget {
  const _MapCard({required this.delivery, required this.rider});

  final _DeliveryLocation delivery;
  final _RiderInfo rider;

  @override
  State<_MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<_MapCard> {
  final _controller = MapController();

  @override
  void didUpdateWidget(covariant _MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitIfPossible());
  }

  @override
  Widget build(BuildContext context) {
    final points = <LatLng>[
      if (widget.delivery.hasLatLng) LatLng(widget.delivery.lat!, widget.delivery.lng!),
      if (widget.rider.hasLatLng) LatLng(widget.rider.lat!, widget.rider.lng!),
    ];

    if (points.isEmpty) {
      return const _InlineNotice(text: 'Tracking unavailable (missing locations).');
    }

    final center = points.first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            onMapReady: _fitIfPossible,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'pk.velo.prorider_merchant_app',
            ),
            MarkerLayer(
              markers: [
                if (widget.delivery.hasLatLng)
                  Marker(
                    point: LatLng(widget.delivery.lat!, widget.delivery.lng!),
                    width: 44,
                    height: 44,
                    child: const _Pin(color: Colors.red, icon: Icons.location_on),
                  ),
                if (widget.rider.hasLatLng)
                  Marker(
                    point: LatLng(widget.rider.lat!, widget.rider.lng!),
                    width: 44,
                    height: 44,
                    child: const _Pin(color: AppTheme.primary, icon: Icons.motorcycle),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _fitIfPossible() {
    final points = <LatLng>[
      if (widget.delivery.hasLatLng) LatLng(widget.delivery.lat!, widget.delivery.lng!),
      if (widget.rider.hasLatLng) LatLng(widget.rider.lat!, widget.rider.lng!),
    ];
    final bounds = _bounds(points);
    if (bounds == null) return;

    _controller.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(36),
      ),
    );
  }

  LatLngBounds? _bounds(List<LatLng> points) {
    if (points.length < 2) return null;
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final p in points.skip(1)) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _DeliveryLocation {
  const _DeliveryLocation({this.lat, this.lng, this.address});
  final double? lat;
  final double? lng;
  final String? address;
  bool get hasLatLng => lat != null && lng != null;
}

class _RiderInfo {
  const _RiderInfo({
    required this.assigned,
    this.name,
    this.phone,
    this.lat,
    this.lng,
  });
  final bool assigned;
  final String? name;
  final String? phone;
  final double? lat;
  final double? lng;
  bool get hasLatLng => lat != null && lng != null;
}

_DeliveryLocation _deliveryLocation(Map<String, dynamic> order) {
  double? d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  final address = order['delivery_address']?.toString() ??
      order['address']?.toString() ??
      (order['delivery'] is Map ? (order['delivery'] as Map)['address']?.toString() : null);

  final lat = d(order['delivery_lat'] ?? order['delivery_latitude'] ?? order['deliveryLatitude']);
  final lng = d(order['delivery_lng'] ?? order['delivery_long'] ?? order['delivery_longitude'] ?? order['deliveryLongitude']);

  // Some APIs might return a nested pin object.
  final pin = order['delivery_pin'] ?? order['delivery_location'] ?? order['customer_pin'];
  if ((lat == null || lng == null) && pin is Map) {
    final lat2 = d(pin['lat'] ?? pin['latitude']);
    final lng2 = d(pin['lng'] ?? pin['longitude'] ?? pin['long']);
    return _DeliveryLocation(lat: lat2, lng: lng2, address: address);
  }

  return _DeliveryLocation(lat: lat, lng: lng, address: address);
}

_RiderInfo _riderInfo(Map<String, dynamic> order) {
  double? d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Map? asMap(dynamic v) => v is Map ? v : null;

  final rider = asMap(order['rider']) ?? asMap(order['rider_profile']) ?? asMap(order['riderProfile']) ?? asMap(order['assigned_rider']);
  if (rider == null) return const _RiderInfo(assigned: false);

  final name = rider['name']?.toString() ??
      (asMap(rider['user'])?['name']?.toString()) ??
      (asMap(order['rider_user'])?['name']?.toString());
  final phone = rider['phone']?.toString() ??
      (asMap(rider['user'])?['phone']?.toString()) ??
      (asMap(order['rider_user'])?['phone']?.toString());

  // Location might be directly on rider or nested rider_location.
  final loc = asMap(order['rider_location']) ?? asMap(rider['location']) ?? asMap(rider['rider_location']);
  final lat = d(loc?['lat'] ?? loc?['latitude'] ?? rider['lat'] ?? rider['latitude']);
  final lng = d(loc?['lng'] ?? loc?['longitude'] ?? loc?['long'] ?? rider['lng'] ?? rider['longitude'] ?? rider['long']);

  return _RiderInfo(assigned: true, name: name, phone: phone, lat: lat, lng: lng);
}
