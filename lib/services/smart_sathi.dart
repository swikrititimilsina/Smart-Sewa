import 'dart:convert';
import 'package:flutter/services.dart';

class SmartSathi {
  static const Map<String, String> _typoMap = {
    "citiznship": "citizenship", "citienship": "citizenship", "citizeship": "citizenship", "citzenship": "citizenship", "nagarikatha": "citizenship", "brith": "birth", "bith": "birth", "berth": "birth", "janmadarta": "birth certificate", "ndi": "nid", "ind": "nid", "natinal": "national", "identiy": "identity", "nabalik": "minor", "pasport": "passport", "passprt": "passport", "passort": "passport", "passpot": "passport", "rahdani": "passport", "rahadni": "passport", "diplmatic": "diplomatic", "ofical": "official", "documant": "document", "docuemnt": "document", "documnet": "document", "documets": "documents", "stesp": "steps", "hwo": "how", "appply": "apply", "aply": "apply", "pratlipi": "pratilipi", "duplicat": "duplicate", "registraton": "registration",
  };

  Map<String, dynamic>? _services;
  Map<String, dynamic>? _rules;
  List<dynamic>? _faqs;

  final _DialogueManager _dialogueManager = _DialogueManager();
  late _IntentRecognizer _recognizer;
  late _ResponseGenerator _generator;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final servicesStr = await rootBundle.loadString('assets/json/services.json');
    _services = json.decode(servicesStr);
    
    final rulesStr = await rootBundle.loadString('assets/json/chatbot_rules.json');
    _rules = json.decode(rulesStr);
    
    final faqsStr = await rootBundle.loadString('assets/json/faqs.json');
    final faqsData = json.decode(faqsStr);
    _faqs = faqsData['faqs'];

    _recognizer = _IntentRecognizer(_services!, _rules!, _faqs!);
    _generator = _ResponseGenerator(_services!, _rules!, _faqs!);
    _isInitialized = true;
  }

  void reset() {
    _dialogueManager.reset();
  }

  String _detectLanguage(String message) {
    for (int i = 0; i < message.length; i++) {
      int code = message.codeUnitAt(i);
      if (code >= 0x0900 && code <= 0x097F) {
        return "ne";
      }
    }
    return "en";
  }

  String _fixTypos(String message) {
    List<String> words = message.toLowerCase().split(RegExp(r'\s+'));
    return words.map((w) => _typoMap[w] ?? w).join(' ');
  }

  Future<Map<String, String>> respond(String userMessage) async {
    await initialize();
    
    String lang = _detectLanguage(userMessage);
    String original = userMessage.trim().toLowerCase();
    String fixed = _fixTypos(original);

    if (original.isEmpty) return {"response": "", "language": lang};

    bool isFollowup = _dialogueManager.isFollowup(original);
    
    String intentType = "unknown";
    dynamic intentValue;

    if (isFollowup) {
      intentType = "service";
      intentValue = _dialogueManager.lastService;
    } else {
      var result = _recognizer.recognize(original, fixed);
      intentType = result.type;
      intentValue = result.value;
    }

    String responseText = _generator.generate(
      intentType,
      intentValue,
      _dialogueManager.getContext(),
      original,
      lang,
    );

    _dialogueManager.update(original, intentType, intentValue, responseText, lang);

    return {"response": responseText, "language": lang};
  }
}

class _IntentResult {
  final String type;
  final dynamic value;
  _IntentResult(this.type, this.value);
}

class _DialogueManager {
  String? lastService;
  String? lastSubintent;
  String lastLanguage = "en";
  int conversationCount = 0;

  void update(String userMsg, String intentType, dynamic intentValue, String botResponse, String language) {
    conversationCount++;
    lastLanguage = language;

    if (intentType == "service") {
      lastService = intentValue;
      lastSubintent = null;
    } else if (["citizenship_sub", "birth_sub", "nid_sub", "passport_sub"].contains(intentType)) {
      Map<String, String> serviceMap = {
        "citizenship_sub": "citizenship",
        "birth_sub": "birth_certificate",
        "nid_sub": "nid",
        "passport_sub": "passport"
      };
      lastService = serviceMap[intentType];
      lastSubintent = intentValue;
    }
  }

  bool isFollowup(String message) {
    List<String> followupWords = [
      "documents", "docs", "papers", "what do i need",
      "steps", "how to", "procedure", "process",
      "fee", "cost", "price", "how much",
      "time", "how long", "days",
      "office", "where", "location",
      "eligibility", "who can", "requirement",
      "more", "tell me", "what", "which", "also", "types",
      "कागजात", "शुल्क", "चरण", "समय", "कार्यालय", "योग्यता", "प्रकार"
    ];
    return lastService != null && _Helper.anyKeyword(message.toLowerCase(), followupWords);
  }

