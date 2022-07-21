import 'package:analyzer/dart/element/nullability_suffix.dart';

import '../collection_generator.dart';
import 'template.dart';

class QueryTemplate extends Template<CollectionData> {
  @override
  String generate(CollectionData data) {
    return '''
abstract class ${data.queryReferenceInterfaceName} implements QueryReference<${data.type}, ${data.querySnapshotName}> {
  @override
  ${data.queryReferenceInterfaceName} limit(int limit);

  @override
  ${data.queryReferenceInterfaceName} limitToLast(int limit);

  /// Perform an order query based on a [FieldPath].
  /// 
  /// This method is considered unsafe as it does check that the field path
  /// maps to a valid property or that parameters such as [isEqualTo] receive
  /// a value of the correct type.
  /// 
  /// If possible, instead use the more explicit variant of order queries:
  /// 
  /// **AVOID**:
  /// ```dart
  /// collection.orderByFieldPath(
  ///   FieldPath.fromString('title'),
  ///   startAt: 'title',
  /// );
  /// ```
  /// 
  /// **PREFER**:
  /// ```dart
  /// collection.orderByTitle(startAt: 'title');
  /// ```
  ${data.queryReferenceInterfaceName} orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt,
    Object? startAfter,
    Object? endAt,
    Object? endBefore,
    ${data.documentSnapshotName}? startAtDocument,
    ${data.documentSnapshotName}? endAtDocument,
    ${data.documentSnapshotName}? endBeforeDocument,
    ${data.documentSnapshotName}? startAfterDocument,
  });

  /// Perform a where query based on a [FieldPath].
  /// 
  /// This method is considered unsafe as it does check that the field path
  /// maps to a valid property or that parameters such as [isEqualTo] receive
  /// a value of the correct type.
  /// 
  /// If possible, instead use the more explicit variant of where queries:
  /// 
  /// **AVOID**:
  /// ```dart
  /// collection.whereFieldPath(FieldPath.fromString('title'), isEqualTo: 'title');
  /// ```
  /// 
  /// **PREFER**:
  /// ```dart
  /// collection.whereTitle(isEqualTo: 'title');
  /// ```
  ${data.queryReferenceInterfaceName} whereFieldPath(
    FieldPath fieldPath, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  });

  ${_where(data, isAbstract: true)}
  ${_orderByProto(data)}
}

class ${data.queryReferenceImplName}
    extends QueryReference<${data.type}, ${data.querySnapshotName}>
    implements ${data.queryReferenceInterfaceName} {
  ${data.queryReferenceImplName}(
    this._collection, {
    required Query<${data.type}> referenceWithoutCursor,
    Query<${data.type}> Function(Query<${data.type}> query)? applyCursor,
  })  : super(
          referenceWithoutCursor: referenceWithoutCursor,
          applyCursor: applyCursor,
        );

  final CollectionReference<Object?> _collection;

  ${data.querySnapshotName} _decodeSnapshot(
    QuerySnapshot<${data.type}> snapshot,
  ) {
    final docs = snapshot
      .docs
      .map((e) {
        return ${data.queryDocumentSnapshotName}._(e, e.data());
      })
      .toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<${data.documentSnapshotName}>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: ${data.documentSnapshotName}._(change.doc, change.doc.data()),
      );
    }).toList();

    return ${data.querySnapshotName}._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<${data.querySnapshotName}> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }
  

  @override
  Future<${data.querySnapshotName}> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  ${data.queryReferenceInterfaceName} limit(int limit) {
    return ${data.queryReferenceImplName}(
      _collection,
      referenceWithoutCursor: referenceWithoutCursor.limit(limit),
      applyCursor: applyCursor,
    );
  }

  @override
  ${data.queryReferenceInterfaceName} limitToLast(int limit) {
    return ${data.queryReferenceImplName}(
      _collection,
      referenceWithoutCursor: referenceWithoutCursor.limitToLast(limit),
      applyCursor: applyCursor,
    );
  }

  ${data.queryReferenceInterfaceName} orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ${data.documentSnapshotName}? startAtDocument,
    ${data.documentSnapshotName}? endAtDocument,
    ${data.documentSnapshotName}? endBeforeDocument,
    ${data.documentSnapshotName}? startAfterDocument,
  }) {
    final query = referenceWithoutCursor.orderBy(fieldPath, descending: descending);
    var applyCursor = this.applyCursor;

    void updateCursor(Query<${data.type}> Function(Query<${data.type}> q) newCursor) {
      final previousCursor = applyCursor;
      if (previousCursor != null) {
        applyCursor = (q) => newCursor(previousCursor(q));
      } else {
        applyCursor = newCursor;
      }
    }

    if (startAtDocument != null) {
      updateCursor((q) => q.startAtDocument(startAtDocument.snapshot));
    }
    if (startAfterDocument != null) {
      updateCursor((q) => q.startAfterDocument(startAfterDocument.snapshot));
    }
    if (endAtDocument != null) {
      updateCursor((q) => q.endAtDocument(endAtDocument.snapshot));
    }
    if (endBeforeDocument != null) {
      updateCursor((q) => q.endBeforeDocument(endBeforeDocument.snapshot));
    }

    if (startAt != _sentinel) {
      updateCursor((q) => q.startAt([startAt]));
    }
    if (startAfter != _sentinel) {
      updateCursor((q) => q.startAfter([startAfter]));
    }
    if (endAt != _sentinel) {
      updateCursor((q) => q.endAt([endAt]));
    }
    if (endBefore != _sentinel) {
      updateCursor((q) => q.endBefore([endBefore]));
    }

    return ${data.queryReferenceImplName}(
      _collection,
      referenceWithoutCursor: query,
      applyCursor: applyCursor,
    );
  }

  ${data.queryReferenceInterfaceName} whereFieldPath(
    FieldPath fieldPath, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return ${data.queryReferenceImplName}(
      _collection,
      referenceWithoutCursor: referenceWithoutCursor.where(
        fieldPath,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull,
      ),
      applyCursor: applyCursor,
    );
  }

  ${_where(data)}
  ${_orderBy(data)}

  ${_equalAndHashCode(data)}
}
''';
  }

