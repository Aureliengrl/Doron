import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GiftsRecord extends FirestoreRecord {
  GiftsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  bool hasId() => _id != null;

  // "brand" field.
  String? _brand;
  String get brand => _brand ?? '';
  bool hasBrand() => _brand != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "productUrl" field.
  String? _productUrl;
  String get productUrl => _productUrl ?? '';
  bool hasProductUrl() => _productUrl != null;

  // "price" field.
  String? _price;
  String get price => _price ?? '';
  bool hasPrice() => _price != null;

  // "originalPrice" field.
  String? _originalPrice;
  String get originalPrice => _originalPrice ?? '';
  bool hasOriginalPrice() => _originalPrice != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "tags" field.
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  // "ageRange" field.
  String? _ageRange;
  String get ageRange => _ageRange ?? '';
  bool hasAgeRange() => _ageRange != null;

  // "style" field.
  String? _style;
  String get style => _style ?? '';
  bool hasStyle() => _style != null;

  // "occasion" field.
  String? _occasion;
  String get occasion => _occasion ?? '';
  bool hasOccasion() => _occasion != null;

  // "budgetRange" field.
  String? _budgetRange;
  String get budgetRange => _budgetRange ?? '';
  bool hasBudgetRange() => _budgetRange != null;

  // "rating" field.
  double? _rating;
  double get rating => _rating ?? 0.0;
  bool hasRating() => _rating != null;

  // "numRatings" field.
  int? _numRatings;
  int get numRatings => _numRatings ?? 0;
  bool hasNumRatings() => _numRatings != null;

  // "verified" field.
  bool? _verified;
  bool get verified => _verified ?? false;
  bool hasVerified() => _verified != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _id = snapshotData['id'] as String?;
    _brand = snapshotData['brand'] as String?;
    _title = snapshotData['title'] as String?;
    _imageUrl = snapshotData['imageUrl'] as String?;
    _productUrl = snapshotData['productUrl'] as String?;
    _price = snapshotData['price'] as String?;
    _originalPrice = snapshotData['originalPrice'] as String?;
    _category = snapshotData['category'] as String?;
    _tags = getDataList(snapshotData['tags']);
    _gender = snapshotData['gender'] as String?;
    _ageRange = snapshotData['ageRange'] as String?;
    _style = snapshotData['style'] as String?;
    _occasion = snapshotData['occasion'] as String?;
    _budgetRange = snapshotData['budgetRange'] as String?;
    _rating = castToType<double>(snapshotData['rating']);
    _numRatings = castToType<int>(snapshotData['numRatings']);
    _verified = snapshotData['verified'] as bool?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('gifts');

  static Stream<GiftsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GiftsRecord.fromSnapshot(s));

  static Future<GiftsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GiftsRecord.fromSnapshot(s));

  static GiftsRecord fromSnapshot(DocumentSnapshot snapshot) => GiftsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GiftsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GiftsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GiftsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GiftsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGiftsRecordData({
  String? id,
  String? brand,
  String? title,
  String? imageUrl,
  String? productUrl,
  String? price,
  String? originalPrice,
  String? category,
  String? gender,
  String? ageRange,
  String? style,
  String? occasion,
  String? budgetRange,
  double? rating,
  int? numRatings,
  bool? verified,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id': id,
      'brand': brand,
      'title': title,
      'imageUrl': imageUrl,
      'productUrl': productUrl,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'gender': gender,
      'ageRange': ageRange,
      'style': style,
      'occasion': occasion,
      'budgetRange': budgetRange,
      'rating': rating,
      'numRatings': numRatings,
      'verified': verified,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class GiftsRecordDocumentEquality implements Equality<GiftsRecord> {
  const GiftsRecordDocumentEquality();

  @override
  bool equals(GiftsRecord? e1, GiftsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.id == e2?.id &&
        e1?.brand == e2?.brand &&
        e1?.title == e2?.title &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.productUrl == e2?.productUrl &&
        e1?.price == e2?.price &&
        e1?.originalPrice == e2?.originalPrice &&
        e1?.category == e2?.category &&
        listEquality.equals(e1?.tags, e2?.tags) &&
        e1?.gender == e2?.gender &&
        e1?.ageRange == e2?.ageRange &&
        e1?.style == e2?.style &&
        e1?.occasion == e2?.occasion &&
        e1?.budgetRange == e2?.budgetRange &&
        e1?.rating == e2?.rating &&
        e1?.numRatings == e2?.numRatings &&
        e1?.verified == e2?.verified &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(GiftsRecord? e) => const ListEquality().hash([
        e?.id,
        e?.brand,
        e?.title,
        e?.imageUrl,
        e?.productUrl,
        e?.price,
        e?.originalPrice,
        e?.category,
        e?.tags,
        e?.gender,
        e?.ageRange,
        e?.style,
        e?.occasion,
        e?.budgetRange,
        e?.rating,
        e?.numRatings,
        e?.verified,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is GiftsRecord;
}
