plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.paypulse"
    compileSdk = flutter.compileSdkVersion

    //  Use the correct NDK version for Firebase compatibility
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        //  Your unique application ID
        applicationId = "com.example.paypulse"

        //  Set minimum SDK version required by Firebase
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Required for desugaring
        multiDexEnabled = true
    }

    buildTypes {
        release {
            //  Using debug signing for now so `flutter run --release` works
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    configurations.all {
        resolutionStrategy {
            // Use a known-published core version that includes the needed APIs
            force("androidx.core:core:1.10.1")
            force("androidx.core:core-ktx:1.10.1")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ADD DESUGARING DEPENDENCY HERE
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Ensure core libraries are present at runtime to avoid missing-method errors
    implementation("androidx.core:core:1.10.1")
    implementation("androidx.core:core-ktx:1.10.1")
}