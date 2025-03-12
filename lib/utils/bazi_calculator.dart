import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';


class BaziCalculator {
  static Map<String, List<String>> getAstroData(DateTime date, TimeOfDay time) {
    // Create combined DateTime with hour and minute
    DateTime dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    Lunar lunar = Lunar.fromDate(dt);
    EightChar eightChar = lunar.getEightChar();

    return {
      'Hour': _getPillarData(eightChar.getTimeGan(), eightChar.getTimeZhi()),
      'Day': _getPillarData(eightChar.getDayGan(), eightChar.getDayZhi()),
      'Month': _getPillarData(eightChar.getMonthGan(), eightChar.getMonthZhi()),
      'Year': _getPillarData(eightChar.getYearGan(), eightChar.getYearZhi()),
    };
  }

  static List<String> _getPillarData(String gan, String zhi) {
    return [
      gan,
      zhi,
      _getHiddenStems(zhi),
      _getNaYin(gan, zhi),
      _getStars(gan, zhi),
    ];
  }

  static String _getHiddenStems(String zhi) {
    const hiddenStemsMap = {
      '子': '癸',
      '丑': '己癸辛',
      '寅': '甲丙戊',
      '卯': '乙',
      '辰': '戊乙癸',
      '巳': '丙戊庚',
      '午': '丁己',
      '未': '己丁乙',
      '申': '庚壬戊',
      '酉': '辛',
      '戌': '戊辛丁',
      '亥': '壬甲',
    };
    return hiddenStemsMap[zhi] ?? 'Unknown';
  }

  static String _getNaYin(String gan, String zhi) {
    const naYinMap = {
      '甲子': '海中金', '乙丑': '海中金',
      '丙寅': '炉中火', '丁卯': '炉中火',
      '戊辰': '大林木', '己巳': '大林木',
      '庚午': '路旁土', '辛未': '路旁土',
      '壬申': '剑锋金', '癸酉': '剑锋金',
      '甲戌': '山头火', '乙亥': '山头火',
      '丙子': '涧下水', '丁丑': '涧下水',
      '戊寅': '城头土', '己卯': '城头土',
      '庚辰': '白蜡金', '辛巳': '白蜡金',
      '壬午': '杨柳木', '癸未': '杨柳木',
      '甲申': '泉中水', '乙酉': '泉中水',
      '丙戌': '屋上土', '丁亥': '屋上土',
      '戊子': '霹雳火', '己丑': '霹雳火',
      '庚寅': '松柏木', '辛卯': '松柏木',
      '壬辰': '长流水', '癸巳': '长流水',
      '甲午': '砂石金', '乙未': '砂石金',
      '丙申': '山下火', '丁酉': '山下火',
      '戊戌': '平地木', '己亥': '平地木',
      '庚子': '壁上土', '辛丑': '壁上土',
      '壬寅': '金薄金', '癸卯': '金薄金',
      '甲辰': '覆灯火', '乙巳': '覆灯火',
      '丙午': '天河水', '丁未': '天河水',
      '戊申': '大驿土', '己酉': '大驿土',
      '庚戌': '钗环金', '辛亥': '钗环金',
      '壬子': '桑柘木', '癸丑': '桑柘木',
      '甲寅': '大溪水', '乙卯': '大溪水',
      '丙辰': '沙中土', '丁巳': '沙中土',
      '戊午': '天上火', '己未': '天上火',
      '庚申': '石榴木', '辛酉': '石榴木',
      '壬戌': '大海水', '癸亥': '大海水',
    };
    return naYinMap['$gan$zhi'] ?? 'Unknown';
  }

  static String _getStars(String gan, String zhi) {
    const starsMap = {
      '甲子': '天德',    '乙丑': '天德',
      '丙寅': '月德',    '丁卯': '月德',
      '戊辰': '天赦',    '己巳': '天赦',
      '庚午': '金匮',    '辛未': '金匮',
      '壬申': '青龙',    '癸酉': '青龙',
      '甲戌': '福德',    '乙亥': '福德',
      '丙子': '天厨',    '丁丑': '天厨',
      '戊寅': '文昌',    '己卯': '文昌',
      '庚辰': '天官',    '辛巳': '天官',
      '壬午': '天刑',    '癸未': '天刑',
      '甲申': '天乙',    '乙酉': '天乙',
      '丙戌': '太极',    '丁亥': '太极',
      '戊子': '国印',    '己丑': '国印',
      '庚寅': '红鸾',    '辛卯': '红鸾',
      '壬辰': '天喜',    '癸巳': '天喜',
      '甲午': '龙德',    '乙未': '龙德',
      '丙申': '紫微',    '丁酉': '紫微',
      '戊戌': '地解',    '己亥': '地解',
      '庚子': '将星',    '辛丑': '将星',
      '壬寅': '华盖',    '癸卯': '华盖',
      '甲辰': '驿马',    '乙巳': '驿马',
      '丙午': '桃花',    '丁未': '桃花',
      '戊申': '羊刃',    '己酉': '羊刃',
      '庚戌': '亡神',    '辛亥': '亡神',
      '壬子': '孤辰',    '癸丑': '孤辰',
      '甲寅': '劫煞',    '乙卯': '劫煞',
      '丙辰': '灾煞',    '丁巳': '灾煞',
      '戊午': '天煞',    '己未': '天煞',
      '庚申': '地煞',    '辛酉': '地煞',
      '壬戌': '年煞',    '癸亥': '年煞',
    };
    return starsMap['$gan$zhi'] ?? 'Unknown';
  }

  static String calculateBazi(DateTime date, TimeOfDay time) {
    // Implement your Bazi calculation logic here
    return 'Bazi Calculation Result';
  }
}

