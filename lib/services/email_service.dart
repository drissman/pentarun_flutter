import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pentarun_flutter/config/email_config.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';

class EmailService {
  EmailService._();

  static String _buildBody(Athlete athlete) {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}'
        ' à ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return '''PENTARUN — FICHE RÉSULTAT OFFICIELLE
════════════════════════════════════════

ATHLÈTE        : ${athlete.name}
NIVEAU         : ${athlete.level.label}
KETTLEBELL     : ${athlete.weightKb} kg
MORPHO         : ${athlete.heightAthlete} cm / ${athlete.weightAthlete} kg
COEFFICIENT    : ${athlete.coeff.toStringAsFixed(3)}

PERFORMANCE
───────────
Temps brut     : ${TimeFormatter.format(athlete.finalTimeMs)}
Score officiel : ${TimeFormatter.format(athlete.officialScore?.round())}
No-Count       : ${athlete.noCountEvents}

BILAN MÉTABOLIQUE
─────────────────
Course         : ${athlete.energy.run.round()} kcal
Acier          : ${athlete.energy.steel.round()} kcal
Total EPOC×1.15: ${athlete.energy.total.round()} kcal

════════════════════════════════════════
Transmis le $date
via PENTARUN v1.2 — pentarun.netlify.app''';
  }

  /// Ouvre le client email avec la fiche pré-remplie
  static Future<void> sendViaMailto(Athlete athlete) async {
    final subject =
        Uri.encodeComponent('PENTARUN — Résultat: ${athlete.name}');
    final body = Uri.encodeComponent(_buildBody(athlete));
    final uri = Uri.parse(
        'mailto:${EmailConfig.destinationEmail}?subject=$subject&body=$body');
    await launchUrl(uri);
  }

  /// Envoi automatique via l'API EmailJS (nécessite configuration dans email_config.dart)
  static Future<bool> sendViaEmailJS(Athlete athlete) async {
    if (!EmailConfig.isEmailJsConfigured) return false;
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': EmailConfig.emailjsServiceId,
          'template_id': EmailConfig.emailjsTemplateId,
          'user_id': EmailConfig.emailjsPublicKey,
          'template_params': {
            'to_email': EmailConfig.destinationEmail,
            'athlete_name': athlete.name,
            'subject': 'PENTARUN — Résultat: ${athlete.name}',
            'message': _buildBody(athlete),
          },
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