  Map<String, dynamic> getContext() {
    return {
      "last_service": lastService,
      "last_subintent": lastSubintent,
      "conversation_count": conversationCount
    };
  }

  void reset() {
    lastService = null;
    lastSubintent = null;
    conversationCount = 0;
  }
}

class _Helper {
  static bool containsKeyword(String message, String keyword) {
    String k = keyword.toLowerCase();
    String m = message.toLowerCase();

    bool isDevanagari = k.runes.any((c) => c >= 0x0900 && c <= 0x097F);
    if (isDevanagari || k.contains(" ") || k.length > 4) {
      return m.contains(k);
    }
    
    RegExp pattern = RegExp(r'(?<![a-zA-Z])' + RegExp.escape(k) + r'(?![a-zA-Z])');
    return pattern.hasMatch(m);
  }

  static bool anyKeyword(String message, List<String> keywords) {
    return keywords.any((k) => containsKeyword(message, k));
  }
  
  static String t(dynamic field, String lang) {
    if (field is Map) {
      return field[lang]?.toString() ?? field['en']?.toString() ?? "";
    }
    if (field is List) {
      return field.map((e) => e.toString()).toList().join("\n");
    }
    return field?.toString() ?? "";
  }
}

class _IntentRecognizer {
  final Map<String, dynamic> services;
  final Map<String, dynamic> rules;
  final List<dynamic> faqs;

  _IntentRecognizer(this.services, this.rules, this.faqs);

  _IntentResult recognize(String original, String fixed) {
    var res = _exactMatch(original);
    if (res.type != "unknown") return res;

    if (fixed != original) {
      res = _exactMatch(fixed);
      if (res.type != "unknown") return res;
    }

    return _IntentResult("unknown", null);
  }

  _IntentResult _exactMatch(String message) {
    for (var entry in rules.entries) {
      if (entry.key == "unknown") continue;
      List patterns = entry.value["patterns"] ?? [];
      for (var pattern in patterns) {
        if (_Helper.containsKeyword(message, pattern)) {
          return _IntentResult("rule", entry.key);
        }
      }
    }

    var sub = _detectSubintent(message);
    if (sub != null) return sub;

    for (int i = 0; i < faqs.length; i++) {
      List keywords = faqs[i]["keywords"] ?? [];
      for (var keyword in keywords) {
        if (_Helper.containsKeyword(message, keyword)) {
          return _IntentResult("faq", i);
        }
      }
    }

    for (var entry in services.entries) {
      List keywords = entry.value["keywords"] ?? [];
      for (var keyword in keywords) {
        if (_Helper.containsKeyword(message, keyword)) {
          return _IntentResult("service", entry.key);
        }
      }
    }

    return _IntentResult("unknown", null);
  }

