import 'package:flutter/material.dart';
import 'package:pentarun_flutter/config/email_config.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/services/email_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class SendDialog extends StatefulWidget {
  final Athlete athlete;
  final VoidCallback onSealed;

  const SendDialog({
    super.key,
    required this.athlete,
    required this.onSealed,
  });

  @override
  State<SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog> {
  bool _loading = false;
  String? _resultMessage;
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: A2Colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                const Icon(Icons.lock_outline, color: A2Colors.cyan, size: 22),
                const SizedBox(width: 12),
                const Text(
                  'TRANSMETTRE LA FICHE',
                  style: TextStyle(
                    color: A2Colors.blanc,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.athlete.name,
              style: const TextStyle(
                color: A2Colors.cyan,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Color(0xFF1F1F1F)),
            ),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: A2Colors.cyan),
                      SizedBox(height: 14),
                      Text(
                        'Envoi en cours...',
                        style: TextStyle(color: A2Colors.gris1, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else if (_resultMessage != null) ...[
              // Message de résultat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _success
                      ? const Color(0xFF052E16)
                      : const Color(0xFF1A0505),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _success ? A2Colors.vert : A2Colors.rouge,
                  ),
                ),
                child: Text(
                  _resultMessage!,
                  style: TextStyle(
                    color: _success ? A2Colors.vert : A2Colors.rouge,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_success)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onSealed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: A2Colors.vert,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text(
                          'SCELLER LA FICHE',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _resultMessage = null),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: A2Colors.gris1,
                          side: const BorderSide(color: Color(0xFF2A2A2A)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('RÉESSAYER'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onSealed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: A2Colors.vert,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.lock, size: 16),
                        label: const Text(
                          'SCELLER QUAND MÊME',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              // Choix du mode d'envoi
              const Text(
                'CHOISIR LE MODE D\'ENVOI',
                style: TextStyle(
                  color: A2Colors.gris2,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // Option mailto
                  Expanded(
                    child: _OptionTile(
                      icon: Icons.email_outlined,
                      label: 'Client Email',
                      sublabel: 'Ouvre votre messagerie\n(Gmail, Outlook…)',
                      color: A2Colors.cyan,
                      onTap: _sendMailto,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Option EmailJS
                  Expanded(
                    child: _OptionTile(
                      icon: Icons.send_outlined,
                      label: 'EmailJS',
                      sublabel: EmailConfig.isEmailJsConfigured
                          ? 'Envoi automatique\nsans client email'
                          : 'Non configuré\n(voir email_config.dart)',
                      color: EmailConfig.isEmailJsConfigured
                          ? A2Colors.vert
                          : A2Colors.gris2,
                      onTap: EmailConfig.isEmailJsConfigured
                          ? _sendEmailJS
                          : _showEmailJSInfo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'ANNULER',
                    style: TextStyle(
                      color: A2Colors.gris2,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendMailto() async {
    setState(() => _loading = true);
    try {
      await EmailService.sendViaMailto(widget.athlete);
      setState(() {
        _loading = false;
        _success = true;
        _resultMessage =
            '✓ Client email ouvert avec la fiche pré-remplie.\n\nEnvoyez le message pour transmettre à ${EmailConfig.destinationEmail}.';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _success = false;
        _resultMessage = '✗ Impossible d\'ouvrir le client email.\n$e';
      });
    }
  }

  void _sendEmailJS() async {
    setState(() => _loading = true);
    final ok = await EmailService.sendViaEmailJS(widget.athlete);
    setState(() {
      _loading = false;
      _success = ok;
      _resultMessage = ok
          ? '✓ Email envoyé avec succès à ${EmailConfig.destinationEmail}.'
          : '✗ Échec de l\'envoi EmailJS.\nVérifiez les identifiants dans email_config.dart.';
    });
  }

  void _showEmailJSInfo() {
    setState(() {
      _success = false;
      _resultMessage = '✗ EmailJS non configuré.\n\n'
          '1. Créer un compte sur emailjs.com\n'
          '2. Connecter un service Gmail\n'
          '3. Créer un template (variables : {{subject}}, {{to_email}}, {{message}})\n'
          '4. Renseigner Service ID, Template ID et Public Key\n'
          '   dans lib/config/email_config.dart';
    });
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: A2Colors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: A2Colors.gris2,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
