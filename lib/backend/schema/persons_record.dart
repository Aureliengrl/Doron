import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PersonsRecord extends FirestoreRecord {
  PersonsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "uid" field - reference to the user who created this person
  DocumentReference? _uid;
  DocumentReference? get uid => _uid;
  bool hasUid() => _uid != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "relationship" field.
  String? _relationship;
  String get relationship => _relationship ?? '';
  bool hasRelationship() => _relationship != null;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  bool hasAvatarUrl() => _avatarUrl != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  // "age" field.
  int? _age;
  int get age => _age ?? 0;
  bool hasAge() => _age != null;

  // "ageRange" field.
  String? _ageRange;
  String get ageRange => _ageRange ?? '';
  bool hasAgeRange() => _ageRange != null;

  // "interests" field - list of interests/hobbies
  List<String>? _interests;
  List<String> get interests => _interests ?? const [];
  bool hasInterests() => _interests != null;

  // "style" field.
  String? _style;
  String get style => _style ?? '';
  bool hasStyle() => _style != null;

  // "favoriteColors" field.
  List<String>? _favoriteColors;
  List<String> get favoriteColors => _favoriteColors ?? const [];
  bool hasFavoriteColors() => _favoriteColors != null;

  // "budgetRange" field.
  String? _budgetRange;
  String get budgetRange => _budgetRange ?? '';
  bool hasBudgetRange() => _budgetRange != null;

  // "occasions" field - upcoming occasions for this person
  List<String>? _occasions;
  List<String> get occasions => _occasions ?? const [];
  bool hasOccasions() => _occasions != null;

  // "tags" field - generated tags for gift matching
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // "savedGifts" field - list of gift IDs saved for this person
  List<DocumentReference>? _savedGifts;
  List<DocumentReference> get savedGifts => _savedGifts ?? const [];
  bool hasSavedGifts() => _savedGifts != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "description" field - free-form description from voice or text input
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as DocumentReference?;
    _name = snapshotData['name'] as String?;
    _relationship = snapshotData['relationship'] as String?;
    _avatarUrl = snapshotData['avatarUrl'] as String?;
    _gender = snapshotData['gender'] as String?;
    _age = castToType<int>(snapshotData['age']);
    _ageRange = snapshotData['ageRange'] as String?;
    _interests = getDataList(snapshotData['interests']);
    _style = snapshotData['style'] as String?;
    _favoriteColors = getDataList(snapshotData['favoriteColors']);
    _budgetRange = snapshotData['budgetRange'] as String?;
    _occasions = getDataList(snapshotData['occasions']);
    _tags = getDataList(snapshotData['tags']);
    _savedGifts = getDataList(snapshotData['savedGifts']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _description = snapshotData['description'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('persons');

  static Stream<PersonsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PersonsRecord.fromSnapshot(s));

  static Future<PersonsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PersonsRecord.fromSnapshot(s));

  static PersonsRecord fromSnapshot(DocumentSnapshot snapshot) => PersonsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PersonsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PersonsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PersonsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PersonsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPersonsRecordData({
  DocumentReference? uid,
  String? name,
  String? relationship,
  String? avatarUrl,
  String? gender,
  int? age,
  String? ageRange,
  String? style,
  String? budgetRange,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? description,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'name': name,
      'relationship': relationship,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'age': age,
      'ageRange': ageRange,
      'style': style,
      'budgetRange': budgetRange,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'description': description,
    }.withoutNulls,
  );

  return firestoreData;
}

class PersonsRecordDocumentEquality implements Equality<PersonsRecord> {
  const PersonsRecordDocumentEquality();

  @override
  bool equals(PersonsRecord? e1, PersonsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.uid == e2?.uid &&
        e1?.name == e2?.name &&
        e1?.relationship == e2?.relationship &&
        e1?.avatarUrl == e2?.avatarUrl &&
        e1?.gender == e2?.gender &&
        e1?.age == e2?.age &&
        e1?.ageRange == e2?.ageRange &&
        listEquality.equals(e1?.interests, e2?.interests) &&
        e1?.style == e2?.style &&
        listEquality.equals(e1?.favoriteColors, e2?.favoriteColors) &&
        e1?.budgetRange == e2?.budgetRange &&
        listEquality.equals(e1?.occasions, e2?.occasions) &&
        listEquality.equals(e1?.tags, e2?.tags) &&
        listEquality.equals(e1?.savedGifts, e2?.savedGifts) &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.description == e2?.description;
  }

  @override
  int hash(PersonsRecord? e) => const ListEquality().hash([
        e?.uid,
        e?.name,
        e?.relationship,
        e?.avatarUrl,
        e?.gender,
        e?.age,
        e?.ageRange,
        e?.interests,
        e?.style,
        e?.favoriteColors,
        e?.budgetRange,
        e?.occasions,
        e?.tags,
        e?.savedGifts,
        e?.createdAt,
        e?.updatedAt,
        e?.description
      ]);

  @override
  bool isValidKey(Object? o) => o is PersonsRecord;
}