  _IntentResult? _detectSubintent(String message) {
    if (_Helper.anyKeyword(message, ["types of citizenship", "citizenship types", "नागरिकताका प्रकार", "नागरिकता प्रकार"])) return _IntentResult("citizenship_sub", "types");
    if (_Helper.anyKeyword(message, ["pratilipi", "duplicate citizenship", "प्रतिलिपि", "नक्कल"])) {
      if (_Helper.anyKeyword(message, ["migration", "basai", "moved", "बसाइसराइ"])) return _IntentResult("citizenship_sub", "pratilipi_migration");
      if (_Helper.anyKeyword(message, ["divorce", "divorced", "पारपाचुके", "सम्बन्ध विच्छेद"])) return _IntentResult("citizenship_sub", "pratilipi_divorce");
      if (_Helper.anyKeyword(message, ["husband", "marriage", "married", "पति", "विवाह"])) return _IntentResult("citizenship_sub", "pratilipi_husband");
      if (_Helper.anyKeyword(message, ["surname", "name correction", "थर सुधार", "नाम सुधार"])) return _IntentResult("citizenship_sub", "pratilipi_surname");
      return _IntentResult("citizenship_sub", "pratilipi_general");
    }
    if (_Helper.anyKeyword(message, ["by descent", "descent citizenship", "वंशज"])) return _IntentResult("citizenship_sub", "descent");
    if (_Helper.anyKeyword(message, ["naturalized marriage", "वैवाहिक अंगीकृत"])) return _IntentResult("citizenship_sub", "naturalized_marriage");
    if (_Helper.anyKeyword(message, ["naturalized citizenship", "naturalization", "अंगीकृत नागरिकता"])) return _IntentResult("citizenship_sub", "naturalized");
    if (_Helper.anyKeyword(message, ["sifarish", "sifarish patra", "सिफारिस"])) return _IntentResult("citizenship_sub", "sifarish");
    if (_Helper.anyKeyword(message, ["dao step", "cdo step", "sanaakhat", "sarjaamin", "सनाखत", "सर्जमिन"])) return _IntentResult("citizenship_sub", "dao_step");
    
    if (_Helper.anyKeyword(message, ["early birth", "birth within 35", "समयमै जन्मदर्ता"])) return _IntentResult("birth_sub", "early");
    if (_Helper.anyKeyword(message, ["late birth", "birth after 35", "ढिलो जन्मदर्ता"])) return _IntentResult("birth_sub", "late");
    if (_Helper.anyKeyword(message, ["birth father abroad", "father abroad birth", "बाबा विदेश जन्मदर्ता"])) return _IntentResult("birth_sub", "father_abroad");
    if (_Helper.anyKeyword(message, ["birth father unknown", "father unknown birth", "बाबा अज्ञात जन्मदर्ता"])) return _IntentResult("birth_sub", "father_unknown");
    if (_Helper.anyKeyword(message, ["orphan birth", "birth orphan", "अनाथ जन्मदर्ता"])) return _IntentResult("birth_sub", "orphan");
    if (_Helper.anyKeyword(message, ["foreign parent birth", "birth foreign parent", "विदेशी अभिभावक जन्मदर्ता"])) return _IntentResult("birth_sub", "foreign_parent");
    if (_Helper.anyKeyword(message, ["birth migrated parents", "migration birth", "बसाइसराइ जन्मदर्ता"])) return _IntentResult("birth_sub", "migrated_parents");
    if (_Helper.anyKeyword(message, ["types of birth", "birth registration types", "जन्मदर्ताका प्रकार"])) return _IntentResult("birth_sub", "types");
    
    if (_Helper.anyKeyword(message, ["minor id", "nabalik parichaya", "child nid", "नाबालक परिचयपत्र"])) return _IntentResult("nid_sub", "minor_id");
    if (_Helper.anyKeyword(message, ["standard nid", "adult nid", "सामान्य nid", "सामान्य परिचयपत्र"])) return _IntentResult("nid_sub", "standard_nid");
    if (_Helper.anyKeyword(message, ["types of nid", "nid types", "nid का प्रकार"])) return _IntentResult("nid_sub", "types");
    
    if (_Helper.anyKeyword(message, ["types of passport", "passport types", "राहदानीका प्रकार"])) return _IntentResult("passport_sub", "types");
    if (_Helper.anyKeyword(message, ["ordinary passport", "green passport", "सामान्य राहदानी"])) {
      if (_Helper.anyKeyword(message, ["minor", "child", "under 16", "नाबालक"])) return _IntentResult("passport_sub", "ordinary_minor");
      return _IntentResult("passport_sub", "ordinary_adult");
    }
    if (_Helper.anyKeyword(message, ["minor passport", "child passport", "नाबालक राहदानी"])) return _IntentResult("passport_sub", "ordinary_minor");
    if (_Helper.anyKeyword(message, ["official passport", "blue passport", "सरकारी राहदानी"])) return _IntentResult("passport_sub", "official");
    if (_Helper.anyKeyword(message, ["diplomatic passport", "red passport", "कूटनीतिक राहदानी"])) return _IntentResult("passport_sub", "diplomatic");
    if (_Helper.anyKeyword(message, ["travel document", "black passport", "emergency travel", "यात्रा अनुमतिपत्र"])) return _IntentResult("passport_sub", "travel_document");
    
    return null;
  }
}

class _ResponseGenerator {
  final Map<String, dynamic> services;
  final Map<String, dynamic> rules;
  final List<dynamic> faqs;

  _ResponseGenerator(this.services, this.rules, this.faqs);

  String generate(String intentType, dynamic intentValue, Map<String, dynamic> context, String userMessage, String lang) {
    if (intentType == "service") return _serviceResponse(intentValue, userMessage, lang);
    if (intentType == "citizenship_sub") return _citizenshipSub(intentValue, lang);
    if (intentType == "birth_sub") return _birthSub(intentValue, lang);
    if (intentType == "nid_sub") return _nidSub(intentValue, lang);
    if (intentType == "passport_sub") return _passportSub(intentValue, lang);
    if (intentType == "rule") return _ruleResponse(intentValue, lang);
    if (intentType == "faq") return _faqResponse(intentValue, lang);
    return _unknownResponse(context, lang);
  }

  String _serviceResponse(String serviceKey, String userMessage, String lang) {
    var service = services[serviceKey];
    if (service == null) return "Service not found.";

    if (_Helper.anyKeyword(userMessage, ["fee", "cost", "price", "how much", "paisa", "shulk", "शुल्क"])) return _showFee(service, lang);
    if (_Helper.anyKeyword(userMessage, ["step", "how to", "apply", "process", "procedure", "चरण", "कसरी"])) return _showSteps(service, lang);
    if (_Helper.anyKeyword(userMessage, ["eligible", "eligibility", "qualify", "age", "योग्यता"])) return _showEligibility(service, lang);
    if (_Helper.anyKeyword(userMessage, ["office", "where", "location", "address", "कार्यालय", "कहाँ"])) return _showOffice(service, lang);
    if (_Helper.anyKeyword(userMessage, ["type", "types", "kinds", "category", "प्रकार"])) return _showTypes(service, serviceKey, lang);
    if (_Helper.anyKeyword(userMessage, ["document", "docs", "paper", "need", "bring", "required", "कागजात"])) return _showDocumentsMenu(serviceKey, lang);
    
    return _showFull(service, serviceKey, lang);
  }

