
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
    'online_doctor': {
      Language.english: 'Online Doctors',
      Language.telugu: 'ఆన్‌లైన్ డాక్టర్',
      Language.hindi: 'ऑनलाइन डॉक्टर',
    },
    'book_lab_test': {
      Language.english: 'Book Lab Test',
      Language.telugu: 'ల్యాబ్ టెస్ట్ బుక్ చేయండి',
      Language.hindi: 'लैब टेस्ट बुक करें',
    },
    'order_medicine': {
      Language.english: 'Order Medicine',
      Language.telugu: 'మందులు ఆర్డర్ చేయండి',
      Language.hindi: 'दवाई ऑर्डर करें',
    },
    'find_hospitals': {
      Language.english: 'Find Hospitals',
      Language.telugu: 'ఆసుపత్రులను కనుగొనండి',
      Language.hindi: 'अस्पताल खोजें',
    },
    'find_labs': {
      Language.english: 'Find Labs',
      Language.telugu: 'ల్యాబ్లను కనుగొనండి',
      Language.hindi: 'लैब खोजें',
    },
    'find_diagnostics': {
      Language.english: 'Find Diagnostics',
      Language.telugu: 'డయాగ్నస్టిక్స్ కనుగొనండి',
      Language.hindi: 'डायग्नोस्टिक्स खोजें',
    },
    'find_pharmacy': {
      Language.english: 'Find Pharmacy',
      Language.telugu: 'ఫార్మసీని కనుగొనండి',
      Language.hindi: 'फार्मेसी खोजें',
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

    'admission': {
      Language.english: 'Admission',
      Language.telugu: 'అడ్మిషన్',
      Language.hindi: 'प्रवेश',
    },
    'records': {
      Language.english: 'Records',
      Language.telugu: 'రికార్డులు',
      Language.hindi: 'रिकॉर्ड',
    },

    'confirm_booking': {
      Language.english: 'Confirm Booking',
      Language.telugu: 'బుకింగ్ నిర్ధారించండి',
      Language.hindi: 'बुकिंग की पुष्टि करें',
    },
    'book_lab_test': {
      Language.english: 'Book Lab Test',
      Language.telugu: 'ల్యాబ్ టెస్ట్ బుక్ చేయండి',
      Language.hindi: 'लैब टेस्ट बुक करें',
    },
    'med_locker': {
      Language.english: 'Med Locker',
      Language.telugu: 'మెడ్ లాకర్',
      Language.hindi: 'मेड लॉकर',
    },
    'wallet': {
      Language.english: 'Wallet',
      Language.telugu: 'వాలెట్',
      Language.hindi: 'वॉलेट',
    },
    'ecard': {
      Language.english: 'E-Card',
      Language.telugu: 'ఈ-కార్డ్',
      Language.hindi: 'ई-कार्ड',
    },
    'care_plans': {
      Language.english: 'Care Plans',
      Language.telugu: 'కేర్ ప్లాన్లు',
      Language.hindi: 'केयर प्लान्स',
    },
    'my_ecard': {
      Language.english: 'My eCard',
      Language.telugu: 'నా ఈ-కార్డ్',
      Language.hindi: 'माई ई-कार्ड',
    },
    'acko_insurance': {
      Language.english: 'Acko Insurance',
      Language.telugu: 'అక్కో ఇన్సూరెన్స్',
      Language.hindi: 'एको इंश्योरेंस',
    },
    'share': {
      Language.english: 'Share',
      Language.telugu: 'షేర్',
      Language.hindi: 'शेयर',
    },
    'diagnostic_bookings': {
      Language.english: 'Diagnostic Bookings',
      Language.telugu: 'డయాగ్నస్టిక్ బుకింగ్స్',
      Language.hindi: 'डायग्नोस्टिक बुकिंग्स',
    },
    'hospital_diagnostic_bookings': {
      Language.english: 'Hospital Diagnostic Bookings',
      Language.telugu: 'హాస్పిటల్ డయాగ్నస్టిక్ బుకింగ్స్',
      Language.hindi: 'हॉस्पिटल डायग्नोस्टिक बुकिंग्स',
    },
    'hospital_pharmacy_bookings': {
      Language.english: 'Hospital Pharmacy Bookings',
      Language.telugu: 'హాస్పిటల్ ఫార్మసీ బుకింగ్స్',
      Language.hindi: 'हॉस्पिटल फार्मेसी बुकिंग्स',
    },
    'hospital_doctor_bookings': {
      Language.english: 'Hospital Doctor Bookings',
      Language.telugu: 'హాస్పిటల్ డాక్టర్ బుకింగ్స్',
      Language.hindi: 'हॉस्पिटल डॉक्टर बुकिंग्स',
    },
    'lab_test_bookings': { // Corrected from "Lab Text"
      Language.english: 'Lab Test Bookings',
      Language.telugu: 'ల్యాబ్ టెస్ట్ బుకింగ్స్',
      Language.hindi: 'लैब टेस्ट बुकिंग्स',
    },
    'pharmacy_bookings': { // Corrected from "pharmcay"
      Language.english: 'Pharmacy Bookings',
      Language.telugu: 'ఫార్మసీ బుకింగ్స్',
      Language.hindi: 'फार्मेसी बुकिंग्स',
    },
    'online_doctor_bookings': {
      Language.english: 'Online Doctor Bookings',
      Language.telugu: 'ఆన్‌లైన్ డాక్టర్ బుకింగ్స్',
      Language.hindi: 'ऑनलाइन डॉक्टर बुकिंग्स',
    },
    'bookingss': {
      Language.english: 'Bookings',
      Language.telugu: 'బుకింగ్స్',
      Language.hindi: 'बुकिंग्स',
    },


    'add_family_member': {
      Language.english: 'Add Family Member',
      Language.telugu: 'కుటుంబ సభ్యుడిని జోడించండి',
      Language.hindi: 'परिवार के सदस्य को जोड़ें',
    },

    'pharmacy': {
      Language.english: 'Pharmacy',
      Language.telugu: 'ఫార్మసీ',
      Language.hindi: 'फार्मेसी',
    },
    'diagnostics': {
      Language.english: 'Diagnostics',
      Language.telugu: 'డయాగ్నస్టిక్స్',
      Language.hindi: 'डायग्नोस्टिक्स',
    },
    'lab_test': {
      Language.english: 'Lab Test',
      Language.telugu: 'ల్యాబ్ టెస్ట్',
      Language.hindi: 'लैब टेस्ट',
    },
    'hospitals': {
      Language.english: 'Hospitals',
      Language.telugu: 'ఆసుపత్రులు',
      Language.hindi: 'अस्पताल',
    },
    'relationship': {
      Language.english: 'Relationship',
      Language.telugu: 'సంబంధం',
      Language.hindi: 'संबंध',
    },
    'add_member': {
      Language.english: 'Add Member',
      Language.telugu: 'సభ్యుడిని జోడించండి',
      Language.hindi: 'सदस्य जोड़ें',
    },
    'select_speciality': {
      Language.english: 'Select Speciality',
      Language.telugu: 'స్పెషాలిటీ ఎంచుకోండి',
      Language.hindi: 'विशेषता चुनें',
    },
    'all_specialities': {
      Language.english: 'All Specialities',
      Language.telugu: 'అన్ని స్పెషాలిటీలు',
      Language.hindi: 'सभी विशेषताएँ',
    },
    'select_delivery_address': {
      Language.english: 'Select Delivery Address',
      Language.telugu: 'డెలివరీ చిరునామా ఎంచుకోండి',
      Language.hindi: 'डिलीवरी पता चुनें',
    },
    'add_new_address': {
      Language.english: 'Add New Address',
      Language.telugu: 'కొత్త చిరునామా జోడించండి',
      Language.hindi: 'नया पता जोड़ें',
    },
    'add_address': {
      Language.english: 'Add Address',
      Language.telugu: 'చిరునామా జోడించండి',
      Language.hindi: 'पता जोड़ें',
    },
    'confirm': {
      Language.english: 'Confirm',
      Language.telugu: 'నిర్ధారించండి',
      Language.hindi: 'पुष्टि करें',
    },
    'book_lab_test': {
      Language.english: 'Book Lab Test',
      Language.telugu: 'ల్యాబ్ టెస్ట్ బుక్ చేయండి',
      Language.hindi: 'लैब टेस्ट बुक करें',
    },
    'available_today': {
      Language.english: 'Available Today',
      Language.telugu: 'ఈరోజు అందుబాటులో ఉంది',
      Language.hindi: 'आज उपलब्ध',
    },

    'doctor_details': {
      Language.english: 'Doctor Details',
      Language.telugu: 'డాక్టర్ వివరాలు',
      Language.hindi: 'डॉक्टर विवरण',
    },
    'qualification': {
      Language.english: 'Qualification',
      Language.telugu: 'అర్హత',
      Language.hindi: 'योग्यता',
    },
    'experience': {
      Language.english: 'Experience',
      Language.telugu: 'అనుభవం',
      Language.hindi: 'अनुभव',
    },
    'fee': {
      Language.english: 'Fee',
      Language.telugu: 'రుసుము',
      Language.hindi: 'शुल्क',
    },
    'rating': {
      Language.english: 'Rating',
      Language.telugu: 'రేటింగ్',
      Language.hindi: 'रेटिंग',
    },
    'request_booking': {
      Language.english: 'Request Booking',
      Language.telugu: 'బుకింగ్ అభ్యర్థించండి',
      Language.hindi: 'बुकिंग अनुरोध करें',
    },
    'select_time_slot': {
      Language.english: 'Select Time Slot',
      Language.telugu: 'టైమ్ స్లాట్ ఎంచుకోండి',
      Language.hindi: 'टाइम स्लॉट चुनें',
    },
    'select_date': {
      Language.english: 'Select Date',
      Language.telugu: 'తేదీ ఎంచుకోండి',
      Language.hindi: 'तारीख चुनें',
    },
    'available_time_slots': {
      Language.english: 'Available Time Slots',
      Language.telugu: 'అందుబాటులో ఉన్న టైమ్ స్లాట్లు',
      Language.hindi: 'उपलब्ध टाइम स्लॉट',
    },
    'continue_text': { // already have 'continue_text' – use if exists, otherwise add
      Language.english: 'Continue',
      Language.telugu: 'కొనసాగించండి',
      Language.hindi: 'जारी रखें',
    },
    'select_family_member': {
      Language.english: 'Select Family Member',
      Language.telugu: 'కుటుంబ సభ్యుడిని ఎంచుకోండి',
      Language.hindi: 'परिवार के सदस्य को चुनें',
    },
    'appointment_details': {
      Language.english: 'Appointment Details',
      Language.telugu: 'అపాయింట్మెంట్ వివరాలు',
      Language.hindi: 'अपॉइंटमेंट विवरण',
    },
    'date': {
      Language.english: 'Date',
      Language.telugu: 'తేదీ',
      Language.hindi: 'तारीख',
    },
    'time': {
      Language.english: 'Time',
      Language.telugu: 'సమయం',
      Language.hindi: 'समय',
    },
    'patient_details': {
      Language.english: 'Patient Details',
      Language.telugu: 'రోగి వివరాలు',
      Language.hindi: 'मरीज का विवरण',
    },
    'payment_summary': {
      Language.english: 'Payment Summary',
      Language.telugu: 'చెల్లింపు సారాంశం',
      Language.hindi: 'भुगतान सारांश',
    },
    'consultation_fee': {
      Language.english: 'Consultation Fee',
      Language.telugu: 'సంప్రదింపు రుసుము',
      Language.hindi: 'परामर्श शुल्क',
    },
    'total_amount': {
      Language.english: 'Total Amount',
      Language.telugu: 'మొత్తం మొత్తం',
      Language.hindi: 'कुल राशि',
    },
    'apply_coupon': {
      Language.english: 'Apply Coupon',
      Language.telugu: 'కూపన్ వర్తించండి',
      Language.hindi: 'कूपन लागू करें',
    },
    'confirm_and_pay': {
      Language.english: 'Confirm & Pay',
      Language.telugu: 'నిర్ధారించి చెల్లించండి',
      Language.hindi: 'पुष्टि करें और भुगतान करें',
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