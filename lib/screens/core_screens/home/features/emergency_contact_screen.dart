import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ungal_kaavalan/providers/contact_provider.dart';
import 'package:ungal_kaavalan/providers/provider.dart';

class EmergencyContactScreen extends ConsumerWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(emergencyContactProvider);
    final uid = ref.watch(uidProvider); // Fetch UID from provider

    return Scaffold(
      body: Stack(
        children: [
          // Background design with curved shapes
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.go('/landing'),
                      ),
                      const Text(
                        "Emergency Contacts",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const Icon(Icons.people, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              "${contacts.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contact List or Empty State
                Expanded(
                  child: contacts.isEmpty
                      ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "No emergency contacts added",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            contacts[index]['name']!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            contacts[index]['phone']!,
                            style: TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildCircularIconButton(
                                icon: Icons.edit,
                                color: Colors.orange,
                                onPressed: () {
                                  _showAddOrEditContactDialog(
                                    context,
                                    ref,
                                    uid!,
                                    isEditing: true,
                                    index: index,
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildCircularIconButton(
                                icon: Icons.delete,
                                color: Colors.red,
                                onPressed: () async {
                                  ref
                                      .read(emergencyContactProvider.notifier)
                                      .removeContact(index);

                                  final uid = ref.read(uidProvider);

                                  if (uid != null) {
                                    await ref
                                        .read(emergencyContactProvider.notifier)
                                        .saveEmergencyContacts(uid);
                                  }
                                  await ref
                                      .read(emergencyContactProvider.notifier)
                                      .saveContactsToPrefs();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Floating Action Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: FloatingActionButton(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () {
                      _showAddOrEditContactDialog(context, ref, uid!, isEditing: false);
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showAddOrEditContactDialog(
      BuildContext context,
      WidgetRef ref,
      String uid, {
        required bool isEditing,
        int? index,
      }) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    if (isEditing && index != null) {
      final contact = ref.read(emergencyContactProvider)[index];
      nameController.text = contact['name']!;
      phoneController.text = contact['phone']!;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Edit Emergency Contact' : 'Add Emergency Contact',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String name = nameController.text.trim();
                    String phone = phoneController.text.trim();

                    if (name.isNotEmpty && phone.isNotEmpty) {
                      if (isEditing && index != null) {
                        ref
                            .read(emergencyContactProvider.notifier)
                            .editContact(index, name, phone);
                      } else {
                        ref.read(emergencyContactProvider.notifier).addContact(
                          name,
                          phone,
                        );
                      }

                      await ref
                          .read(emergencyContactProvider.notifier)
                          .saveEmergencyContacts(uid);
                      await ref
                          .read(emergencyContactProvider.notifier)
                          .saveContactsToPrefs();

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context); // Close bottom sheet
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter valid details')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                  child: Text(
                    isEditing ? 'Update Contact' : 'Save Contact',
                    style: const TextStyle(color: Colors.white),
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

// Custom painter for the background (same as in HomeScreen)
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4F46E5),  // Indigo
          Color(0xFF1E40AF),  // Dark blue
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Paint background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw decorative shapes
    final shapePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // First shape
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.2,
          size.width,
          size.height * 0.3
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path1, shapePaint);

    // Second shape
    final path2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width * 0.7,
          size.height * 0.8,
          size.width,
          size.height * 0.95
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, shapePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}