  String _showFee(dynamic service, String lang) {
    if (lang == "ne") {
      return "${service['nepali_name']} को शुल्क:\n\n  रकम   : ${_Helper.t(service['fee'], lang)}\n  समय   : ${_Helper.t(service['processing_time'], lang)}\n  कार्यालय: ${_Helper.t(service['office'], lang)}";
    }
    return "Fee for ${service['name']}:\n\n  Amount          : ${_Helper.t(service['fee'], lang)}\n  Processing Time : ${_Helper.t(service['processing_time'], lang)}\n  Office          : ${_Helper.t(service['office'], lang)}";
  }

  String _showSteps(dynamic service, String lang) {
    var stepsRaw = service["steps"];
    List<String> steps = [];
    if (stepsRaw is Map) {
      List dynamicList = stepsRaw[lang] ?? stepsRaw['en'] ?? [];
      steps = dynamicList.map((e) => e.toString()).toList();
    } else if (stepsRaw is List) {
      steps = stepsRaw.map((e) => e.toString()).toList();
    }

    if (lang == "ne") {
      List<String> lines = ["${service['nepali_name']} आवेदन गर्ने तरिका:\n"];
      for (int i = 0; i < steps.length; i++) lines.add("  ${i+1}. ${steps[i]}");
      lines.add("\nलाग्ने समय: ${_Helper.t(service['processing_time'], lang)}");
      return lines.join("\n");
    }
    List<String> lines = ["How to apply for ${service['name']}:\n"];
    for (int i = 0; i < steps.length; i++) lines.add("  ${i+1}. ${steps[i]}");
    lines.add("\nProcessing Time: ${_Helper.t(service['processing_time'], lang)}");
    return lines.join("\n");
  }

  String _showEligibility(dynamic service, String lang) {
    dynamic eligRaw = service["eligibility"];
    dynamic elig;
    if (eligRaw is Map && (eligRaw.containsKey('en') || eligRaw.containsKey('ne'))) {
      elig = eligRaw[lang] ?? eligRaw['en'];
    } else {
      elig = eligRaw;
    }
    
    String title = lang == "ne" ? "${service['nepali_name']} को योग्यता:" : "Eligibility for ${service['name']}:";
    List<String> lines = [title, ""];
    if (elig is Map) {
      elig.forEach((k, v) => lines.add("  ${k.replaceAll('_',' ')}: $v"));
    } else if (elig is List) {
      for (var item in elig) lines.add("  • $item");
    } else {
       lines.add(elig.toString());
    }
    return lines.join("\n");
  }

  String _showOffice(dynamic service, String lang) {
    if (lang == "ne") {
      return "${service['nepali_name']} को कार्यालय:\n\n  ${_Helper.t(service['office'], lang)}\n\nशुल्क: ${_Helper.t(service['fee'], lang)}\nसमय : ${_Helper.t(service['processing_time'], lang)}";
    }
    return "Office for ${service['name']}:\n\n  ${_Helper.t(service['office'], lang)}\n\nFee            : ${_Helper.t(service['fee'], lang)}\nProcessing Time: ${_Helper.t(service['processing_time'], lang)}";
  }

  String _showTypes(dynamic service, String serviceKey, String lang) {
    if (service["types"] == null) return _showFull(service, serviceKey, lang);
    dynamic typesRaw = service["types"];
    List<String> types = [];
    if (typesRaw is Map) {
       List dynList = typesRaw[lang] ?? typesRaw['en'] ?? [];
       types = dynList.map((e)=>e.toString()).toList();
    } else if (typesRaw is List) {
       types = typesRaw.map((e)=>e.toString()).toList();
    }
    if (types.isEmpty) return _showFull(service, serviceKey, lang);

    String title = lang == "ne" ? "${service['nepali_name']} का प्रकारहरू:" : "Types of ${service['name']}:";
    List<String> lines = [title, ""];
    for (int i = 0; i < types.length; i++) lines.add("  ${i+1}. ${types[i]}");
    Map<String, String> hints = lang == "ne" ? {
      "citizenship": "\nसोध्नुहोस्: 'वंशज नागरिकता कागजात' / 'प्रतिलिपि कागजात'",
      "birth_certificate": "\nसोध्नुहोस्: 'समयमै जन्मदर्ता कागजात' / 'ढिलो जन्मदर्ता कागजात'",
      "nid": "\nसोध्नुहोस्: 'सामान्य nid कागजात' / 'नाबालक परिचयपत्र कागजात'",
      "passport": "\nसोध्नुहोस्: 'सामान्य राहदानी कागजात' / 'कूटनीतिक राहदानी कागजात'"
    } : {
      "citizenship": "\nAsk: 'citizenship by descent documents' / 'pratilipi documents'",
      "birth_certificate": "\nAsk: 'early birth documents' / 'late birth documents'",
      "nid": "\nAsk: 'standard nid documents' / 'minor id documents'",
      "passport": "\nAsk: 'ordinary passport documents' / 'diplomatic passport documents'"
    };
    lines.add(hints[serviceKey] ?? "");
    return lines.join("\n");
  }

