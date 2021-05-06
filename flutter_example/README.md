# flutter_example

A simple example for **Rosetta** just to demonstrate the usage to get localization for your Flutter app.

To launch the generator and get the missing parts of Translation class, execute the following command:

```bash
flutter packages pub run build_runner build
```

## Web and Desktop support
With the introduction of Flutter 2.0 it is now possible to create web and desktop applications with Flutter, and this is no different when you're using `Rosetta`.

### Web
Please make sure you meet the following requirements:
https://flutter.dev/docs/get-started/web#requirements

Once you've made sure you meet the requirements, you can check what browsers you have available by running the following command and observing the output:
```
flutter devices
```
Afterwards, you can use the following command to serve your app on `localhost`:

```
flutter run -d <browser>
```
where `<browser>` is a browser previously listed by ```flutter devices``` that you want to use (e.g. `chrome` / `edge` / etc) .


And the following command to build your app as a web app:
```
flutter build web
```

### Desktop
Please make sure you meet the following requirements:
https://flutter.dev/desktop#requirements

Once you've made sure you meet the requirements, you can use the following command to enable desktop support for a platform for your app:
```
flutter config --enable-<platform>-desktop
```
where `<platform>` is one of the following: `windows` / `macos` / `linux`
(e.g. `flutter config --enable-macos-desktop`)

To ensure that desktop _is_ enabled, list the devices available by running
```
flutter devices
```
 You should see Windows, macOS, or Linux, depending on which platforms you’ve enabled.

After you've successfully enabled desktop support for one (or more) of the aforementioned platforms, you can run the following command to launch your application:
 ```
flutter run -d <platform>
```
where `<platform>` is one of the following: `windows` / `macos` / `linux`
(e.g. ```flutter run -d windows```)

To generate a release build, run the following command:
```
flutter build <platform>
```
where `<platform>` is your platform of choice, e.g. `flutter build macos`.


For more information, please refer to the official Flutter documentation:
https://flutter.dev/desktop
https://flutter.dev/docs/get-started/web
