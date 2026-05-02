
enum Language {
  english,
  telugu,
  hindi;

  String get apiCode {
    switch (this) {
      case Language.english:
        return 'en';
      case Language.telugu:
        return 'te';
      case Language.hindi:
        return 'hi';
    }
  }
}

class AppTranslations {
  static Language currentLanguage = Language.english;

  static final Map<String, Map<Language, String>> _strings = {
    // ========== App Common ==========
    'app_name': {
      Language.english: 'Med Rayder',
      Language.telugu: 'మెడ్ రేడర్',
      Language.hindi: 'मेड रेडर',
    },

    // ========== Login Screen ==========
    'login': {
      Language.english: 'Login',
      Language.telugu: 'లాగిన్',
      Language.hindi: 'लॉगिन',
    },
    'enter_phone_number': {
      Language.english: 'Enter Phone Number',
      Language.telugu: 'ఫోన్ నంబర్ నమోదు చేయండి',
      Language.hindi: 'फोन नंबर दर्ज करें',
    },
    'continue_text': {
      Language.english: 'Continue',
      Language.telugu: 'కొనసాగించు',
      Language.hindi: 'जारी रखें',
    },
    'otp_sent': {
      Language.english: 'OTP sent successfully',
      Language.telugu: 'OTP విజయవంతంగా పంపబడింది',
      Language.hindi: 'OTP सफलतापूर्वक भेजा गया',
    },

    // ========== OTP Screen ==========
    'otp_verification': {
      Language.english: 'OTP Verification',
      Language.telugu: 'OTP ధృవీకరణ',
      Language.hindi: 'OTP सत्यापन',
    },
    'otp_sent_to_mobile': {
      Language.english: 'OTP sent to your mobile number',
      Language.telugu: 'OTP మీ మొబైల్ నంబర్‌కు పంపబడింది',
      Language.hindi: 'OTP आपके मोबाइल नंबर पर भेजा गया है',
    },
    'enter_otp': {
      Language.english: 'Enter 6-digit OTP',
      Language.telugu: '6 అంకెల OTP నమోదు చేయండి',
      Language.hindi: '6 अंकों का OTP दर्ज करें',
    },
    'verify': {
      Language.english: 'Verify',
      Language.telugu: 'ధృవీకరించు',
      Language.hindi: 'सत्यापित करें',
    },

    // ========== Home Screen ==========
    'home': {
      Language.english: 'Home',
      Language.telugu: 'హోమ్',
      Language.hindi: 'होम',
    },
    'search_hint': {
      Language.english: 'Search doctors, medicines, diagnostics...',
      Language.telugu: 'డాక్టర్లు, మందులు, డయాగ్నస్టిక్స్... శోధించండి',
      Language.hindi: 'डॉक्टर, दवाएं, डायग्नोस्टिक्स खोजें...',
    },
    'online_doctors': {
      Language.english: 'Online Doctors',
      Language.telugu: 'ఆన్‌లైన్ డాక్టర్లు',
      Language.hindi: 'ऑनलाइन डॉक्टर',
    },
    'offline_doctors': {
      Language.english: 'Offline Doctors',
      Language.telugu: 'ఆఫ్‌లైన్ డాక్టర్లు',
      Language.hindi: 'ऑफ़लाइन डॉक्टर',
    },
    'pharmacy': {
      Language.english: 'Pharmacy',
      Language.telugu: 'ఫార్మసీ',
      Language.hindi: 'फार्मेसी',
    },
    'diagnostic': {
      Language.english: 'Diagnostic',
      Language.telugu: 'డయాగ్నస్టిక్',
      Language.hindi: 'डायग्नोस्टिक',
    },
    'lab': {
      Language.english: 'Lab Tests',
      Language.telugu: 'ల్యాబ్ పరీక్షలు',
      Language.hindi: 'लैब टेस्ट',
    },
    'ambulance': {
      Language.english: 'Ambulance',
      Language.telugu: 'అంబులెన్స్',
      Language.hindi: 'एम्बुलेंस',
    },

    // ========== Profile Screen ==========
    'profile': {
      Language.english: 'Profile',
      Language.telugu: 'ప్రొఫైల్',
      Language.hindi: 'प्रोफ़ाइल',
    },
    'name': {
      Language.english: 'Name',
      Language.telugu: 'పేరు',
      Language.hindi: 'नाम',
    },
    'email': {
      Language.english: 'Email',
      Language.telugu: 'ఇమెయిల్',
      Language.hindi: 'ईमेल',
    },
    'mobile': {
      Language.english: 'Mobile',
      Language.telugu: 'మొబైల్',
      Language.hindi: 'मोबाइल',
    },
    'blood_group': {
      Language.english: 'Blood Group',
      Language.telugu: 'బ్లడ్ గ్రూప్',
      Language.hindi: 'ब्लड ग्रुप',
    },
    'coverage_category': {
      Language.english: 'Coverage Category',
      Language.telugu: 'కవరేజ్ వర్గం',
      Language.hindi: 'कवरेज श्रेणी',
    },
    'gender': {
      Language.english: 'Gender',
      Language.telugu: 'లింగం',
      Language.hindi: 'लिंग',
    },
    'date_of_birth': {
      Language.english: 'Date of Birth',
      Language.telugu: 'పుట్టిన తేదీ',
      Language.hindi: 'जन्म तिथि',
    },
    'edit': {
      Language.english: 'Edit',
      Language.telugu: 'సవరించు',
      Language.hindi: 'संपादित करें',
    },
    'update': {
      Language.english: 'Update',
      Language.telugu: 'నవీకరించు',
      Language.hindi: 'अपडेट करें',
    },

    // ========== Side Menu / Drawer ==========
    'menu': {
      Language.english: 'Menu',
      Language.telugu: 'మెను',
      Language.hindi: 'मेनू',
    },
    'my_orders': {
      Language.english: 'My Orders',
      Language.telugu: 'నా ఆర్డర్లు',
      Language.hindi: 'मेरे आदेश',
    },
    'wishlist': {
      Language.english: 'Wishlist',
      Language.telugu: 'విష్‌లిస్ట్',
      Language.hindi: 'विशलिस्ट',
    },
    'about': {
      Language.english: 'About',
      Language.telugu: 'గురించి',
      Language.hindi: 'के बारे में',
    },
    'contact_us': {
      Language.english: 'Contact Us',
      Language.telugu: 'మమ్మల్ని సంప్రదించండి',
      Language.hindi: 'संपर्क करें',
    },
    'logout': {
      Language.english: 'Logout',
      Language.telugu: 'లాగౌట్',
      Language.hindi: 'लॉगआउट',
    },

    // ========== Common ==========
    'submit': {
      Language.english: 'Submit',
      Language.telugu: 'సమర్పించు',
      Language.hindi: 'जमा करें',
    },
    'cancel': {
      Language.english: 'Cancel',
      Language.telugu: 'రద్దు చేయండి',
      Language.hindi: 'रद्द करें',
    },
    'save': {
      Language.english: 'Save',
      Language.telugu: 'సేవ్ చేయండి',
      Language.hindi: 'सहेजें',
    },
    'loading': {
      Language.english: 'Loading...',
      Language.telugu: 'లోడ్ అవుతోంది...',
      Language.hindi: 'लोड हो रहा है...',
    },
    'no_internet': {
      Language.english: 'No internet connection',
      Language.telugu: 'ఇంటర్నెట్ కనెక్షన్ లేదు',
      Language.hindi: 'इंटरनेट कनेक्शन नहीं है',
    },
  };

  static String get(String key) {
    return _strings[key]?[currentLanguage] ??
        _strings[key]?[Language.english] ??
        'Missing: $key';
  }

  // Convenience method to change language globally
  static void setLanguage(Language lang) {
    currentLanguage = lang;
  }
}

// Extension for easy access in widgets
extension Translate on String {
  String tr() => AppTranslations.get(this);
}