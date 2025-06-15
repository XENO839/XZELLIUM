import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Firebase plugin
}

// 🔐 Load keystore properties (if exists)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    println("🔐 Keystore file found. Loading properties...")
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("⚠️ Keystore file not found at: ${keystorePropertiesFile.absolutePath}")
    throw GradleException("Missing key.properties file required for release signing.")
}

android {
    namespace = "com.example.xzellium"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.xzellium"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // ✅ Needed for Firebase and large apps
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"]?.toString()
            val storePasswordProp = keystoreProperties["storePassword"]?.toString()
            val keyAliasProp = keystoreProperties["keyAlias"]?.toString()
            val keyPasswordProp = keystoreProperties["keyPassword"]?.toString()

            if (
                storeFilePath != null &&
                storePasswordProp != null &&
                keyAliasProp != null &&
                keyPasswordProp != null
            ) {
                storeFile = file(storeFilePath)
                storePassword = storePasswordProp
                keyAlias = keyAliasProp
                keyPassword = keyPasswordProp
                println("✅ Keystore config loaded successfully.")
            } else {
                throw GradleException("❌ Missing required fields in key.properties")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    lint {
        checkReleaseBuilds = false
        baseline = file("lint-baseline.xml")
    }
}
