import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use(::load)
    }
}

fun resolveBuildValue(gradleKey: String, localKey: String): String? {
    val gradleValue = project.findProperty(gradleKey) as String?
    if (!gradleValue.isNullOrBlank()) {
        return gradleValue
    }

    val localValue = localProperties.getProperty(localKey)
    return localValue?.takeIf { it.isNotBlank() }
}

val androidTestAdMobAppId = "ca-app-pub-3940256099942544~3347511713"
val androidReleaseAdMobAppId = resolveBuildValue(
    gradleKey = "ADMOB_ANDROID_APP_ID",
    localKey = "admob.android.app.id",
)
val requestedTaskSummary = gradle.startParameter.taskNames.joinToString(" ").lowercase()
val isReleaseBuildRequested =
    requestedTaskSummary.contains("release") || requestedTaskSummary.contains("bundle")

if (isReleaseBuildRequested && androidReleaseAdMobAppId.isNullOrBlank()) {
    throw GradleException(
        "Missing Android AdMob app id for release. " +
            "Set admob.android.app.id in android/local.properties " +
            "or pass -PADMOB_ANDROID_APP_ID=<your-app-id>.",
    )
}

android {
    namespace = "com.titlegym.anime_title_academy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.titlegym.anime_title_academy"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("debug") {
            manifestPlaceholders["admobApplicationId"] = androidTestAdMobAppId
        }

        getByName("profile") {
            manifestPlaceholders["admobApplicationId"] = androidTestAdMobAppId
        }

        release {
            manifestPlaceholders["admobApplicationId"] =
                androidReleaseAdMobAppId ?: androidTestAdMobAppId
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
