import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.backgroundLight,
        title: const Text('POLICY & TERMS', style: TextStyle(letterSpacing: 2)),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: GameColors.backgroundLight,
              child: TabBar(
                indicatorColor: GameColors.primary,
                labelColor: GameColors.primary,
                unselectedLabelColor: GameColors.textDark,
                tabs: const [
                  Tab(text: 'PRIVACY POLICY'),
                  Tab(text: 'TERMS OF SERVICE'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPrivacyPolicy(),
                  _buildTermsOfService(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Privacy Policy'),
          _buildLastUpdated('January 2025'),
          const SizedBox(height: 20),

          _buildSubTitle('1. Information We Collect'),
          _buildParagraph(
            'Astral Strike: Space Battle collects minimal data to provide you with the best gaming experience:\n\n'
            '• Game Progress: Your scores, levels, achievements, and in-game purchases are stored locally on your device.\n\n'
            '• Device Information: Basic device identifiers for crash reporting and analytics.\n\n'
            '• Usage Data: How you interact with the game to improve gameplay experience.',
          ),

          _buildSubTitle('2. How We Use Your Information'),
          _buildParagraph(
            '• To save and restore your game progress\n'
            '• To provide customer support\n'
            '• To improve game performance and fix bugs\n'
            '• To personalize your gaming experience',
          ),

          _buildSubTitle('3. Data Storage'),
          _buildParagraph(
            'All game data is stored locally on your device using secure storage methods. '
            'We do not transfer your personal game data to external servers unless explicitly required for cloud saves (if enabled).',
          ),

          _buildSubTitle('4. Third-Party Services'),
          _buildParagraph(
            'We may use third-party services for:\n\n'
            '• Analytics (to understand game usage)\n'
            '• Crash reporting (to fix bugs)\n'
            '• Advertising (if applicable)\n\n'
            'These services have their own privacy policies.',
          ),

          _buildSubTitle('5. Children\'s Privacy'),
          _buildParagraph(
            'Astral Strike: Space Battle is suitable for all ages. We do not knowingly collect personal information from children under 13. '
            'If you believe we have collected such information, please contact us.',
          ),

          _buildSubTitle('6. Your Rights'),
          _buildParagraph(
            'You have the right to:\n\n'
            '• Access your data\n'
            '• Delete your data (via Reset Progress in Settings)\n'
            '• Opt-out of analytics\n'
            '• Contact us with privacy concerns',
          ),

          _buildSubTitle('7. Contact Us'),
          _buildParagraph(
            'If you have questions about this Privacy Policy, please contact us at:\n\n'
            'Email: support@spaceshooter.game',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTermsOfService() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Terms of Service'),
          _buildLastUpdated('January 2025'),
          const SizedBox(height: 20),

          _buildSubTitle('1. Acceptance of Terms'),
          _buildParagraph(
            'By downloading, installing, or playing Astral Strike: Space Battle, you agree to be bound by these Terms of Service. '
            'If you do not agree to these terms, please do not use the game.',
          ),

          _buildSubTitle('2. Game License'),
          _buildParagraph(
            'We grant you a limited, non-exclusive, non-transferable, revocable license to use Astral Strike: Space Battle for personal, '
            'non-commercial entertainment purposes only.',
          ),

          _buildSubTitle('3. User Conduct'),
          _buildParagraph(
            'You agree NOT to:\n\n'
            '• Modify, hack, or reverse engineer the game\n'
            '• Use cheats, exploits, or automation software\n'
            '• Distribute or sell the game or its content\n'
            '• Use the game for any illegal purpose\n'
            '• Attempt to gain unauthorized access to game systems',
          ),

          _buildSubTitle('4. Virtual Items & Currency'),
          _buildParagraph(
            '• In-game coins and items are virtual goods with no real-world value\n'
            '• Virtual items cannot be exchanged for real money\n'
            '• We reserve the right to modify virtual item values and availability\n'
            '• Lost progress due to device issues is not our responsibility',
          ),

          _buildSubTitle('5. Intellectual Property'),
          _buildParagraph(
            'All content in Astral Strike: Space Battle, including graphics, sounds, code, and gameplay mechanics, '
            'are owned by us and protected by copyright laws. You may not copy, modify, or distribute any game content.',
          ),

          _buildSubTitle('6. Disclaimer of Warranties'),
          _buildParagraph(
            'Astral Strike: Space Battle is provided "AS IS" without warranties of any kind. We do not guarantee:\n\n'
            '• Uninterrupted or error-free gameplay\n'
            '• Compatibility with all devices\n'
            '• Preservation of game data',
          ),

          _buildSubTitle('7. Limitation of Liability'),
          _buildParagraph(
            'We are not liable for any damages arising from your use of Astral Strike: Space Battle, including but not limited to '
            'loss of data, device damage, or any indirect damages.',
          ),

          _buildSubTitle('8. Changes to Terms'),
          _buildParagraph(
            'We may update these Terms at any time. Continued use of the game after changes constitutes acceptance of the new terms.',
          ),

          _buildSubTitle('9. Termination'),
          _buildParagraph(
            'We reserve the right to terminate your access to the game at any time for violation of these terms.',
          ),

          _buildSubTitle('10. Contact'),
          _buildParagraph(
            'For questions about these Terms, contact us at:\n\n'
            'Email: support@spaceshooter.game',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: GameColors.primary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLastUpdated(String date) {
    return Text(
      'Last Updated: $date',
      style: const TextStyle(
        color: GameColors.textDark,
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildSubTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: GameColors.secondary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: GameColors.text,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}
