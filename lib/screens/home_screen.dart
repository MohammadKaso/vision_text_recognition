import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_provider.dart';
import '../providers/media_provider.dart';
import '../providers/ai_provider.dart';
import '../models/order.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Order Inbox',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().loadOrders(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildStats(),
              const SizedBox(height: 24),
              _buildRecentOrders(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Camera',
              'Scan order',
              Icons.camera_alt,
              () => context.go('/camera'),
            ),
            _buildActionCard(
              'Voice',
              'Record order',
              Icons.mic,
              _handleVoiceRecording,
            ),
            _buildActionCard(
              'Gallery',
              'From photos',
              Icons.photo_library,
              _handleGalleryPick,
            ),
            _buildActionCard(
              'Manual',
              'Type order',
              Icons.edit,
              _handleManualEntry,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Orders',
                    orderProvider.totalOrders.toString(),
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    orderProvider.pendingOrdersCount.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    orderProvider.completedOrdersCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Total Value',
                    '\$${orderProvider.totalAmount.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 12),
            if (orderProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (orderProvider.orders.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by capturing your first order',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderProvider.orders.take(5).length,
                itemBuilder: (context, index) {
                  final order = orderProvider.orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: _getSourceIcon(order.source),
                      title: Text('Order #${order.id.substring(0, 8)}'),
                      subtitle: Text(
                        '${order.items.length} items • \$${order.totalAmount.toStringAsFixed(2)}',
                      ),
                      trailing: _getStatusChip(order.status),
                      onTap: () => context.go('/order/${order.id}'),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _getSourceIcon(OrderSource source) {
    IconData icon;
    Color color;

    switch (source) {
      case OrderSource.image:
        icon = Icons.camera_alt;
        color = Colors.blue;
        break;
      case OrderSource.voice:
        icon = Icons.mic;
        color = Colors.green;
        break;
      case OrderSource.whatsapp:
        icon = Icons.chat;
        color = Colors.green;
        break;
      case OrderSource.email:
        icon = Icons.email;
        color = Colors.orange;
        break;
      case OrderSource.manual:
        icon = Icons.edit;
        color = Colors.purple;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _getStatusChip(OrderStatus status) {
    Color color;
    String label;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case OrderStatus.processing:
        color = Colors.blue;
        label = 'Processing';
        break;
      case OrderStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
    }

    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  void _handleVoiceRecording() async {
    final mediaProvider = context.read<MediaProvider>();

    if (mediaProvider.isRecording) {
      await mediaProvider.stopRecording();
    } else {
      await mediaProvider.startRecording();
      _showRecordingDialog();
    }
  }

  void _handleGalleryPick() async {
    final mediaProvider = context.read<MediaProvider>();
    final aiProvider = context.read<AIProvider>();
    final orderProvider = context.read<OrderProvider>();

    final imageFile = await mediaProvider.pickImageFromGallery();
    if (imageFile != null) {
      final order = await aiProvider.processImageToOrder(imageFile);
      if (order != null) {
        await orderProvider.createOrder(order);
        context.go('/order/${order.id}');
      }
    }
  }

  void _handleManualEntry() {
    showDialog(context: context, builder: (context) => _ManualEntryDialog());
  }

  void _showRecordingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _RecordingDialog(),
    );
  }
}

class _RecordingDialog extends StatelessWidget {
  const _RecordingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Recording...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Speak your order clearly'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<MediaProvider>().cancelRecording();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await context.read<MediaProvider>().stopRecording();
            Navigator.of(context).pop();

            final aiProvider = context.read<AIProvider>();
            final orderProvider = context.read<OrderProvider>();
            final order = await aiProvider.processAudioToOrder();
            if (order != null) {
              await orderProvider.createOrder(order);
              context.go('/order/${order.id}');
            }
          },
          child: const Text('Stop & Process'),
        ),
      ],
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manual Order Entry'),
      content: TextField(
        controller: _textController,
        decoration: const InputDecoration(
          hintText: 'Type your order here...',
          border: OutlineInputBorder(),
        ),
        maxLines: 4,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_textController.text.isNotEmpty) {
              Navigator.of(context).pop();

              final aiProvider = context.read<AIProvider>();
              final orderProvider = context.read<OrderProvider>();
              final order = await aiProvider.processTextToOrder(
                _textController.text,
                OrderSource.manual,
              );
              if (order != null) {
                await orderProvider.createOrder(order);
                context.go('/order/${order.id}');
              }
            }
          },
          child: const Text('Process'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
