import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../utils/consts.dart';

class BottomInputContainer extends StatefulWidget {
  final Function(String) onTextSend;
  final Function(File) onImageSend;
  final bool isProcessing;

  const BottomInputContainer({
    Key? key,
    required this.onTextSend,
    required this.onImageSend,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  State<BottomInputContainer> createState() => _BottomInputContainerState();
}

class _BottomInputContainerState extends State<BottomInputContainer> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  File? _selectedImage;
  bool _showImagePreview = false;
  String? _errorText;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        preferredCameraDevice:
            CameraDevice.front, // Prioritize front camera for eye imaging
        imageQuality: 100, // High quality needed for medical analysis
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _showImagePreview = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  void _handleImageSubmit() {
    if (_selectedImage != null) {
      widget.onImageSend(_selectedImage!);
      setState(() {
        _selectedImage = null;
        _showImagePreview = false;
      });
    }
  }

  void _handleTextSubmit() {
    if (_textController.text.trim().isNotEmpty) {
      widget.onTextSend(_textController.text.trim());
      _textController.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  void _cancelImageSelection() {
    setState(() {
      _selectedImage = null;
      _showImagePreview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Constants.lightPrimary
            : Constants.darkPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showImagePreview && _selectedImage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              width: width,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: InkWell(
                      onTap: _cancelImageSelection,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (widget.isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Processing eye vein analysis...",
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Constants.lightTextColor
                          : Constants.darkTextColor,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: TextFormField(
              controller: _textController,
              onChanged: (text) {
                setState(() {
                  _isComposing = text.trim().isNotEmpty;
                });
              },
              cursorColor: Theme.of(context).brightness == Brightness.light
                  ? Constants.lightTextColor
                  : Constants.darkTextColor,
              // validator: (String? text) {
              //   return (text == null || text.isEmpty)
              //       ? 'Please enter a message'
              //       : null;
              // },
              keyboardType: TextInputType.text,
              maxLines: 5,
              minLines: 1,
              style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Constants.lightTextColor
                      : Constants.darkTextColor,
                  fontStyle: FontStyle.normal),
              decoration: InputDecoration(
                  // errorText: _errorText,
                  // errorStyle: GoogleFonts.urbanist(
                  //     fontSize: 10,
                  //     color: Theme.of(context).brightness == Brightness.light
                  //         ? Colors.red.shade600
                  //         : Colors.red.shade300,
                  //     fontStyle: FontStyle.normal),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Constants.lightBorderColor
                              : Constants.darkBorderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      gapPadding: 24),
                  hintText: 'Ask about your eye vein analysis...',
                  hintStyle: GoogleFonts.urbanist(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                      fontStyle: FontStyle.normal),
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? Constants.lightSecondary.withAlpha(10)
                      : Constants.darkSecondary.withAlpha(10),
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Constants.lightSecondary
                              : Constants.darkSecondary),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      gapPadding: 24),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.red.shade600
                              : Colors.red.shade300),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      gapPadding: 24),
                  errorBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.light ? Colors.red.shade200 : Colors.red.shade300), borderRadius: const BorderRadius.all(Radius.circular(12)), gapPadding: 24)),
            ),
          ),

          // Input container
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
            child: Row(
              children: [
                // Camera button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    opticalSize: 20,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Constants.lightSecondary
                        : Constants.darkSecondary,
                  ),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),

                // Gallery button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.photo_library_rounded,
                    opticalSize: 20,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Constants.lightSecondary
                        : Constants.darkSecondary,
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),

                // Text input field
                Expanded(
                  child: Container(),
                ),

                // Send button (for text)
                if (_isComposing)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.send_rounded,
                      opticalSize: 20,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Constants.lightSecondary
                          : Constants.darkSecondary,
                    ),
                    onPressed: _handleTextSubmit,
                  ),

                // Analyze button (for image)
                if (_selectedImage != null && !_isComposing)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.analytics_outlined,
                      opticalSize: 20,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Constants.lightSecondary
                          : Constants.darkSecondary,
                    ),
                    onPressed: _handleImageSubmit,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
