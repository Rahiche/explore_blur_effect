import 'package:flutter/material.dart';
import 'package:explore_blur_effect/blur_examples.dart';
import 'package:explore_blur_effect/gradual_background_blur.dart';
import 'package:explore_blur_effect/interactive_explainer.dart';
import 'package:explore_blur_effect/name_drop.dart';

void main() {
  runApp(BlurGallery());
}

class BlurGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text('Blur Effect Demo')),
          body: GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(8),
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BlurListScreen()),
                  );
                },
                child: buildContent("Types of Blurs"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NameDropIOS17()),
                  );
                },
                child: buildContent("Name Drop iOS 17"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GradualBackgroundBlur()),
                  );
                },
                child: buildContent("Gradual Background Blur"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InteractiveBlurExplainerPage()),
                  );
                },
                child: buildContent("Interactive Blur Explainer"),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildContent(String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
