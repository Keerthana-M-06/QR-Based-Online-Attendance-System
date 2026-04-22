import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinClassScreen extends StatefulWidget {
  @override
  _JoinClassScreenState createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final TextEditingController codeController = TextEditingController();
  bool loading = false;

  Future<void> joinClass() async {
    String code = codeController.text.trim();

    if (code.isEmpty) return;

    setState(() => loading = true);

    try {
      // 🔥 STEP 1: Find class with this code
      final query = await FirebaseFirestore.instance
          .collection('classes')
          .where('joinCode', isEqualTo: code)
          .get();

      // ❌ If not found
      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid class code")),
        );
        setState(() => loading = false);
        return;
      }

      final classDoc = query.docs.first;

      // 🔥 STEP 2: Add student to class
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classDoc.id)
          .update({
        'students': FieldValue.arrayUnion([
          FirebaseAuth.instance.currentUser!.email
        ])
      });

      // ✅ Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Joined class successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      print("JOIN ERROR: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Soft slate background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Floating Header Icon
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0E7FF), Color(0xFFEDE9FE)], // Indigo / Purple soft
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
                    Icons.groups_rounded,
                    size: 50,
                    color: Color(0xFF6366F1), // Deep indigo
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Welcome Header
            const Text(
              "Join a Class",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A), // Slate-900
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Enter the unique class code provided by your teacher to join.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B), // Slate-500
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // Input Card Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF94A3B8).withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // Clean borderless input
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: "Class Code",
                      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.key_rounded, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Floating gradient button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: loading
                          ? null
                          : const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      color: loading ? const Color(0xFFCBD5E1) : null, // Muted slate if loading
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: loading
                          ? []
                          : [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: loading ? null : joinClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : const Text(
                        "Join Class",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
