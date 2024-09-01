import 'dart:io';
import 'dart:convert';

class CardSet {
  CardSet(this.version, this.name, this.enabled, this.cards);

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
    List<Card> cards = [];

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
              cards.add(Card(term, definition));
            }
          }
        }
        return CardSet(version!, name, enabled, cards);

      case null:
      default:
        return null;
    }
  }

  String version = '0.0'; // Version of the JSON format (major.minor)
  String name = '';
  bool enabled = false;
  List<Card> cards = [];
}

class Card {
  Card(this.term, this.definition);

  String term;
  String definition;
}
