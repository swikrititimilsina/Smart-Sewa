# chatbot/smart_sathi.py
# Smart Sathi — bilingual chatbot (English + Nepali) using JSON files only
# Auto-detects Nepali script and replies in the same language

import json
import random
import os
import re

# ══════════════════════════════════════════
# JSON LOADER
# ══════════════════════════════════════════

def load_json(relative_path):
    base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    full_path = os.path.join(base, relative_path)
    with open(full_path, "r", encoding="utf-8") as f:
        return json.load(f)


# ══════════════════════════════════════════
# LANGUAGE DETECTOR
#
# Nepali (Devanagari script) Unicode range:
# \u0900 to \u097F
#
# If the message contains ANY Devanagari character,
# treat the whole message as Nepali.
# This is simple and reliable since English text
# never contains Devanagari characters.
# ══════════════════════════════════════════

def detect_language(message: str) -> str:
    """
    Returns 'ne' if message contains Nepali script
    Returns 'en' otherwise
    """
    for char in message:
        if '\u0900' <= char <= '\u097F':
            return "ne"
    return "en"


# ══════════════════════════════════════════
# KEYWORD MATCHER (word-boundary safe)
#
# Plain "in" substring checks are dangerous:
# "hi" matches inside "citizenship" (citizens-HI-p)
# "id" matches inside "voted" or "kid"
#
# This helper only matches short English keywords
# (<=4 letters, alphabetic only) on whole-word
# boundaries. Longer keywords, phrases, and any
# Nepali (Devanagari) keywords still use normal
# substring matching since Nepali compounds don't
# split into space-separated words the same way
# and longer phrases are safe from false positives.
# ══════════════════════════════════════════

def contains_keyword(message: str, keyword: str) -> bool:
    keyword = keyword.lower()
    message = message.lower()

    # Devanagari or multi-word phrases: substring is safe
    is_devanagari = any('\u0900' <= ch <= '\u097F' for ch in keyword)
    if is_devanagari or " " in keyword or len(keyword) > 4:
        return keyword in message

    # Short plain English word: require word boundary
    pattern = r'(?<![a-zA-Z])' + re.escape(keyword) + r'(?![a-zA-Z])'
    return re.search(pattern, message) is not None


def any_keyword(message: str, keywords) -> bool:
    """Safe replacement for: any(w in message for w in keywords)"""
    return any(contains_keyword(message, w) for w in keywords)


# ══════════════════════════════════════════
# TYPO FIXER (English typos only)
# ══════════════════════════════════════════

TYPO_MAP = {
    "citiznship":   "citizenship",
    "citienship":   "citizenship",
    "citizeship":   "citizenship",
    "citzenship":   "citizenship",
    "nagarikatha":  "citizenship",
    "brith":        "birth",
    "bith":         "birth",
    "berth":        "birth",
    "janmadarta":   "birth certificate",
    "ndi":          "nid",
    "ind":          "nid",
    "natinal":      "national",
    "identiy":      "identity",
    "nabalik":      "minor",
    "pasport":      "passport",
    "passprt":      "passport",
    "passort":      "passport",
    "passpot":      "passport",
    "rahdani":      "passport",
    "rahadni":      "passport",
    "diplmatic":    "diplomatic",
    "ofical":       "official",
    "documant":     "document",
    "docuemnt":     "document",
    "documnet":     "document",
    "documets":     "documents",
    "stesp":        "steps",
    "hwo":          "how",
    "appply":       "apply",
    "aply":         "apply",
    "pratlipi":     "pratilipi",
    "duplicat":     "duplicate",
    "registraton":  "registration",
}

def fix_typos(message: str) -> str:
    words = message.lower().split()
    return " ".join(TYPO_MAP.get(w, w) for w in words)


# ══════════════════════════════════════════
# COMPONENT 1 — INTENT RECOGNIZER
# Works the same regardless of language —
# keywords lists already contain both
# English and Nepali terms (see services.json)
# ══════════════════════════════════════════

try:
    from thefuzz import fuzz
    FUZZY_AVAILABLE = True
except ImportError:
    FUZZY_AVAILABLE = False


