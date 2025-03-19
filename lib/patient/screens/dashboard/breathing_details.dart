import 'package:flutter/material.dart';

class BreathingGuideScreen extends StatefulWidget {
  @override
  _BreathingGuideScreenState createState() => _BreathingGuideScreenState();
}

class _BreathingGuideScreenState extends State<BreathingGuideScreen> {
  Map<String, bool> isExpandedMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Breathing Exercise Guide")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'images/breath.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Breathing Exercise Guide:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10),
            const Text(
              "There are different types of breathing exercises/techniques that could help you feel calm and relax. Breathing exercises don't have to take a lot of time. It's about setting aside time to pay attention to your breathing.\n",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            const Text(
              "- Begin with 2 to 5 minutes a day, and increase your time as the exercise becomes easier and more comfortable.\n\n"
              "- Practice multiple times a day.\n\n"
              "- Schedule set times or practice conscious breathing as you feel the need.\n\n",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const Text(
              "Now here are some breathing exercises",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            _buildBreathingExercise(
                "Pursed Lip Breathing",
                "This simple breathing technique helps to slow down your breathing pace by having you apply deliberate effort in each breath.\n\n"
                    "To do it:\n"
                    "- Relax your neck and shoulders.\n"
                    "- Keeping your mouth closed, inhale slowly through your nose for 2 counts.\n"
                    "- Pucker or purse your lips as though you were going to whistle.\n"
                    "- Exhale slowly by blowing air through your pursed lips for a count of 4."),
            _buildBreathingExercise(
                "Diaphragmatic Breathing",
                "Diaphragmatic breathing (aka belly breathing) can help you use your diaphragm properly.\n\n"
                    "To do it:\n"
                    "- Lie on your back with your knees slightly bent and your head on a pillow.\n"
                    "- You may place a pillow under your knees for support.\n"
                    "- Place one hand on your upper chest and one hand below your rib cage, allowing you to feel the movement of your diaphragm.\n"
                    "- Slowly inhale through your nose, feeling your stomach pressing into your hand.\n"
                    "- Keep your other hand as still as possible.\n"
                    "- Exhale using pursed lips as you tighten your abdominal muscles, keeping your upper hand completely still."),
            _buildBreathingExercise(
                "Breath Focus Technique",
                "This deep breathing technique uses imagery or focus words and phrases.\n\n"
                    "To do it:\n"
                    "- Sit or lie down in a comfortable place.\n"
                    "- Bring your awareness to your breaths without trying to change how you’re breathing.\n"
                    "- Alternate between normal and deep breaths a few times.\n"
                    "- Notice how your abdomen expands with deep inhalations.\n"
                    "- Note how shallow breathing feels compared to deep breathing.\n"
                    "- Practice your deep breathing for a few minutes.\n"
                    "- Place one hand below your belly button, keeping your belly relaxed, and notice how it rises with each inhale and falls with each exhale.\n"
                    "- Let out a loud sigh with each exhale.\n"
                    "- Begin the practice of breath focus by combining this deep breathing with imagery and a focus word or phrase that will support relaxation."),
            _buildBreathingExercise(
                "Lion’s Breath",
                "Lion’s breath is an energizing yoga breathing practice that may help relieve tension in your jaw and facial muscles.\n\n"
                    "To do this:\n"
                    "- Come into a comfortable seated position.\n"
                    "- Press your palms against your knees with your fingers spread wide.\n"
                    "- Inhale deeply through your nose and open your eyes wide.\n"
                    "- At the same time, open your mouth wide and stick out your tongue, bringing the tip down toward your chin.\n"
                    "- Contract the muscles at the front of your throat as you exhale out through your mouth by making a long ‘haaa’ sound.\n"
                    "- Do this breath 2 to 3 times."),
            _buildBreathingExercise(
                "Alternate Nostril Breathing",
                "Alternate nostril breathing, known as Nadi Shodhana Pranayama in Sanskrit, is a breathing practice for relaxation.\n\n"
                    "To do this:\n"
                    "- Choose a comfortable seated position.\n"
                    "- Lift your right hand toward your nose, pressing your first and middle fingers down toward your palm and leaving your other fingers extended.\n"
                    "- After an exhale, use your right thumb to gently close your right nostril.\n"
                    "- Inhale through your left nostril and then close your left nostril with your right pinky and ring fingers.\n"
                    "- Release your thumb and exhale out through your right nostril.\n"
                    "- Inhale through your right nostril and then close this nostril.\n"
                    "- Release your fingers to open your left nostril and exhale through this side.\n"
                    "- This is one cycle.\n"
                    "- Continue this breathing pattern for up to 5 minutes.\n"
                    "- Finish your session with an exhale on the left side."),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingExercise(String title, String description) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpandedMap[title] = !(isExpandedMap[title] ?? false);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  (isExpandedMap[title] ?? false)
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
            if (isExpandedMap[title] ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.justify,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
