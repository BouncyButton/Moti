import 'package:fluffy_bunny/Suggestion.dart';

class SuggestionTree {
  List<Suggestion> roots;

  SuggestionTree() {

    /* start study */
    var study = Suggestion(
      parent: null,
      text: 'Study',
      repetition: 'once',
      type: 'remind',
    );

    study.add(Suggestion(
        text: 'Buy a book',
        repetition: 'once',
        type: 'remind'));


    study.add(Suggestion(
        text: 'Study 2 hours a day',
        repetition: 'daily',
        type: 'remind'));

    study.add(Suggestion(
        text: 'Ask a friend to study together',
        repetition: 'once',
        type: 'remind'));

    study.add(Suggestion(
        text: 'Change study method',
        repetition: 'once',
        type: 'learn'));
    /* end study */

    /*start craft */
    var craft = Suggestion(
      parent: null,
      text: 'Craft',
      type: 'learn',
      repetition: 'once',
    );

    var draw = Suggestion(text: 'Draw', repetition: 'once', type: 'remind');
    craft.add(draw);

    var origami = Suggestion(
        text: 'Make origami',
        repetition: 'once',
        type: 'learn');
    craft.add(origami);


    origami.add(Suggestion(
        text: 'Make a paper butterfly',
        type: 'learn',
        repetition: 'once'));

    origami.add(Suggestion(
        text: 'Make a flexagon',
        type: 'learn',
        repetition: 'once'));

    origami.add(Suggestion(
        text: 'Make a paper crane',
        type: 'learn',
        repetition: 'daily'));

    draw.add(Suggestion(text: 'Complete a drawing', repetition: 'once', type: 'remind'));
    draw.add(Suggestion(text: 'Share a drawing', repetition: 'once', type: 'remind'));
    draw.add(Suggestion(text: 'Study anatomy', repetition: 'once', type: 'learn'));
    draw.add(Suggestion(text: 'Learn from other artists', repetition: 'weekly', type: 'learn'));
    draw.add(Suggestion(text: 'Buy a sketchbook', repetition: 'once', type: 'remind'));
    draw.add(Suggestion(text: 'Enroll in an art class', repetition: 'once', type: 'remind'));
    draw.add(Suggestion(text: 'Complete a drawing each day', repetition: 'daily', type: 'remind'));

    var gardening = Suggestion(
        text: 'Do gardening',
        repetition: 'once',
        type: 'remind');

    var lemon = Suggestion(text: 'Plant a lemon tree', repetition: 'once', type: 'learn');
    var avocado = Suggestion(text: 'Plant an avocado tree', repetition: 'once', type: 'learn');
    var bean = Suggestion(text: 'Plant a bean seed', repetition: 'once', type: 'learn');

    gardening.add(lemon);
    gardening.add(avocado);
    gardening.add(bean);

    craft.add(gardening);

    /* end craft */

/* start exercise */
    var exercise = Suggestion(parent: null, text: 'Exercise', repetition: 'daily', type: 'remind');
    var plank = Suggestion(text: 'Learn to plank', repetition: 'once', type: 'learn');
    var jogging = Suggestion(text: 'Do jogging', repetition: 'once', type: 'remind');
    var walk = Suggestion(text: 'Walk 30 minutes a day', repetition: 'daily', type: 'remind');
    var bike = Suggestion(text: 'Bike 10 km a day', repetition: 'daily', type: 'remind');
    var dance = Suggestion(text: 'Dance', repetition: 'once', type: 'remind');

    exercise.add(plank);
    exercise.add(jogging);
    exercise.add(walk);
    exercise.add(bike);
    exercise.add(dance);


    /* end exercise */


    var relax = Suggestion(parent: null, text: 'Relax', repetition: 'once', type: 'remind');
    var breath = Suggestion(text: 'Practice deep breathing', repetition: 'once', type: 'learn');
    var yoga = Suggestion(text: 'Enroll in a yoga class', repetition: 'once', type: 'remind');
    var outside = Suggestion(text: 'Meditate outside', repetition: 'once', type: 'remind');

    relax.add(breath);
    relax.add(yoga);
    relax.add(outside);

    roots = [study, exercise, craft, relax];

  }
}
