import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secondary_screen/secondary_screen.dart';

import 'models/order_item_model.dart';
import 'models/product_model.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<OrderItem> _orderItems = [];
  late final SecondaryScreenCubit _cubit = context.read<SecondaryScreenCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.init(autoShow: true, defaultRouterName: 'presentation');
  }

  int get _total => _orderItems.fold(0, (sum, item) => sum + item.subtotal);

  String _buildOrderPayload() {
    final payload = TransferDataModel(
      eventName: 'update_order',
      data: {
        'items': _orderItems.map((e) => e.toJson()).toList(),
        'total': _total,
      },
    );
    return jsonEncode(payload.toJson());
  }

  void _addProduct(Product product) {
    final wasEmpty = _orderItems.isEmpty;

    setState(() {
      final existing =
          _orderItems.where((i) => i.product.id == product.id).firstOrNull;
      if (existing != null) {
        existing.quantity++;
      } else {
        _orderItems.add(OrderItem(product: product));
      }
    });

    final payload = _buildOrderPayload();
    if (wasEmpty) {
      _cubit.showOnSecondary('order_display', json: payload);
    } else {
      _cubit.updateDataOnSecondary(payload);
    }
  }

  void _removeItem(int index) {
    setState(() => _orderItems.removeAt(index));

    if (_orderItems.isEmpty) {
      _cubit.showOnSecondary('presentation');
    } else {
      _cubit.updateDataOnSecondary(_buildOrderPayload());
    }
  }

  void _checkout() {
    setState(() => _orderItems.clear());
    _cubit.showOnSecondary('presentation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          Expanded(flex: 6, child: _buildProductGrid()),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(flex: 4, child: _buildOrderPanel()),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Menu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: Product.catalog.length,
            itemBuilder: (context, index) {
              final product = Product.catalog[index];
              return _ProductCard(
                product: product,
                onTap: () => _addProduct(product),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderPanel() {
    return Column(
      children: [
        _buildConnectionBadge(),
        const Divider(height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_orderItems.isNotEmpty)
                TextButton(
                  onPressed: _checkout,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _orderItems.isEmpty
              ? const Center(
                  child: Text(
                    'No products added',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: _orderItems.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 1),
                  itemBuilder: (context, index) {
                    final item = _orderItems[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        '${item.product.emoji} ${item.product.name}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${item.quantity} × ${_formatPrice(item.product.price)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatPrice(item.subtotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                _formatPrice(_total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _orderItems.isEmpty ? null : _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionBadge() {
    return BlocBuilder<SecondaryScreenCubit, SecondaryScreenState>(
      builder: (context, state) {
        final isConnected =
            state.status == SecondaryScreenServiceState.connected;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConnected
                    ? 'Secondary display: Connected'
                    : 'Secondary display: Disconnected',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} VND';
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${product.price ~/ 1000}K VND',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
