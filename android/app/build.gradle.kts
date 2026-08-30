import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --------------------------------------------------
// RELEASE SIGNING
// --------------------------------------------------
//
// Reads android/key.properties if present. That file is
// git-ignored and must never be committed — see Instructions.md
// ("Signing") for how to generate a keystore and populate it.
//
// Without it, release builds fall back to debug signing so
// `flutter build apk --release --flavor <x>` still works out of
// the box for local testing.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.exists()

if (hasReleaseSigning) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "oiracam.flow.bloop"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications, which uses APIs only
        // available via desugaring on lower API levels.
        isCoreLibraryDesugaringEnabled = true
    }

    // AGP 9 requires resValues to be explicitly enabled — used below
    // by each product flavor to set a distinct app_name.
    buildFeatures {
        resValues = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "oiracam.flow.bloop"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --------------------------------------------------
    // PRODUCT FLAVORS — dev / alpha / prod
    // --------------------------------------------------
    //
    // Combined with buildTypes (debug/release) this produces:
    // devDebug, devRelease, alphaDebug, alphaRelease, prodDebug,
    // prodRelease. Each flavor gets a distinct applicationId
    // (suffix) so dev/alpha/prod can all be installed on the same
    // device at once, and a distinct app_name resource.
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "FLOW Dev")
        }

        create("alpha") {
            dimension = "environment"
            applicationIdSuffix = ".alpha"
            versionNameSuffix = "-alpha"
            resValue("string", "app_name", "FLOW Alpha")
        }

        create("prod") {
            dimension = "environment"
            // No suffix: prod keeps the canonical application ID.
            resValue("string", "app_name", "FLOW")
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // TODO: Once android/key.properties is configured, this
            // automatically switches to real release signing. Until
            // then it signs with the debug keys so
            // `flutter build apk --release --flavor <x>` still works.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for isCoreLibraryDesugaringEnabled above.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
