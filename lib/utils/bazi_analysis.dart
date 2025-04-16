import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BaziAnalysis {
  static Map<String, dynamic> getBaziAnalysis(
      DateTime date, TimeOfDay time, Map<String, List<String>> astroData) {
    // Extract data from astroData
    final yearPillar = astroData['Year'] ?? [];
    final monthPillar = astroData['Month'] ?? [];
    final dayPillar = astroData['Day'] ?? [];
    final hourPillar = astroData['Hour'] ?? [];

    // Determine Day Master (天干 of Day Pillar)
    final dayMaster = dayPillar.isNotEmpty ? dayPillar[0] : 'N/A';

    // Format date and time
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final formattedTime = '${time.hour}:${time.minute}';

    // Add to the top of the file
    const completeNayinInterpretations = {
      '海中金': 'Sea Gold - Hidden potential that needs time to develop, like treasure in the ocean. Represents patience and long-term growth.',
      '剑锋金': 'Sword Gold - Sharp and decisive like a blade. Indicates strong willpower and ability to cut through obstacles.',
      '白蜡金': 'White Wax Gold - Delicate and refined but can melt under pressure. Needs protection and careful handling.',
      '砂石金': 'Sand Gold - Unrefined potential that requires work. Represents perseverance through difficulties.',
      '金箔金': 'Gold Foil - Decorative and beautiful. Indicates artistic talent but can be superficial if not grounded.',
      '钗钏金': 'Hairpin Gold - Valuable and elegant. Represents refinement and appreciation for beauty.',
      '大林木': 'Forest Wood - Strong and protective like a giant tree. Provides shelter and support for others.',
      '杨柳木': 'Willow Wood - Flexible and adaptable. Can bend without breaking in difficult situations.',
      '松柏木': 'Pine Wood - Evergreen and resilient. Maintains strength through all seasons of life.',
      '平地木': 'Flatland Wood - Humble and steady growth. Not flashy but reliable and enduring.',
      '桑柘木': 'Mulberry Wood - Fruit-bearing and nurturing. Provides sustenance for others.',
      '石榴木': 'Pomegranate Wood - Protective with thorns. Strong boundaries with sweet rewards inside.',
      '涧下水': 'Mountain Stream - Clear and purposeful flow. Small but determined path through life.',
      '大溪水': 'Big River - Powerful current that can change course. Represents major life changes.',
      '长流水': 'Long Flowing Water - Continuous and persistent. Steady progress over long periods.',
      '天河水': 'Sky River - Heavenly and detached. Big-picture thinking but may lack practicality.',
      '泉中水': 'Spring Water - Pure and emerging from deep sources. Intuitive and mysterious nature.',
      '大海水': 'Ocean Water - Boundless and powerful. Can be overwhelming but full of potential.',
      '炉中火': 'Furnace Fire - Contained and focused energy. Strong passion with discipline.',
      '山头火': 'Mountain Fire - Wild and independent. Burns brightly but may lack control.',
      '霹雳火': 'Lightning Fire - Sudden and dramatic. Quick transformations and revelations.',
      '山下火': 'Foot-hill Fire - Diminishing energy. Needs rekindling to maintain passion.',
      '覆灯火': 'Lantern Fire - Intellectual light. Provides guidance but needs protection from winds.',
      '天上火': 'Sun Fire - Dominant and radiant. Natural leadership with powerful presence.',
      '壁上土': 'Wall Earth - Defensive and strong boundaries. Provides security but can isolate.',
      '城头土': 'City Wall Earth - Protective of community. Traditional values and loyalty.',
      '沙中土': 'Desert Sand - Shifting and unstable. Needs anchoring to find stability.',
      '路旁土': 'Roadside Earth - Practical and transient. Helps others on their journeys.',
      '大驿土': 'Highway Earth - Connects people and ideas. Sociable and adaptable nature.',
      '屋上土': 'Roof Earth - Protective shelter. Creates safe spaces for family and home.',
    };

    const completeSpecialStarMeanings = {
      '天官': 'Heavenly Official - Strong bureaucratic influence, government connections, or structured authority in life.',
      '劫煞': 'Robbery Star - Risk of unexpected losses, theft, or financial leaks. Need for extra protection.',
      '驿马': 'Travel Horse - Frequent movement, changes, or international opportunities. Indicates a mobile lifestyle.',
      '文昌': 'Academic Star - Strong literary and learning abilities. Success in studies and knowledge-based pursuits.',
      '红鸾': 'Peach Blossom - Romantic opportunities and charm. Strong appeal to others in relationships.',
      '孤辰': 'Loneliness Star - Tendency toward isolation or difficulty forming deep connections.',
      '寡宿': 'Widow Star - Emotional distance in relationships. May indicate late marriage or solitude.',
      '羊刃': 'Blade Star - Cutting energy that can lead to conflicts. Needs careful channeling.',
      '将星': 'General Star - Natural leadership abilities and authority. Strong career potential.',
      '天乙贵人': 'Nobleman Star - Help from influential people. Lucky encounters that assist your path.',
      '太极贵人': 'Wisdom Star - Spiritual insight and philosophical depth. Attraction to metaphysics.',
      '华盖': 'Canopy Star - Artistic talent and unconventional thinking. May feel misunderstood.',
      '金舆': 'Golden Chariot - Material comfort and luxury. Indicates wealth potential.',
      '灾煞': 'Disaster Star - Warning of accidents or crises. Need for caution in specified areas.',
      '亡神': 'Death Spirit - Hidden dangers or health concerns. Requires preventive measures.',
    };

    // Define all possible Nayin interpretations
    // const nayinInterpretations = {
    //   '海中金': 'Hidden treasure, patient but ambitious',
    //   '剑锋金': 'Sharp as a sword, decisive and cutting',
    //   '白蜡金': 'Delicate metal, refined but fragile',
    //   '砂石金': 'Unrefined ore, hardworking and persistent',
    //   '金箔金': 'Ornamental gold, artistic and vain',
    //   '钗钏金': 'Jewelry gold, luxury-loving and elegant',
    //   '大林木': 'Forest wood, protective and nurturing',
    //   '杨柳木': 'Willow wood, flexible and emotional',
    //   '松柏木': 'Pine wood, resilient and principled',
    //   '平地木': 'Shrub wood, humble and steady',
    //   '桑柘木': 'Mulberry wood, generous and family-oriented',
    //   '石榴木': 'Pomegranate wood, defensive and passionate',
    //   '涧下水': 'Mountain stream, gentle and introspective',
    //   '大溪水': 'Big river, adventurous and restless',
    //   '长流水': 'Long flowing water, philosophical and deep',
    //   '天河水': 'Sky river, visionary and detached',
    //   '泉中水': 'Spring water, mysterious and intuitive',
    //   '大海水': 'Ocean water, charismatic and unpredictable',
    //   '炉中火': 'Furnace fire, passionate and focused',
    //   '山头火': 'Mountain fire, independent and impulsive',
    //   '霹雳火': 'Lightning fire, revolutionary and explosive',
    //   '山下火': 'Foot-hill fire, warm but fading energy',
    //   '覆灯火': 'Lantern fire, intellectual and guarded',
    //   '天上火': 'Sun fire, bold and dominant',
    //   '壁上土': 'Wall earth, defensive and stubborn',
    //   '城头土': 'City wall earth, loyal and traditional',
    //   '沙中土': 'Desert sand, flexible but unstable',
    //   '路旁土': 'Roadside earth, practical and transient',
    //   '大驿土': 'Highway earth, sociable and adaptable',
    //   '屋上土': 'Roof earth, protective and home-loving',
    // };
    //
    // // Define special star interpretations
    // const specialStarMeanings = {
    //   '天官': 'Heavenly Official - Bureaucratic influence, authority',
    //   '劫煞': 'Robbery Star - Risk of financial loss or theft',
    //   '驿马': 'Travel Horse - Movement, change, expansion',
    //   '文昌': 'Academic Star - Success in studies and knowledge',
    //   '红鸾': 'Peach Blossom - Romantic opportunities',
    //   '孤辰': 'Loneliness Star - Isolation or difficulty bonding',
    //   '寡宿': 'Widow Star - Emotional distance in relationships',
    //   '羊刃': 'Blade Star - Aggression and potential conflict',
    //   '将星': 'General Star - Leadership and authority',
    // };

    // Helper function to get pillar analysis
    Map<String, String> getPillarAnalysis(
        List<String> pillar, String pillarName) {
      if (pillar.isEmpty) return {};

      final heavenlyStem = pillar[0];
      final earthlyBranch = pillar[1];
      final hiddenStems = pillar.length > 2 ? pillar[2] : 'N/A';
      final nayin = pillar.length > 3 ? pillar[3] : 'N/A';
      final specialStar = pillar.length > 4 ? pillar[4] : 'N/A';

      // Heavenly Stem element
      final stemElement = _getElementFromStem(heavenlyStem);

      // Earthly Branch element
      final branchElement = _getElementFromBranch(earthlyBranch);

      // Hidden Stems elements
      final hiddenElements = hiddenStems.split('').map(_getElementFromStem).join(', ');

      // Use the complete interpretations
      final nayinMeaning = completeNayinInterpretations[nayin] ?? 'No interpretation available';
      final starMeaning = completeSpecialStarMeanings[specialStar] ??
          (specialStar == 'N/A' ? 'No special star' : 'Unknown star meaning');

      return {
        'pillar': pillarName,
        'heavenlyStem': heavenlyStem,
        'earthlyBranch': earthlyBranch,
        'stemElement': stemElement,
        'branchElement': branchElement,
        'hiddenStems': hiddenStems,
        'hiddenElements': hiddenElements,
        'nayin': nayin,
        'nayinMeaning': nayinMeaning,
        'specialStar': specialStar,
        'starMeaning': starMeaning,
      };
    }


    // Analyze each pillar
    final yearAnalysis = getPillarAnalysis(yearPillar, 'Year');
    final monthAnalysis = getPillarAnalysis(monthPillar, 'Month');
    final dayAnalysis = getPillarAnalysis(dayPillar, 'Day');
    final hourAnalysis = getPillarAnalysis(hourPillar, 'Hour');

    // Determine overall element balance
    final elementsCount = _countElements([
      yearAnalysis['stemElement'],
      yearAnalysis['branchElement'],
      monthAnalysis['stemElement'],
      monthAnalysis['branchElement'],
      dayAnalysis['stemElement'],
      dayAnalysis['branchElement'],
      hourAnalysis['stemElement'],
      hourAnalysis['branchElement'],
    ]);

    // Key takeaways based on analysis
    final keyTakeaways = _getKeyTakeaways(
      dayMaster: dayMaster,
      elementsCount: elementsCount,
      yearAnalysis: yearAnalysis,
      monthAnalysis: monthAnalysis,
      dayAnalysis: dayAnalysis,
      hourAnalysis: hourAnalysis,
    );

    // Feng Shui enhancements
    final fengShuiEnhancements = _getFengShuiEnhancements(
      dayMaster: dayMaster,
      elementsCount: elementsCount,
    );

    // Final verdict
    final finalVerdict = _getFinalVerdict(
      dayMaster: dayMaster,
      keyTakeaways: keyTakeaways,
    );

    return {
      'date': formattedDate,
      'time': formattedTime,
      'dayMaster': dayMaster,
      'dayMasterElement': _getElementFromStem(dayMaster),
      'yearAnalysis': yearAnalysis,
      'monthAnalysis': monthAnalysis,
      'dayAnalysis': dayAnalysis,
      'hourAnalysis': hourAnalysis,
      'elementsCount': elementsCount,
      'keyTakeaways': keyTakeaways,
      'fengShuiEnhancements': fengShuiEnhancements,
      'finalVerdict': finalVerdict,
    };
  }

  // Add new function for Key Interactions analysis
// Add new function for Key Interactions analysis
  static List<String> getKeyInteractions({
    required String dayMaster,
    required Map<String, String> yearAnalysis,
    required Map<String, String> monthAnalysis,
    required Map<String, String> dayAnalysis,
    required Map<String, String> hourAnalysis,
  }) {
    final interactions = <String>[];
    final pillars = [yearAnalysis, monthAnalysis, dayAnalysis, hourAnalysis];

    // 1. Check for Clashes
    const clashes = {
      '子午': 'Rat-Horse Clash: Water-Fire opposition causing tension in relationships/career',
      '丑未': 'Ox-Goat Clash: Earth-Earth stubbornness creating deadlocks',
      '寅申': 'Tiger-Monkey Clash: Wood-Metal conflict between growth and discipline',
      '卯酉': 'Rabbit-Rooster Clash: Wood-Metal friction between gentleness and precision',
      '辰戌': 'Dragon-Dog Clash: Earth-Earth power struggles for dominance',
      '巳亥': 'Snake-Pig Clash: Fire-Water hidden tensions and emotional volatility',
    };

    // 2. Check for Harmonies
    const harmonies = {
      '子丑': 'Rat-Ox Harmony: Creates stable Earth energy for foundations',
      '寅亥': 'Tiger-Pig Harmony: Generates Wood growth for development',
      '卯戌': 'Rabbit-Dog Harmony: Produces Fire energy for passion/creativity',
      '辰酉': 'Dragon-Rooster Harmony: Forms Metal energy for precision/success',
      '巳申': 'Snake-Monkey Harmony: Creates Water flow for adaptability',
      '午未': 'Horse-Goat Harmony: Sun/Earth combination for warmth/stability',
    };

    // 3. Check Three Combinations
    const threeCombinations = {
      '亥卯未': 'Wood Combination (Pig-Rabbit-Goat): Growth and expansion',
      '寅午戌': 'Fire Combination (Tiger-Horse-Dog): Energy and transformation',
      '巳酉丑': 'Metal Combination (Snake-Rooster-Ox): Structure and discipline',
      '申子辰': 'Water Combination (Monkey-Rat-Dragon): Flow and adaptability',
    };

    // Analyze each pillar combination
    for (var i = 0; i < pillars.length; i++) {
      for (var j = i + 1; j < pillars.length; j++) {
        final pillar1 = pillars[i];
        final pillar2 = pillars[j];
        final branch1 = pillar1['earthlyBranch'] ?? '';
        final branch2 = pillar2['earthlyBranch'] ?? '';

        // Check clashes
        if (clashes.containsKey(branch1 + branch2)) {
        interactions.add('• ${pillar1['pillar']}-${pillar2['pillar']} ${clashes[branch1 + branch2]}');
        }
        if (clashes.containsKey(branch2 + branch1)) {
    interactions.add('• ${pillar2['pillar']}-${pillar1['pillar']} ${clashes[branch2 + branch1]}');
    }

    // Check harmonies
    if (harmonies.containsKey(branch1 + branch2)) {
    interactions.add('• ${pillar1['pillar']}-${pillar2['pillar']} ${harmonies[branch1 + branch2]}');
    }
    }
    }

    // Check for Three Combinations
    final allBranches = pillars.map((p) => p['earthlyBranch'] ?? '').toList();
    for (final combo in threeCombinations.keys) {
    final branches = combo.split('');
    if (allBranches.contains(branches[0]) &&
    allBranches.contains(branches[1]) &&
    allBranches.contains(branches[2])) {
    interactions.add('• Three Combination Found: ${threeCombinations[combo]}');
    }
    }

    // Day Master specific interactions
    final dayMasterElement = _getElementFromStem(dayMaster);
    for (final pillar in pillars) {
    final branchElement = pillar['branchElement'];

    // Productive Cycle
    if ((dayMasterElement == 'Wood' && branchElement == 'Fire') ||
    (dayMasterElement == 'Fire' && branchElement == 'Earth') ||
    (dayMasterElement == 'Earth' && branchElement == 'Metal') ||
    (dayMasterElement == 'Metal' && branchElement == 'Water') ||
    (dayMasterElement == 'Water' && branchElement == 'Wood')) {
    interactions.add('• ${pillar['pillar']} supports your Day Master ($dayMasterElement) through productive cycle');
    }

    // Controlling Cycle
    if ((dayMasterElement == 'Wood' && branchElement == 'Earth') ||
    (dayMasterElement == 'Earth' && branchElement == 'Water') ||
    (dayMasterElement == 'Water' && branchElement == 'Fire') ||
    (dayMasterElement == 'Fire' && branchElement == 'Metal') ||
    (dayMasterElement == 'Metal' && branchElement == 'Wood')) {
    interactions.add('• ${pillar['pillar']} challenges your Day Master ($dayMasterElement) through controlling cycle');
    }
    }

    if (interactions.isEmpty) {
    interactions.add('• No significant clashes or harmonies found between pillars');
    }

    return interactions;
  }


  static String _getElementFromStem(String stem) {
    const stemElements = {
      '甲': 'Wood', '乙': 'Wood',
      '丙': 'Fire', '丁': 'Fire',
      '戊': 'Earth', '己': 'Earth',
      '庚': 'Metal', '辛': 'Metal',
      '壬': 'Water', '癸': 'Water',
    };
    return stemElements[stem] ?? 'Unknown';
  }

  static String _getElementFromBranch(String branch) {
    const branchElements = {
      '子': 'Water', '丑': 'Earth',
      '寅': 'Wood', '卯': 'Wood',
      '辰': 'Earth', '巳': 'Fire',
      '午': 'Fire', '未': 'Earth',
      '申': 'Metal', '酉': 'Metal',
      '戌': 'Earth', '亥': 'Water',
    };
    return branchElements[branch] ?? 'Unknown';
  }

  static Map<String, int> _countElements(List<String?> elements) {
    final count = {'Wood': 0, 'Fire': 0, 'Earth': 0, 'Metal': 0, 'Water': 0};
    for (final element in elements) {
      if (element != null && count.containsKey(element)) {
        count[element] = count[element]! + 1;
      }
    }
    return count;
  }

  static List<String> _getKeyTakeaways({
    required String dayMaster,
    required Map<String, int> elementsCount,
    required Map<String, String> yearAnalysis,
    required Map<String, String> monthAnalysis,
    required Map<String, String> dayAnalysis,
    required Map<String, String> hourAnalysis,
  }) {
    final takeaways = <String>[];

    // Day Master analysis
    final dayMasterElement = _getElementFromStem(dayMaster);
    takeaways.add('• Your Day Master is $dayMaster ($dayMasterElement) - ' +
        _getDayMasterPersonality(dayMaster));

    // Element balance
    final strongestElement = _getStrongestElement(elementsCount);
    final weakestElement = _getWeakestElement(elementsCount);
    takeaways.add('• Element Balance: Strongest in $strongestElement, weakest in $weakestElement');

    // Special stars
    if (yearAnalysis['specialStar'] != 'N/A') {
      takeaways.add('• Year Pillar has ${yearAnalysis['specialStar']}: ${yearAnalysis['starMeaning']}');
    }
    if (monthAnalysis['specialStar'] != 'N/A') {
      takeaways.add('• Month Pillar has ${monthAnalysis['specialStar']}: ${monthAnalysis['starMeaning']}');
    }
    if (dayAnalysis['specialStar'] != 'N/A') {
      takeaways.add('• Day Pillar has ${dayAnalysis['specialStar']}: ${dayAnalysis['starMeaning']}');
    }
    if (hourAnalysis['specialStar'] != 'N/A') {
      takeaways.add('• Hour Pillar has ${hourAnalysis['specialStar']}: ${hourAnalysis['starMeaning']}');
    }

    // Career and wealth indicators
    if (elementsCount['Metal']! > 2 && dayMasterElement == 'Wood') {
      takeaways.add('• Strong Metal controls Wood: Potential for career success but need to manage stress');
    }
    if (elementsCount['Water']! > 2 && dayMasterElement == 'Fire') {
      takeaways.add('• Strong Water controls Fire: Need to protect your energy and resources');
    }

    return takeaways;
  }

  static List<String> _getFengShuiEnhancements({
    required String dayMaster,
    required Map<String, int> elementsCount,
  }) {
    final enhancements = <String>[];
    final dayMasterElement = _getElementFromStem(dayMaster);
    final weakestElement = _getWeakestElement(elementsCount);

    // General enhancements based on Day Master
    switch (dayMasterElement) {
      case 'Wood':
        enhancements.add('• Use Water elements (blue/black colors, fountains) to nourish your Wood');
        enhancements.add('• Add Wood elements (plants, green colors) for support');
        break;
      case 'Fire':
        enhancements.add('• Use Wood elements (plants, green colors) to fuel your Fire');
        enhancements.add('• Add red colors and triangular shapes for Fire energy');
        break;
      case 'Earth':
        enhancements.add('• Use Fire elements (red colors, candles) to strengthen Earth');
        enhancements.add('• Add earthy tones and square shapes for stability');
        break;
      case 'Metal':
        enhancements.add('• Use Earth elements (crystals, earthy tones) to produce Metal');
        enhancements.add('• Add white/metallic colors and round shapes for Metal energy');
        break;
      case 'Water':
        enhancements.add('• Use Metal elements (white colors, metal objects) to produce Water');
        enhancements.add('• Add black/blue colors and wavy shapes for Water energy');
        break;
    }

    // Enhancements for weakest element
    switch (weakestElement) {
      case 'Wood':
        enhancements.add('• Boost Wood with plants in East sector of your home');
        break;
      case 'Fire':
        enhancements.add('• Enhance Fire with lights/candles in South sector');
        break;
      case 'Earth':
        enhancements.add('• Strengthen Earth with crystals/stones in Northeast/Southwest');
        break;
      case 'Metal':
        enhancements.add('• Increase Metal with white colors/metals in West/Northwest');
        break;
      case 'Water':
        enhancements.add('• Support Water with fountains/aquariums in North sector');
        break;
    }

    return enhancements;
  }

  static String _getFinalVerdict({
    required String dayMaster,
    required List<String> keyTakeaways,
  }) {
    final dayMasterElement = _getElementFromStem(dayMaster);
    final hasChallenges = keyTakeaways.any((t) => t.contains('Risk') || t.contains('need'));

    if (hasChallenges) {
      return 'Your Bazi chart shows strong potential but also some challenges to manage. '
          'The $dayMasterElement energy gives you ${_getDayMasterStrength(dayMaster)}, '
          'but you should pay attention to the areas mentioned in Key Takeaways.';
    } else {
      return 'Your Bazi chart indicates favorable energies overall! '
          'As a $dayMaster ($dayMasterElement) person, you have ${_getDayMasterStrength(dayMaster)}. '
          'Focus on maximizing your strengths shown in the analysis.';
    }
  }

  static String _getDayMasterPersonality(String stem) {
    const personalities = {
      '甲': 'strong leadership qualities like a mighty tree',
      '乙': 'flexibility and adaptability like bending grass',
      '丙': 'charismatic and energetic like the sun',
      '丁': 'focused and precise like a candle flame',
      '戊': 'stable and reliable like a mountain',
      '己': 'nurturing and practical like farmland',
      '庚': 'decisive and strong-willed like metal',
      '辛': 'refined and detail-oriented like jewelry',
      '壬': 'adaptable and resourceful like flowing water',
      '癸': 'strategic and insightful like deep water',
    };
    return personalities[stem] ?? 'unique characteristics';
  }

  static String _getDayMasterStrength(String stem) {
    const strengths = {
      '甲': 'natural leadership and growth potential',
      '乙': 'diplomatic skills and adaptability',
      '丙': 'charisma and ability to inspire others',
      '丁': 'precision and attention to detail',
      '戊': 'stability and practical problem-solving',
      '己': 'nurturing abilities and service orientation',
      '庚': 'strong will and ability to cut through obstacles',
      '辛': 'refined taste and analytical skills',
      '壬': 'adaptability and broad perspective',
      '癸': 'strategic thinking and intuition',
    };
    return strengths[stem] ?? 'unique strengths';
  }

  static String _getStrongestElement(Map<String, int> elementsCount) {
    var maxCount = 0;
    var strongest = '';
    elementsCount.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        strongest = element;
      }
    });
    return strongest;
  }

  static String _getWeakestElement(Map<String, int> elementsCount) {
    var minCount = 999;
    var weakest = '';
    elementsCount.forEach((element, count) {
      if (count < minCount) {
        minCount = count;
        weakest = element;
      }
    });
    return weakest;
  }
}