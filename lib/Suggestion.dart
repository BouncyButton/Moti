import 'package:flutter/widgets.dart';

class Suggestion {
  Suggestion parent;
  String text;
  List<Suggestion> children;
  String type;
  String repetition;
  GlobalKey key;


  Suggestion(
      {this.parent,
      this.text,
      this.children,
      this.type,
      this.repetition,
      this.key}) {
    if(this.children == null)
      this.children = [];
  }

  Suggestion get root {
    if(parent != null)
      return parent.root;
    return this;
  }

  void add(Suggestion s) {
    s.parent = this;
    children.add(s);
  }


}
