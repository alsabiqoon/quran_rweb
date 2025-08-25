import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // must be last
    id("dev.flutter.flutter-gradle-plugin")
}

/* --- Load signing keystore (optional) --- */
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

/* --- Load Flutter version from local.properties (generated from pubspec.yaml) --- */
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) FileInputStream(f).use { load(it) }
}
val flutterVersionCode: Int =
    (localProps.getProperty("flutter.versionCode") ?: "1").toInt()
val flutterVersionName: String =
    (localProps.getProperty("flutter.versionName") ?: "1.0.0")

android {
    namespace = "com.alsabiqoon.quran"
    compileSdk = 35

    // AGP 8 uses JDK 17
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.alsabiqoon.quran"
        minSdk = 21
        targetSdk = 35

        // Read from pubspec.yaml (version: x.y.z+CODE) via local.properties
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            // Only configure if key.properties exists
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                val storePath = keystoreProperties["storeFile"] as String?
                if (storePath != null) {
                    storeFile = file(storePath)
                }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // Use real release keystore if available; otherwise Gradle falls back to debug
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // leave defaults
        }
    }
}

flutter {
    source = "../.."
}





































// import java.util.Properties
// import java.io.FileInputStream

// plugins {
//     id("com.android.application")
//     id("kotlin-android")
//     // must be last
//     id("dev.flutter.flutter-gradle-plugin")
// }

// val keystoreProperties = Properties()
// val keystorePropertiesFile = rootProject.file("key.properties")
// if (keystorePropertiesFile.exists()) {
//     keystoreProperties.load(FileInputStream(keystorePropertiesFile))
// }

// android {
//     namespace = "com.alsabiqoon.quran"
//     compileSdk = 35

//     // AGP 8 uses JDK 17
//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_17
//         targetCompatibility = JavaVersion.VERSION_17
//     }
//     kotlinOptions {
//         jvmTarget = "17"
//     }

//     defaultConfig {
//         applicationId = "com.alsabiqoon.quran"
//         minSdk = 21
//         targetSdk = 35
//         // keep using flutter.* if you prefer:
//         // versionCode = flutter.versionCode
//         // versionName = flutter.versionName
//         versionCode = 1
//         versionName = "1.0.0"
//     }

//     signingConfigs {
//         create("release") {
//             // values come from android/key.properties
//             keyAlias = keystoreProperties["keyAlias"] as String?
//             keyPassword = keystoreProperties["keyPassword"] as String?
//             storeFile = file(keystoreProperties["storeFile"] as String)
//             storePassword = keystoreProperties["storePassword"] as String?
//         }
//     }

//     buildTypes {
//         release {
//             // use the real release keystore (not debug)
//             signingConfig = signingConfigs.getByName("release")
//             isMinifyEnabled = true
//             isShrinkResources = true
//             proguardFiles(
//                 getDefaultProguardFile("proguard-android-optimize.txt"),
//                 "proguard-rules.pro"
//             )
//         }
//         debug {
//             // unchanged
//         }
//     }

// }

// flutter {
//     source = "../.."
// }