class IntentRecognizer:

    def __init__(self):
        self.services = load_json("data/services.json")
        self.rules    = load_json("data/chatbot_rules.json")
        self.faqs     = load_json("data/faqs.json")["faqs"]
        self.FUZZY_THRESHOLD = 80

    def recognize(self, user_message: str):
        original = user_message.lower().strip()
        fixed    = fix_typos(original)

        result = self._exact_match(original)
        if result[0] != "unknown":
            return result

        if fixed != original:
            result = self._exact_match(fixed)
            if result[0] != "unknown":
                return result

        if FUZZY_AVAILABLE:
            result = self._fuzzy_match(original)
            if result[0] != "unknown":
                return result

        return ("unknown", None)

    def _exact_match(self, message: str):

        for rule_key, rule_data in self.rules.items():
            if rule_key == "unknown":
                continue
            for pattern in rule_data.get("patterns", []):
                if contains_keyword(message, pattern):
                    return ("rule", rule_key)

        sub = self._detect_subintent(message)
        if sub:
            return sub

        # FAQs are checked before generic service keywords because
        # FAQ entries represent more specific questions
        # (e.g. "is nid mandatory" should hit the FAQ, not just
        # show generic NID info)
        for index, faq in enumerate(self.faqs):
            for keyword in faq["keywords"]:
                if contains_keyword(message, keyword):
                    return ("faq", index)

        for service_key, service_data in self.services.items():
            for keyword in service_data["keywords"]:
                if contains_keyword(message, keyword):
                    return ("service", service_key)

        return ("unknown", None)

    def _detect_subintent(self, message: str):
        """
        Detect specific sub-topics — works with both
        English and Nepali trigger words
        """

        # ── CITIZENSHIP ──
        if any_keyword(message, [
            "types of citizenship", "citizenship types",
            "नागरिकताका प्रकार", "नागरिकता प्रकार"
        ]):
            return ("citizenship_sub", "types")

        if any_keyword(message, [
            "pratilipi", "duplicate citizenship", "प्रतिलिपि", "नक्कल"
        ]):
            if any_keyword(message, ["migration", "basai", "moved", "बसाइसराइ"]):
                return ("citizenship_sub", "pratilipi_migration")
            elif any_keyword(message, ["divorce", "divorced", "पारपाचुके", "सम्बन्ध विच्छेद"]):
                return ("citizenship_sub", "pratilipi_divorce")
            elif any_keyword(message, ["husband", "marriage", "married", "पति", "विवाह"]):
                return ("citizenship_sub", "pratilipi_husband")
            elif any_keyword(message, ["surname", "name correction", "थर सुधार", "नाम सुधार"]):
                return ("citizenship_sub", "pratilipi_surname")
            else:
                return ("citizenship_sub", "pratilipi_general")

        if any_keyword(message, ["by descent", "descent citizenship", "वंशज"]):
            return ("citizenship_sub", "descent")

        if any_keyword(message, ["naturalized marriage", "वैवाहिक अंगीकृत"]):
            return ("citizenship_sub", "naturalized_marriage")

        if any_keyword(message, ["naturalized citizenship", "naturalization", "अंगीकृत नागरिकता"]):
            return ("citizenship_sub", "naturalized")

        if any_keyword(message, ["sifarish", "sifarish patra", "सिफारिस"]):
            return ("citizenship_sub", "sifarish")

        if any_keyword(message, ["dao step", "cdo step", "sanaakhat", "sarjaamin", "सनाखत", "सर्जमिन"]):
            return ("citizenship_sub", "dao_step")

        # ── BIRTH CERTIFICATE ──
        if any_keyword(message, ["early birth", "birth within 35", "समयमै जन्मदर्ता"]):
            return ("birth_sub", "early")

        if any_keyword(message, ["late birth", "birth after 35", "ढिलो जन्मदर्ता"]):
            return ("birth_sub", "late")

        if any_keyword(message, ["birth father abroad", "father abroad birth", "बाबा विदेश जन्मदर्ता"]):
            return ("birth_sub", "father_abroad")

        if any_keyword(message, ["birth father unknown", "father unknown birth", "बाबा अज्ञात जन्मदर्ता"]):
            return ("birth_sub", "father_unknown")

        if any_keyword(message, ["orphan birth", "birth orphan", "अनाथ जन्मदर्ता"]):
            return ("birth_sub", "orphan")

        if any_keyword(message, ["foreign parent birth", "birth foreign parent", "विदेशी अभिभावक जन्मदर्ता"]):
            return ("birth_sub", "foreign_parent")

        if any_keyword(message, ["birth migrated parents", "migration birth", "बसाइसराइ जन्मदर्ता"]):
            return ("birth_sub", "migrated_parents")

        if any_keyword(message, ["types of birth", "birth registration types", "जन्मदर्ताका प्रकार"]):
            return ("birth_sub", "types")

        # ── NID ──
        if any_keyword(message, [
            "minor id", "nabalik parichaya", "child nid", "नाबालक परिचयपत्र"
        ]):
            return ("nid_sub", "minor_id")

        if any_keyword(message, ["standard nid", "adult nid", "सामान्य nid", "सामान्य परिचयपत्र"]):
            return ("nid_sub", "standard_nid")

        if any_keyword(message, ["types of nid", "nid types", "nid का प्रकार"]):
            return ("nid_sub", "types")

        # ── PASSPORT ──
        if any_keyword(message, ["types of passport", "passport types", "राहदानीका प्रकार"]):
            return ("passport_sub", "types")

        if any_keyword(message, ["ordinary passport", "green passport", "सामान्य राहदानी"]):
            if any_keyword(message, ["minor", "child", "under 16", "नाबालक"]):
                return ("passport_sub", "ordinary_minor")
            return ("passport_sub", "ordinary_adult")

        if any_keyword(message, ["minor passport", "child passport", "नाबालक राहदानी"]):
            return ("passport_sub", "ordinary_minor")

        if any_keyword(message, ["official passport", "blue passport", "सरकारी राहदानी"]):
            return ("passport_sub", "official")

        if any_keyword(message, ["diplomatic passport", "red passport", "कूटनीतिक राहदानी"]):
            return ("passport_sub", "diplomatic")

        if any_keyword(message, [
            "travel document", "black passport", "emergency travel", "यात्रा अनुमतिपत्र"
        ]):
            return ("passport_sub", "travel_document")

        return None

    def _fuzzy_match(self, message: str):
        words      = message.split()
        best_type  = "unknown"
        best_value = None
        best_score = 0

        for rule_key, rule_data in self.rules.items():
            if rule_key == "unknown":
                continue
            for pattern in rule_data.get("patterns", []):
                for word in words:
                    score = fuzz.ratio(word, pattern.lower())
                    if score >= self.FUZZY_THRESHOLD and score > best_score:
                        best_score = score
                        best_type  = "rule"
                        best_value = rule_key

        for service_key, service_data in self.services.items():
            for keyword in service_data["keywords"]:
                score1 = fuzz.partial_ratio(message, keyword.lower())
                for word in words:
                    score2 = fuzz.ratio(word, keyword.lower())
                    score  = max(score1, score2)
                    if score >= self.FUZZY_THRESHOLD and score > best_score:
                        best_score = score
                        best_type  = "service"
                        best_value = service_key

        for index, faq in enumerate(self.faqs):
            for keyword in faq["keywords"]:
                for word in words:
                    score = fuzz.ratio(word, keyword.lower())
                    if score >= self.FUZZY_THRESHOLD and score > best_score:
                        best_score = score
                        best_type  = "faq"
                        best_value = index

        return (best_type, best_value)


