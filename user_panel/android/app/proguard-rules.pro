# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings

# A_111: SOVEREIGN AD-REVENUE BRIDGE GUARD [V15]
# Google Mobile Ads Proguard Rules
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class io.google.plugins.googlemobileads.** { *; }

# AppLovin MAX Proguard Rules
-keep class com.applovin.** { *; }
-keepnames class com.applovin.** { *; }
-keep public class com.applovin.sdk.AppLovinSdk { *; }
-keep public class com.applovin.sdk.AppLovinAd { *; }
-keep public class com.applovin.sdk.AppLovinAdNetwork { *; }
-keep public class com.applovin.mediation.** { *; }
-keep class com.applovin.mediation.adapters.** { *; }

# Social DNA & Media Hub Stability
-keep class com.lovetok.sovereign.** { *; }
