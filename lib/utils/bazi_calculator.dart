import 'package:flutter/material.dart';

class BaziCalculator {
  static String calculateBazi(DateTime birthDate, TimeOfDay birthTime) {
    // Heavenly Stems and Earthly Branches
    String heavenlyStemYear = _getHeavenlyStem(birthDate.year);
    String earthlyBranchYear = _getEarthlyBranch(birthDate.year);
    String heavenlyStemMonth = _getHeavenlyStem(birthDate.month);
    String earthlyBranchMonth = _getEarthlyBranch(birthDate.month);
    String heavenlyStemDay = _getHeavenlyStem(birthDate.day);
    String earthlyBranchDay = _getEarthlyBranch(birthDate.day);
    String heavenlyStemHour = _getHeavenlyStem(birthTime.hour);
    String earthlyBranchHour = _getEarthlyBranch(birthTime.hour);

    // Day Master
    String dayMaster = _getDayMaster(heavenlyStemDay);

    // Luck Pillars (simplified example)
    List<String> luckPillars = _getLuckPillars(birthDate.year);

    return '''
      Year: $heavenlyStemYear $earthlyBranchYear
      Month: $heavenlyStemMonth $earthlyBranchMonth
      Day: $heavenlyStemDay $earthlyBranchDay (Day Master: $dayMaster)
      Hour: $heavenlyStemHour $earthlyBranchHour
      Luck Pillars: ${luckPillars.join(', ')}
    ''';
  }

  static String _getHeavenlyStem(int value) {
    List<String> stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    return stems[(value - 4) % 10];
  }

  static String _getEarthlyBranch(int value) {
    List<String> branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    return branches[(value - 4) % 12];
  }

  static String _getDayMaster(String heavenlyStemDay) {
    // Simplified logic for Day Master
    Map<String, String> dayMasterMap = {
      '甲': 'Wood',
      '乙': 'Wood',
      '丙': 'Fire',
      '丁': 'Fire',
      '戊': 'Earth',
      '己': 'Earth',
      '庚': 'Metal',
      '辛': 'Metal',
      '壬': 'Water',
      '癸': 'Water',
    };
    return dayMasterMap[heavenlyStemDay] ?? 'Unknown';
  }

  static List<String> _getLuckPillars(int birthYear) {
    // Simplified logic for Luck Pillars
    List<String> luckPillars = [];
    for (int i = 0; i < 10; i++) {
      int year = birthYear + i * 10;
      luckPillars.add('${_getHeavenlyStem(year)} ${_getEarthlyBranch(year)}');
    }
    return luckPillars;
  }
}