// Text of the in-app Privacy policy and Terms of use.
//
// Written for India first: the Digital Personal Data Protection Act 2023 and
// Rules 2025 (notice, consent, rights, grievances, children), the IT Act 2000
// and Intermediary Rules 2021 (user agreement, prohibited content, Grievance
// Officer), Apple App Review 1.2 / 5.1.1 and Google Play's User Data policy.
// Have a lawyer review it before the production launch, and keep it in step
// with what the app really collects (docs/ARCHITECTURE.md, AGENTS.md §9).

/// Facts the legal pages need. The bracketed values must be filled in before
/// launch; they are kept here so they are changed in one place.
abstract final class LegalInfo {
  static const appName = 'Clarity';
  static const company = '[Company legal name]';
  static const address = '[Registered office address]';
  static const grievanceOfficer = '[Grievance Officer name]';
  static const contactEmail = '[support email]';
  static const grievanceEmail = '[grievance email]';
  static const courtsCity = '[City]';
  static const lastUpdated = '12 October 2026';
}

/// A paragraph or bullet in a [LegalSection].
sealed class LegalBlock {
  const LegalBlock(this.text);
  final String text;
}

class LegalParagraph extends LegalBlock {
  const LegalParagraph(super.text);
}

class LegalBullet extends LegalBlock {
  const LegalBullet(super.text);
}

class LegalSection {
  const LegalSection(this.heading, this.blocks);
  final String heading;
  final List<LegalBlock> blocks;
}

/// One legal page: the Privacy policy or the Terms of use.
class LegalDoc {
  const LegalDoc({required this.title, required this.intro, required this.sections});

  final String title;
  final String intro;
  final List<LegalSection> sections;

