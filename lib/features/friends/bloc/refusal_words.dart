/// The sentence for each refusal the Friend aggregate raises.
///
/// The rules belong to the aggregate, and both screens that write a Friend
/// report the same ones. The sentence names the field to fix, so a User reads
/// which half of the form is wrong rather than that something is.
///
/// [whenUnknown] is what to say for a refusal this file has no sentence for.
/// A form can name the field it is missing; a screen that changes one thing at
/// a time can only say that the change was refused.
String refusalWords(ArgumentError error, {required String whenUnknown}) =>
    switch (error.name) {
      'name' => 'A Friend needs a name.',
      'meeting.happenedOn' =>
        'A Meeting happens on today or an earlier day. Pick a day that has '
            'already come.',
      'body' => 'A Topic, an Update or a Note needs some text.',
      'label' => 'A Fact and a Milestone each need a label.',
      'value' => 'A Fact needs a value.',
      _ => whenUnknown,
    };

/// What Add a Friend says when it cannot name the field.
const somethingIsNotFilledIn = 'Something in the form is not filled in yet.';

/// What the Friend Notepad says when it cannot name the field.
const thatChangeWasRefused = 'That change was refused.';
