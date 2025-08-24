import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/page/home_backup_event.dart';
import 'package:hino/page/home_backup_playback.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/custom_app_bar.dart';

class HomeBackupPage extends StatefulWidget {
  const HomeBackupPage({Key? key}) : super(key: key);

  @override
  _HomeBackupPageState createState() => _HomeBackupPageState();
}

class _HomeBackupPageState extends State<HomeBackupPage> {
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    List<Color>? colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                colors ?? [ColorCustom.blue, ColorCustom.blue.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppbar.basic(
        title: Languages.of(context)!.tracking_history,
        isLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text(
            //   Languages.of(context)!.tracking_history,
            //   style: GoogleFonts.montserrat(
            //     fontSize: 22,
            //     fontWeight: FontWeight.bold,
            //     color: ColorCustom.blue,
            //   ),
            //   textAlign: TextAlign.left,
            // ),
            // const SizedBox(height: 24),

            // Nút Event
            _buildMenuButton(
              icon: Icons.history,
              label: Languages.of(context)!.tracking_history,
              colors: [ColorCustom.blue, Colors.lightBlueAccent],
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const HomeBackupEventPage()));
              },
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              icon: Icons.videocam_rounded,
              label: Languages.of(context)!.cctv_playback,
              colors: [ColorCustom.blue, Colors.lightBlueAccent],
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const HomeBackupPlaybackPage()));
              },
            ),

            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "© Onelink Technology Co., Ltd.",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
