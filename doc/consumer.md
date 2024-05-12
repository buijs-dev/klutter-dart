In Klutter terminology a consumer is a project using (consuming) a plugin
that is made with Klutter. 

Klutter plugins contain native artifacts. These are .aar files for Android
and Frameworks for iOS. A standard Flutter project won't be able to find 
these artifacts for a Klutter plugin which means they won't work.

To work with Klutter plugins the following 2 tasks are required:
- kradle init (initialize Klutter in your project)
- kradle add (add a Klutter plugin to your project)