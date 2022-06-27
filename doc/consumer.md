In Klutter terminology a consumer is a project using (consuming) a plugin
that is made with Klutter. 

Klutter plugins contain native artifacts in the form a pre-packaged .aar file (Android)
or Framework (iOS). A standard Flutter project won't be able to find these artifacts
for a Klutter plugin which means they won't work.

To work with Klutter made plugins the following 2 tasks are required:
- consumer init (initialize Klutter in your project)
- consumer add (add a Klutter plugin to your project)