  static const privacy = LegalDoc(
    title: 'Privacy policy',
    intro:
        '${LegalInfo.appName} is a map of the places you have been, shared with your friends. This policy explains '
        'what personal data we collect, why, who can see it, how long we keep it, and the rights you have. '
        'We do not sell your data, show ads, or use analytics or tracking tools.',
    sections: [
      LegalSection('1. Who we are', [
        LegalParagraph(
          '${LegalInfo.appName} is provided by ${LegalInfo.company}, ${LegalInfo.address} ("we", "us"). '
          'For the Digital Personal Data Protection Act, 2023 we are the Data Fiduciary for your personal data. '
          'Contact us at ${LegalInfo.contactEmail}.',
        ),
      ]),
      LegalSection('2. What we collect', [
        LegalBullet(
          'Phone number. Used to sign you in with a one-time code and to let friends who already have your '
          'number find you. It is never shown on your profile.',
        ),
        LegalBullet('Profile. Your name, username, home city, avatar colours and profile photo, if you add one.'),
        LegalBullet(
          'What you post. Places you add, and for each visit: the date, your rating, whether you recommend it, '
          'your tip, tags, budget per person and photos. Also places you save, lists you make or join, '
          'questions you ask, replies and likes.',
        ),
        LegalBullet('Friends. Friend requests you send, receive, accept or remove.'),
        LegalBullet(
          'Contacts, only if you tap "Find friends" and allow access. The phone numbers in your address book are '
          'sent to us only to check which belong to people already using ${LegalInfo.appName}. Numbers that do not '
          'match are discarded straight away. We never store, log or upload the names or numbers of people who '
          'are not users.',
        ),
        LegalBullet(
          'Location, only when you use a feature that needs it, such as "I\'m here" or places near you, and only '
          'if you allow it. We use it to check you are at a place and to show nearby places. We do not track your '
          'location in the background.',
        ),
        LegalBullet(
          'Photos, only the ones you choose to add to a review. We do not access the rest of your photo library.',
        ),
        LegalBullet(
          'Technical data. Sign-in session tokens, and basic server logs (such as IP address, time and errors) kept '
          'by our hosting provider for security and to fix problems.',
        ),
      ]),
      LegalSection('3. Why we use it', [
        LegalParagraph(
          'We process your personal data with your consent, which you give when you create an account and when '
          'you allow a feature such as contacts or location. We use it to:',
        ),
        LegalBullet('create and secure your account;'),
        LegalBullet('show your map and reviews to the people you choose;'),
        LegalBullet('help you find friends and see their reviews;'),
        LegalBullet('send notifications you have turned on;'),
        LegalBullet('keep the service safe, stop abuse and fix problems;'),
        LegalBullet('meet our legal obligations.'),
        LegalParagraph('We do not use your data for advertising and we do not sell it.'),
      ]),
      LegalSection('4. Who can see what you post', [
        LegalParagraph(
          'Your profile visibility setting decides who sees your map and reviews: Public (anyone with your link), '
          'Friends, or Only me. Members of a list can see what is added to that list. Your phone number is never '
          'shown to anyone. You can change visibility at any time in Settings.',
        ),
      ]),
      LegalSection('5. Who we share data with', [
        LegalParagraph(
          'We share personal data only with service providers that run parts of ${LegalInfo.appName} for us, '
          'under contracts that require them to protect it and use it only for that purpose:',
        ),
        LegalBullet('Supabase: database, sign-in and photo storage.'),
        LegalBullet('Our SMS provider: sends your one-time sign-in code to your phone number.'),
        LegalBullet('Apple and Google: deliver push notifications, if you turn them on.'),
        LegalBullet('Google Maps Platform: shows the map and place details.'),
        LegalParagraph(
          'We may also disclose data when Indian law requires it, for example to a court or a government agency '
          'with lawful authority, or to protect the safety of our users.',
        ),
      ]),
      LegalSection('6. Where your data is stored', [
        LegalParagraph(
          'Our providers may store and process data on servers outside India. We transfer data only as permitted '
          'under the Digital Personal Data Protection Act, 2023 and with the same protection described here.',
        ),
      ]),
      LegalSection('7. How long we keep it', [
        LegalBullet('Your account data and posts: for as long as your account exists.'),
        LegalBullet(
          'When you delete your account (Settings → Delete account), your profile, visits, lists, friendships and '
          'notifications are deleted immediately. Photos are removed from storage within 30 days, and backups '
          'roll over within 30 days.',
        ),
        LegalBullet(
          'We may keep limited records longer when the law requires it, for example information connected with a '
          'legal complaint or an investigation.',
        ),
      ]),
      LegalSection('8. Your rights', [
        LegalParagraph('Under the Digital Personal Data Protection Act, 2023 you have the right to:'),
        LegalBullet('get a summary of the personal data we hold about you and who we have shared it with;'),
        LegalBullet('correct, complete or update it, most of which you can do in the app;'),
        LegalBullet('have it erased, by deleting your account in Settings or by writing to us;'),
        LegalBullet(
          'withdraw consent at any time, as easily as you gave it: turn off contact sync or "Let people find me by '
          'number" in Settings, remove a permission in your phone\'s settings, or delete your account. '
          'Withdrawing does not affect processing that happened before;',
        ),
        LegalBullet('nominate someone to exercise these rights if you die or become unable to;'),
        LegalBullet('have your grievances addressed (section 12).'),
        LegalParagraph(
          'To use any of these rights, email ${LegalInfo.grievanceEmail} from the app\'s Settings or with your '
          'username. We reply within the time the law allows.',
        ),
      ]),
      LegalSection('9. Children', [
        LegalParagraph(
          '${LegalInfo.appName} is only for people aged 18 or over. We do not knowingly collect personal data from '
          'anyone under 18. If you believe a child has created an account, tell us and we will delete it.',
        ),
      ]),
      LegalSection('10. Security', [
        LegalParagraph(
          'Data is encrypted in transit. Access is limited by strict database rules so that people can only read '
          'what they are allowed to see, and only a few authorised staff can reach the systems. If a personal data '
          'breach affects you, we will tell you and the Data Protection Board of India as the law requires.',
        ),
      ]),
      LegalSection('11. Changes to this policy', [
        LegalParagraph(
          'If we change this policy we will tell you in the app before the change takes effect, and we will remind '
          'you of it at least once a year. The date at the top shows the latest version.',
        ),
      ]),
      LegalSection('12. Grievance Officer', [
        LegalParagraph(
          'Grievance Officer: ${LegalInfo.grievanceOfficer}, ${LegalInfo.company}, ${LegalInfo.address}. '
          'Email: ${LegalInfo.grievanceEmail}.',
        ),
        LegalParagraph(
          'We acknowledge complaints within 24 hours and resolve them within 15 days. If you are not satisfied '
          'with our response, you can complain to the Data Protection Board of India.',
        ),
      ]),
    ],
  );

