class EmailConfig {
  EmailConfig._();

  /// Adresse email de destination pour toutes les fiches scellées
  static const String destinationEmail = 'drissman@gmail.com';

  // ─── EMAILJS ────────────────────────────────────────────────────────────────
  // Pour activer l'envoi automatique via EmailJS (gratuit — 200 emails/mois) :
  //
  // 1. Créer un compte sur https://www.emailjs.com/
  // 2. Ajouter un service Gmail : Email Services > Add New Service > Gmail
  //    → Copier le "Service ID" ci-dessous
  // 3. Créer un template : Email Templates > Create New Template
  //    Corps du template (exemple) :
  //      Sujet  : {{subject}}
  //      À      : {{to_email}}
  //      Message: {{message}}
  //    → Copier le "Template ID" ci-dessous
  // 4. Account > API Keys > copier le "Public Key" ci-dessous
  // ────────────────────────────────────────────────────────────────────────────
  static const String emailjsServiceId = 'service_5js1hnl';
  static const String emailjsTemplateId = 'template_53y6vn6';
  static const String emailjsPublicKey = 'XWVpaderHkTXgra5f';

  static bool get isEmailJsConfigured =>
      emailjsServiceId != 'YOUR_SERVICE_ID' &&
      emailjsTemplateId != 'YOUR_TEMPLATE_ID' &&
      emailjsPublicKey != 'YOUR_PUBLIC_KEY';
}
