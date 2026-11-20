allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Some plugins (e.g. better_player_plus on AGP 9) don't set a Kotlin JVM target,
// so Kotlin falls back to the Gradle daemon JDK and no longer matches their Java
// target. Keep each plugin's Kotlin target in line with its Java target.
subprojects {
    afterEvaluate {
        val android =
            extensions.findByType(com.android.build.api.dsl.CommonExtension::class.java)
                ?: return@afterEvaluate
        tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
            compilerOptions.jvmTarget.set(
                provider {
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(
                        android.compileOptions.targetCompatibility.toString(),
                    )
                },
            )
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
