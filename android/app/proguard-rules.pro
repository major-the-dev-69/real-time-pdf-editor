# R8 & Proguard rules for SLF4J and Pusher Channels Flutter
-dontwarn org.slf4j.**
-dontwarn com.pusher.**
-dontwarn javax.annotation.**
-keep class org.slf4j.** { *; }
-keep class com.pusher.** { *; }
