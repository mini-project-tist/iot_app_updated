import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_meter/components/slide_dots.dart';
import 'package:smart_meter/components/slideitem.dart';
import 'package:smart_meter/model/slide.dart';
import '/constants.dart';
import '/screens/login_page.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home_page';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentpage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentpage < slideList.length - 1) {
        _currentpage++;
      } else {
        _currentpage = 0;
      }
      _pageController.animateToPage(
        _currentpage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentpage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: kBoxDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 100),
              SizedBox(
                height: 400, // Increased height to allow space for dots
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        onPageChanged: _onPageChanged,
                        scrollDirection: Axis.horizontal,
                        controller: _pageController,
                        itemCount: slideList.length,
                        itemBuilder: (ctx, i) => SlideItem(index: i),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < slideList.length; i++)
                          SlideDots(isActive: i == _currentpage),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// **Get Started Button**
              GradientElevatedButton(
                style: GradientElevatedButton.styleFrom(
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundGradient: buttonGradient,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, LoginPage.id);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
