import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/database_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders({OrderStatus? status, OrderSource? source}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await DatabaseService.instance.getAllOrders(
        status: status,
        source: source,
      );
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(Order order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.instance.createOrder(order);
      _orders.insert(0, order);
      _currentOrder = order;
    } catch (e) {
      _errorMessage = 'Failed to create order: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrder(Order order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.instance.updateOrder(order);
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = order;
      }
      if (_currentOrder?.id == order.id) {
        _currentOrder = order;
      }
    } catch (e) {
      _errorMessage = 'Failed to update order: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.instance.deleteOrder(orderId);
      _orders.removeWhere((order) => order.id == orderId);
      if (_currentOrder?.id == orderId) {
        _currentOrder = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete order: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentOrder = await DatabaseService.instance.getOrder(orderId);
    } catch (e) {
      _errorMessage = 'Failed to load order: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentOrder(Order? order) {
    _currentOrder = order;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<Order> getOrdersBySource(OrderSource source) {
    return _orders.where((order) => order.source == source).toList();
  }

  int get totalOrders => _orders.length;
  int get pendingOrdersCount => getOrdersByStatus(OrderStatus.pending).length;
  int get completedOrdersCount =>
      getOrdersByStatus(OrderStatus.completed).length;

  double get totalAmount {
    return _orders.fold(0.0, (total, order) => total + order.totalAmount);
  }
}
