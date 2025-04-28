import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ImageHealthBarWidget extends StatefulWidget {
  final int currentHealth;
  final int maxHealth;
  final double? width;
  final double? height;

  const ImageHealthBarWidget({
    super.key,
    required this.currentHealth,
    required this.maxHealth,
    this.width,
    this.height,
  });

  @override
  State<ImageHealthBarWidget> createState() => _ImageHealthBarWidgetState();
}

class _ImageHealthBarWidgetState extends State<ImageHealthBarWidget> {
  ui.Image? _spritesheet;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSpritesheet();
  }

  Future<void> _loadSpritesheet() async {
    try {
      // Use AssetImage to load the spritesheet
      final imageProvider = AssetImage('assets/images/ui/hp_bar/hp_bar_spritesheet.png');
      final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
      
      final completer = Completer<ui.Image>();
      final listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
        },
        onError: (exception, stackTrace) {
          setState(() {
            _isLoading = false;
            _errorMessage = exception.toString();
          });
        },
      );
      
      stream.addListener(listener);
      
      final image = await completer.future;
      setState(() {
        _spritesheet = image;
        _isLoading = false;
      });
      
      stream.removeListener(listener);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height ?? 20,
        child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    
    if (_spritesheet == null) {
      return Container(
        width: widget.width,
        height: widget.height ?? 20,
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text('Error: $_errorMessage', 
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
      );
    }
    
    final current = widget.currentHealth.clamp(0, widget.maxHealth);
    final percentage = (widget.maxHealth <= 0) ? 0.0 : (current / widget.maxHealth).clamp(0.0, 1.0);
    // Calculate index: 0 is full, 8 is empty
    final index = (8 - (percentage * 8)).round().clamp(0, 8);
    
    // Constants from the JSON for frame dimensions
    const frameWidth = 3540.0;
    const frameHeight = 385.0;
    
    return CustomPaint(
      size: Size(widget.width ?? 120, (widget.height ?? (widget.width ?? 120) * (frameHeight/frameWidth))),
      painter: _HealthBarPainter(
        spritesheet: _spritesheet!,
        index: index,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
      ),
    );
  }
}

class _HealthBarPainter extends CustomPainter {
  final ui.Image spritesheet;
  final int index;
  final double frameWidth;
  final double frameHeight;
  
  _HealthBarPainter({
    required this.spritesheet,
    required this.index,
    required this.frameWidth,
    required this.frameHeight,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      index * frameWidth, // x position in spritesheet
      0,                  // y position (always top row)
      frameWidth,         // width of a frame
      frameHeight,        // height of a frame
    );
    
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Draw the specific frame from the spritesheet
    canvas.drawImageRect(spritesheet, src, dst, Paint());
  }
  
  @override
  bool shouldRepaint(covariant _HealthBarPainter oldDelegate) {
    return oldDelegate.index != index;
  }
}
