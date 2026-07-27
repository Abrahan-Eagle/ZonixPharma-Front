# Mantener las clases necesarias para ML Kit Text Recognition
-keep class com.google.mlkit.** { *; }
-keepnames class com.google.mlkit.**
-keepclassmembers class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# SLF4J (R8 release): binder no presente en Android
-dontwarn org.slf4j.impl.StaticLoggerBinder
