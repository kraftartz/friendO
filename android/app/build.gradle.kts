plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dev.kraftartz.friendo"
    // Pinned above flutter.compileSdkVersion, which is 36 on Flutter 3.41.7.
    // flutter_secure_storage compiles against 37 and the build warns on every
    // run until this matches. Compile SDKs are backward compatible, so raising
    // it does not change what devices the app runs on; minSdk decides that.
    // Drop this line once the Flutter default reaches 37.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications schedules with java.time, which does not
        // exist below API 26. Desugaring back-ports it, and the plugin refuses
        // to build without this flag. See its README, "Gradle setup".
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "dev.kraftartz.friendo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Version taken from flutter_local_notifications' own build.gradle. Keep
    // the two in step when that plugin is upgraded.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