  String _showDocumentsMenu(String serviceKey, String lang) {
    Map<String, String> menus = lang == "ne" ? {
      "citizenship": "नागरिकताका कागजात तपाईंको अवस्थामा निर्भर हुन्छ:\n\n  १. वंशजको आधारमा → सोध्नुहोस्: 'वंशज नागरिकता कागजात'\n  २. वैवाहिक अंगीकृत → सोध्नुहोस्: 'वैवाहिक अंगीकृत कागजात'\n  ३. अंगीकृत (विदेशी नागरिक) → सोध्नुहोस्: 'अंगीकृत नागरिकता कागजात'\n  ४. प्रतिलिपि (नक्कल प्रति) → सोध्नुहोस्: 'प्रतिलिपि कागजात'\n\nतपाईंलाई कुन लागू हुन्छ?",
      "birth_certificate": "जन्मदर्ताका कागजात तपाईंको अवस्थामा निर्भर हुन्छ:\n\n  १. समयमै दर्ता (३५ दिनभित्र) → सोध्नुहोस्: 'समयमै जन्मदर्ता कागजात'\n  २. ढिलो दर्ता (३५ दिनपछि) → सोध्नुहोस्: 'ढिलो जन्मदर्ता कागजात'\n  ३. बाबा विदेशमा → सोध्नुहोस्: 'बाबा विदेश जन्मदर्ता कागजात'\n  ४. बाबा अज्ञात वा हराएको → सोध्नुहोस्: 'बाबा अज्ञात जन्मदर्ता कागजात'\n  ५. अनाथ → सोध्नुहोस्: 'अनाथ जन्मदर्ता कागजात'\n  ६. एक अभिभावक विदेशी → सोध्नुहोस्: 'विदेशी अभिभावक जन्मदर्ता कागजात'\n\nतपाईंलाई कुन लागू हुन्छ?",
      "nid": "NID कागजात तपाईंको उमेरमा निर्भर हुन्छ:\n\n  १. सामान्य NID (१६+) → सोध्नुहोस्: 'सामान्य nid कागजात'\n  २. नाबालक परिचयपत्र (१६ भन्दा कम) → सोध्नुहोस्: 'नाबालक परिचयपत्र कागजात'\n\nतपाईंलाई कुन लागू हुन्छ?",
      "passport": "राहदानीका कागजात प्रकार अनुसार फरक हुन्छ:\n\n  १. सामान्य राहदानी → सोध्नुहोस्: 'सामान्य राहदानी कागजात'\n  २. सरकारी राहदानी → सोध्नुहोस्: 'सरकारी राहदानी कागजात'\n  ३. कूटनीतिक राहदानी → सोध्नुहोस्: 'कूटनीतिक राहदानी कागजात'\n  ४. यात्रा अनुमतिपत्र → सोध्नुहोस्: 'यात्रा अनुमतिपत्र कागजात'\n\nतपाईंलाई कुन लागू हुन्छ?"
    } : {
      "citizenship": "Citizenship documents depend on your situation:\n\n  1. Citizenship by Descent → ask: 'citizenship by descent documents'\n  2. Naturalized through Marriage → ask: 'naturalized marriage documents'\n  3. Naturalized (Foreign National) → ask: 'naturalized citizenship documents'\n  4. Pratilipi (Duplicate Copy) → ask: 'pratilipi documents'\n\nWhich applies to you?",
      "birth_certificate": "Birth certificate documents depend on your situation:\n\n  1. Early Registration (within 35 days) → ask: 'early birth registration documents'\n  2. Late Registration (after 35 days) → ask: 'late birth registration documents'\n  3. Father is abroad → ask: 'birth father abroad documents'\n  4. Father is unknown or missing → ask: 'birth father unknown documents'\n  5. Orphan → ask: 'orphan birth documents'\n  6. One parent is a foreigner → ask: 'birth foreign parent documents'\n\nWhich applies to you?",
      "nid": "NID documents depend on your age:\n\n  1. Standard NID (age 16+) → ask: 'standard nid documents'\n  2. Minor's ID (under 16) → ask: 'minor id documents'\n\nWhich applies to you?",
      "passport": "Passport documents depend on the type:\n\n  1. Ordinary Passport → ask: 'ordinary passport documents'\n  2. Official Passport → ask: 'official passport documents'\n  3. Diplomatic Passport → ask: 'diplomatic passport documents'\n  4. Travel Document → ask: 'travel document documents'\n\nWhich applies to you?"
    };
    return menus[serviceKey] ?? (lang == "ne" ? "कुन सेवाको कागजात चाहियो भन्नुहोस्।" : "Please specify which service you need documents for.");
  }

