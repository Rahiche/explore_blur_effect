import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

enum ViewMode { grid, list }

class BlurListScreen extends StatefulWidget {
  @override
  State<BlurListScreen> createState() => _BlurListScreenState();
}

class _BlurListScreenState extends State<BlurListScreen> {
  final List<Map<String, dynamic>> blurData = [
    {'name': 'box', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'gaussian', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'lens', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'mean', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'motion', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'radial', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'shape', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'smart', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'surface', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'tilt_shift', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'glass', 'imageUrl': 'URL_OF_IMAGE_2'},
    {'name': 'flutter', 'imageUrl': 'URL_OF_IMAGE_2'},
  ];
  ViewMode _currentView = ViewMode.grid;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blur Examples'),
        actions: [
          IconButton(
            icon: Icon(_currentView == ViewMode.grid
                ? Icons.view_list
                : Icons.view_module),
            onPressed: () {
              setState(() {
                _currentView = _currentView == ViewMode.grid
                    ? ViewMode.list
                    : ViewMode.grid;
              });
            },
          )
        ],
      ),
      body: _currentView == ViewMode.grid
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.1,
              ),
              itemCount: blurData.length,
              itemBuilder: _buildItem,
            )
          : SafeArea(
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: blurData.length,
                    controller: _pageController, // Use the PageController here
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(blurData[index]["name"]),
                            Expanded(
                              child: EffectContent(
                                name: blurData[index]["name"],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // 3. Use the Stack widget to overlay the FABs over the PageView
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlurDetailScreen(
              blur: blurData[index],
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: EffectContent(
                name: blurData[index]["name"],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(blurData[index]['name']),
            ),
          ],
        ),
      ),
    );
  }
}

class BlurDetailScreen extends StatefulWidget {
  final Map<String, dynamic> blur;

  BlurDetailScreen({required this.blur});

  @override
  State<BlurDetailScreen> createState() => _BlurDetailScreenState();
}

class _BlurDetailScreenState extends State<BlurDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blur['name']),
      ),
      body: EffectContent(name: widget.blur['name']),
    );
  }
}

class EffectContent extends StatefulWidget {
  const EffectContent({
    Key? key,
    required this.name,
  }) : super(key: key);

  final String name;

  @override
  State<EffectContent> createState() => _EffectContentState();
}

class _EffectContentState extends State<EffectContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
      reverseDuration: const Duration(seconds: 30),
    );

    _animation = Tween<double>(begin: 0, end: 10).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    if (widget.name == "motion") {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.name == "flutter") {
      return ClipRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
          child: Image.asset(
            "assets/rg.jpg",
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: ShaderBuilder(
        (context, shader, child) {
          return AnimatedSampler(
            (image, size, canvas) {
              shader.setFloat(0, size.width);
              shader.setFloat(1, size.height);
              if (widget.name == "motion") {
                shader.setFloat(2, _animation.value);
              }
              // Here you can use _animation.value where you need it.
              // Example: shader.setFloat(3, _animation.value);

              shader.setImageSampler(0, image);

              canvas.drawRect(
                Rect.fromLTWH(0, 0, size.width, size.height),
                Paint()..shader = shader,
              );
            },
            child: Image.asset(
              "assets/rg.jpg",
              fit: BoxFit.cover,
            ),
          );
        },
        assetKey: 'shaders/${widget.name}.frag',
      ),
    );
  }
}