# ══════════════════════════════════════════
# COMPONENT 2 — DIALOGUE MANAGER
# Now also remembers the language of the
# conversation so follow-ups stay consistent
# ══════════════════════════════════════════

class DialogueManager:

    def __init__(self):
        self.last_service       = None
        self.last_subintent     = None
        self.last_language      = "en"
        self.conversation_count = 0
        self.history            = []

    def update(self, user_msg, intent_type, intent_value, bot_response, language):
        self.conversation_count += 1
        self.last_language = language

        if intent_type == "service":
            self.last_service   = intent_value
            self.last_subintent = None
        elif intent_type in ("citizenship_sub", "birth_sub", "nid_sub", "passport_sub"):
            service_map = {
                "citizenship_sub": "citizenship",
                "birth_sub":       "birth_certificate",
                "nid_sub":         "nid",
                "passport_sub":    "passport"
            }
            self.last_service   = service_map.get(intent_type)
            self.last_subintent = intent_value

        self.history.append({
            "turn":         self.conversation_count,
            "user":         user_msg,
            "intent_type":  intent_type,
            "intent_value": str(intent_value),
            "language":     language
        })

    def is_followup(self, message: str) -> bool:
        followup_words = [
            "documents", "docs", "papers", "what do i need",
            "steps", "how to", "procedure", "process",
            "fee", "cost", "price", "how much",
            "time", "how long", "days",
            "office", "where", "location",
            "eligibility", "who can", "requirement",
            "more", "tell me", "what", "which", "also", "types",
            # Nepali follow-up words
            "कागजात", "शुल्क", "चरण", "समय", "कार्यालय", "योग्यता", "प्रकार"
        ]
        return (
            self.last_service is not None
            and any_keyword(message.lower(), followup_words)
        )

    def get_context(self):
        return {
            "last_service":       self.last_service,
            "last_subintent":     self.last_subintent,
            "conversation_count": self.conversation_count
        }


# ══════════════════════════════════════════
# COMPONENT 3 — RESPONSE GENERATOR
# Now takes a `lang` parameter ('en' or 'ne')
# and pulls the matching text from JSON
# ══════════════════════════════════════════

