import 'package:flutter/material.dart';
import 'package:velo_core/velo_core.dart';

class SlideToShip extends StatefulWidget {
  const SlideToShip({super.key, required this.onComplete});
  final Future<void> Function() onComplete;

  @override
  State<SlideToShip> createState() => _SlideToShipState();
}

class _SlideToShipState extends State<SlideToShip> {
  double _drag = 0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final max = constraints.maxWidth - 56;
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text('Slide to mark ready to ship', style: TextStyle(fontWeight: FontWeight.w600)),
              Positioned(
                left: _drag.clamp(0, max),
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => setState(() => _drag += d.delta.dx),
                  onHorizontalDragEnd: (_) async {
                    if (_drag >= max * 0.85 && !_done) {
                      setState(() => _done = true);
                      await widget.onComplete();
                    } else {
                      setState(() => _drag = 0);
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.double_arrow, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
