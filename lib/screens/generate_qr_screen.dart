import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'teacher_dashboard.dart';
import '../widgets/logout_button.dart';

class GenerateQRScreen extends StatefulWidget {
  final String subject;
  final String classId;

  GenerateQRScreen({
    required this.subject,
    required this.classId,
  });

  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  String? sessionId;
  int secondsLeft = 30;
  Timer? timer;

  void generateSession() async {
    final String tempId = const Uuid().v4();

    setState(() {
      sessionId = tempId;
      secondsLeft = 30;
    });

    timer?.cancel();

    // ⏱ Countdown timer
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
        });
      } else {
        t.cancel();
      }
    });

    try {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(tempId)
          .set({
        'subject': widget.subject,
        'classId': widget.classId,
        'teacherEmail': FirebaseAuth.instance.currentUser?.email,

        'startTime': DateTime.now(),

        // 🔥 IMPORTANT FIX: consistency
        'isActive': true,

        'expiresAt': DateTime.now().add(Duration(seconds: 30)),
      });

      // ⏱ Auto-expire session
      Future.delayed(Duration(seconds: 30), () {
        FirebaseFirestore.instance
            .collection('sessions')
            .doc(tempId)
            .update({
          'isActive': false,
        });
      });
    } catch (e) {
      print("ERROR CREATING SESSION: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
        title: Text(
          widget.subject,
          style: const TextStyle(
            color: Color(0xFF0F172A), // Slate-900
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: LogoutButton(),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: sessionId == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0E7FF), Color(0xFFEDE9FE)], // Soft indigo/purple
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 60,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Generate Security QR",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Broadcast this code to the class.\nIt will automatically expire in 30 seconds.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Main Action Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: generateSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        "Generate QR Code",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary Action Card
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherDashboard(
                          subject: widget.subject,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.dashboard_rounded, color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Go to Dashboard",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF94A3B8).withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: sessionId!,
                  size: 260,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              // Expire Timer Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: secondsLeft <= 5
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF1F5F9), // Red or Slate background
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: secondsLeft <= 5
                        ? const Color(0xFFFCA5A5) // Soft red border
                        : Colors.transparent,
                  ),
                  boxShadow: secondsLeft <= 5
                      ? [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 22,
                      color: secondsLeft <= 5
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Expires in $secondsLeft sec",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: secondsLeft <= 5
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