  String _showFull(dynamic service, String serviceKey, String lang) {
    List<String> lines = [];
    String sep = "═" * 52;
    lines.add("\n$sep");
    if (lang == "ne") {
      lines.add("  ${service['nepali_name']}");
    } else {
      lines.add("  ${service['name']}");
      lines.add("  ${service['nepali_name']}");
    }
    lines.add(sep);

    if (lang == "ne") {
      lines.add("\n  शुल्क : ${_Helper.t(service['fee'], lang)}");
      lines.add("  समय   : ${_Helper.t(service['processing_time'], lang)}");
      lines.add("  कार्यालय: ${_Helper.t(service['office'], lang)}");
    } else {
      lines.add("\n  Fee            : ${_Helper.t(service['fee'], lang)}");
      lines.add("  Processing Time: ${_Helper.t(service['processing_time'], lang)}");
      lines.add("  Office         : ${_Helper.t(service['office'], lang)}");
    }

    if (service["types"] != null) {
      dynamic typesRaw = service["types"];
      List types = (typesRaw is Map ? typesRaw[lang] ?? typesRaw['en'] : typesRaw) ?? [];
      if (types.isNotEmpty) {
        lines.add("\n  ${lang == 'ne' ? 'प्रकारहरू:' : 'TYPES:'}");
        for (int i = 0; i < types.length; i++) lines.add("    ${i+1}. ${types[i]}");
      }
    }

    lines.add("\n  ${lang == 'ne' ? 'योग्यता:' : 'ELIGIBILITY:'}");
    dynamic eligRaw = service["eligibility"];
    dynamic elig = eligRaw is Map && (eligRaw.containsKey('en') || eligRaw.containsKey('ne')) ? eligRaw[lang] ?? eligRaw['en'] : eligRaw;
    if (elig is Map) {
      elig.forEach((k, v) => lines.add("    • ${k.replaceAll('_',' ')}: $v"));
    } else if (elig is List) {
      for (var item in elig) lines.add("    ✓ $item");
    }

    Map<String, String> hint = lang == "ne" ? {
      "citizenship": "\n  कागजात: नागरिकताको प्रकारमा निर्भर।\n  सोध्नुहोस्: 'नागरिकता कागजात'",
      "birth_certificate": "\n  कागजात: जन्म अवस्थामा निर्भर।\n  सोध्नुहोस्: 'जन्मदर्ता कागजात'",
      "nid": "\n  कागजात: उमेरमा निर्भर।\n  सोध्नुहोस्: 'nid कागजात'",
      "passport": "\n  कागजात: राहदानी प्रकारमा निर्भर।\n  सोध्नुहोस्: 'राहदानी कागजात'"
    } : {
      "citizenship": "\n  DOCUMENTS: Depend on citizenship type.\n  Ask: 'citizenship documents' to see all options.",
      "birth_certificate": "\n  DOCUMENTS: Depend on birth situation.\n  Ask: 'birth certificate documents' to see all options.",
      "nid": "\n  DOCUMENTS: Depend on your age.\n  Ask: 'nid documents' to see all options.",
      "passport": "\n  DOCUMENTS: Depend on passport type.\n  Ask: 'passport documents' to see all options."
    };
    lines.add(hint[serviceKey] ?? "");

    String footerSep = "─" * 52;
    lines.add("\n$footerSep");
    lines.add(lang == "ne" ? "  सोध्नुहोस्: शुल्क / प्रकार / कागजात / चरण / योग्यता / कार्यालय" : "  Ask: fee / types / documents / steps / eligibility / office");
    return lines.join("\n");
  }

