import 'package:uuid/uuid.dart';

enum OrderSource { whatsapp, voice, email, image, manual }

enum OrderStatus { pending, processing, completed, cancelled }

class OrderItem {
  final String id;
  final String skuName;
  final int quantity;
  final double? unitPrice;
  final String? notes;
  final BoundingBox? boundingBox;
  final double? confidence;
  final bool isUserCorrected;

  OrderItem({
    String? id,
    required this.skuName,
    required this.quantity,
    this.unitPrice,
    this.notes,
    this.boundingBox,
    this.confidence,
    this.isUserCorrected = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skuName': skuName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'notes': notes,
      'boundingBox': boundingBox?.toJson(),
      'confidence': confidence,
      'isUserCorrected': isUserCorrected,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      skuName: json['skuName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      notes: json['notes'],
      boundingBox: json['boundingBox'] != null
          ? BoundingBox.fromJson(json['boundingBox'])
          : null,
      confidence: json['confidence'],
      isUserCorrected: json['isUserCorrected'] ?? false,
    );
  }

  OrderItem copyWith({
    String? skuName,
    int? quantity,
    double? unitPrice,
    String? notes,
    BoundingBox? boundingBox,
    double? confidence,
    bool? isUserCorrected,
  }) {
    return OrderItem(
      id: id,
      skuName: skuName ?? this.skuName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
      boundingBox: boundingBox ?? this.boundingBox,
      confidence: confidence ?? this.confidence,
      isUserCorrected: isUserCorrected ?? this.isUserCorrected,
    );
  }
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'width': width, 'height': height};
  }

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
    );
  }
}

class Order {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final OrderSource source;
  final OrderStatus status;
  final String? customerName;
  final String? customerContact;
  final List<OrderItem> items;
  final String? originalText;
  final String? imagePath;
  final String? audioPath;
  final String? notes;
  final Map<String, dynamic>? metadata;

  Order({
    String? id,
    DateTime? createdAt,
    this.updatedAt,
    required this.source,
    this.status = OrderStatus.pending,
    this.customerName,
    this.customerContact,
    this.items = const [],
    this.originalText,
    this.imagePath,
    this.audioPath,
    this.notes,
    this.metadata,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  double get totalAmount {
    return items.fold(0.0, (total, item) {
      return total + ((item.unitPrice ?? 0.0) * item.quantity);
    });
  }

  int get totalItems {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'source': source.name,
      'status': status.name,
      'customerName': customerName,
      'customerContact': customerContact,
      'items': items.map((item) => item.toJson()).toList(),
      'originalText': originalText,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      source: OrderSource.values.byName(json['source']),
      status: OrderStatus.values.byName(json['status']),
      customerName: json['customerName'],
      customerContact: json['customerContact'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      originalText: json['originalText'],
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      notes: json['notes'],
      metadata: json['metadata'],
    );
  }

  Order copyWith({
    OrderStatus? status,
    String? customerName,
    String? customerContact,
    List<OrderItem>? items,
    String? originalText,
    String? imagePath,
    String? audioPath,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      source: source,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerContact: customerContact ?? this.customerContact,
      items: items ?? this.items,
      originalText: originalText ?? this.originalText,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }
}