  String _orderByProto(CollectionData data) {
    final buffer = StringBuffer();

    for (final field in data.queryableFields) {
      final titledNamed = field.name.replaceFirstMapped(
        RegExp('[a-zA-Z]'),
        (match) => match.group(0)!.toUpperCase(),
      );

      buffer.writeln(
        '''
  ${data.queryReferenceInterfaceName} orderBy$titledNamed({
    bool descending = false,
    ${field.type.getDisplayString(withNullability: true)} startAt,
    ${field.type.getDisplayString(withNullability: true)} startAfter,
    ${field.type.getDisplayString(withNullability: true)} endAt,
    ${field.type.getDisplayString(withNullability: true)} endBefore,
    ${data.documentSnapshotName}? startAtDocument,
    ${data.documentSnapshotName}? endAtDocument,
    ${data.documentSnapshotName}? endBeforeDocument,
    ${data.documentSnapshotName}? startAfterDocument,
  });
''',
      );
    }

    return buffer.toString();
  }

  String _orderBy(CollectionData data) {
    final buffer = StringBuffer();

    for (final field in data.queryableFields) {
      final titledNamed = field.name.replaceFirstMapped(
        RegExp('[a-zA-Z]'),
        (match) => match.group(0)!.toUpperCase(),
      );

      buffer.writeln(
        '''
  ${data.queryReferenceInterfaceName} orderBy$titledNamed({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ${data.documentSnapshotName}? startAtDocument,
    ${data.documentSnapshotName}? endAtDocument,
    ${data.documentSnapshotName}? endBeforeDocument,
    ${data.documentSnapshotName}? startAfterDocument,
  }) {
    final query = referenceWithoutCursor.orderBy(${field.field}, descending: descending);
    var applyCursor = this.applyCursor;

    void updateCursor(Query<${data.type}> Function(Query<${data.type}> q) newCursor) {
      final previousCursor = applyCursor;
      if (previousCursor != null) {
        applyCursor = (q) => newCursor(previousCursor(q));
      } else {
        applyCursor = newCursor;
      }
    }

    if (startAtDocument != null) {
      updateCursor((q) => q.startAtDocument(startAtDocument.snapshot));
    }
    if (startAfterDocument != null) {
      updateCursor((q) => q.startAfterDocument(startAfterDocument.snapshot));
    }
    if (endAtDocument != null) {
      updateCursor((q) => q.endAtDocument(endAtDocument.snapshot));
    }
    if (endBeforeDocument != null) {
      updateCursor((q) => q.endBeforeDocument(endBeforeDocument.snapshot));
    }

    if (startAt != _sentinel) {
      updateCursor((q) => q.startAt([startAt]));
    }
    if (startAfter != _sentinel) {
      updateCursor((q) => q.startAfter([startAfter]));
    }
    if (endAt != _sentinel) {
      updateCursor((q) => q.endAt([endAt]));
    }
    if (endBefore != _sentinel) {
      updateCursor((q) => q.endBefore([endBefore]));
    }

    return ${data.queryReferenceImplName}(
      _collection,
      referenceWithoutCursor: query,
      applyCursor: applyCursor,
    );
  }
''',
      );
    }

    return buffer.toString();
  }

