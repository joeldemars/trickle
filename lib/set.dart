import 'dart:io';
import 'dart:convert';

class CardSet {
  CardSet(this.file, this.version, this.name, this.enabled, this.cards);

  CardSet.from(CardSet set)
      : this(set.file, set.version, set.name, set.enabled,
            List<FlashCard>.from(set.cards));

  File file;
  String version = '0.0'; // Version of the JSON format (major.minor)
  String name = '';
  bool enabled = false;
  List<FlashCard> cards = [];

  static CardSet? fromFile(File file) {
    dynamic data;
    try {
      data = jsonDecode(file.readAsStringSync());
    } catch (e) {
      return null;
    }

    String? version;
    String? name;
    bool? enabled;
    List<FlashCard> cards = [];

    version = data['version'];
    switch (version) {
      case '0.0':
        name = data['name'];
        enabled = data['enabled'];
        if (name == null || enabled == null) {
          return null;
        }
        if (data['cards'] != null) {
          for (dynamic card in data['cards']) {
            String? term = card['term'];
            String? definition = card['definition'];
            if (term == null || definition == null) {
              return null;
            } else {
              cards.add(FlashCard(term, definition));
            }
          }
        }
        return CardSet(file, version!, name, enabled, cards);

      case null:
      default:
        return null;
    }
  }

  String toJson() {
    return jsonEncode({
      'version': version,
      'name': name,
      'enabled': enabled,
      'cards': cards
          .map((card) => {'term': card.term, 'definition': card.definition})
          .toList()
    });
  }

  void save() {
    file.writeAsStringSync(toJson());
  }
}

class FlashCard {
  FlashCard(this.term, this.definition);

  String term;
  String definition;
}
