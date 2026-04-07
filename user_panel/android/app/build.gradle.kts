import java.util.Properties
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lovetok.sovereign"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.lovetok.sovereign"
        minSdk = flutter.minSdkVersion // V15: Boosted for Ad SDK stability
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val keyProperties = Properties()
            val keyPropertiesFile = rootProject.file("key.properties")
            if (keyPropertiesFile.exists()) {
                keyPropertiesFile.inputStream().use { keyProperties.load(it) }
            }
            keyAlias = keyProperties.getProperty("keyAlias")
            keyPassword = keyProperties.getProperty("keyPassword")
            storePassword = keyProperties.getProperty("storePassword")
            val storeFileProperty = keyProperties.getProperty("storeFile")
            if (storeFileProperty != null) {
                storeFile = file(storeFileProperty)
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.ads.mediation:facebook:6.19.0.1")       // 1. Meta Audience Network
    implementation("com.google.ads.mediation:applovin:13.1.0.0")       // 2. AppLovin
    implementation("com.google.ads.mediation:vungle:7.4.3.0")         // 3. Vungle (Liftoff)
    implementation("com.google.ads.mediation:pangle:6.4.0.5.0")       // 4. Pangle
    // Note: Other niche networks from the 23-list are handled via AdMob Open Bidding (Server-to-Server)
    // and do not require additional app-level adapters to function under the Master Mediation logic.
}

configurations.all {
    resolutionStrategy {
        force("com.google.android.gms:play-services-ads:23.0.0") 
    }
}
