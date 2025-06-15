// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false // ✅ Firebase plugin
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ This relocates the build directory outside the android folder
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// ✅ Ensures each subproject has its own relocated build dir
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ✅ Makes sure the app project is evaluated before others
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Clean task to delete the relocated build folder
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