  String _where(CollectionData data, {bool isAbstract = false}) {
    // TODO handle JsonSerializable case change and JsonKey(name: ...)
    final buffer = StringBuffer();

    for (final field in data.queryableFields) {
      final titledNamed = field.name.replaceFirstMapped(
        RegExp('[a-zA-Z]'),
        (match) => match.group(0)!.toUpperCase(),
      );

      final nullableType =
          field.type.nullabilitySuffix == NullabilitySuffix.question
              ? '${field.type}'
              : '${field.type}?';

      final operators = {
        'isEqualTo': nullableType,
        'isNotEqualTo': nullableType,
        'isLessThan': nullableType,
        'isLessThanOrEqualTo': nullableType,
        'isGreaterThan': nullableType,
        'isGreaterThanOrEqualTo': nullableType,
        'isNull': 'bool?',
        if (field.type.isDartCoreList) ...{
          // TODO support arrayContains
          // 'arrayContains': nullableType,
          'arrayContainsAny': nullableType,
        } else ...{
          'whereIn': 'List<${field.type}>?',
          'whereNotIn': 'List<${field.type}>?',
        }
      };

      final prototype =
          operators.entries.map((e) => '${e.value} ${e.key},').join();

      final parameters = operators.keys.map((e) => '$e: $e,').join();

      // TODO support whereX(isEqual: null);
      // TODO handle JsonSerializable case change and JsonKey(name: ...)

      if (isAbstract) {
        buffer.writeln(
          '${data.queryReferenceInterfaceName} where$titledNamed({$prototype});',
        );
      } else {
        buffer.writeln(
          '''
  ${data.queryReferenceInterfaceName} where$titledNamed({$prototype}) {
    return ${data.queryReferenceImplName}(
      _collection,
      referenceWithoutCursor: referenceWithoutCursor.where(${field.field}, $parameters),
      applyCursor: applyCursor,
    );
  }
''',
        );
      }
    }

    return buffer.toString();
  }

  String _equalAndHashCode(CollectionData data) {
    final propertyNames = [
      'runtimeType',
      'reference',
    ];

    return '''
  @override
  bool operator ==(Object other) {
    return other is ${data.queryReferenceImplName}
      && ${propertyNames.map((p) => 'other.$p == $p').join(' && ')};
  }

  @override
  int get hashCode => Object.hash(${propertyNames.join(', ')});
''';
  }
}
