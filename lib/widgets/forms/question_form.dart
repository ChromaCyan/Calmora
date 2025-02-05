import 'package:flutter/material.dart';

class QuestionWidget extends StatelessWidget {
  final String question;
  final List<Map<String, dynamic>> choices; 
  final String selectedChoiceId; 
  final ValueChanged<String> onAnswerSelected; 

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.choices,
    required this.selectedChoiceId,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...List.generate(
            choices.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: GestureDetector(
                onTap: () => onAnswerSelected(choices[index]['_id']),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: selectedChoiceId == choices[index]['_id']
                        ? Color(0xFF81C784)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF81C784), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      choices[index]['text'],
                      style: TextStyle(
                        color: selectedChoiceId == choices[index]['_id']
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
