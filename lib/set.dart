import 'dart:io';
import 'dart:convert';

class CardSet {
  CardSet(this.file) : setData = jsonDecode(file.readAsStringSync());

  File file;
  dynamic setData;

  List<Card> get cards {
    List<Card> cards = [];
    for (final card in setData['cards']) {
      cards.add(Card.fromObject(card));
    }
    return cards;
  }

  bool get isActive => setData['active'];
  String get name => setData['name'];
}

class Card {
  Card(this.term, this.definition);
  Card.fromObject(dynamic object) {
    term = object['term'];
    definition = object['definition'];
  }
  Card.fromJson(String json) {
    final data = jsonDecode(json);
    term = data['term'];
    definition = data['defintion'];
  }

  String term = '';
  String definition = '';
}
