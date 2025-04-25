// ignore_for_file: prefer_interpolation_to_compose_strings

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
      '海中金': 'មាសមហាសមុទ្រ - សក្តានុពលអ្នកច្រើនណាស់ គ្រាន់តែត្រូវការវេលាដុសខាត់ អ្នកប្រៀបបានទៅនឹងកំណព្វទ្រព្យក្នុងមហាសាគរ។ តារាសំណាងរបស់អ្នកតំណាងភាពអំណត់អត់ធ្មត និងការលូតលាស់យូរអង្វែង។',
      '剑锋金': 'ដាវមាស - មុតស្រួច ហើយសម្រេចចិត្តដាច់ណាត់ដូចដាវដកចេញពីស្រោម។ ស្តែងឲ្យឃើញនូវភាពមោះមុតដ៏ខ្លាំងក្លា និងសមត្ថភាពដែលអាចជំនះបាននូវគ្រប់ឧបសគ្គ។',
      '白蜡金': 'មាសក្រមួន ស - ផុយស្រួយបន្តិច តែច្នៃរួចជាស្រេច មានតម្លៃខ្លាំងគ្រាន់តែងាយរលាយពេលមានសំពាធរឺកំដៅ ម្លោះហើយត្រូវការការពារ និងថែរក្សាឲ្យម៉ត់ចត់បន្តិច។',
      '砂石金': 'ខ្សាច់មាស - សក្តានុពលដែលមិនទាន់មានអ្នកច្នៃនៅឡើយ ម្លោះហើយសក្តានុពលនេះទាមទាឲ្យមានការលុតដំ។ តារាអ្នកតំណាងដោយការតស៊ូរជំនះសេចក្តីលំបាក។',
      '金箔金': 'ក្រដាសមាស - សម្រស់ស្រសស្អាតផូរផង់ តុបតែងកាន់តែប្រសើរ។ ស្តែងចេញពីទេពកោសល្យសិល្បះរបស់អ្នក តែពេលខ្លះវាហាក់ដូចជារវើរវាយពេក ដូច្នេះត្រូវចេះទប់លំនឹងស្មារតី។',
      '钗钏金': 'សក់មាស - មានគុណតម្លៃ ហើយថ្លៃថ្នូរណាស់។ តំណាងនូវការសម្រិតសម្រាំងដ៏ល្អឥតខ្ចោះ និងការចេះរៀបចំប្រកបដោយសម្រស់ដ៏ស្រស់បវរ។',
      '大林木': 'ដើមឈើក្នុងព្រៃធំ - រឹងមាំ ហើយអភិរក្សាដូចជាដើមឈើដ៏ធំស្កឹមស្កៃ។ អ្នកផ្តល់ទីជម្រកដ៏រឹងមាំ និងកក់ក្តៅសម្រាប់អ្នកដទៃ។',
      '杨柳木': 'ព្រៃរបោះ - មានភាពបត់បែន និងងាយសម្របខ្លួន។ អោយពត់ពែនទៅតាមកាលះទេសះ អាកាសធាតុ ពិសេសនឹងមិនដួលរលំពេលជួបស្ថានការណ៍លំបាក។',
      '松柏木': 'ព្រៃស្រល់ - បៃតងជានិច និងធន់ខ្លាំង។ រក្សាកំលាំងឋាមពលរឹងមាំបានគ្រប់រដូវនៃជីវិត រស់បានយូរអង្វែង មិនងាយសាបសូន្យ។',
      '平地木': 'ព្រៃឈើវាលទំនាប - ដាក់ខ្លួន មិនកោងកាច ហើយលូតលាស់បានរហ័ស។ មិនអំនួត ក៏ប៉ុន្តែទុកចិត្តបាន ហើយអត់ធន់សម្បើមណាស់។',
      '桑柘木': 'Mulberry Wood - Fruit-bearing and nurturing. Provides sustenance for others.',
      '石榴木': 'Pomegranate Wood - Protective with thorns. Strong boundaries with sweet rewards inside.',
      '涧下水': 'ខ្សែទឹកចង្កេះភ្នំ - ថ្លាឆ្វង់ ហើយហូរមានទិសដៅ។ ខ្សែទឹកតូច តែមានទិសដៅច្បាស់លាស់ ហូរមិនរអាក់រអួល ជីវិតនិងប្រព្រឹត្តិទៅដោយរលូន។',
      '大溪水': 'មហាទន្លេ - ខ្សែទឹកដ័មានអំណាចខ្លាំងក្លាក្រៃ ហើយអាចបង្វែរទិសនៃប្រភពទឹកទាំងមូលទៀតផង។ ម្លោះហើយកត្តានេះក៏តំណាងឲ្យការផ្លាស់ប្តូរទ្រង់ទ្រាយធំនៃជីវិតរបស់អ្នកផងដែរ។',
      '长流水': 'ខ្សែរទឹកហូរដ៏វែងអន្លាយ - បន្តរដំណើររហូត ហើយអត់ធន់ និងមានភាពរុញច្រានទៅមុខជានិច្ចមិនរាថយឡើយ។ ដំណើររហ័សរហួនបើទោះជាត្រូវចំណាយពេលវេលាយូរអង្វែងយ៉ាងណាក៏ដោយ។',
      '天河水': 'ទន្លេឋានសួគ៌ - នៅលើមេឃ ហើយឆ្ងាយផុតពីដៃ។ មហិច្ឆតាធំ គំនិតវែងឆ្ងាយក៏ប៉ុន្តែខ្វះការអនុវត្តន៍ជាក់ស្តែង មិនសូវឃើញលទ្ធផលដែលជាទីគាប់ចិត្ត។',
      '泉中水': 'ទឹកបរិសុទ្ធរដូវផ្ការីក - ស្រស់បវរ ទឹកហូរចេញពីប្រភពដ៏ស្រស់ត្រកាលបរិសុទ្ធ។ មានគំនិតផ្តួចផ្តើមច្រើន និងមានធម្មជាតិអាថកំបាំង។',
      '大海水': 'ទឹកមហាសមុទ្រ - ធំល្វឹងល្វើយសឹងរកព្រំដែនគ្មាន ហើយមានអំណាចណាស់។ ពេលខ្លះអាចលើសហួស អាចមានអំណាចជ្រុល តែគឺពិតជាប្រកបដោយសក្តានុពលពិតប្រាកដមែន',
      '炉中火': 'ភ្លើងឆេះសន្ធោសន្ធៅ - ឋាមពលប្រមូលផ្តុំ ហើយស្រួចស្រាលខ្លាំងល្អណាស់។ មានចំណង់ចំណូលចិត្តខ្លាំងហើយពិតប្រាកដ ប្រកបដោយវិន័យគត់មត់។',
      '山头火': 'ភ្លើងលើភ្នំ - អំណាចព្រៃ អំណាចដែលគ្មានអ្នកស្គាល់ ហើយឯករាជ្យម្ចាស់ការណាស់។ ឆេះសន្ធោសន្ធៅភ្លឺចិញ្ចាច តែពេលខ្លះពិបាកគ្រប់គ្រងណាស់។',
      '霹雳火': 'ភ្លើងរន្ទះ - ភ្លាមៗ ទាន់ហន់ ហើយកក្រើកតែម្តង។ ប្រែរូបប្រែកាយលឿនរហ័ស បត់បែនខ្លាំង ហើយងាយយល់ពីស្ថានភាពនៅនឹងមុខ។',
      '山下火': 'ភ្លើងជ្រលងភ្នំ - ឋាមពលដែលកំពុងតែបាត់បង់។ ចាំបាច់ត្រូវការកំលាំងធាតុចូលបន្ថែម បញ្ឆេះឡើងវិញដើម្បីរក្សាចំណង់ និងការតាំងចិត្តទៅមុខ។',
      '覆灯火': 'ភ្លើងគោម - ពន្លឺនៃចំណេះដឹងដ័ស្រទន់។ ផ្តល់ឲ្យនូវមគ្គុទេសក៍ចង្អុលបង្ហាញផ្លូវដ៏ប្រសើរ ក៏ប៉ុន្តែទាមទាការការពារពីខ្សល់ដែលអាចនឹងធ្វើឲ្យគោមរលត់។',
      '天上火': 'ភ្លើងសុរិយព្រះអាទិត្យ - ក្តោបក្តាប់លើសគេ តេជៈរង្សីភ្លឺចិញ្ចាច។ ធម្មជាតិកើតមកជាអ្នកដឹកនាំប្រកបដោយឋាមពល និងអំណាច។ ឲ្យតែមានវត្តមាន គឺគេខ្លាចរអារណាស់។',
      '壁上土': 'ជញ្ជាំងផែនដី - ពូកែការពារខ្លួន និងមានព្រំប្រទល់រឹងមាំ ជាដែនសីមាដែលការពារបាន។ ផ្តល់នូវសុខសុវត្ថិភាពដ៏មានប្រសិទ្ធភាព ក៏ប៉ុន្តែឯកកោនិងដាច់ពីគេណាស់។',
      '城头土': 'កំផែងដីការពាររាជធានី - កិច្ចការពារ និងបម្រើប្រជាជន សហគមន៍ និងសាច់ញាតិ។ គុណតម្លៃពីដូនតា រឺក្រុមគ្រួសារនឹងត្រូវបានថែរក្សា ហើយប្រកបទៅដោយភក្តីភាព។',
      '沙中土': 'ដៃខ្សាច់នៃវាលរហោឋាន - បក់ផាត់គ្មានគោលដៅ រេរាតាមខ្យល់គ្មានលំនឹង។ ត្រូវការស្វែងរកលំនឹងភាព រកទីឈរជើងឲ្យច្បាស់លាស់ ជៀសវាងរសាត់ឥតព្រំដែន។',
      '路旁土': 'ដីតាមដងផ្លូវ - ប្រើប្រាស់បាន មានជីវជាតិ មានតម្លៃ។ និយាយរួមគេពឹងពាក់បាន ចេះជួយអ្នកដ៏ទៃតាមដំណើរជីវិតរបស់គេ។',
      '大驿土': 'ដីផ្លូវវែងឆ្ងាយដាច់សង្វែង - ផ្សារភ្ជាប់មនុស្ស និងគំនិតបញ្ញា។ មានធម្មជាតិជាអ្នកចូលក្នុងសង្គម ងាយចុះសម្រុងនិងគេ ហើយងាយភ្ជាប់ទំនាក់ទំនងជាមួយមនុស្សទូទៅ។',
      '屋上土': 'ដឺក្បឿងប្រក់ - ជាអ្នកផ្តល់នូវជំរកសម្រាប់អ្នកដ៏ទៃ។ កូនចៅពឹងពាក់បាន ហាលថ្ងៃហាលភ្លៀងដើម្បីគេ។ អ្នកបង្កើតទីកន្លែងសុខក្សេមក្សាន្តសម្រាប់ក្រុមគ្រួសារ និងមនុស្សពឹងពាក់ឲ្យកក់ក្តៅ។',
    };

    const completeSpecialStarMeanings = {
      '天官': 'វីរៈមន្ត្រីឋានសួគ៌ Heavenly Official - មានអំណាចកិច្ចការរាជការធំធេង ឋានៈខ្ពស់ខ្ពស់ គេខ្លាចរអារ, មានបណ្តាញក្នុងរដ្ឋាភិបាល, បើជីវិតគឺមានឋានានុក្រមចេះរៀបចំរចនាសម្ព័ន្ធរស់នៅសម្រាប់ជីវិត។',
      '劫煞': 'ផ្កាយចោ Robbery Star - ហារនិភ័យច្រើន ងាយបង់ទ្រព្យដោយមិនបានរំពឹងទុក, ចោលួច និងមនុស្សក្បត់, រឺធ្លាយហិបលុយទៅក្រោដោយងាយ។ ត្រូវចេះប្រុងប្រយ័ត្នឲ្យមែនទែន។',
      '驿马': 'សេះផាយទៅមុខ Travel Horse - ដំណើរញឹកញាប់, មានការផ្លាស់ប្តូរ, រឺមានកិច្ចការដែលជាឧកាសនៅតាមបណ្តារប្រទេសដទៃច្រើន។ ជីវិតអ្នកចេញ ទើបបានសុី។',
      '文昌': 'តារានិស្សិត Academic Star - ចំណេះដឹងជ្រៅជ្រះ រៀនអ្វីថ្មីឆាប់ចាប់បាន ពូកែរស្វែងយល់ណាស់។ ជោគជ័យធំបើរៀនបានខ្ពស់ ហើយបើរកសុីវិញពូកែតាមទាន់របររកសុីថ្មីៗ។',
      '红鸾': 'ផ្កាសូដា Peach Blossom - មនោសញ្ជេតនាជាធំ គួរឲ្យបេតី មានមន្តស្នេហ៍ ទាក់ទាញណាស់។ សំបូរគូស្នេហ៍ ហើយក៏អភ័ព្វនិងស្នេហាណាស់ដែរ។',
      '孤辰': 'តារាឯកការ Loneliness Star - ចូលចិត្តសំងំតែម្នាក់ឯក ចូលចិត្តឯករាជ្យ សេរីភាព ពិបាកបង្កើយទំនាក់ទំនងសុីជម្រៅជាមួយមនុស្សទូទៅ ព្រោះមិនចង់ឲ្យគេលូកលាន់រឿងខ្លួន។',
      '寡宿': 'តារាពោះម៉ាយ Widow Star - មិនសូវចាប់អារម្មណ៍រឿងស្នេហា គ្រួសារ រឺសម្ព័ន្ធភាពវែងឆ្ងាយ។ នឹងរៀបការយឺត អាយុច្រើនទើបរៀបការ រឺដាក់ចិត្តដាក់កាយក្នុងសម្ព័ន្ធមេត្រី។',
      '羊刃': 'តារាដាវរន្ទះ Blade Star - ឋាមពលវៀងវៃ ស្រួចស្រាវងាយនឹងមានជម្លោះ។ ប្រយ័ត្នរឿងសេពគប់ និងជួយគេឥតប្រយោជន័ នាំទុក្ខដាក់ខ្លួន។',
      '将星': 'តារាមេទ័ព General Star - កើតមកជាអ្នកដឹកនាំគេ មានសមត្ថភាព និងសមត្ថកិច្ចលើហ្វូងមនុស្ស និងការងាររកសុី។ មានសក្តានុពលខ្លាំងណាស់ក្នុងការងាររកសុី។',
      '天乙贵人': 'តារាឧត្តមមន្ត្រី Nobleman Star - នឹងមានគេអ្នកមានស័ក្តធំជួយជ្រោមជ្រែងអាណិតស្រលាញ់។ សំណាងច្រើនក្នុងផ្លូវជីវិត គឹជួយជ្រោមជ្រែងច្រើន។',
      '太极贵人': 'តារាចំណេះដឹង Wisdom Star - ផ្លូវលោកក៏ពូកែ ផ្លូវសាសនា និងធម៌ក៏ពូកែ បើរឿងទស្សនៈវិជ្ជា យុទ្ធសាស្ត្ររឹតតែពូកែ។ បើធ្វើគ្រូគេគឺពូកែ បើបួសរៀននឹងក្លាយជាមេសាសនា។',
      '华盖': 'Canopy Star - Artistic talent and unconventional thinking. May feel misunderstood.',
      '金舆': 'រាជរថមាស Golden Chariot - សម្បូរទ្រព្យ និងគ្រឿងប្រណីត ក្នុងជីវិតនឹងជួបរឿងស្តុកស្តម្ភ មិនខ្វះឡើយទ្រព្យសម្បត្តិ។',
      '灾煞': 'តារាគ្រោះមហន្តរាយ Disaster Star - ប្រយ័ត្នគ្រោះកាច វិបត្តិរាំងជល់ និងឧប្បត្តិទាន់ហន់។ ត្រូវចេះមើលភូមិសាស្រ្តរស់នៅ ធ្វើការ និងធ្វើដំណើរទើបសមប្រកប។',
      '亡神': 'តារាវិញ្ញាណបិសាច Death Spirit - មានគ្រោះកំណើតមើលមិនឃើញ ដូចម្ជុលលាក់មុខ មានជំងឺប្រចាំកាយ ប្រហេសនឹងគ្រោះធំ។ ទាមទាឲ្យរៀបខ្លួន ពិនិត្យសុខភាព ឲ្យទៀងទាត់។',
    };

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
      final nayinMeaning = completeNayinInterpretations[nayin] ?? 'សូមបញ្ជាក់ជាមួយMaster';
      final starMeaning = completeSpecialStarMeanings[specialStar] ??
          (specialStar == 'N/A' ? 'No special star' : 'សូមបញ្ជាក់ជាមួយMaster');

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
      '子午': 'កណ្តុរ និង សេះ ឆុងគ្នា : ទឹក មិនត្រូវនឹង ភ្លើង បង្កើតទំនាស់ភាពតានតឹងក្នុងទំនាក់ទំនង និងការងាររកសុី',
      '丑未': 'គោ និង ពពែ ឆុងគ្នា : ដី ប៉ះ ដី រឹងក្បាលណាស់ បង្កើតភាពជាប់គាំងទៅមុខមិនរួច រកសុីមិនឡើង',
      '寅申': 'ខ្លា និង ស្វា ឆុងគ្នា : ឈើ និង ដែក ឆុងគ្នា ប្រទាញប្រទុងរវាងការលូតលាស់ និងវិន័យច្បាប់ទំលាប់',
      '卯酉': 'ទន្សាយ និង មាន់ ឆុងគ្នា : ឈើ និង ដែក កកិតគ្នា បុកផុយ រិចរិលយូរទៅនឹងខូចខាត ឈប់ដំណើរការ។',
      '辰戌': 'នាគរាជ និង ឆ្កែ ឆុងគ្នា : ដី ប៉ះ ដី ដណ្តើមអំណាចគ្នា ដណ្តើមតំបន់ត្រួតតារគ្នា',
      '巳亥': 'ពស់ និង ជ្រួក ឆុងគ្នា: ភ្លើង និង ទឹក បង្ករសង្គ្រាមត្រជាក់ អារម្មណ៍គុំគួនចងអាឃាតគ្នា',
    };

    // 2. Check for Harmonies
    const harmonies = {
      '子丑': 'កណ្តុ និង គោ សុខដុមរមនា : ឆុងហេង បង្កើតលំនឹងឋាមពលដី ចាក់គ្រឹះរឹងមាំ',
      '寅亥': 'ខ្លា និង ជ្រូក សុខដុមរមនា : ជម្រុញឲ្យកើតមានការលូតលាស់របស់ធាតុឈើ នឹងឃើញការរីកចម្រើនធំៗ',
      '卯戌': 'ទន្សាយ និង ឆ្កែ សុខដុមរមនា : បង្កើនឋាមពលភ្លើង ឲ្យស្រលាញ់គ្នា មានគំនិតច្នៃប្រឌិត រកសុីធ្វើការជុំគ្នា មិនចាញ់គេ',
      '辰酉': 'នាគរាជ និង មាន់ សុខដុមរមនា : បង្កើយនូវឋាមពលមាសដែក ជោគជ័យច្បាស់នៅនឹងមុខ បានសម្រេចមិនខកខានឡើយ',
      '巳申': 'ពស់ និង ស្វា សុខដុមរមនា: បង្កើតលំហូរទឹក ដំណើរជីវិតនឹងរលូត លាភចូលឥតឈប់ ងាយចូលសង្គមណាស់',
      '午未': 'សេះ និង ពពែ សុខដុមរមនា: ព្រះអាទិត្យ និង ផែនដី ឋាមពលសណ្តោសប្រណីនិងគ្នា ធ្វើឲ្យកក់ក្តៅ ហើយមានលំនឹងរឹងមាំ',
    };

    // 3. Check Three Combinations
    const threeCombinations = {
      '亥卯未': 'កំលាំងធាតុឈើ សង្រួមចូលគ្នា Wood Combination (ជ្រូក-ទន្សាយ-ពពែ): លូតលាស់ បែកសាខា និងបង្រីកជានិច្ច',
      '寅午戌': 'កំលាំងធាតុភ្លើង សង្រួមចូលគ្នា Fire Combination (ខ្លា-សេះ-ឆ្កែ): មានឋាមពលដ៏អស្ចារ្យ ហើយងាយប្រែឧកាសទៅជាលាភ',
      '巳酉丑': 'កំលាំងធាតុមាស សង្រូមចូលគ្នា (ពស់-មាន់-គោ): មានគ្រឹះរចនាសម្ព័ន្ធរឹងមាំ មានវិន័យ គ្រោះសត្រូវធ្វើមិនបែក',
      '申子辰': 'កំលាំងធាតុទឹក សង្រួមចូលគ្នា (ស្វា-កណ្តុរ-នាគ): លំហូរលាភឥតឈប់ឈរ ហើយងាយបត់បែនគ្រប់ស្ថានការណ៍',
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
    interactions.add('• មិនឃើញមានឆុង រឺសុខដុមរុម្យនា ឆុងហេង អីគួរឲ្យកត់សម្គាល់នោះទេរវាងតួរាសីនីមួយៗ');
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
    takeaways.add('• តួរាសីថ្ងៃរបស់អ្នកគឺ $dayMaster ($dayMasterElement) - ' +
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
      takeaways.add('• ធាតុមាសខ្លាំង អាចគ្រប់គ្រង ធាតុឈើបាន ៖ មានសក្តានុពលល្អណាស់សម្រាប់ភាពជោគជ័យក្នុងការងារ ប៉ុន្តែត្រូវចេះគ្រប់គ្រងអារម្មណ៍ស្ត្រេស និងសំពាធឲ្យបាន');
    }
    if (elementsCount['Water']! > 2 && dayMasterElement == 'Fire') {
      takeaways.add('• ធាតុទឹកខ្លាំង អាចគ្រប់គ្រង ធាតុភ្លើងបាន ៖ ត្រូវចេះឃុំគ្រងការពារឋាមពល និងធនធានរបស់អ្នក កុំខ្ជះខ្ជាយ!');
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
        enhancements.add('• ប្រើធាតុទឹក (ព័ណ ខៀវ រឺ ខ្មៅ និងប្រើទឹកធ្លាក់) ដើម្បីស្រោចស្រប់ចិញ្ចឹមធាតុឈើ');
        enhancements.add('• បន្ថែមធាតុឈើ (ដាំដើមឈើ ដើមផ្ការ, ប្រើព័ណ៌បៃតង) ដើម្បីគាំទ្រគាំពារបន្ថែមទៀត');
        break;
      case 'Fire':
        enhancements.add('• ប្រើធាតុឈើ (ដាំដើមឈើ ដើមផ្ការ, ប្រើព័ណ៌បៃតង) ដើម្បីដុតបន្ថែមកំលាំងធាតុភ្លើង');
        enhancements.add('• បន្ថែមព័ណ៌ក្រហម និង ប្រើរបស់របរដែលមានរាងជាត្រីកោណ ដើម្បីបន្ថែមកំលាំងធាតុភ្លើង');
        break;
      case 'Earth':
        enhancements.add('• ប្រើធាតុភ្លើង (ព័ណ៌ក្រហម រឺលឿង, ប្រើទានក្រអូប) ដើម្បីបន្ថែមកំលាំងធាតុដី');
        enhancements.add('• ប្រើព័ណ៌ណារាងដីៗ និងប្រើរបស់របរតុបតែងដែលមានរាងការ៉េ ដើម្បីឲ្យមានលំនឹង');
        break;
      case 'Metal':
        enhancements.add('• ប្រើធាតុដី (ដាក់គ្រីស្តាល់ ថ្មកែវ ត្បូង, ប្រើព័ណ៌ដី) ដើម្បីបង្កើតកំលាំងធាតុដែក');
        enhancements.add('• បន្ថែមព័ណ៌ ស រឺ ដែកស្រគាំៗ ហើយប្រើរបស់របរដែលមានរាងមូល រឺជារង្វង់ ដើម្បីលើកកំលាំងធាតុមាស');
        break;
      case 'Water':
        enhancements.add('• ប្រើធាតុមាស (ប្រើព័ណ ស, គ្រឿងតុបតែងដែលធ្វើពីដែក រឺលោហៈ) ដើម្បីបង្កើតកំលាំងធាតុទឹក');
        enhancements.add('• បន្ថែមព័ណ៌ ខ្មៅ រឺ ខៀវ ហើយប្រើរបស់របរដែលមានរូបរាងដូចជាទឹករលក ដើម្បីលើកកំលាំងធាតុទឹក');
        break;
    }

    // Enhancements for weakest element
    switch (weakestElement) {
      case 'Wood':
        enhancements.add('• ជម្រុញធាតុឈើ ដោយប្រើកូនឈើ រឺរុក្ខជាតិ ដាក់នៅទិសខាងកើត នៃផ្ទះរបស់អ្នក');
        break;
      case 'Fire':
        enhancements.add('• ជម្រុញធាតុភ្លើង ដោយប្រើភ្លើងរឺទាន ដោយបំភ្លឺនៅទិសខាងត្បូង នៃផ្ទះរបស់អ្នក');
        break;
      case 'Earth':
        enhancements.add('• ពង្រឹងធាតុដី ដោយប្រើគ្រីស្តាល់ រឺត្បូង ដោយដាក់នៅទិសខាងជើងឈាងខាងកើត រឺត្បូងឈាងលិច នៃផ្ទះរបស់អ្នក');
        break;
      case 'Metal':
        enhancements.add('• បន្ថែមធាតុដែក ដោយប្រើព័ណ៌ សរឺលោហៈ ដោយដាក់នៅទិសខាងលិច រឺជើងឈាងខាងលិច នៃផ្ទះរបស់អ្នក');
        break;
      case 'Water':
        enhancements.add('• បំប៉នធាតុទឹក ដោយប្រើទឹកហូរ រឺអាងចិញ្ចឹមត្រី នៅទិសខាងជើង នៃផ្ទះរបស់អ្នក');
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
      return 'ប៉ាជឺរបស់អ្នកបង្ហាញថា អ្នកមានសក្តានុពលខ្លាំងណាស់ ប៉ុន្តែមានបញ្ហាប្រឈមមួយចំនួនដែលត្រូវគ្រប់គ្រងឲ្យបាន។ '
          'តួរាសីថ្ងៃ (Day Master) $dayMasterElement របស់អ្នក ផ្តល់នូវឋាមពលឲ្យអ្នកនូវកំលាំង ${_getDayMasterStrength(dayMaster)}, '
          'ប៉ុន្តែអ្នកត្រូវយកចិត្តទុកដាក់ទៅលើកត្តាដែលគួរប្រយ័ត្នប្រយែងដែលបានរៀបរាប់ខាងលើ។';
    } else {
      return 'ប៉ាជឺរបស់អ្នកបង្ហាញថា ឋាមពលរបស់អ្នកសមប្រកបនឹងគ្នាជារួម មានសុខដុមរមនាល្អណាស់! '
          'ក្នុងនាមជាអ្នកដែលមានតួរាសីថ្ងៃ (Day Master) ជា $dayMaster ($dayMasterElement) , អ្នកមានឋាមពល ${_getDayMasterStrength(dayMaster)} ។ '
          'ដូចនេះត្រូវចេះពង្រីក និងធ្វើឲ្យប្រើសើរឡើងនូវកំលាំងដែលធាតុ និងវាសនាអ្នកនាំមក ដូចបានបង្ហាញនៅក្នុងការវិភាគខាងលើ។';
    }
  }

  static String _getDayMasterPersonality(String stem) {
    const personalities = {
      '甲': 'គុណភាពជាអ្នកដឹកនាំដ៏មោះមុត រឹងមាំដូចដើមឈើដ៏ធំសម្បើម',
      '乙': 'ពូកែបត់បែន និងងាយសម្របគ្រប់ស្ថានការណ៍ ដូចស្មៅដែរទន់រេមិនងាយបាក់',
      '丙': 'មានមន្តស្នេហ៍ គេរស់មិនអាចខ្វះបាន និងស្វាហាប់ដូចព្រះអាទិត្យ',
      '丁': 'ពូកែសម្រួចទិសដៅ ផ្តោតអ្វីច្បាស់រឿងនោះ ដូចភ្លើងទៀនដែលចេះនឹងធឹងល្អ',
      '戊': 'មានលំនឹង ហើយទុកចិត្តបាន មហិមាដូចជាភ្នំដ៏រឹងមាំ',
      '己': 'ជាមនុស្សគេមាននិស្ស័យ ដូចដីមានជីជាតិ ជាមនុសបានការមានប្រយោជន៍ដូចដីកសិដ្ឋាន',
      '庚': 'ពូកែសម្រេចចិត្ត ម៉ាត់ប្រៃ ហើយមោះមុត ដូចដាវដ៏មុតស្រួច',
      '辛': 'ជាពេជ្រដែលច្នៃដ័ប្រណីត សម្រិតសម្រាំង ហើយគិតពិចារណាល្អិតល្អន់',
      '壬': 'ងាយចូលចំណោមគេ ហើយប្រកបដោយធនធានដែលអាស្រ័យបាន ដូចទឹកដែលហូរ',
      '癸': 'មនុស្សមានយុទ្ធសាស្ត្រក្នុងខ្លួន មើលវែងឆ្ងាយ សុីជ្រៅ ត្រជាក់មិនងាយមើលដឹង ដូចទឹកបាតទន្លេ និងសមុទ្រ',
    };
    return personalities[stem] ?? 'unique characteristics';
  }

  static String _getDayMasterStrength(String stem) {
    const strengths = {
      '甲': 'កើមមកជាអ្នកដឹកនាំពីធម្មជាតិ ធំធាត់ប្រកបដោយសក្តានុពល',
      '乙': 'ប្រកបដោយជំនាញការទូត ពូកែសម្របសម្រួល និងដោះស្រាយបញ្ហារដោយសន្តិវិធី',
      '丙': 'មានមន្តស្នេហ៍ និងមានសមត្ថភាពក្នុងការលើកទឹកចិត្តអ្នកដទៃ',
      '丁': 'មានភាពជាក់លាក់ ម៉ាត់ប្រៃ និងចេះយកចិត្តទុកដាក់ល្អិតល្អន់គ្រប់ប្រភេទការងារ',
      '戊': 'មានលំនឹង នឹងធឹង ហើយប្រកបដោយភាពប្រាកដនិយម និងពូកែដោះស្រាយបញ្ហា',
      '己': 'ពូកែចិញ្ចឹមបីបាច់ថែរក្សា និងចេះតំរង់ទិសការងាររកសុី',
      '庚': 'មានឆន្ទៈដ៏រឹងមាំ និងសមត្ថភាពក្នុងការដោះស្រាយឆ្លងកាត់ឧបសគ្គនានា',
      '辛': 'ជំនាញក្នុងការវិភាគគឺពូកែណាស់ ហើយជាមនុស្សប្រកបដោយរសនិយមប្លែកគេ',
      '壬': 'ងាយបន្សាំនិងស្ថានភាពថ្មី ហើយមានគោលគំនិតទូលំទូលាយ',
      '癸': 'ជាមនុសដែលមានការគិតបែបយុទ្ធសាស្ត្រ និងប្រកបដោយវិចារណញាណ',
    };
    return strengths[stem] ?? 'ជំនាញពិសេសប្លែកគេ';
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