// lib/features/camera/domain/models/measurement.dart

class Measurement {
  final double width;
  final double height;
  final double depth;
  final String objectType;
  final double confidence;
  final DateTime timestamp;
  static const String currentDateTime = '2025-02-06 16:09:21';
  static const String currentUser = 'surajgore-007';

  Measurement({
    required this.width,
    required this.height,
    required this.depth,
    required this.objectType,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'depth': depth,
      'objectType': objectType,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'user': currentUser,
    };
  }

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      depth: (json['depth'] as num).toDouble(),
      objectType: json['objectType'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Measurement copyWith({
    double? width,
    double? height,
    double? depth,
    String? objectType,
    double? confidence,
    DateTime? timestamp,
  }) {
    return Measurement(
      width: width ?? this.width,
      height: height ?? this.height,
      depth: depth ?? this.depth,
      objectType: objectType ?? this.objectType,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'Measurement(width: $width, height: $height, depth: $depth, '
        'objectType: $objectType, confidence: $confidence, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Measurement &&
        other.width == width &&
        other.height == height &&
        other.depth == depth &&
        other.objectType == objectType &&
        other.confidence == confidence &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return width.hashCode ^
        height.hashCode ^
        depth.hashCode ^
        objectType.hashCode ^
        confidence.hashCode ^
        timestamp.hashCode;
  }
}