  String _citizenshipSub(String subintent, String lang) {
    var c = services["citizenship"];
    if (subintent == "types") return _showTypes(c, "citizenship", lang);
    if (subintent == "pratilipi_general") {
      return lang == "ne" 
        ? "प्रतिलिपि (नागरिकता नक्कल) — कुन अवस्था लागू हुन्छ?\n\n  १. बसाइसराइ पछि → सोध्नुहोस्: 'प्रतिलिपि बसाइसराइ कागजात'\n  २. पतिको नाम थपी → सोध्नुहोस्: 'प्रतिलिपि पति नाम कागजात'\n  ३. पारपाचुके पछि → सोध्नुहोस्: 'प्रतिलिपि पारपाचुके कागजात'\n  ४. थर सुधार → सोध्नुहोस्: 'प्रतिलिपि थर सुधार कागजात'"
        : "Pratilipi (Duplicate Citizenship) — Which situation applies?\n\n  1. After Migration → ask: 'pratilipi migration documents'\n  2. Adding Husband's Name → ask: 'pratilipi husband name documents'\n  3. After Divorce → ask: 'pratilipi divorce documents'\n  4. Surname Correction → ask: 'pratilipi surname correction documents'";
    }

    Map<String, List<String>> subMap = {
      "pratilipi_migration": ["pratilipi_after_migration", "Duplicate Citizenship After Migration", "बसाइसराइ पछिको नागरिकता प्रतिलिपि"],
      "pratilipi_husband": ["pratilipi_add_husband_name", "Duplicate Citizenship — Adding Husband's Name", "पतिको नाम थप्ने नागरिकता प्रतिलिपि"],
      "pratilipi_divorce": ["pratilipi_after_divorce", "Duplicate Citizenship After Divorce", "पारपाचुके पछिको नागरिकता प्रतिलिपि"],
      "pratilipi_surname": ["pratilipi_surname_correction", "Duplicate Citizenship — Surname Correction", "थर सुधार नागरिकता प्रतिलिपि"],
      "descent": ["citizenship_by_descent", "Citizenship by Descent", "वंशजको आधारमा नागरिकता"],
      "naturalized_marriage": ["naturalized_through_marriage", "Naturalized Citizenship Through Marriage", "वैवाहिक अंगीकृत नागरिकता"],
      "naturalized": ["naturalized", "Naturalized Citizenship", "अंगीकृत नागरिकता"],
    };

    if (subMap.containsKey(subintent)) {
      var arr = subMap[subintent]!;
      List docsRaw = c["required_documents"][arr[0]][lang] ?? c["required_documents"][arr[0]]['en'] ?? [];
      String title = lang == "ne" ? arr[2] : arr[1];
      String label = lang == "ne" ? "का लागि कागजात:" : "Documents for";
      List<String> lines = lang == "ne" ? ["$title $label\n"] : ["$label $title:\n"];
      for (int i = 0; i < docsRaw.length; i++) lines.add("  ${i+1}. ${docsRaw[i]}");
      lines.add(lang == "ne" ? "\nसूचना: सक्कल र फोटोकपी दुवै बुझाउनुहोस्।" : "\nNote: Bring both originals AND photocopies.");
      return lines.join("\n");
    }

    if (subintent == "sifarish") {
      List stepsRaw = c["steps"][lang] ?? c["steps"]['en'] ?? [];
      List<String> wardSteps = stepsRaw.map((e)=>e.toString()).where((s) => s.contains("चरण १") || s.contains("Step 1")).toList();
      List<String> lines = [lang == "ne" ? "चरण १ — वडा कार्यालय (सिफारिस पत्र):\n" : "Step 1 — Ward Office (Sifarish Patra):\n"];
      for (var s in wardSteps) lines.add("  • ${s.replaceAll('Step 1 - Ward Office: ', '').replaceAll('चरण १ - वडा कार्यालय: ', '')}");
      lines.add(lang == "ne" ? "\nसिफारिस पत्र पाएपछि DAO जानुहोस्।" : "\nAfter getting Sifarish Patra → proceed to DAO.");
      return lines.join("\n");
    }

    if (subintent == "dao_step") {
      List stepsRaw = c["steps"][lang] ?? c["steps"]['en'] ?? [];
      List<String> daoSteps = stepsRaw.map((e)=>e.toString()).where((s) => s.contains("चरण २") || s.contains("Step 2")).toList();
      List<String> lines = [lang == "ne" ? "चरण २ — DAO/CDO कार्यालय:\n" : "Step 2 — DAO/CDO Office:\n"];
      for (var s in daoSteps) lines.add("  • ${s.replaceAll('Step 2 - DAO: ', '').replaceAll('चरण २ - DAO: ', '')}");
      lines.add(lang == "ne" ? "\nसूचना: कम्तिमा एक अभिभावक उपस्थित हुनुपर्छ (सनाखत)।" : "\nNote: At least one parent must be present (Sanaakhat).");
      return lines.join("\n");
    }

    return _showFull(c, "citizenship", lang);
  }