class ResponseGenerator:

    def __init__(self):
        self.services = load_json("data/services.json")
        self.rules    = load_json("data/chatbot_rules.json")
        self.faqs     = load_json("data/faqs.json")["faqs"]

    def generate(self, intent_type, intent_value, context, user_message="", lang="en"):
        if intent_type == "service":
            return self._service_response(intent_value, user_message, lang)
        elif intent_type == "citizenship_sub":
            return self._citizenship_sub(intent_value, lang)
        elif intent_type == "birth_sub":
            return self._birth_sub(intent_value, lang)
        elif intent_type == "nid_sub":
            return self._nid_sub(intent_value, lang)
        elif intent_type == "passport_sub":
            return self._passport_sub(intent_value, lang)
        elif intent_type == "rule":
            return self._rule_response(intent_value, lang)
        elif intent_type == "faq":
            return self._faq_response(intent_value, lang)
        else:
            return self._unknown_response(context, lang)

    # ── small helper to safely pull bilingual text ──
    def _t(self, field, lang):
        """
        field can be:
          {"en": "...", "ne": "..."}   → returns field[lang]
          "plain string"               → returns as-is (no translation available)
          list                         → returns as-is
        """
        if isinstance(field, dict) and "en" in field and "ne" in field:
            return field.get(lang, field["en"])
        return field

    # ────────────────────────────────────────
    # GENERAL SERVICE RESPONSE
    # ────────────────────────────────────────

    def _service_response(self, service_key, user_message, lang):
        service = self.services[service_key]
        msg     = user_message.lower()

        fee_words   = ["fee", "cost", "price", "how much", "paisa", "shulk", "शुल्क"]
        step_words  = ["step", "how to", "apply", "process", "procedure", "चरण", "कसरी"]
        elig_words  = ["eligible", "eligibility", "qualify", "age", "योग्यता"]
        office_words= ["office", "where", "location", "address", "कार्यालय", "कहाँ"]
        type_words  = ["type", "types", "kinds", "category", "प्रकार"]
        doc_words   = ["document", "docs", "paper", "need", "bring", "required", "कागजात"]

        if any_keyword(msg, fee_words):
            return self._show_fee(service, lang)
        elif any_keyword(msg, step_words):
            return self._show_steps(service, lang)
        elif any_keyword(msg, elig_words):
            return self._show_eligibility(service, lang)
        elif any_keyword(msg, office_words):
            return self._show_office(service, lang)
        elif any_keyword(msg, type_words):
            return self._show_types(service, service_key, lang)
        elif any_keyword(msg, doc_words):
            return self._show_documents_menu(service_key, lang)
        else:
            return self._show_full(service, service_key, lang)

    def _show_fee(self, service, lang):
        if lang == "ne":
            return (
                f"{service['nepali_name']} को शुल्क:\n\n"
                f"  रकम   : {self._t(service['fee'], lang)}\n"
                f"  समय   : {self._t(service['processing_time'], lang)}\n"
                f"  कार्यालय: {self._t(service['office'], lang)}"
            )
        return (
            f"Fee for {service['name']}:\n\n"
            f"  Amount          : {self._t(service['fee'], lang)}\n"
            f"  Processing Time : {self._t(service['processing_time'], lang)}\n"
            f"  Office          : {self._t(service['office'], lang)}"
        )

    def _show_steps(self, service, lang):
        steps = self._t(service["steps"], lang)
        if lang == "ne":
            lines = [f"{service['nepali_name']} आवेदन गर्ने तरिका:\n"]
            for i, step in enumerate(steps, 1):
                lines.append(f"  {i}. {step}")
            lines.append(f"\nलाग्ने समय: {self._t(service['processing_time'], lang)}")
            return "\n".join(lines)
        lines = [f"How to apply for {service['name']}:\n"]
        for i, step in enumerate(steps, 1):
            lines.append(f"  {i}. {step}")
        lines.append(f"\nProcessing Time: {self._t(service['processing_time'], lang)}")
        return "\n".join(lines)

    def _show_eligibility(self, service, lang):
        elig = self._t(service["eligibility"], lang)
        title = f"{service['nepali_name']} को योग्यता:" if lang == "ne" else f"Eligibility for {service['name']}:"
        lines = [title, ""]
        if isinstance(elig, dict):
            for key, val in elig.items():
                lines.append(f"  {key.replace('_',' ').title()}: {val}")
        else:
            bullet = "•"
            for item in elig:
                lines.append(f"  {bullet} {item}")
        return "\n".join(lines)

    def _show_office(self, service, lang):
        if lang == "ne":
            return (
                f"{service['nepali_name']} को कार्यालय:\n\n"
                f"  {self._t(service['office'], lang)}\n\n"
                f"शुल्क: {self._t(service['fee'], lang)}\n"
                f"समय : {self._t(service['processing_time'], lang)}"
            )
        return (
            f"Office for {service['name']}:\n\n"
            f"  {self._t(service['office'], lang)}\n\n"
            f"Fee            : {self._t(service['fee'], lang)}\n"
            f"Processing Time: {self._t(service['processing_time'], lang)}"
        )

    def _show_types(self, service, service_key, lang):
        types = self._t(service.get("types", []), lang)
        if not types:
            return self._show_full(service, service_key, lang)

        title = f"{service['nepali_name']} का प्रकारहरू:" if lang == "ne" else f"Types of {service['name']}:"
        lines = [title, ""]
        for i, t in enumerate(types, 1):
            lines.append(f"  {i}. {t}")

        hints_en = {
            "citizenship":       "\nAsk: 'citizenship by descent documents' / 'pratilipi documents'",
            "birth_certificate": "\nAsk: 'early birth documents' / 'late birth documents'",
            "nid":               "\nAsk: 'standard nid documents' / 'minor id documents'",
            "passport":          "\nAsk: 'ordinary passport documents' / 'diplomatic passport documents'"
        }
        hints_ne = {
            "citizenship":       "\nसोध्नुहोस्: 'वंशज नागरिकता कागजात' / 'प्रतिलिपि कागजात'",
            "birth_certificate": "\nसोध्नुहोस्: 'समयमै जन्मदर्ता कागजात' / 'ढिलो जन्मदर्ता कागजात'",
            "nid":               "\nसोध्नुहोस्: 'सामान्य nid कागजात' / 'नाबालक परिचयपत्र कागजात'",
            "passport":          "\nसोध्नुहोस्: 'सामान्य राहदानी कागजात' / 'कूटनीतिक राहदानी कागजात'"
        }
        hints = hints_ne if lang == "ne" else hints_en
        lines.append(hints.get(service_key, ""))
        return "\n".join(lines)

    def _show_documents_menu(self, service_key, lang):
        menus_en = {
            "citizenship": (
                "Citizenship documents depend on your situation:\n\n"
                "  1. Citizenship by Descent → ask: 'citizenship by descent documents'\n"
                "  2. Naturalized through Marriage → ask: 'naturalized marriage documents'\n"
                "  3. Naturalized (Foreign National) → ask: 'naturalized citizenship documents'\n"
                "  4. Pratilipi (Duplicate Copy) → ask: 'pratilipi documents'\n\n"
                "Which applies to you?"
            ),
            "birth_certificate": (
                "Birth certificate documents depend on your situation:\n\n"
                "  1. Early Registration (within 35 days) → ask: 'early birth registration documents'\n"
                "  2. Late Registration (after 35 days) → ask: 'late birth registration documents'\n"
                "  3. Father is abroad → ask: 'birth father abroad documents'\n"
                "  4. Father is unknown or missing → ask: 'birth father unknown documents'\n"
                "  5. Orphan → ask: 'orphan birth documents'\n"
                "  6. One parent is a foreigner → ask: 'birth foreign parent documents'\n\n"
                "Which applies to you?"
            ),
            "nid": (
                "NID documents depend on your age:\n\n"
                "  1. Standard NID (age 16+) → ask: 'standard nid documents'\n"
                "  2. Minor's ID (under 16) → ask: 'minor id documents'\n\n"
                "Which applies to you?"
            ),
            "passport": (
                "Passport documents depend on the type:\n\n"
                "  1. Ordinary Passport → ask: 'ordinary passport documents'\n"
                "  2. Official Passport → ask: 'official passport documents'\n"
                "  3. Diplomatic Passport → ask: 'diplomatic passport documents'\n"
                "  4. Travel Document → ask: 'travel document documents'\n\n"
                "Which applies to you?"
            )
        }
        menus_ne = {
            "citizenship": (
                "नागरिकताका कागजात तपाईंको अवस्थामा निर्भर हुन्छ:\n\n"
                "  १. वंशजको आधारमा → सोध्नुहोस्: 'वंशज नागरिकता कागजात'\n"
                "  २. वैवाहिक अंगीकृत → सोध्नुहोस्: 'वैवाहिक अंगीकृत कागजात'\n"
                "  ३. अंगीकृत (विदेशी नागरिक) → सोध्नुहोस्: 'अंगीकृत नागरिकता कागजात'\n"
                "  ४. प्रतिलिपि (नक्कल प्रति) → सोध्नुहोस्: 'प्रतिलिपि कागजात'\n\n"
                "तपाईंलाई कुन लागू हुन्छ?"
            ),
            "birth_certificate": (
                "जन्मदर्ताका कागजात तपाईंको अवस्थामा निर्भर हुन्छ:\n\n"
                "  १. समयमै दर्ता (३५ दिनभित्र) → सोध्नुहोस्: 'समयमै जन्मदर्ता कागजात'\n"
                "  २. ढिलो दर्ता (३५ दिनपछि) → सोध्नुहोस्: 'ढिलो जन्मदर्ता कागजात'\n"
                "  ३. बाबा विदेशमा → सोध्नुहोस्: 'बाबा विदेश जन्मदर्ता कागजात'\n"
                "  ४. बाबा अज्ञात वा हराएको → सोध्नुहोस्: 'बाबा अज्ञात जन्मदर्ता कागजात'\n"
                "  ५. अनाथ → सोध्नुहोस्: 'अनाथ जन्मदर्ता कागजात'\n"
                "  ६. एक अभिभावक विदेशी → सोध्नुहोस्: 'विदेशी अभिभावक जन्मदर्ता कागजात'\n\n"
                "तपाईंलाई कुन लागू हुन्छ?"
            ),
            "nid": (
                "NID कागजात तपाईंको उमेरमा निर्भर हुन्छ:\n\n"
                "  १. सामान्य NID (१६+) → सोध्नुहोस्: 'सामान्य nid कागजात'\n"
                "  २. नाबालक परिचयपत्र (१६ भन्दा कम) → सोध्नुहोस्: 'नाबालक परिचयपत्र कागजात'\n\n"
                "तपाईंलाई कुन लागू हुन्छ?"
            ),
            "passport": (
                "राहदानीका कागजात प्रकार अनुसार फरक हुन्छ:\n\n"
                "  १. सामान्य राहदानी → सोध्नुहोस्: 'सामान्य राहदानी कागजात'\n"
                "  २. सरकारी राहदानी → सोध्नुहोस्: 'सरकारी राहदानी कागजात'\n"
                "  ३. कूटनीतिक राहदानी → सोध्नुहोस्: 'कूटनीतिक राहदानी कागजात'\n"
                "  ४. यात्रा अनुमतिपत्र → सोध्नुहोस्: 'यात्रा अनुमतिपत्र कागजात'\n\n"
                "तपाईंलाई कुन लागू हुन्छ?"
            )
        }
        menus = menus_ne if lang == "ne" else menus_en
        fallback = "कुन सेवाको कागजात चाहियो भन्नुहोस्।" if lang == "ne" else "Please specify which service you need documents for."
        return menus.get(service_key, fallback)

    def _show_full(self, service, service_key, lang):
        lines = []
        sep = "═" * 52
        lines.append(f"\n{sep}")
        if lang == "ne":
            lines.append(f"  {service['nepali_name']}")
        else:
            lines.append(f"  {service['name']}")
            lines.append(f"  {service['nepali_name']}")
        lines.append(sep)

        if lang == "ne":
            lines.append(f"\n  शुल्क : {self._t(service['fee'], lang)}")
            lines.append(f"  समय   : {self._t(service['processing_time'], lang)}")
            lines.append(f"  कार्यालय: {self._t(service['office'], lang)}")
        else:
            lines.append(f"\n  Fee            : {self._t(service['fee'], lang)}")
            lines.append(f"  Processing Time: {self._t(service['processing_time'], lang)}")
            lines.append(f"  Office         : {self._t(service['office'], lang)}")

        if "types" in service:
            types = self._t(service["types"], lang)
            lines.append(f"\n  {'प्रकारहरू:' if lang=='ne' else 'TYPES:'}")
            for i, t in enumerate(types, 1):
                lines.append(f"    {i}. {t}")

        elig = self._t(service["eligibility"], lang)
        lines.append(f"\n  {'योग्यता:' if lang=='ne' else 'ELIGIBILITY:'}")
        if isinstance(elig, dict):
            for key, val in elig.items():
                lines.append(f"    • {key.replace('_',' ').title()}: {val}")
        else:
            for item in elig:
                lines.append(f"    ✓ {item}")

        doc_hint_en = {
            "citizenship":       "\n  DOCUMENTS: Depend on citizenship type.\n  Ask: 'citizenship documents' to see all options.",
            "birth_certificate": "\n  DOCUMENTS: Depend on birth situation.\n  Ask: 'birth certificate documents' to see all options.",
            "nid":               "\n  DOCUMENTS: Depend on your age.\n  Ask: 'nid documents' to see all options.",
            "passport":          "\n  DOCUMENTS: Depend on passport type.\n  Ask: 'passport documents' to see all options."
        }
        doc_hint_ne = {
            "citizenship":       "\n  कागजात: नागरिकताको प्रकारमा निर्भर।\n  सोध्नुहोस्: 'नागरिकता कागजात'",
            "birth_certificate": "\n  कागजात: जन्म अवस्थामा निर्भर।\n  सोध्नुहोस्: 'जन्मदर्ता कागजात'",
            "nid":               "\n  कागजात: उमेरमा निर्भर।\n  सोध्नुहोस्: 'nid कागजात'",
            "passport":          "\n  कागजात: राहदानी प्रकारमा निर्भर।\n  सोध्नुहोस्: 'राहदानी कागजात'"
        }
        hint = (doc_hint_ne if lang == "ne" else doc_hint_en).get(service_key, "")
        lines.append(hint)

        footer_sep = "─" * 52
        lines.append(f"\n{footer_sep}")
        if lang == "ne":
            lines.append("  सोध्नुहोस्: शुल्क / प्रकार / कागजात / चरण / योग्यता / कार्यालय")
        else:
            lines.append("  Ask: fee / types / documents / steps / eligibility / office")
        return "\n".join(lines)

    # ────────────────────────────────────────
    # CITIZENSHIP SUB-INTENTS
    # ────────────────────────────────────────

    def _citizenship_sub(self, subintent, lang):
        c = self.services["citizenship"]

        if subintent == "types":
            return self._show_types(c, "citizenship", lang)

        if subintent == "pratilipi_general":
            if lang == "ne":
                return (
                    "प्रतिलिपि (नागरिकता नक्कल) — कुन अवस्था लागू हुन्छ?\n\n"
                    "  १. बसाइसराइ पछि → सोध्नुहोस्: 'प्रतिलिपि बसाइसराइ कागजात'\n"
                    "  २. पतिको नाम थपी → सोध्नुहोस्: 'प्रतिलिपि पति नाम कागजात'\n"
                    "  ३. पारपाचुके पछि → सोध्नुहोस्: 'प्रतिलिपि पारपाचुके कागजात'\n"
                    "  ४. थर सुधार → सोध्नुहोस्: 'प्रतिलिपि थर सुधार कागजात'"
                )
            return (
                "Pratilipi (Duplicate Citizenship) — Which situation applies?\n\n"
                "  1. After Migration → ask: 'pratilipi migration documents'\n"
                "  2. Adding Husband's Name → ask: 'pratilipi husband name documents'\n"
                "  3. After Divorce → ask: 'pratilipi divorce documents'\n"
                "  4. Surname Correction → ask: 'pratilipi surname correction documents'"
            )

        sub_map = {
            "pratilipi_migration": ("pratilipi_after_migration",   "Duplicate Citizenship After Migration",        "बसाइसराइ पछिको नागरिकता प्रतिलिपि"),
            "pratilipi_husband":   ("pratilipi_add_husband_name",  "Duplicate Citizenship — Adding Husband's Name", "पतिको नाम थप्ने नागरिकता प्रतिलिपि"),
            "pratilipi_divorce":   ("pratilipi_after_divorce",     "Duplicate Citizenship After Divorce",           "पारपाचुके पछिको नागरिकता प्रतिलिपि"),
            "pratilipi_surname":   ("pratilipi_surname_correction","Duplicate Citizenship — Surname Correction",    "थर सुधार नागरिकता प्रतिलिपि"),
            "descent":             ("citizenship_by_descent",      "Citizenship by Descent",                        "वंशजको आधारमा नागरिकता"),
            "naturalized_marriage":("naturalized_through_marriage","Naturalized Citizenship Through Marriage",      "वैवाहिक अंगीकृत नागरिकता"),
            "naturalized":         ("naturalized",                 "Naturalized Citizenship",                       "अंगीकृत नागरिकता"),
        }

        if subintent in sub_map:
            doc_key, title_en, title_ne = sub_map[subintent]
            docs = self._t(c["required_documents"][doc_key], lang)
            title = title_ne if lang == "ne" else title_en
            label = "का लागि कागजात:" if lang == "ne" else "Documents for"
            lines = [f"{title} {label}\n"] if lang == "ne" else [f"{label} {title}:\n"]
            for i, doc in enumerate(docs, 1):
                lines.append(f"  {i}. {doc}")
            note = "\nसूचना: सक्कल र फोटोकपी दुवै बुझाउनुहोस्।" if lang == "ne" else "\nNote: Bring both originals AND photocopies."
            lines.append(note)
            return "\n".join(lines)

        elif subintent == "sifarish":
            steps = self._t(c["steps"], lang)
            ward_steps = [s for s in steps if ("चरण १" in s or "Step 1" in s)]
            title = "चरण १ — वडा कार्यालय (सिफारिस पत्र):\n" if lang == "ne" else "Step 1 — Ward Office (Sifarish Patra):\n"
            lines = [title]
            for s in ward_steps:
                clean = s.replace("Step 1 - Ward Office: ", "").replace("चरण १ - वडा कार्यालय: ", "")
                lines.append(f"  • {clean}")
            footer = "\nसिफारिस पत्र पाएपछि DAO जानुहोस्।" if lang == "ne" else "\nAfter getting Sifarish Patra → proceed to DAO."
            lines.append(footer)
            return "\n".join(lines)

        elif subintent == "dao_step":
            steps = self._t(c["steps"], lang)
            dao_steps = [s for s in steps if ("चरण २" in s or "Step 2" in s)]
            title = "चरण २ — DAO/CDO कार्यालय:\n" if lang == "ne" else "Step 2 — DAO/CDO Office:\n"
            lines = [title]
            for s in dao_steps:
                clean = s.replace("Step 2 - DAO: ", "").replace("चरण २ - DAO: ", "")
                lines.append(f"  • {clean}")
            note = "\nसूचना: कम्तिमा एक अभिभावक उपस्थित हुनुपर्छ (सनाखत)।" if lang == "ne" else "\nNote: At least one parent must be present (Sanaakhat)."
            lines.append(note)
            return "\n".join(lines)

        return self._show_full(c, "citizenship", lang)

    # ────────────────────────────────────────
    # BIRTH CERTIFICATE SUB-INTENTS
    # ────────────────────────────────────────

    def _birth_sub(self, subintent, lang):
        b = self.services["birth_certificate"]

        if subintent == "types":
            return self._show_types(b, "birth_certificate", lang)

        doc_map = {
            "early":            ("early_registration",   "Early Birth Registration",        "समयमै जन्मदर्ता"),
            "late":             ("late_registration",    "Late Birth Registration",          "ढिलो जन्मदर्ता"),
            "father_abroad":    ("father_abroad",        "Father is Abroad",                 "बाबा विदेशमा"),
            "father_unknown":   ("father_unknown_missing","Father Unknown or Missing",       "बाबा अज्ञात वा हराएको"),
            "orphan":           ("orphan",                "Orphan",                          "अनाथ"),
            "foreign_parent":   ("foreign_parent",        "One Parent is a Foreigner",        "एक अभिभावक विदेशी"),
            "migrated_parents": ("migrated_parents",      "Parents are Migrated/Resettled",   "अभिभावक बसाइसराइ भएको"),
        }

        if subintent in doc_map:
            doc_key, title_en, title_ne = doc_map[subintent]
            docs = self._t(b["required_documents"][doc_key], lang)
            title = title_ne if lang == "ne" else title_en
            label = "का लागि कागजात:" if lang == "ne" else "Documents for"
            lines = [f"{title} {label}\n"] if lang == "ne" else [f"{label} {title}:\n"]
            for i, doc in enumerate(docs, 1):
                lines.append(f"  {i}. {doc}")
            return "\n".join(lines)

        return self._show_full(b, "birth_certificate", lang)

    # ────────────────────────────────────────
    # NID SUB-INTENTS
    # ────────────────────────────────────────

    def _nid_sub(self, subintent, lang):
        n = self.services["nid"]

        if subintent == "types":
            return self._show_types(n, "nid", lang)

        elif subintent == "standard_nid":
            docs = self._t(n["required_documents"]["standard_nid"], lang)
            title = "सामान्य NID (१६+) का कागजात:\n" if lang == "ne" else "Documents for Standard NID (Age 16+):\n"
            lines = [title]
            for i, doc in enumerate(docs, 1):
                lines.append(f"  {i}. {doc}")
            return "\n".join(lines)

        elif subintent == "minor_id":
            docs = self._t(n["required_documents"]["minor_id"], lang)
            title = "नाबालक परिचयपत्र (१६ भन्दा कम) का कागजात:\n" if lang == "ne" else "Documents for Minor's ID (Under 16):\n"
            lines = [title]
            for i, doc in enumerate(docs, 1):
                lines.append(f"  {i}. {doc}")
            return "\n".join(lines)

        return self._show_full(n, "nid", lang)

    # ────────────────────────────────────────
    # PASSPORT SUB-INTENTS
    # ────────────────────────────────────────

    def _passport_sub(self, subintent, lang):
        p = self.services["passport"]

        if subintent == "types":
            return self._show_types(p, "passport", lang)

        doc_map = {
            "ordinary_adult":  ("ordinary_adult",    "Ordinary Passport — Adults",   "सामान्य राहदानी — वयस्क"),
            "ordinary_minor":  ("ordinary_minor",    "Ordinary Passport — Minors",   "सामान्य राहदानी — नाबालक"),
            "official":        ("official_passport", "Official Passport",            "सरकारी राहदानी"),
            "diplomatic":      ("diplomatic_passport","Diplomatic Passport",          "कूटनीतिक राहदानी"),
            "travel_document": ("travel_document",   "Travel Document",               "यात्रा अनुमतिपत्र"),
        }

        if subintent in doc_map:
            doc_key, title_en, title_ne = doc_map[subintent]
            docs = self._t(p["required_documents"][doc_key], lang)
            title = title_ne if lang == "ne" else title_en
            label = "का लागि कागजात:" if lang == "ne" else "Documents for"
            lines = [f"{title} {label}\n"] if lang == "ne" else [f"{label} {title}:\n"]
            for i, doc in enumerate(docs, 1):
                lines.append(f"  {i}. {doc}")
            return "\n".join(lines)

        return self._show_full(p, "passport", lang)

    # ────────────────────────────────────────
    # RULE RESPONSE
    # ────────────────────────────────────────

    def _rule_response(self, rule_key, lang):
        rule = self.rules.get(rule_key, {})
        if "responses" in rule:
            options = rule["responses"].get(lang, rule["responses"].get("en", []))
            return random.choice(options) if options else ""
        if "response" in rule:
            return self._t(rule["response"], lang)
        unknown = self.rules["unknown"]["response"]
        return self._t(unknown, lang)

    # ────────────────────────────────────────
    # FAQ RESPONSE
    # ────────────────────────────────────────

    def _faq_response(self, faq_index, lang):
        faq = self.faqs[faq_index]
        q = self._t(faq["question"], lang)
        a = self._t(faq["answer"], lang)
        if lang == "ne":
            return f"प्रश्न: {q}\n\nउत्तर: {a}"
        return f"Q: {q}\n\nA: {a}"

    # ────────────────────────────────────────
    # UNKNOWN RESPONSE
    # ────────────────────────────────────────

    def _unknown_response(self, context, lang):
        last = context.get("last_service")
        if last:
            service = self.services[last]
            service_name = service["nepali_name"] if lang == "ne" else service["name"]

            sub_hints_en = {
                "citizenship":       "  • types / descent / naturalized / pratilipi\n  • sifarish patra / dao steps\n",
                "birth_certificate": "  • types / early / late / father abroad\n  • father unknown / orphan / foreign parent\n",
                "nid":               "  • types / standard nid / minor id\n",
                "passport":          "  • types / ordinary / official / diplomatic / travel document\n"
            }
            sub_hints_ne = {
                "citizenship":       "  • प्रकार / वंशज / अंगीकृत / प्रतिलिपि\n  • सिफारिस पत्र / dao चरण\n",
                "birth_certificate": "  • प्रकार / समयमै / ढिलो / बाबा विदेश\n  • बाबा अज्ञात / अनाथ / विदेशी अभिभावक\n",
                "nid":               "  • प्रकार / सामान्य nid / नाबालक परिचयपत्र\n",
                "passport":          "  • प्रकार / सामान्य / सरकारी / कूटनीतिक / यात्रा अनुमतिपत्र\n"
            }
            hint = (sub_hints_ne if lang == "ne" else sub_hints_en).get(last, "")

            if lang == "ne":
                return (
                    f"मैले बुझिनँ।\n\n"
                    f"तपाईं {service_name} बारे सोधिरहनुभएको थियो।\n"
                    f"तपाईं यी सोध्न सक्नुहुन्छ:\n{hint}"
                    f"  • शुल्क / कागजात / चरण / योग्यता / कार्यालय"
                )
            return (
                f"I did not understand that.\n\n"
                f"You were asking about {service_name}.\n"
                f"You can ask:\n{hint}"
                f"  • fee / documents / steps / eligibility / office"
            )
        return self._t(self.rules["unknown"]["response"], lang)


