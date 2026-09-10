import 'package:drift/drift.dart' show Variable;
import 'package:friendo/core/text/folded_text.dart' show foldedText;
import 'package:friendo_domain/friendo_domain.dart' show NoteLabel, Orbit;

/// The escape character each matching arm gives to LIKE.
const _escape = r'\';

/// The statement that names every Friend a term matches, and what it binds.
///
/// Four kinds of arm produce Friend ids, and UNION folds them into one set:
/// the folded name, the folded body of a Topic, the folded label of an
/// Affinity, and one arm for each Orbit the term names.
///
/// A Friend whose name and three of whose Topics match is one Friend, and the
/// set operation says so. One LEFT JOIN with an OR was measured ten times
/// slower and would need the same duplicates taken out afterwards.
///
/// The statement holds no Orbit threshold. Each Orbit knows its own range of
/// Cadence days, and a matched Orbit binds that range as two numbers. The
/// numbers 14 and 60 stay in the domain, which is what ADR-0008 promised.
final class FriendSearch {
  const FriendSearch._(this.statement, this.variables);

  /// Build the search for what the User typed, or null when the term narrows
  /// nothing.
  ///
  /// A term that holds nothing is not an empty result. It is the whole
  /// roster, and null says so once here rather than at each caller.
  static FriendSearch? forTerm(String term) {
    final folded = foldedText(term.trim());
    if (folded.isEmpty) return null;

    final pattern = _patternFor(folded);
    final arms = <String>[
      'select f.id as id from friends f '
          "where f.name_folded like ? escape '$_escape'",
      'select n.friend_id as id from notes n '
          "where n.label = ? and n.body_folded like ? escape '$_escape'",
      'select fa.friend_id as id from friend_affinities fa '
          'join affinities a on a.id = fa.affinity_id '
          "where a.label_folded like ? escape '$_escape'",
    ];
    final variables = <Variable<Object>>[
      Variable<String>(pattern),
      Variable<String>(NoteLabel.topic.name),
      Variable<String>(pattern),
      Variable<String>(pattern),
    ];

    for (final orbit in Orbit.values) {
      if (!orbit.name.contains(folded)) continue;

      final days = orbit.cadenceDays;
      final last = days.last;
      arms.add(
        'select f.id as id from friends f where f.cadence_days >= ?'
        '${last == null ? '' : ' and f.cadence_days <= ?'}',
      );
      variables.add(Variable<int>(days.first));
      if (last != null) variables.add(Variable<int>(last));
    }

    return FriendSearch._(arms.join(' union '), variables);
  }

  final String statement;

  final List<Variable<Object>> variables;
}

/// Wrap a Folded Text in the pattern LIKE matches inside a word.
///
/// The backslash is escaped first. Escaped last, it would also escape the
/// backslashes the other two steps had just added. Without the escaping, a
/// User who types `a_b` matches `axb`, and a User who types a percent matches
/// every Friend they have.
String _patternFor(String folded) {
  final escaped = folded
      .replaceAll(_escape, '$_escape$_escape')
      .replaceAll('%', '$_escape%')
      .replaceAll('_', '${_escape}_');

  return '%$escaped%';
}
