import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 3,
        backgroundColor: Colors.white,
        title: Center(
          child: Row(
            children: [
              Image.asset(
                'assets/images/LifeLink-removebg-preview.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 10),
              Text(
                "LifeLink",
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("Notification clicked");
            },
            icon: Image.asset(
              'assets/icons/notification.png',
              width: 22,
              height: 22,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/location.png',
                              width: 26,
                              height: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Maitidevi",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        card(
                          child: SizedBox(
                            height: 190,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Image.asset(
                                    'assets/images/measureoflife.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () {
                            debugPrint("Nearby hospital clicked");
                          },
                          child: card(
                            child: SizedBox(
                              height: 150,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/blood-drop.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "Nearby  hospital",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  debugPrint("Blood banks clicked");
                                },
                                child: card(
                                  child: SizedBox(
                                    height: 175,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/blood-transfusion.png',
                                          width: 52,
                                          height: 52,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Blood banks",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  debugPrint("Hospital clicked");
                                },
                                child: card(
                                  child: SizedBox(
                                    height: 175,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/hospital.png',
                                          width: 52,
                                          height: 52,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Hospital",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