  static const terms = LegalDoc(
    title: 'Terms of use',
    intro:
        'These terms are the agreement between you and ${LegalInfo.company} for using ${LegalInfo.appName}. '
        'By creating an account or using the app you accept them. Please read them together with our '
        'Privacy policy.',
    sections: [
      LegalSection('1. Who can use it', [
        LegalBullet('You must be 18 or older.'),
        LegalBullet('You need a mobile number you own. One account per person.'),
        LegalBullet('You must give accurate information and must not pretend to be someone else.'),
      ]),
      LegalSection('2. Your account', [
        LegalParagraph(
          'Keep your phone and sign-in codes to yourself. You are responsible for what happens on your account. '
          'Tell us straight away at ${LegalInfo.contactEmail} if you think someone else is using it.',
        ),
      ]),
      LegalSection('3. Your reviews and photos', [
        LegalParagraph(
          'You own what you post. You give us a non-exclusive, royalty-free, worldwide licence to store, show and '
          'share it inside ${LegalInfo.appName} as your privacy settings allow, and to make copies needed to run '
          'the service. The licence ends when you delete the content or your account, except for backups that '
          'roll over and copies other people have saved to a shared list.',
        ),
        LegalParagraph(
          'Reviews must be your honest opinion of a place you have actually visited. Do not post reviews you were '
          'paid for or rewarded for without saying so, reviews of your own business or a competitor\'s, or reviews '
          'written for someone else.',
        ),
      ]),
      LegalSection('4. What you must not post or do', [
        LegalParagraph(
          'We have zero tolerance for objectionable content and abusive users. You must not post, share or send '
          'anything that:',
        ),
        LegalBullet('belongs to someone else and you have no right to share;'),
        LegalBullet(
          'is defamatory, obscene, pornographic, paedophilic, invasive of another person\'s privacy (including '
          'bodily privacy), insulting or harassing on the basis of gender, or racially or ethnically '
          'objectionable;',
        ),
        LegalBullet('relates to or encourages money laundering, gambling or other illegal activity;'),
        LegalBullet('is harmful to children;'),
        LegalBullet('infringes a patent, trademark, copyright or other proprietary right;'),
        LegalBullet('deceives or misleads people about where it came from, or is knowingly false or misleading;'),
        LegalBullet('impersonates another person;'),
        LegalBullet(
          'threatens the unity, integrity, defence, security or sovereignty of India, friendly relations with '
          'other countries, or public order, or incites an offence;',
        ),
        LegalBullet('contains viruses or other harmful code;'),
        LegalBullet('breaks any law in force.'),
        LegalParagraph(
          'You also must not spam people with friend requests, harass or threaten anyone, collect other users\' '
          'data, scrape or copy the service, or try to get around our security.',
        ),
      ]),
      LegalSection('5. Reporting and blocking', [
        LegalParagraph(
          'Report a review, photo, list or person that breaks these terms by writing to ${LegalInfo.grievanceEmail}. '
          'You can remove a friend at any time to stop them seeing your friends-only content. We review reports '
          'promptly, and act on requests to remove content that invades privacy, is sexual, or impersonates '
          'someone within 72 hours of the report. We act on other complaints within 15 days.',
        ),
      ]),
      LegalSection('6. What we can do', [
        LegalParagraph(
          'If you break these terms or the law, we may remove your content, limit your account, or suspend or '
          'close it. Where the law requires, we keep information about removed content and closed accounts for '
          'the period it sets, and share it with authorities that lawfully ask for it.',
        ),
      ]),
      LegalSection('7. Other services', [
        LegalParagraph(
          'Maps and some place information come from third parties such as Google Maps. Their own terms apply to '
          'that content, and we are not responsible for its accuracy.',
        ),
      ]),
      LegalSection('8. Reviews are opinions', [
        LegalParagraph(
          'Reviews are the personal opinions of the people who wrote them, not ours. Places change: prices, '
          'opening hours, safety and access may differ from what a review says. Check before you go, and take '
          'care on treks, roads and remote places. You visit places at your own risk.',
        ),
      ]),
      LegalSection('9. The service', [
        LegalParagraph(
          'We work to keep ${LegalInfo.appName} running and safe, but we provide it "as is" and "as available". '
          'We may change, add or remove features, and may stop the service with reasonable notice.',
        ),
      ]),
      LegalSection('10. Liability', [
        LegalParagraph(
          'To the extent the law allows, we are not liable for indirect or consequential losses, or for content '
          'posted by other users. Nothing in these terms limits liability that cannot be limited under Indian '
          'law. You agree to cover our losses if a claim is made against us because of content you posted or '
          'your breach of these terms.',
        ),
      ]),
      LegalSection('11. Leaving', [
        LegalParagraph(
          'You can stop using ${LegalInfo.appName} and delete your account at any time in Settings → Delete '
          'account. What happens to your data is explained in the Privacy policy.',
        ),
      ]),
      LegalSection('12. Changes to these terms', [
        LegalParagraph(
          'We will tell you in the app before important changes take effect, and remind you of these terms at '
          'least once a year. If you keep using the app after a change, the new terms apply.',
        ),
      ]),
      LegalSection('13. Law and disputes', [
        LegalParagraph(
          'These terms are governed by the laws of India. Courts in ${LegalInfo.courtsCity} have jurisdiction, '
          'without affecting any right you have to go to a consumer forum.',
        ),
      ]),
      LegalSection('14. Grievance Officer and contact', [
        LegalParagraph(
          'Grievance Officer: ${LegalInfo.grievanceOfficer}, ${LegalInfo.company}, ${LegalInfo.address}. '
          'Email: ${LegalInfo.grievanceEmail}. We acknowledge complaints within 24 hours.',
        ),
        LegalParagraph(
          'If you disagree with the Grievance Officer\'s decision, you can appeal to the Grievance Appellate '
          'Committee set up by the Government of India within 30 days. For anything else, write to '
          '${LegalInfo.contactEmail}.',
        ),
      ]),
    ],
  );
}
