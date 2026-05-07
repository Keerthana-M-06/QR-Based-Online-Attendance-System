import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/logout_button.dart';

class TeacherDashboard extends StatelessWidget {
  final String subject;

  TeacherDashboard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Soft slate background
        appBar: AppBar(
          elevation: 1, // Subtle shadow for tab bar depth
          shadowColor: const Color(0xFF94A3B8).withOpacity(0.2),
          backgroundColor: Colors.white,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
          title: Text(
            "Dashboard - $subject",
            style: const TextStyle(
              color: Color(0xFF0F172A), // Slate-900
              fontSize: 22,
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
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 4,
            indicatorColor: Color(0xFF6366F1), // Indigo
            labelColor: Color(0xFF6366F1),
            unselectedLabelColor: Color(0xFF64748B),
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            tabs: [
              Tab(text: "Sessions"),
              Tab(text: "Stats"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SessionsTab(subject: subject),
            StatsTab(subject: subject),
          ],
        ),
      ),
    );
  }
}

class SessionsTab extends StatelessWidget {
  final String subject;

  SessionsTab({required this.subject});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sessions')
          .where('subject', isEqualTo: subject)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              strokeWidth: 3,
            ),
          );
        }

        final sessions = snapshot.data!.docs;

        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    size: 64,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No sessions yet",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Generated QRs will appear here.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          physics: const BouncingScrollPhysics(),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF94A3B8).withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionDetailScreen(sessionId: session.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF818CF8).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.fact_check_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Session ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_filled_rounded,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      session['startTime'].toDate().toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9), // Slate-100
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Color(0xFF94A3B8), // Slate-400
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;

  SessionDetailScreen({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // ❌ REMOVED STATS TAB (redundant)
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 1,
          shadowColor: const Color(0xFF94A3B8).withOpacity(0.2),
          backgroundColor: Colors.white,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
          title: const Text(
            "Session Details",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 4,
            indicatorColor: Color(0xFF6366F1),
            labelColor: Color(0xFF6366F1),
            unselectedLabelColor: Color(0xFF64748B),
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            tabs: [
              Tab(text: "Present"),
              Tab(text: "Absent"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PresentTab(sessionId: sessionId),
            AbsentTab(sessionId: sessionId),
          ],
        ),
      ),
    );
  }
}

class StatsTab extends StatefulWidget {
  final String subject;

  StatsTab({required this.subject});

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  List<Map<String, dynamic>> studentStats = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    setState(() => loading = true);

    // 1️⃣ Get sessions for subject
    final sessionsSnap = await FirebaseFirestore.instance
        .collection('sessions')
        .where('subject', isEqualTo: widget.subject)
        .get();

    List<QueryDocumentSnapshot> sessions = sessionsSnap.docs;

    if (sessions.isEmpty) {
      setState(() {
        studentStats = [];
        loading = false;
      });
      return;
    }

    // 2️⃣ Get classId from first session
    String classId = sessions.first['classId'];

    // 3️⃣ Get ONLY students of this class
    final classDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .get();

    List<String> classStudents =
    List<String>.from(classDoc.data()?['students'] ?? []);

    int totalSessions = sessions.length;

    // 4️⃣ Get attendance only for these sessions
    final attendanceSnap = await FirebaseFirestore.instance
        .collection('attendance')
        .where('sessionId',
        whereIn: sessions.length > 10
            ? sessions.map((e) => e.id).toList().sublist(0, 10)
            : sessions.map((e) => e.id).toList())
        .get();

    // 5️⃣ Count attendance
    Map<String, int> attendanceCount = {};

    for (var doc in attendanceSnap.docs) {
      String email = doc['studentEmail'];

      // 🔥 IMPORTANT FILTER
      if (!classStudents.contains(email)) continue;

      attendanceCount[email] = (attendanceCount[email] ?? 0) + 1;
    }

    // 6️⃣ Build stats ONLY for class students
    List<Map<String, dynamic>> temp = [];

    for (String email in classStudents) {
      int present = attendanceCount[email] ?? 0;

      double percentage =
      totalSessions == 0 ? 0 : (present / totalSessions) * 100;

      temp.add({
        'email': email,
        'percentage': percentage,
      });
    }

