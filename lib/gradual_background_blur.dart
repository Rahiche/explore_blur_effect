import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class GradualBackgroundBlur extends StatefulWidget {
  @override
  _GradualBackgroundBlurState createState() => _GradualBackgroundBlurState();
}

class _GradualBackgroundBlurState extends State<GradualBackgroundBlur> {
  bool isClipped = true;
  ScrollController _scrollController = ScrollController();

  double blurSigma = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    Future.delayed(Duration(seconds: 1)).then((value) {
      _scrollController.animateTo(
        300,
        duration: Duration(seconds: 1),
        curve: Curves.linear,
      );
    });
  }

  void _onScroll() {
    const maxBlur = 8.0;
    const scrollThreshold = 200.0;

    if (_scrollController.offset < scrollThreshold) {
      // Calculate blurSigma based on scroll position
      setState(() {
        blurSigma = maxBlur * (_scrollController.offset / scrollThreshold);
        if (blurSigma == maxBlur) {}
      });
      print("blurSigma ${blurSigma}");
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // Remove listener
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return SizedBox(
                        height: 100,
                      );
                    }
                    if (index == 1) {
                      return Container(
                        child: Image.asset(
                          'assets/rg.jpg',
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return ListTile(
                      title: Text(index.toString()),
                    );
                  },
                ),
              ),
            ],
          ),
          if (isClipped)
            Align(
              alignment: Alignment.topCenter,
              child: ClipRect(
                child: Container(
                  height: 120,
                  width: double.infinity,
                  child: BackdropFilter(
                    filter:
                        ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Switch.adaptive(
                value: isClipped,
                onChanged: (value) {
                  setState(() {
                    isClipped = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );

    if (isClipped) {
      return child;
    } else {
      return TiltShift(
        child: child,
        progress: blurSigma,
      );
    }
  }
}

class TiltShift extends StatelessWidget {
  const TiltShift({Key? key, required this.child, required this.progress})
      : super(key: key);

  final Widget child;
  final double progress;
  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader.setFloat(0, size.width);
            shader.setFloat(1, size.height);
            shader.setFloat(2, progress);

            shader.setImageSampler(0, image);
            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Paint()..shader = shader,
            );
          },
          child: child,
        );
      },
      assetKey: 'shaders/tilt_shift_gaussian.frag',
    );
  }
}
