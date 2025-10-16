// import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:armstrong/widgets/cards/map_picker.dart';
import 'package:armstrong/widgets/forms/bio_textfield.dart';
import 'package:geocoding/geocoding.dart';

class CombinedForm extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController genderController;
  final TextEditingController dateOfBirthController;

  // Patient-specific fields
  final TextEditingController addressController;
  final TextEditingController medicalHistoryController;
  final TextEditingController therapyGoalsController;
  final TextEditingController emergencyContactNameController;
  final TextEditingController emergencyContactPhoneController;
  final TextEditingController emergencyContactRelationController;

  // Specialist-specific fields
  final TextEditingController specializationController;
  final TextEditingController bioController;
  final TextEditingController yearsOfExperienceController;
  final TextEditingController languagesSpokenController;
  final TextEditingController availabilityController;
  final TextEditingController locationController;
  final TextEditingController clinicController;

  final bool isEditing;
  final VoidCallback onPickDateOfBirth;
  final String userType;

  const CombinedForm({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.genderController,
    required this.dateOfBirthController,
    required this.addressController,
    required this.medicalHistoryController,
    required this.therapyGoalsController,
    required this.emergencyContactNameController,
    required this.emergencyContactPhoneController,
    required this.emergencyContactRelationController,
    required this.specializationController,
    required this.bioController,
    required this.yearsOfExperienceController,
    required this.languagesSpokenController,
    required this.availabilityController,
    required this.locationController,
    required this.clinicController,
    required this.isEditing,
    required this.onPickDateOfBirth,
    required this.userType,
  }) : super(key: key);

  @override
  State<CombinedForm> createState() => _CombinedFormState();
}

