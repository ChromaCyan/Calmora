import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:armstrong/providers/font_provider.dart';
import 'package:armstrong/providers/theme_provider.dart';

void showFontSettingsPopup(BuildContext context) {
  final fontProvider = context.read<FontProvider>();
  final themeProvider = context.read<ThemeProvider>();

  final List<String> availableFonts = [
    'OpenSans',
    'Roboto',
    'Lora',
    'Merriweather',
    'Bitter',
    'Nunito',
    'Quicksand',
    'Mulish',
    'Raleway',
    'SourceSans3',
    'Cabin',
    'Comfortaa',
    'Asap',
  ];

  final themeModes = [
    {'label': 'System', 'mode': ThemeMode.system},
    {'label': 'Light', 'mode': ThemeMode.light},
    {'label': 'Dark', 'mode': ThemeMode.dark},
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 8,
        backgroundColor: Theme.of(context).colorScheme.surface,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Appearance Settings",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),

            // Font list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, _) =>
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                itemCount: availableFonts.length,
                itemBuilder: (context, index) {
                  final fontName = availableFonts[index];
                  final isSelected = fontName == fontProvider.selectedFont;

                  return ListTile(
                    title: Text(
                      fontName,
                      style: TextStyle(
                        fontFamily: fontName,
                        fontSize: 16,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      fontProvider.setFont(fontName);
                    },
                  );
                },
              ),
            ),

            Divider(height: 1, color: Theme.of(context).dividerColor),

            // Theme mode selection
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "App Theme",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Wrap(
              spacing: 8,
              children: themeModes.map((themeOption) {
                final isSelected =
                    themeOption['mode'] == themeProvider.themeMode;
                return ChoiceChip(
                  label: Text(themeOption['label'] as String),
                  selected: isSelected,
                  onSelected: (_) {
                    themeProvider
                        .setThemeMode(themeOption['mode'] as ThemeMode);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
