Gradle is a build tool that works on the JVM. Every Flutter project uses Gradle in some form.
For instance the Flutter deliverables for Android are build with Gradle. Klutter however uses 
Gradle to work with Kotlin Multiplatform. 

Kotlin Multiplatform projects can only build with Gradle. 
Klutter consists of 2 components to make this possible:
- Dart plugin (this library)
- Gradle plugin

The Klutter Gradle plugin is applied in the Kotlin Multiplatform project, 
e.g. in a producer project this is the root/platform folder. This plugin 
roughly does two things:
- Generate method-channel code on Flutter and platform side.
- Build native artifacts for both iOS and Android.

Gradle needs to be installed to be able to do all this.
Even though Flutter installs gradle wrapper in the android folder, 
Klutter adds it's own wrapper files to producer project.

This is done to make sure all Gradle versions within the Klutter project
are aligned and to make the Gradle distributions between consumer
and producer projects independent. 

For more information about how to work with Klutter Multiplatform in Klutter
see [here](https://github.com/buijs-dev/klutter).