# ══════════════════════════════════════════
# SMART SATHI — MAIN CLASS
# ══════════════════════════════════════════

class SmartSathi:

    def __init__(self):
        self.recognizer = IntentRecognizer()
        self.dialogue   = DialogueManager()
        self.generator  = ResponseGenerator()

    def respond(self, user_message: str) -> str:
        if not user_message or not user_message.strip():
            return "Please type something. I am here to help! / केहि लेख्नुहोस्।"

        # Step 0: Detect language of THIS message
        lang = detect_language(user_message)

        # Step 1: Recognize intent
        intent_type, intent_value = self.recognizer.recognize(user_message)

        # Step 2: Check follow-up
        # If unknown but it's a short follow-up message,
        # use the last service AND remember which language
        # the conversation was in (in case current message
        # is too short to detect, e.g. just "fee" vs "शुल्क")
        if intent_type == "unknown" and self.dialogue.is_followup(user_message):
            intent_type  = "service"
            intent_value = self.dialogue.last_service

        # Step 3: Get context
        context = self.dialogue.get_context()

        # Step 4: Generate response in detected language
        response = self.generator.generate(
            intent_type, intent_value, context, user_message, lang
        )

        # Step 5: Update dialogue
        self.dialogue.update(user_message, intent_type, intent_value, response, lang)

        return response

    def get_history(self):
        return self.dialogue.history

    def reset(self):
        self.dialogue = DialogueManager()