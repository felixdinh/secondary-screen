import 'package:flutter/material.dart';
import 'package:secondary_screen/secondary_screen/secondary_screen.dart';

import 'models/order_item_model.dart';

class OrderDisplayScreen extends StatefulWidget {
  const OrderDisplayScreen({super.key});

  @override
  State<OrderDisplayScreen> createState() => _OrderDisplayScreenState();
}

class _OrderDisplayScreenState extends State<OrderDisplayScreen> {
  List<OrderItem> _items = [];
  int _total = 0;

  void _onDataReceived(dynamic args) {
    if (args is! Map) return;
    final map = Map<String, dynamic>.from(args);
    if (!map.containsKey('event_name') || !map.containsKey('data')) return;

    final eventName = map['event_name'] as String?;
    final data = map['data'];

    if (eventName == 'update_order' && data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final rawItems = dataMap['items'] as List?;
      if (rawItems == null) return;
      setState(() {
        _items = rawItems
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _total = (dataMap['total'] as num).toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryDisplay(
      callback: _onDataReceived,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildItemsList()),
            _buildTotalRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      color: const Color(0xFF16213E),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '☕ Corner Coffee Shop',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Thank you for visiting!',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'Welcome!',
          style: TextStyle(fontSize: 32, color: Colors.white54),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
          child: Row(
            children: const [
              Expanded(
                flex: 4,
                child: Text(
                  'PRODUCT',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'QTY × PRICE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'SUBTOTAL',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white24, height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            itemCount: _items.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${item.quantity} × ${_fmt(item.product.price)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _fmt(item.subtotal),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      color: const Color(0xFF0F3460),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _fmt(_total),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} VND';
  }
}