class _CombinedFormState extends State<CombinedForm> {
  String _getReadableClinicText(BuildContext context, String clinic) {
    if (clinic.isEmpty) return "Pick Clinic Location";
    final parts = clinic.split(',');
    if (parts.length != 2) return "Invalid Clinic Coordinates";

    try {
      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);
      return "Location: ($lat, $lng)";
    } catch (_) {
      return "Invalid Clinic Coordinates";
    }
  }

  String _formatPlacemark(Placemark place) {
    return [
      place.name,
      place.locality,
      place.administrativeArea,
    ].where((e) => e != null && e.isNotEmpty).join(", ");
  }

  InputDecoration customInputDecoration(String label, BuildContext context,
      {bool readOnly = false, bool hideStandbyBorder = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: colorScheme.onBackground,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      filled: false,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: hideStandbyBorder
              ? Colors.transparent
              : (widget.isEditing
                  ? colorScheme.onSurface.withOpacity(0.5)
                  : colorScheme.onSurface.withOpacity(0.1)),
          width: 1.5,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.primaryContainer,
          width: 2,
        ),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.onSurface.withOpacity(0.0),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Personal Information",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.firstNameController,
                        decoration:
                            customInputDecoration("First Name", context),
                        enabled: widget.isEditing,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: widget.lastNameController,
                        decoration: customInputDecoration("Last Name", context),
                        enabled: widget.isEditing,
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: widget.phoneNumberController,
                  decoration: customInputDecoration("Phone Number", context),
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),

                DropdownButtonFormField<String>(
                  value: widget.genderController.text.isNotEmpty
                      ? widget.genderController.text
                      : null,
                  decoration: customInputDecoration("Gender", context,
                      hideStandbyBorder: true),
                  items: [
                    {"label": "Male", "value": "male"},
                    {"label": "Female", "value": "female"}
                  ].map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender["value"],
                      child: Text(gender["label"]!),
                    );
                  }).toList(),
                  onChanged: widget.isEditing
                      ? (newValue) {
                          widget.genderController.text = newValue!;
                        }
                      : null,
                  icon: widget.isEditing
                      ? const Icon(Icons.arrow_drop_down)
                      : const SizedBox.shrink(),
                ),

                // Only show the date picker for patients
                if (widget.userType.toLowerCase() == "patient") ...[
                  GestureDetector(
                    onTap: widget.isEditing ? widget.onPickDateOfBirth : null,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: widget.dateOfBirthController,
                        readOnly: true,
                        decoration: customInputDecoration(
                                "Date of Birth", context,
                                hideStandbyBorder: true)
                            .copyWith(
                          suffixIcon: widget.isEditing
                              ? const Icon(Icons.calendar_today)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                if (widget.userType.toLowerCase() == "specialist") ...[
                  Text(
                    "Professional Information",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: widget.specializationController.text.isNotEmpty
                        ? widget.specializationController.text
                        : null,
                    decoration:
                        customInputDecoration("Specialization", context),
                    items: ["Psychologist", "Psychiatrist", "Counselor"]
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: widget.isEditing
                        ? (newValue) {
                            widget.specializationController.text = newValue!;
                          }
                        : null,
                  ),
                  const SizedBox(height: 30),
                  // Container(
                  //   constraints: BoxConstraints(
                  //       maxHeight: isEditing ? double.infinity : 100),
                  //   child: SingleChildScrollView(
                  //     child: TextField(
                  //       controller: bioController,
                  //       decoration: customInputDecoration("Bio", context),
                  //       enabled: isEditing,
                  //       maxLines: isEditing ? 4 : null,
                  //       readOnly: !isEditing,
                  //     ),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: widget.isEditing
                        ? () async {
                            final updatedBio = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditBioPage(initialBio: widget.bioController.text),
                              ),
                            );
                            if (updatedBio != null && updatedBio != widget.bioController.text) {
                              setState(() {
                                widget.bioController.text = updatedBio;
                              });
                            }
                          }
                        : null,
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Text(
                                widget.bioController.text.isEmpty
                                    ? 'Add your contents here...'
                                    : widget.bioController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: widget.bioController.text.isEmpty
                                      ? Theme.of(context).hintColor
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: widget.yearsOfExperienceController,
                    decoration:
                        customInputDecoration("Years of Experience", context),
                    enabled: widget.isEditing,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      List<String> availableLanguages = [
                        'English',
                        'Tagalog',
                        'Pangasinan'
                      ];
                      List<String> selectedLanguages = widget.languagesSpokenController
                          .text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Languages Spoken",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: availableLanguages.map((language) {
                                  final isSelected =
                                      selectedLanguages.contains(language);
                                  return FilterChip(
                                    label: Text(language),
                                    selected: isSelected,
                                    onSelected: widget.isEditing
                                        ? (bool selected) {
                                            setModalState(() {
                                              if (selected) {
                                                selectedLanguages.add(language);
                                              } else {
                                                selectedLanguages
                                                    .remove(language);
                                              }
                                              widget.languagesSpokenController.text =
                                                  selectedLanguages.join(', ');
                                            });
                                          }
                                        : null,
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Work Information",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    value: widget.availabilityController.text.isNotEmpty
                        ? widget.availabilityController.text
                        : null,
                    decoration: customInputDecoration("Availability", context),
                    items: ["Available", "Not Available"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: widget.isEditing
                        ? (newValue) => widget.availabilityController.text = newValue!
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: widget.locationController.text.isNotEmpty
                        ? widget.locationController.text
                        : null,
                    decoration: customInputDecoration("Location", context),
                    items: ["Dagupan City", "Urdaneta City"]
                        .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ))
                        .toList(),
                    onChanged: widget.isEditing
                        ? (value) {
                            widget.locationController.text = value!;
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Clinic Location",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.location_pin),
                        label: Text(
                          _getReadableClinicText(
                              context, widget.clinicController.text),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        onPressed: widget.isEditing
                            ? () async {
                                final picked = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MapPickerScreen(),
                                  ),
                                );

                                if (picked != null) {
                                  try {
                                    final placemarks =
                                        await placemarkFromCoordinates(
                                      picked.latitude,
                                      picked.longitude,
                                    );
                                    String readable =
                                        _formatPlacemark(placemarks.first);
                                    widget.clinicController.text =
                                        "${picked.latitude},${picked.longitude}";
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Clinic updated to: $readable")),
                                    );
                                  } catch (e) {
                                    debugPrint("Reverse geocoding failed: $e");
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
