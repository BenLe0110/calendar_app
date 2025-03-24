# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep your application classes that will be used by Flutter
-keep class com.example.calendar_app.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Serializable classes
-keepnames class * implements java.io.Serializable

# Keep R classes
-keep class **.R$* {
    *;
}

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# Keep the line number information for debugging stack traces
-keepattributes SourceFile,LineNumberTable

# Keep the original source file name and line number information
-renamesourcefileattribute SourceFile
-keepattributes *Annotation* 