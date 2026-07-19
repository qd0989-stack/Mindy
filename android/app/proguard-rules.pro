# Flutter default rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep model classes
-keep class com.mindy.mindy.domain.entities.** { *; }
-keep class com.mindy.mindy.data.models.** { *; }

# Keep serialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# R8 full mode
-allowaccessmodification
-repackageclasses
