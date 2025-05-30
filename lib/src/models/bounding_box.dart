/// Represents a bounding box for detected text elements.
///
/// Coordinates are normalized (0.0 to 1.0) relative to the image dimensions.
/// Origin (0,0) is at the top-left corner of the image.
class BoundingBox {
  /// The x-coordinate of the left edge (0.0 to 1.0)
  final double x;

  /// The y-coordinate of the top edge (0.0 to 1.0)
  final double y;

  /// The width of the bounding box (0.0 to 1.0)
  final double width;

  /// The height of the bounding box (0.0 to 1.0)
  final double height;

  /// Creates a bounding box with normalized coordinates.
  ///
  /// All parameters should be between 0.0 and 1.0.
  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Creates a BoundingBox from a map representation.
  factory BoundingBox.fromMap(Map<String, dynamic> map) {
    return BoundingBox(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
    );
  }

  /// Converts the bounding box to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  /// The x-coordinate of the right edge
  double get right => x + width;

  /// The y-coordinate of the bottom edge
  double get bottom => y + height;

  /// The center point of the bounding box
  ({double x, double y}) get center => (x: x + width / 2, y: y + height / 2);

  /// Converts normalized coordinates to absolute coordinates based on image size.
  ///
  /// [imageWidth] and [imageHeight] are the actual dimensions of the image.
  BoundingBox toAbsolute(double imageWidth, double imageHeight) {
    return BoundingBox(
      x: x * imageWidth,
      y: y * imageHeight,
      width: width * imageWidth,
      height: height * imageHeight,
    );
  }

  /// Checks if this bounding box contains the given point.
  ///
  /// [pointX] and [pointY] should be in the same coordinate system as this box.
  bool contains(double pointX, double pointY) {
    return pointX >= x && pointX <= right && pointY >= y && pointY <= bottom;
  }

  /// Calculates the intersection area with another bounding box.
  ///
  /// Returns 0.0 if the boxes don't overlap.
  double intersectionArea(BoundingBox other) {
    final left = x > other.x ? x : other.x;
    final top = y > other.y ? y : other.y;
    final right = this.right < other.right ? this.right : other.right;
    final bottom = this.bottom < other.bottom ? this.bottom : other.bottom;

    if (left < right && top < bottom) {
      return (right - left) * (bottom - top);
    }
    return 0.0;
  }

  @override
  String toString() {
    return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoundingBox &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode {
    return Object.hash(x, y, width, height);
  }
}
