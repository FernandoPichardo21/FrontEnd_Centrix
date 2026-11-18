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
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid = {
        project.extensions.findByName("android")?.let { ext ->
            val intMethod = ext.javaClass.methods.firstOrNull { 
                it.name in listOf("compileSdkVersion", "setCompileSdkVersion", "setCompileSdk") && 
                it.parameterCount == 1 &&
                (it.parameterTypes[0] == Int::class.javaPrimitiveType || it.parameterTypes[0] == java.lang.Integer::class.java)
            }
            if (intMethod != null) {
                try {
                    intMethod.invoke(ext, 36)
                } catch (_: Throwable) {}
            } else {
                val strMethod = ext.javaClass.methods.firstOrNull {
                    it.name in listOf("compileSdkVersion", "setCompileSdkVersion", "setCompileSdk") &&
                    it.parameterCount == 1 &&
                    it.parameterTypes[0] == String::class.java
                }
                try {
                    strMethod?.invoke(ext, "android-36")
                } catch (_: Throwable) {}
            }
        }
    }
    if (project.state.executed) {
        configureAndroid()
    } else {
        project.afterEvaluate { configureAndroid() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
