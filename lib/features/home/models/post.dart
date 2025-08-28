import 'package:image_picker/image_picker.dart';

enum TradeType { sell, share }

class PostDraft {
  PostDraft({
    required this.title,
    this.content,
    List<XFile>? images,
    this.price,
    required this.tradeType,
  }) : images = images ?? [];

  String title;
  String? content;
  List<XFile> images;
  double? price;
  TradeType tradeType;
}

class Post {
  Post({
    required this.id,
    required this.title,
    this.content,
    this.imageUrls = const [],
    this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.tradeType,
  });

  final String id;
  final String title;
  final String? content;
  final List<String> imageUrls;
  final double? price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TradeType tradeType;

  Post copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? imageUrls,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    TradeType? tradeType,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tradeType: tradeType ?? this.tradeType,
    );
  }
}
