import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'join_class_screen.dart';
import '../widgets/logout_button.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  bool scanned = false;
  final MobileScannerController controller = MobileScannerController();

  Future<void> markAttendance(String sessionId) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) return;

    // 🔥 Get session
    final sessionDoc = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .get();

    if (!sessionDoc.exists || sessionDoc['isActive'] == false) {
      showMsg("QR Expired");
      return;
    }

    final data = sessionDoc.data() as Map<String, dynamic>?;

    final classId = data?['classId'];

    if (classId == null) {
      showMsg("Invalid session");
      return;
    }


    // 🔥 Check if student belongs to class
    final classDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .get();

    final classData = classDoc.data() as Map<String, dynamic>?;

    List students = List<String>.from(classData?['students'] ?? []);


    if (!students.contains(userEmail)) {
      showMsg("You are not part of this class");
      return;
    }

    // 🔥 Check duplicate
    final existing = await FirebaseFirestore.instance
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .where('studentEmail', isEqualTo: userEmail)
        .get();

    if (existing.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('attendance').add({
        'sessionId': sessionId,
        'studentEmail': userEmail,
        'status': 'present', // 🔥 IMPORTANT
        'timestamp': DateTime.now(),
      });

      showMsg("Attendance Marked ✅");
    } else {
      showMsg("Already Marked ⚠️");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Soft slate background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          "Scanner",
          style: TextStyle(
            color: Color(0xFF0F172A), // Slate-900
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // 🔥 JOIN CLASS BUTTON
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF94A3B8).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.group_add_rounded, color: Color(0xFF6366F1)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JoinClassScreen(),
                  ),
                );
              },
            ),
          ),

          // 🔥 LOGOUT BUTTON
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 16.0),
              child: LogoutButton(),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              "Center the session QR code inside the frame to mark your attendance.",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B), // Slate-500
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              decoration: BoxDecoration(
                color: Colors.black, // Dark backdrop while camera initializes
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.2), // Subtle indigo glow
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: (barcodeCapture) async {
                        if (scanned) return; // 🔥 prevent multiple scans

                        final barcode = barcodeCapture.barcodes.first;
                        final String? code = barcode.rawValue;

                        if (code != null) {
                          // Trigger UI update to show processing loader
                          setState(() {
                            scanned = true;
                          });

                          controller.stop(); // 🔥 stop camera

                          await markAttendance(code);

                          // 🔥 optional: go back after scan
                          await Future.delayed(const Duration(seconds: 2));
                          if (mounted) Navigator.pop(context);
                        }
                      },
                    ),

                    // Semi-transparent framing border
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),

                    // Glass-morphic loading overlay
                    if (scanned)
                      Container(
                        color: Colors.white.withOpacity(0.85),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Processing...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
