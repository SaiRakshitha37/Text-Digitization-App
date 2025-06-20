import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
// import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/sidebar.dart';
import '../models/text_model.dart';

class TextExtractorScreen extends StatefulWidget {
  final Box<TextModel> box;

  const TextExtractorScreen({super.key, required this.box});

  @override
  State<TextExtractorScreen> createState() => _TextExtractorScreenState();
}

class _TextExtractorScreenState extends State<TextExtractorScreen> {
  final ImagePicker picker = ImagePicker();
  XFile? _image;
  String _extractedText = "";
  String _statusMessage = "";
  int _currentPage = 0;
  bool _alwaysUseCamera = false;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadCameraPreference();
  }

  Future<void> _loadCameraPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _alwaysUseCamera = prefs.getBool('alwaysUseCamera') ?? false;
    });
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
          _extractedText = "";
          _statusMessage = "Uploading image...";
        });
        await _uploadImage(pickedFile);
      } else {
        setState(() => _statusMessage = "No image selected.");
      }
    } catch (e) {
      setState(() => _statusMessage = "Picker error: $e");
    }
  }

  Future<void> _uploadImage(XFile image) async {
    try {
      final uri = Uri.parse('http://192.168.120.159:3000/api/extract-text');
      var request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final extracted = data['extractedText']?.toString() ?? 'No text found.';
        setState(() {
          _extractedText = extracted;
          _statusMessage = "Text extracted successfully!";
        });

        final newName = 'Document ${widget.box.length + 1}';
        await widget.box.add(TextModel(
          name: newName,
          content: _extractedText,
          dateTime: DateTime.now(),
        ));

        _pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
      } else {
        setState(() => _statusMessage = 'Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Upload error: $e');
    }
  }

  Future<void> _generatePDF() async {
    if (_extractedText.isEmpty) {
      setState(() => _statusMessage = "No text to convert.");
      return;
    }

    try {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Text(_extractedText, style: const pw.TextStyle(fontSize: 14)),
        ),
      ));

      final pdfBytes = await pdf.save();
      final fileName = 'Extracted_Text_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await _showPDFOptions(pdfBytes, fileName);
    } catch (e) {
      setState(() => _statusMessage = "PDF error: $e");
    }
  }

  Future<void> _showPDFOptions(Uint8List pdfBytes, String fileName) async {
    if (kIsWeb) {
      // final blob = html.Blob([pdfBytes]);
      // final url = html.Url.createObjectUrlFromBlob(blob);
      // final anchor = html.AnchorElement(href: url)
      //   ..setAttribute("download", fileName)
      //   ..click();
      // html.Url.revokeObjectUrl(url);
      // setState(() => _statusMessage = "PDF downloaded.");
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final dir = await getApplicationDocumentsDirectory();
                  final file = File('${dir.path}/$fileName');
                  await file.writeAsBytes(pdfBytes);
                  setState(() => _statusMessage = "Saved to ${file.path}");
                  await OpenFilex.open(file.path);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.download),
                label: const Text('Download & Open'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final dir = await getApplicationDocumentsDirectory();
                  final file = File('${dir.path}/$fileName');
                  await file.writeAsBytes(pdfBytes);
                  await Share.shareXFiles([XFile(file.path)], text: 'Your PDF is ready!');
                  setState(() => _statusMessage = "PDF shared.");
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(box: widget.box),
      appBar: AppBar(
        title: const Text('MediScan - Text Extractor'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Page 0: Upload Image
          Container(
            color: const Color(0xFFB3E5FC),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  minWidth: 400,
                  minHeight: 450,
                  maxHeight: 500,
                ),
                child: Card(
                  elevation: 14,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  color: Colors.white,
                  shadowColor: Colors.green.shade200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.medical_services, size: 90, color: Color(0xFF2E8B57)),
                        const SizedBox(height: 20),
                        const Text(
                          "Scan Your Image",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: () {
                            _getImage(_alwaysUseCamera ? ImageSource.camera : ImageSource.gallery);
                          },
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 26),
                          label: Text(
                            _alwaysUseCamera ? "Use Camera" : "Use Gallery",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8B57),
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 7,
                          ),
                        ),
                        if (_statusMessage.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            _statusMessage,
                            style: const TextStyle(
                              color: Color(0xFF2E8B57),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Page 1: Extracted Text Display
          Container(
            padding: const EdgeInsets.all(40),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Extracted Text", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SelectableText(
                    _extractedText,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _generatePDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export as PDF"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:io';
// import 'dart:html' as html;

// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:hive/hive.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:share_plus/share_plus.dart';

// import '../widgets/sidebar.dart';
// import '../models/text_model.dart';

// class TextExtractorScreen extends StatefulWidget {
//   final Box<TextModel> box;

//   const TextExtractorScreen({super.key, required this.box});

//   @override
//   State<TextExtractorScreen> createState() => _TextExtractorScreenState();
// }

// class _TextExtractorScreenState extends State<TextExtractorScreen> {
//   final ImagePicker picker = ImagePicker();
//   XFile? _image;
//   String _extractedText = "";
//   String _statusMessage = "";
//   int _currentPage = 0;

//   final PageController _pageController = PageController();

//   Future<void> _getImage(ImageSource source) async {
//     try {
//       final pickedFile = await picker.pickImage(source: source);
//       if (pickedFile != null) {
//         setState(() {
//           _image = pickedFile;
//           _extractedText = "";
//           _statusMessage = "Uploading image...";
//         });
//         await _uploadImage(pickedFile);
//       } else {
//         setState(() => _statusMessage = "No image selected.");
//       }
//     } catch (e) {
//       setState(() => _statusMessage = "Picker error: $e");
//     }
//   }

//   Future<void> _uploadImage(XFile image) async {
//     try {
//       final uri = Uri.parse('http://localhost:3000/api/extract-text');
//       var request = http.MultipartRequest('POST', uri);

//       if (kIsWeb) {
//         final bytes = await image.readAsBytes();
//         request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
//       } else {
//         request.files.add(await http.MultipartFile.fromPath('image', image.path));
//       }

//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         final data = jsonDecode(responseBody);
//         final extracted = data['extractedText']?.toString() ?? 'No text found.';
//         setState(() {
//           _extractedText = extracted;
//           _statusMessage = "Text extracted successfully!";
//         });

//         final newName = 'Document ${widget.box.length + 1}';
//         await widget.box.add(TextModel(
//           name: newName,
//           content: _extractedText,
//           dateTime: DateTime.now(),
//         ));

//         _pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
//       } else {
//         setState(() => _statusMessage = 'Upload failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _statusMessage = 'Upload error: $e');
//     }
//   }

//   Future<void> _generatePDF() async {
//     if (_extractedText.isEmpty) {
//       setState(() => _statusMessage = "No text to convert.");
//       return;
//     }

//     try {
//       final pdf = pw.Document();
//       pdf.addPage(pw.Page(
//         build: (context) => pw.Padding(
//           padding: const pw.EdgeInsets.all(16),
//           child: pw.Text(_extractedText, style: const pw.TextStyle(fontSize: 14)),
//         ),
//       ));

//       final pdfBytes = await pdf.save();
//       final fileName = 'Extracted_Text_${DateTime.now().millisecondsSinceEpoch}.pdf';
//       await _showPDFOptions(pdfBytes, fileName);
//     } catch (e) {
//       setState(() => _statusMessage = "PDF error: $e");
//     }
//   }

//   Future<void> _showPDFOptions(Uint8List pdfBytes, String fileName) async {
//     if (kIsWeb) {
//       final blob = html.Blob([pdfBytes]);
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       final anchor = html.AnchorElement(href: url)
//         ..setAttribute("download", fileName)
//         ..click();
//       html.Url.revokeObjectUrl(url);
//       setState(() => _statusMessage = "PDF downloaded.");
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('PDF Options'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   final dir = await getApplicationDocumentsDirectory();
//                   final file = File('${dir.path}/$fileName');
//                   await file.writeAsBytes(pdfBytes);
//                   setState(() => _statusMessage = "Saved to ${file.path}");
//                   await OpenFilex.open(file.path);
//                   Navigator.pop(context);
//                 },
//                 icon: const Icon(Icons.download),
//                 label: const Text('Download & Open'),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   final dir = await getApplicationDocumentsDirectory();
//                   final file = File('${dir.path}/$fileName');
//                   await file.writeAsBytes(pdfBytes);
//                   await Share.shareXFiles([XFile(file.path)], text: 'Your PDF is ready!');
//                   setState(() => _statusMessage = "PDF shared.");
//                   Navigator.pop(context);
//                 },
//                 icon: const Icon(Icons.share),
//                 label: const Text('Share'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//   }

//   void _scanAnother() {
//     setState(() {
//       _image = null;
//       _extractedText = "";
//       _statusMessage = "";
//     });
//     _pageController.animateToPage(
//       0,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Sidebar(box: widget.box),
//       appBar: AppBar(
//         title: const Text(
//           'MediScan - Text Extractor',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.indigo,
//       ),
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: [
//           // Page 0: Upload UI
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blueGrey, Colors.lightBlueAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   minWidth: 500,
//                   maxWidth: 700,
//                   minHeight: 600,
//                   maxHeight: 750,
//                 ),
//                 child: Card(
//                   margin: const EdgeInsets.all(24),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                   elevation: 8,
//                   color: Colors.white,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.medical_services, size: 60, color: Colors.teal),
//                         const SizedBox(height: 24),
//                         const Text(
//                           "Scan an Image",
//                           style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 30),
//                         ElevatedButton.icon(
//                           onPressed: () => _getImage(ImageSource.gallery),
//                           icon: const Icon(Icons.image, size: 28, color: Colors.white),
//                           label: const Text(
//                             "Choose from Gallery",
//                             style: TextStyle(fontSize: 20, color: Colors.white),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                             minimumSize: const Size(250, 50),
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         ElevatedButton.icon(
//                           onPressed: () => _getImage(ImageSource.camera),
//                           icon: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
//                           label: const Text(
//                             "Take a Photo",
//                             style: TextStyle(fontSize: 20, color: Colors.white),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                             minimumSize: const Size(250, 50),
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         if (_statusMessage.isNotEmpty)
//                           Text(
//                             _statusMessage,
//                             style: const TextStyle(
//                               color: Colors.black87,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Page 1: Text Display
//           Container(
//             padding: const EdgeInsets.all(40),
//             color: Colors.white,
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Extracted Text",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   const Divider(
//                     color: Colors.grey,
//                     thickness: 1,
//                     indent: 20,
//                     endIndent: 20,
//                   ),
//                   const SizedBox(height: 20),
//                   SelectableText(
//                     _extractedText,
//                     style: const TextStyle(fontSize: 18),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 30),
//                   Wrap(
//                     alignment: WrapAlignment.center,
//                     spacing: 12, // Horizontal spacing between buttons
//                     runSpacing: 12, // Vertical spacing if wrapping occurs
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: _generatePDF,
//                         icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
//                         label: const Text(
//                           "Export as PDF",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.teal,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
//                           textStyle: const TextStyle(fontSize: 16),
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _scanAnother,
//                         icon: const Icon(Icons.camera_alt, color: Colors.white),
//                         label: const Text(
//                           "Scan Another",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.teal,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
//                           textStyle: const TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }