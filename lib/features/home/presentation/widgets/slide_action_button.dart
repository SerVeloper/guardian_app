import 'package:flutter/material.dart';

class SlideActionButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final Color knobColor;
  final Color iconColor;
  final VoidCallback onSubmit;
  final double height;
  final double borderRadius;
  final IconData icon;
  final Duration resetDuration;
  final bool enabled;

  const SlideActionButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.onSubmit,
    this.knobColor = Colors.white,
    this.iconColor = Colors.black,
    this.height = 52,
    this.borderRadius = 12,
    this.icon = Icons.keyboard_double_arrow_right,
    this.resetDuration = const Duration(milliseconds: 250),
    this.enabled = true,
  });

  @override
  State<SlideActionButton> createState() => _SlideActionButtonState();
}

class _SlideActionButtonState extends State<SlideActionButton> {
  double _dragPosition = 0;
  double _maxDrag = 0;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double knobSize = widget.height - 8;
        _maxDrag = width - knobSize - 8;

        return SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: widget.enabled ? 1 : 0.6,
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _submitted
                    ? const Duration(milliseconds: 120)
                    : widget.resetDuration,
                curve: Curves.easeOut,
                left: _dragPosition + 4,
                top: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: widget.enabled ? (details) {
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > _maxDrag) _dragPosition = _maxDrag;
                    });
                  } : null,
                  onHorizontalDragEnd: widget.enabled ? (_) async {
                    final bool shouldSubmit = _dragPosition > _maxDrag * 0.8;

                    if (shouldSubmit) {
                      setState(() {
                        _dragPosition = _maxDrag;
                        _submitted = true;
                      });

                      widget.onSubmit();

                      await Future.delayed(const Duration(milliseconds: 200));

                      if (!mounted) return;

                      setState(() {
                        _dragPosition = 0;
                        _submitted = false;
                      });
                    } else {
                      setState(() {
                        _dragPosition = 0;
                        _submitted = false;
                      });
                    }
                  } : null,
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: widget.knobColor,
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius - 4,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}