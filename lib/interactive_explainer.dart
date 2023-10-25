import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(BlurInteractiveExplainer());
}

class BlurInteractiveExplainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaussian Blur Simulation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InteractiveBlurExplainerPage(),
    );
  }
}

class InteractiveBlurExplainerPage extends StatefulWidget {
  @override
  _InteractiveBlurExplainerPageState createState() =>
      _InteractiveBlurExplainerPageState();
}

class _InteractiveBlurExplainerPageState
    extends State<InteractiveBlurExplainerPage> {
  int gridSize = 5;
  double sigma = 1.0;
  List<List<Color>> gridColors = [];
  List<List<Color>> blurredGridColors = [];
  Offset? kernelPosition;
  bool showKernel = false;
  Timer? _timer;
  int _currentIndex = 0;

  final GaussianBlurSimulation simulation = GaussianBlurSimulation();

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    simulation.setKernel(3, sigma);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      int x = _currentIndex % gridSize;
      int y = _currentIndex ~/ gridSize;

      kernelPosition = Offset(
          x * (fullWidth / gridSize) + (fullWidth / gridSize) / 2,
          y * (fullHeight / gridSize) + (fullHeight / gridSize) / 2);
      showKernel = true;
      setState(() {});

      _currentIndex++;
      if (_currentIndex >= gridSize * gridSize) {
        _timer?.cancel(); // Stop the timer when all items have been processed
      }
      applyEffect(x, y);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _initializeGrid() {
    gridColors = List.generate(gridSize, (i) {
      return List.generate(gridSize, (j) {
        return generateRandomColor();
      });
    });

    blurredGridColors = List.generate(gridSize, (i) {
      return List.generate(gridSize, (j) {
        return Colors.white;
      });
    });
  }

  void onClickGridItem(int x, int y) {
    setState(() {
      kernelPosition = Offset(
          x * (fullWidth / gridSize) + (fullWidth / gridSize) / 2,
          y * (fullHeight / gridSize) + (fullHeight / gridSize) / 2);
      showKernel = !showKernel;
    });
  }

  void onDoubleTapGridItem(int x, int y) {
    applyEffect(x, y);
  }

  void applyEffect(int x, int y) {
    setState(() {
      final list = [
        ...simulation.applyGaussianBlur(List.of(gridColors), x, y, gridSize)
      ];
      blurredGridColors[x][y] = list[x][y];

      // showKernel = false; // Hide kernel after applying Gaussian blur
      kernelPosition = Offset(
          x * (fullWidth / gridSize) + (fullWidth / gridSize) / 2,
          y * (fullHeight / gridSize) + (fullHeight / gridSize) / 2);
    });
  }

  final double fullWidth = 200.0;
  final double fullHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gaussian Blur Simulation'),
        actions: [
          FloatingActionButton.small(
            heroTag: "1",
            onPressed: () => _startTimer(),
            child: Icon(Icons.play_circle),
          ),
          FloatingActionButton.small(
            heroTag: "2",
            onPressed: () {
              if (_timer?.isActive == true) {
                _timer?.cancel();
              }
            },
            child: Icon(Icons.stop),
          ),
          FloatingActionButton.small(
            heroTag: "3",
            onPressed: () {
              _currentIndex = 0;
              blurredGridColors = List.generate(gridSize, (i) {
                return List.generate(gridSize, (j) {
                  return Colors.white;
                });
              });
              if (_timer?.isActive == true) {
                _timer?.cancel();
              }
              _startTimer();
              setState(() {});
            },
            child: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildGrid(gridColors),
          ),
          Slider(
            value: sigma,
            onChanged: (value) {
              setState(() {
                sigma = value;
                simulation.setKernel(3, sigma);
              });
            },
            min: 0.1,
            max: 10.0,
            divisions: 100,
            label: 'Sigma: ${sigma.toStringAsFixed(1)}',
          ),
          Expanded(
            child: _buildGrid(blurredGridColors),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<List<Color>> colors) {
    return Center(
      child: SizedBox(
        width: fullWidth,
        height: fullHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int x = index % gridSize;
                int y = index ~/ gridSize;
                return GestureDetector(
                  onTap: () {
                    onClickGridItem(x, y);
                  },
                  onDoubleTap: () {
                    onDoubleTapGridItem(x, y);
                  },
                  child: Container(
                    color: colors[x][y],
                  ),
                );
              },
            ),
            if (showKernel)
              KernelOverlay(
                kernelPosition: kernelPosition!,
                gridSize: gridSize,
                kernelSize: simulation.kernel.length,
                kernel: simulation.kernel,
                fullWidth: fullWidth,
                fullHeight: fullHeight,
                onTap: () {
                  setState(() {
                    showKernel = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Color generateRandomColor() {
    return Color.fromARGB(
      255,
      math.Random().nextInt(256),
      math.Random().nextInt(256),
      math.Random().nextInt(256),
    );
  }
}

class KernelOverlay extends StatelessWidget {
  final Offset kernelPosition;
  final int gridSize;
  final int kernelSize;
  final List<List<double>> kernel;
  final double fullWidth;
  final double fullHeight;
  final VoidCallback onTap;

  KernelOverlay({
    required this.kernelPosition,
    required this.gridSize,
    required this.kernelSize,
    required this.kernel,
    required this.fullWidth,
    required this.fullHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            child: Container(color: Colors.white54),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 200),
          left: kernelPosition.dx - (fullWidth / gridSize * kernelSize) / 2,
          top: kernelPosition.dy - (fullHeight / gridSize * kernelSize) / 2,
          child: Opacity(
            opacity: 0.9,
            child: Container(
              width: fullWidth / gridSize * kernelSize,
              height: fullHeight / gridSize * kernelSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: kernelSize,
                ),
                itemCount: kernelSize * kernelSize,
                itemBuilder: (context, index) {
                  int i = index % kernelSize;
                  int j = index ~/ kernelSize;
                  return Container(
                    color: Colors.black38,
                    child: Center(
                      child: Text(
                        kernel[i][j].toStringAsFixed(2),
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GridViewWidget extends StatelessWidget {
  final int gridSize;
  final List<List<Color>> gridColors;
  final Function(int x, int y) onClickGridItem;
  final Function(int x, int y) onDoubleTapGridItem;

  GridViewWidget({
    required this.gridSize,
    required this.gridColors,
    required this.onClickGridItem,
    required this.onDoubleTapGridItem,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        int x = index % gridSize;
        int y = index ~/ gridSize;
        return GestureDetector(
          onTap: () {
            onClickGridItem(x, y);
          },
          onDoubleTap: () {
            onDoubleTapGridItem(x, y);
          },
          child: Container(
            color: gridColors[x][y],
          ),
        );
      },
    );
  }
}

class GaussianBlurSimulation {
  List<List<double>> kernel = [];

  void setKernel(int size, double sigma) {
    kernel = _createGaussianKernel(size, sigma);
  }

  List<List<double>> _createGaussianKernel(int size, double sigma) {
    List<List<double>> kernel =
        List.generate(size, (_) => List.filled(size, 0.0));
    double twoSigmaSquare = 2 * sigma * sigma;
    double sum = 0.0;

    for (int x = -size ~/ 2; x <= size ~/ 2; x++) {
      for (int y = -size ~/ 2; y <= size ~/ 2; y++) {
        kernel[x + size ~/ 2][y + size ~/ 2] =
            (math.exp(-(x * x + y * y) / twoSigmaSquare) /
                (math.pi * twoSigmaSquare));
        sum += kernel[x + size ~/ 2][y + size ~/ 2];
      }
    }

    // Normalize the kernel
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        kernel[i][j] /= sum;
      }
    }

    return kernel;
  }

  List<List<Color>> applyGaussianBlur(
      List<List<Color>> gridColors, int x, int y, int gridSize) {
    if (kernel.isEmpty) return gridColors;

    List<List<Color>> newGridColors =
        List.generate(gridSize, (i) => List.from(gridColors[i]));

    if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) {
      return newGridColors;
    }

    newGridColors[x][y] = _applyKernelToPixel(
      gridColors,
      x,
      y,
      gridSize,
      kernel,
      kernel.length,
    );

    return newGridColors;
  }

  Color _applyKernelToPixel(
    List<List<Color>> gridColors,
    int x,
    int y,
    int gridSize,
    List<List<double>> kernel,
    int kernelSize,
  ) {
    int halfKernelSize = kernelSize ~/ 2;

    double red = 0.0, green = 0.0, blue = 0.0;
    for (int i = -halfKernelSize; i <= halfKernelSize; i++) {
      for (int j = -halfKernelSize; j <= halfKernelSize; j++) {
        int newX = x + i;
        int newY = y + j;
        if (newX >= 0 && newX < gridSize && newY >= 0 && newY < gridSize) {
          Color pixelColor = gridColors[newX][newY];
          double kernelValue = kernel[i + halfKernelSize][j + halfKernelSize];
          red += pixelColor.red * kernelValue;
          green += pixelColor.green * kernelValue;
          blue += pixelColor.blue * kernelValue;
        }
      }
    }

    return Color.fromARGB(
      255,
      red.clamp(0, 255).toInt(),
      green.clamp(0, 255).toInt(),
      blue.clamp(0, 255).toInt(),
    );
  }
}
