class Helpers {
  // Gender mapping
  static String getGenderString(dynamic genderCode) {
    switch (genderCode) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      default:
        return 'Other';
    }
  }

  static int getGenderCode(String genderString) {
    switch (genderString.toLowerCase()) {
      case 'male':
        return 1;
      case 'female':
        return 2;
      default:
        return 0;
    }
  }

  // Blood group mapping (extend as needed)
  static String getBloodGroupString(dynamic bloodGroupCode) {
    switch (bloodGroupCode) {
      case 1:
        return 'A+';
      case 2:
        return 'A-';
      case 3:
        return 'B+';
      case 4:
        return 'B-';
      case 5:
        return 'O+';
      case 6:
        return 'O-';
      case 7:
        return 'AB+';
      case 8:
        return 'AB-';
      default:
        return 'Not specified';
    }
  }

  static int getBloodGroupCode(String bloodGroupString) {
    switch (bloodGroupString) {
      case 'A+':
        return 1;
      case 'A-':
        return 2;
      case 'B+':
        return 3;
      case 'B-':
        return 4;
      case 'O+':
        return 5;
      case 'O-':
        return 6;
      case 'AB+':
        return 7;
      case 'AB-':
        return 8;
      default:
        return 0;
    }
  }
  // Coverage category mapping
  static String getCoverageString(dynamic code) {
    switch (code) {
      case 0:
        return 'Health Insurance';
      case 1:
        return 'ESIC/EHS/CGHS';
      case 3:
        return 'Aarogya Sree';
      case 4:
        return 'Cash';
      case 5:
        return 'Other';
      case 6:
        return 'Aarogya Sree and Health Insurance';
      default:
        return 'Not specified';
    }
  }

  static int getCoverageCode(String coverageString) {
    switch (coverageString) {
      case 'Health Insurance':
        return 0;
      case 'ESIC/EHS/CGHS':
        return 1;
      case 'Aarogya Sree':
        return 3;
      case 'Cash':
        return 4;
      case 'Other':
        return 5;
      case 'Aarogya Sree and Health Insurance':
        return 6;
      default:
        return 0;
    }
  }
}