import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebQRScreen extends StatefulWidget {
  final String sessionId;

  const WebQRScreen({super.key, required this.sessionId});

  @override
  State<WebQRScreen> createState() => _WebQRScreenState();
}

class _WebQRScreenState extends State<WebQRScreen> {
  int secondsLeft = 15;
  bool loading = true;
  bool expired = false;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId);

      final doc = await docRef.get();

      if (!doc.exists) {
        setState(() {
          expired = true;
          loading = false;
        });
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      // 🔥 START TIMER ONLY FIRST TIME
      if (data['started'] != true) {

        final newExpiry =
        DateTime.now().add(const Duration(seconds: 15));

        await docRef.update({
          'started': true,
          'isActive': true,
          'expiresAt': newExpiry,
        });

        secondsLeft = 15;

      } else {

        final expiresAt =
        (data['expiresAt'] as Timestamp).toDate();

        final diff =
            expiresAt.difference(DateTime.now()).inSeconds;

        if (diff <= 0) {
          setState(() {
            expired = true;
            loading = false;
          });
          return;
        }

        secondsLeft = diff;
      }

      setState(() {
        loading = false;
      });

      startTimer();

    } catch (e) {
      print("WEB QR ERROR: $e");

      setState(() {
        expired = true;
        loading = false;
      });
    }
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      if (secondsLeft <= 1) {
        setState(() {
          secondsLeft = 0;
          expired = true;
        });
        return false;
      }

      setState(() {
        secondsLeft--;
      });

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (expired) {
      return const Scaffold(
        body: Center(
          child: Text(
            "QR Expired",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: widget.sessionId,
              size: 300,
            ),
            const SizedBox(height: 30),
            Text(
              "Expires in $secondsLeft sec",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}