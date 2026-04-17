import 'package:flutter/material.dart';

import 'databases.dart';

class taggingPage extends StatefulWidget {
  const taggingPage({super.key});

  @override
  State<taggingPage> createState() => _taggingPageState();
}

class _taggingPageState extends State<taggingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(uiStrings['tagging.title'], style: TextStyle(fontSize: 30)),
              Tooltip(
                message: uiStrings['tagging.tooltip'],
                child: const Icon(Icons.info, size: 25),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          // fixedSize: const Size(50, 50),
                          padding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          uiStrings['tagging.file'],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          // fixedSize: const Size(50, 50),
                          padding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          uiStrings['tagging.save'],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                  
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
