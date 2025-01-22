import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';
import 'package:armstrong/splash_screen/models/splash_message.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "images/wallpaper.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: size.height * 0.7,
                child: PageView.builder(
                  itemCount: onBoardData.length,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return onBoardingItems(size, index);
                  },
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (currentPage == onBoardData.length - 1) {
                    final storage = FlutterSecureStorage();
                    await storage.write(
                        key: 'onboarding_completed', value: 'true');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                      (route) => false,
                    );
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                child: Container(
                  height: 70,
                  width: size.width * 0.6,
                  decoration: BoxDecoration(
                    color: orangeContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      currentPage == onBoardData.length - 1
                          ? "Get started!"
                          : "Continue",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    onBoardData.length,
                    (index) => indicatorForSlider(index: index),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  AnimatedContainer indicatorForSlider({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: currentPage == index ? 20 : 10,
      height: 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: currentPage == index ? orangeContainer : black.withOpacity(0.2),
      ),
    );
  }

  Column onBoardingItems(Size size, int index) {
    return Column(
      children: [
        Container(
          height: size.height * 0.4,
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              // Positioned(
              //   bottom: 0,
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(50),
              //     child: Container(
              //       height: 240,
              //       width: size.width * 0.9,
              //       color: black,
              //     ),
              //   ),
              // ),
              Positioned(
                top: 75,
                bottom: 0,
                right: 0,
                child: SizedBox(
                  height: size.height * 0.9,
                  width: size.width * 0.9,
                  child: Image.asset(
                    onBoardData[index].image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        if (index == 0)
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 35,
                color: black,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              children: [
                TextSpan(text: "Armstrong"),
              ],
            ),
            textAlign: TextAlign.center,
          )
        else if (index == 1)
        const Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 35,
              color: black,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(text: "It's Okay Not to Be Okay"),
            ],
          ),
          textAlign: TextAlign.center,
        )
        else if (index == 2)
        const Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 35,
              color: black,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: "Sorting through the Noise",
              ),
            ],
          ),
          textAlign: TextAlign.center,
        )
        else if (index == 3)
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 35,
                color: black,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: "Browse Resources!",
                ),
              ],
            ),
            textAlign: TextAlign.center,
          )
        else if (index == 4)
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 35,
                color: black,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: "Find a specialist",
                ),
              ],
            ),
            textAlign: TextAlign.center,
          )
        else if (index == 5)
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 35,
                color: black,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: "Connect with the community",
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 10),
        Text(
          onBoardData[index].text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15.5,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
