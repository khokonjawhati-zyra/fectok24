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

// ═══════════════════════════════════════════════════════════════
// SOVEREIGN V15: LEGACY PLUGIN MESH PATCH [A_124]
// ═══════════════════════════════════════════════════════════════
subprojects {
    afterEvaluate {
        val plugin = this
        if (plugin.hasProperty("android")) {
            val android = plugin.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            
            // Fix 1: Auto-Inject Namespace if missing
            if (android.namespace == null) {
                android.namespace = "com.sovereign.sms_bridge.plugins.${plugin.name}"
            }

            // Fix 2: Strip 'package' from Manifest (Required for AGP 8.0+)
            val manifestFile = file("${plugin.projectDir}/src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                var content = manifestFile.readText()
                if (content.contains("package=")) {
                    content = content.replace(Regex("""package="[^"]+""""), "")
                    manifestFile.writeText(content)
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
