# تشغيل المرحلة 1

```bash
flutter create . --platforms=android   # مرة واحدة لتوليد مجلد android
flutter pub get
dart run build_runner build            # يولّد database.g.dart
flutter test                           # اختبارات التخزين
flutter run
```

ملاحظات:
- البحث الحالي يعمل جيدًا مع الكلمات؛ تطبيع النص العربي (إزالة التشكيل وتوحيد الألف) يُضاف في مرحلة البحث.
- عند تغيير أي جدول: ارفع `schemaVersion` وأضف خطوة في `onUpgrade` مع اختبار.