    temp.sort((a, b) =>
        (b['percentage'] as double).compareTo(a['percentage'] as double));

    setState(() {
      studentStats = temp;
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          strokeWidth: 3,
        ),
      );
    }

    if (studentStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_rounded,
                size: 64,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No stats available",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      physics: const BouncingScrollPhysics(),
      itemCount: studentStats.length,
      itemBuilder: (context, index) {
        final student = studentStats[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF94A3B8).withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    student['email'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['email'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: student['percentage'] / 100,
                        backgroundColor: const Color(0xFFF1F5F9), // Slate-100 track
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "${student['percentage'].toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ---------------- PRESENT TAB ---------------- */

class PresentTab extends StatelessWidget {
  final String sessionId;

  PresentTab({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .where('sessionId', isEqualTo: sessionId)
          .where('status', isEqualTo: 'present')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
              strokeWidth: 3,
            ),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.how_to_reg_rounded,
                    size: 64,
                    color: Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No present students",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          physics: const BouncingScrollPhysics(),
          children: docs.map((doc) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF94A3B8).withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4), // Soft green
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.check_rounded, color: Color(0xFF22C55E)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        doc['studentEmail'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/* ---------------- ABSENT TAB (FIXED NO RELOAD) ---------------- */

class AbsentTab extends StatefulWidget {
  final String sessionId;

  AbsentTab({required this.sessionId});

  @override
  State<AbsentTab> createState() => _AbsentTabState();
}

class _AbsentTabState extends State<AbsentTab>
    with AutomaticKeepAliveClientMixin {
  List<String> absentStudents = [];
  bool loading = true;
  bool loaded = false;

  @override
  bool get wantKeepAlive => true; // 🔥 IMPORTANT FIX

  @override
  void initState() {
    super.initState();
    loadAbsent();
  }

  Future<void> loadAbsent() async {
    print("👉 loadAbsent called for session: ${widget.sessionId}");

    if (loaded) return;

    setState(() => loading = true);

    final sessionDoc = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .get();

    final data = sessionDoc.data() as Map<String, dynamic>?;

    final classId = data?['classId'];

    if (classId == null) {
      if (mounted) {
        setState(() {
          loading = false;
          absentStudents = [];
        });
      }
      return;
    }

    final classDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .get();

    final classData = classDoc.data() as Map<String, dynamic>?;

    List<String> students =
    List<String>.from(classData?['students'] ?? []);

    final presentSnap = await FirebaseFirestore.instance
        .collection('attendance')
        .where('sessionId', isEqualTo: widget.sessionId)
        .where('status', isEqualTo: 'present')
        .get();

    Set<String> present = presentSnap.docs
        .map((e) => e['studentEmail'].toString())
        .toSet();

    absentStudents =
        students.where((s) => !present.contains(s)).toList();

    loaded = true;

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 🔥 REQUIRED for keep alive

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
          strokeWidth: 3,
        ),
      );
    }

    if (absentStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 64,
                color: Color(0xFF22C55E),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No absent students 🎉",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      physics: const BouncingScrollPhysics(),
      itemCount: absentStudents.length,
      itemBuilder: (context, index) {
        final email = absentStudents[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF94A3B8).withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2), // Soft red
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 28),
                    tooltip: "Mark as Present manually",
                    onPressed: () async {
                      final existing = await FirebaseFirestore.instance
                          .collection('attendance')
                          .where('sessionId', isEqualTo: widget.sessionId)
                          .where('studentEmail', isEqualTo: email)
                          .get();

                      if (existing.docs.isEmpty) {
                        await FirebaseFirestore.instance
                            .collection('attendance')
                            .add({
                          'sessionId': widget.sessionId,
                          'studentEmail': email,
                          'status': 'present',
                          'timestamp': DateTime.now(),
                        });
                      }

                      setState(() {
                        absentStudents.remove(email);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ---------------- SESSION STATS (NOT IN USE ANYMORE) ---------------- */

class SessionStatsTab extends StatelessWidget {
  final String sessionId;

  SessionStatsTab({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Removed (redundant)",
        style: TextStyle(
          color: Color(0xFF94A3B8), // Muted slate look
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
