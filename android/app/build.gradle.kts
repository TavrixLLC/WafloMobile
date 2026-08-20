import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.isFile) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}

fun signingProperty(name: String): String? =
    keystoreProperties.getProperty(name)?.trim()?.takeIf { it.isNotEmpty() }

val requiredSigningProperties =
    listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingSigningProperties =
    requiredSigningProperties.filter { signingProperty(it) == null }
val productionReleaseStoreFile = signingProperty("storeFile")?.let { file(it) }
val productionReleaseSigningConfigured =
    missingSigningProperties.isEmpty() && productionReleaseStoreFile?.isFile == true

android {
    namespace = "app.waflo.staff"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        resValues = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "app.waflo.staff"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (productionReleaseSigningConfigured) {
            create("productionRelease") {
                storeFile = requireNotNull(productionReleaseStoreFile)
                storePassword = requireNotNull(signingProperty("storePassword"))
                keyAlias = requireNotNull(signingProperty("keyAlias"))
                keyPassword = requireNotNull(signingProperty("keyPassword"))
            }
        }
    }

    flavorDimensions += "environment"
    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Waflo Staff Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Waflo Staff Staging")
        }
        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "Waflo Staff")
            if (productionReleaseSigningConfigured) {
                signingConfig = signingConfigs.getByName("productionRelease")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

val validateProductionReleaseSigning =
    tasks.register("validateProductionReleaseSigning") {
        group = "verification"
        description = "Fails closed when production release signing is incomplete."
        doLast {
            if (missingSigningProperties.isNotEmpty()) {
                throw GradleException(
                    "Production release signing is not configured. Populate the ignored " +
                        "android/key.properties with storeFile, storePassword, keyAlias, " +
                        "and keyPassword.",
                )
            }
            if (productionReleaseStoreFile?.isFile != true) {
                throw GradleException(
                    "Production release signing storeFile does not identify a local file.",
                )
            }
        }
    }

tasks.configureEach {
    if (
        name.contains("ProductionRelease", ignoreCase = true) &&
            name != validateProductionReleaseSigning.name
    ) {
        dependsOn(validateProductionReleaseSigning)
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
