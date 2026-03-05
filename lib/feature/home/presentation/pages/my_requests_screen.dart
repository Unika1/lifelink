import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/home/presentation/state/home_state.dart';
import 'package:lifelink/feature/home/presentation/view_model/home_view_model.dart';
import 'package:lifelink/theme/app_theme.dart';

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final items = homeState.myRequests;

    Widget content;
    if (items.isNotEmpty) {
      content = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final statusColor = _statusColor(item.status);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (homeState.status == HomeStatus.loading) {
      content = const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    } else if (homeState.status == HomeStatus.error) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(homeState.errorMessage ?? 'Error loading'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(homeViewModelProvider.notifier).loadRequests();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      content = const Center(child: Text('No requests yet'));
    }

    // Show list (or empty state)
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(homeViewModelProvider.notifier).loadRequests();
            },
          ),
        ],
      ),
      body: content,
    );
  }

  Color _statusColor(String status) {
    if (status == 'approved') return Colors.green;
    if (status == 'rejected') return Colors.red;
    return Colors.grey;
  }

  String _statusLabel(String status) {
    if (status == 'approved') return 'Approved';
    if (status == 'rejected') return 'Rejected';
    return status;
  }
}