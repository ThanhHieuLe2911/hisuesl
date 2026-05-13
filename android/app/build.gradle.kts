plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.hisuesl"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Cần đổi về Java 1.8 để tương thích tốt nhất với Desugaring
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

        // --- SỬA CÚ PHÁP CHO KOTLIN DSL ---
        isCoreLibraryDesugaringEnabled = true
        // ----------------------------------
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.hisuesl"
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
    // Import Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

    // --- SỬA CÚ PHÁP CHO KOTLIN DSL (Dùng ngoặc tròn và ngoặc kép) ---
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // ----------------------------------------------------------------
}