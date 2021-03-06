import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/screens/about/aboutscreen.dart';
import 'package:myagenda/screens/about/licences/licences.dart';
import 'package:myagenda/screens/findroom/findroom.dart';
import 'package:myagenda/screens/help/help.dart';
import 'package:myagenda/screens/home/home.dart';
import 'package:myagenda/screens/introduction/intro.dart';
import 'package:myagenda/screens/login/login.dart';
import 'package:myagenda/screens/settings/settings.dart';
import 'package:myagenda/screens/splashscreen/splashscreen.dart';
import 'package:myagenda/screens/supportme/supportme.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

final routes = {
  RouteKey.SPLASHSCREEN: SplashScreen(),
  RouteKey.HOME: HomeScreen(),
  RouteKey.FINDROOM: FindRoomScreen(),
  RouteKey.SETTINGS: SettingsScreen(),
  RouteKey.HELP: HelpScreen(),
  RouteKey.ABOUT: AboutScreen(),
  RouteKey.LICENCES: LicencesScreen(),
  RouteKey.INTRO: IntroductionScreen(),
  RouteKey.LOGIN: LoginScreen(),
  RouteKey.SUPPORTME: SupportMeScreen(),
};

class App extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return AnalyticsProvider(
      analytics,
      observer,
      child: PreferencesProvider(
        child: Builder(
          builder: (context) {
            return DynamicTheme(
              themedWidgetBuilder: (context, theme) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: "MyAgenda",
                  theme: theme,
                  localizationsDelegates: [
                    const TranslationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: [const Locale('en'), const Locale('fr')],
                  navigatorObservers: [observer],
                  initialRoute: RouteKey.SPLASHSCREEN,
                  onGenerateRoute: (RouteSettings settings) {
                    if (routes.containsKey(settings.name))
                      return CustomRoute(
                        builder: (_) => routes[settings.name],
                        settings: settings,
                        routeName: settings.name
                      );
                    assert(false);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