  String _birthSub(String subintent, String lang) {
    var b = services["birth_certificate"];
    if (subintent == "types") return _showTypes(b, "birth_certificate", lang);
    Map<String, List<String>> docMap = {
      "early": ["early_registration", "Early Birth Registration", "समयमै जन्मदर्ता"],
      "late": ["late_registration", "Late Birth Registration", "ढिलो जन्मदर्ता"],
      "father_abroad": ["father_abroad", "Father is Abroad", "बाबा विदेशमा"],
      "father_unknown": ["father_unknown_missing", "Father Unknown or Missing", "बाबा अज्ञात वा हराएको"],
      "orphan": ["orphan", "Orphan", "अनाथ"],
      "foreign_parent": ["foreign_parent", "One Parent is a Foreigner", "एक अभिभावक विदेशी"],
      "migrated_parents": ["migrated_parents", "Parents are Migrated/Resettled", "अभिभावक बसाइसराइ भएको"],
    };
    if (docMap.containsKey(subintent)) {
      var arr = docMap[subintent]!;
      List docsRaw = b["required_documents"][arr[0]][lang] ?? b["required_documents"][arr[0]]['en'] ?? [];
      String title = lang == "ne" ? arr[2] : arr[1];
      String label = lang == "ne" ? "का लागि कागजात:" : "Documents for";
      List<String> lines = lang == "ne" ? ["$title $label\n"] : ["$label $title:\n"];
      for (int i = 0; i < docsRaw.length; i++) lines.add("  ${i+1}. ${docsRaw[i]}");
      return lines.join("\n");
    }
    return _showFull(b, "birth_certificate", lang);
  }

  String _nidSub(String subintent, String lang) {
    var n = services["nid"];
    if (subintent == "types") return _showTypes(n, "nid", lang);
    Map<String, List<String>> docMap = {
      "standard_nid": ["standard_nid", "Standard NID (Age 16+)", "सामान्य NID (१६+ वर्ष)"],
      "minor_id": ["minor_id", "Minor Identity Card (Under 16)", "नाबालक परिचयपत्र (१६ भन्दा कम)"],
    };
    if (docMap.containsKey(subintent)) {
      var arr = docMap[subintent]!;
      List docsRaw = n["required_documents"][arr[0]][lang] ?? n["required_documents"][arr[0]]['en'] ?? [];
      String title = lang == "ne" ? arr[2] : arr[1];
      String label = lang == "ne" ? "का लागि कागजात:" : "Documents for";
      List<String> lines = lang == "ne" ? ["$title $label\n"] : ["$label $title:\n"];
      for (int i = 0; i < docsRaw.length; i++) lines.add("  ${i+1}. ${docsRaw[i]}");
      return lines.join("\n");
    }
    return _showFull(n, "nid", lang);
  }

  String _passportSub(String subintent, String lang) {
    var p = services["passport"];
    if (subintent == "types") return _showTypes(p, "passport", lang);
    Map<String, List<String>> docMap = {
      "ordinary_adult": ["ordinary_passport_adult", "Ordinary Passport (Adult)", "सामान्य राहदानी (वयस्क)"],
      "ordinary_minor": ["ordinary_passport_minor", "Ordinary Passport (Minor)", "सामान्य राहदानी (नाबालक)"],
      "official": ["official_passport", "Official Passport", "सरकारी राहदानी"],
      "diplomatic": ["diplomatic_passport", "Diplomatic Passport", "कूटनीतिक राहदानी"],
      "travel_document": ["travel_document", "Travel Document", "यात्रा अनुमतिपत्र"],
    };
    if (docMap.containsKey(subintent)) {
      var arr = docMap[subintent]!;
      List docsRaw = p["required_documents"][arr[0]][lang] ?? p["required_documents"][arr[0]]['en'] ?? [];
      String title = lang == "ne" ? arr[2] : arr[1];
      String label = lang == "ne" ? "का लागि कागजात:" : "Documents for";
      List<String> lines = lang == "ne" ? ["$title $label\n"] : ["$label $title:\n"];
      for (int i = 0; i < docsRaw.length; i++) lines.add("  ${i+1}. ${docsRaw[i]}");
      return lines.join("\n");
    }
    return _showFull(p, "passport", lang);
  }

  String _ruleResponse(String ruleKey, String lang) {
    return _Helper.t(rules[ruleKey]["responses"], lang);
  }

  String _faqResponse(int faqIndex, String lang) {
    var faq = faqs[faqIndex];
    String q = _Helper.t(faq["question"], lang);
    String a = _Helper.t(faq["answer"], lang);
    return "Q: $q\n\nA: $a";
  }

  String _unknownResponse(Map<String, dynamic> context, String lang) {
    if (lang == "ne") {
      return "माफ गर्नुहोस्, मैले बुझिनँ। तपाईं नागरिकता, जन्मदर्ता, NID, वा राहदानीको बारेमा सोध्न सक्नुहुन्छ।";
    }
    return "Sorry, I didn't understand. You can ask about Citizenship, Birth Certificate, NID, or Passport.";
  }
}
