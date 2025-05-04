import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../utils/consts.dart';

class BottomInputContainer extends StatefulWidget {
  final Function(String, FilePickerResult?) onTextSend;
  final Function(String, FilePickerResult?, List<List<int>>) onTextSendPrompt;
  final Function(File) onImageSend;
  final bool isProcessing;

  const BottomInputContainer({
    Key? key,
    required this.onTextSend,
    required this.onTextSendPrompt,
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
  final GlobalKey _imageKey = GlobalKey();
  List<List<int>> promptVector = []; // Change to 2D vector
  int _imageWidth = 0;
  int _imageHeight = 0;
  List<Offset> _selectedPoints = []; // List to store the selected points

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
        withData: true
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

  void _openCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        FilePickerResult result = FilePickerResult([
          PlatformFile(
            name: photo.name,
            path: photo.path,
            size: await File(photo.path).length(),
          )
        ]);

        setState(() {
          _pickerResult = result;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error capturing image.",
            style: Theme.of(context).textTheme.labelSmall),
        backgroundColor: Theme.of(context).cardColor,
      ));
    }
  }

  void _onImageTap(BuildContext context, Offset position) {
    // Count the number of selected prompts (1s in the promptVector)
    final int selectedPrompts =
        promptVector.expand((row) => row).where((value) => value == 1).length;

    if (selectedPrompts >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 5 prompts.')),
      );
      return;
    }

    // Convert the tapped position to row and column indices
    final RenderBox renderBox =
        _imageKey.currentContext!.findRenderObject() as RenderBox;
    final Size imageSize = renderBox.size;
    final int row = ((position.dy / imageSize.height) * _imageHeight).toInt();
    final int col = ((position.dx / imageSize.width) * _imageWidth).toInt();

    setState(() {
      promptVector[row][col] = 1; // Mark the tapped position
      _selectedPoints.add(Offset(
          position.dx,
          position
              .dy)); // Add the tapped position to the list of selected points
    });
  }

  void _showImagePromptPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Constants.lightPrimary
              : Constants.darkPrimary,
          title: Text('Tap on the image to select prompts',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? Constants.lightTextColor
                    : Constants.darkTextColor,
              )),
          content: FutureBuilder<Size>(
            future: _getImageDimensions(File(_pickerResult!.files.first.path!)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error loading image dimensions');
              } else {
                final Size dimensions = snapshot.data!;
                _imageWidth = dimensions.width.toInt();
                _imageHeight = dimensions.height.toInt();

                // Initialize promptVector as a 2D list
                promptVector = List.generate(
                    _imageHeight, (_) => List.filled(_imageWidth, 0));
                return StatefulBuilder(builder: (context, setState) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          final RenderBox renderBox = _imageKey.currentContext!
                              .findRenderObject() as RenderBox;
                          final Offset localPosition =
                              renderBox.globalToLocal(details.globalPosition);
                          setState(() {
                            _onImageTap(context, localPosition);
                          });
                        },
                        child: Image.file(
                          File(_pickerResult!.files.first.path!),
                          key: _imageKey,
                          fit: BoxFit.contain,
                        ),
                      ),
                      ..._selectedPoints.map((point) => Positioned(
                            left: point.dx - 5,
                            top: point.dy - 5,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )),
                    ],
                  );
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Done',
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Constants.lightTextColor
                        : Constants.darkTextColor,
                  )),
            ),
          ],
        );
      },
    );
  }

  Future<Size> _getImageDimensions(File imageFile) async {
    final Completer<Size> completer = Completer();
    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()));
      }),
    );
    return completer.future;
  }

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
    if (viaPromptMode) {
      widget.onTextSendPrompt(
          _textController.text.trim(), _pickerResult, promptVector);
    } else {
      widget.onTextSend(_textController.text.trim(), _pickerResult);
    }

    _textController.clear();
    setState(() {
      _isComposing = false;
      _pickerResult = null;
      promptVector = [];
      _selectedPoints = [];
    });
  }

  void _cancelImageSelection() {
    setState(() {
      _pickerResult = null;
      promptVector = [];
      _selectedPoints = [];
    });
  }

  bool viaPromptMode = false;

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
                    child: GestureDetector(
                      onTap: viaPromptMode
                          ? () => _showImagePromptPopup(context)
                          : null,
                      child: Image.file(
                        File(_pickerResult!.files.first.path!),
                        height: 120,
                        fit: BoxFit.cover,
                      ),
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
                      borderSide:
                          BorderSide(color: Theme.of(context).brightness == Brightness.light ? Colors.red.shade600 : Colors.red.shade300),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      gapPadding: 24),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.light ? Colors.red.shade200 : Colors.red.shade300), borderRadius: const BorderRadius.all(Radius.circular(12)), gapPadding: 24)),
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
                  onPressed: _openCamera,
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
                Switch(
                  value: viaPromptMode,
                  onChanged: (value) {
                    setState(() {
                      viaPromptMode = value;
                    });
                  },
                  activeColor: Theme.of(context).brightness == Brightness.light
                      ? Constants.lightSecondary
                      : Constants.darkSecondary,
                  activeTrackColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.lightSecondary.withOpacity(0.3)
                          : Constants.darkSecondary.withOpacity(0.3),
                  inactiveThumbColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.lightTextColor
                          : Constants.darkTextColor,
                  inactiveTrackColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.lightTextColor.withOpacity(0.3)
                          : Constants.darkTextColor.withOpacity(0.3),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  disabledColor: Colors.grey,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Constants.lightSecondary
                      : Constants.darkSecondary,
                  icon: Icon(
                    Icons.send_rounded,
                    opticalSize: 20,
                  ),
                  onPressed: _isComposing ? _handleTextSubmit : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
