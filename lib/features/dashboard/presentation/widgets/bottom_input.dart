import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../utils/consts.dart';

class BottomInputContainer extends StatefulWidget {
  final Function(String, FilePickerResult?) onTextSend;
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
  FilePickerResult? _pickerResult;
  String? _errorText;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      FilePickerResult? files = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["jpg", "jpeg", "png", "gif"],
      );
      if (files != null && files.files.length == 1) {
        setState(() {
          _pickerResult = files;
        });
      } else if (files != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Only 1 image can be selected.",
              style: Theme.of(context).textTheme.labelSmall),
          backgroundColor: Theme.of(context).cardColor));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error uploading image.",
            style: Theme.of(context).textTheme.labelSmall),
        backgroundColor: Theme.of(context).cardColor));
    }
  }

  // Future<void> pickFromCamera() async {
  //   try {
  //     final ImagePicker picker = ImagePicker();
  //     final XFile? image = await picker.pickImage(source: ImageSource.camera);
  //     if (image != null) {
  //       setState(() async {
  //         _pickerResult = FilePickerResult([
  //           PlatformFile(
  //             name: image.name,
  //             path: image.path,
  //             size: await File(image.path).length(),
  //           ),
  //         ]);
  //       });
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text("Error opening camera.",
  //           style: Theme.of(context).textTheme.labelSmall),
  //       backgroundColor: Theme.of(context).cardColor));
  //   }
  // }

  void _handleTextSubmit() {
    if (_textController.text.trim().isEmpty) {
      return;
    }
    // if (_pickerResult == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please attach an image.')),
    //   );
    //   return;
    // }
    widget.onTextSend(_textController.text.trim(), _pickerResult);
    _textController.clear();
    setState(() {
      _isComposing = false;
      _pickerResult = null;
    });
  }

  void _cancelImageSelection() {
    setState(() {
      _pickerResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
          if (_pickerResult != null && _pickerResult!.files.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              width: width,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_pickerResult!.files.first.path!),
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

          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
            child: Row(
              children: [
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
                  onPressed: () {},
                  // onPressed: pickFromCamera,
                ),

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
                  onPressed: pickImage,
                ),

                Expanded(
                  child: Container(),
                ),

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
