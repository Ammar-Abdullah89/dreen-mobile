import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  const radius = 200;
  final background = img.ColorRgb8(0x1A, 0x23, 0x7E);

  final image = img.Image(width: size, height: size);

  // Fill with rounded rect background
  img.fill(image, color: background);

  // Draw rounded rect manually
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      // Check if pixel is outside rounded corners
      bool outside = false;
      if (x < radius && y < radius) {
        if ((x - radius) * (x - radius) + (y - radius) * (y - radius) > radius * radius) {
          outside = true;
        }
      } else if (x < radius && y >= size - radius) {
        if ((x - radius) * (x - radius) + (y - (size - radius)) * (y - (size - radius)) > radius * radius) {
          outside = true;
        }
      } else if (x >= size - radius && y < radius) {
        if ((x - (size - radius)) * (x - (size - radius)) + (y - radius) * (y - radius) > radius * radius) {
          outside = true;
        }
      } else if (x >= size - radius && y >= size - radius) {
        if ((x - (size - radius)) * (x - (size - radius)) + (y - (size - radius)) * (y - (size - radius)) > radius * radius) {
          outside = true;
        }
      }
      if (outside) {
        image.setPixelRgba(x, y, 0, 0, 0, 0); // transparent
      }
    }
  }

  // Draw letter D (simple pixel approximation)
  final white = img.ColorRgb8(255, 255, 255);
  // Very basic D letter using a filled rectangle + semi-circle approximation
  final cx = size ~/ 2;
  final cy = size ~/ 2;
  final letterW = 300;
  final letterH = 600;

  // Vertical bar of D
  for (int y = cy - letterH ~/ 2; y < cy + letterH ~/ 2; y++) {
    for (int x = cx - letterW ~/ 2; x < cx - letterW ~/ 2 + 100; x++) {
      if (x >= 0 && x < size && y >= 0 && y < size) {
        image.setPixel(x, y, white);
      }
    }
  }

  // Curved part of D (half circle on right side)
  for (int y = cy - letterH ~/ 2; y < cy + letterH ~/ 2; y++) {
    for (int x = cx - letterW ~/ 2 + 100; x < cx + letterW ~/ 2; x++) {
      final dx = x - (cx - letterW ~/ 2 + 100);
      final dy = y - cy;
      final maxDx = letterW ~/ 2 - 100;
      final halfH = letterH ~/ 2;
      // Ellipse: (dx/maxDx)^2 + (dy/halfH)^2 <= 1
      if (dx >= 0 && (dx * dx) / (maxDx * maxDx) + (dy * dy) / (halfH * halfH) <= 1.0) {
        if (x >= 0 && x < size && y >= 0 && y < size) {
          image.setPixel(x, y, white);
        }
      }
    }
  }

  final png = img.encodePng(image);
  final file = File('assets/logo.png');
  file.writeAsBytesSync(png);
  print('Icon generated: assets/logo.png');
}
