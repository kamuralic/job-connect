import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:job_connect/screens/accountPage.dart';
import 'package:job_connect/screens/authScreens/email_verification_screen.dart';
import 'package:job_connect/screens/authScreens/login_screen.dart';
import 'package:job_connect/screens/authScreens/signup_screen.dart';
import 'package:job_connect/screens/categories_list_page.dart';
import 'package:job_connect/screens/home_page.dart';
import 'package:job_connect/screens/main_page_wrapper.dart';
import 'package:job_connect/screens/myAds_page.dart';
import 'package:job_connect/screens/postAdd_page.dart';
import 'package:job_connect/screens/splash_screen.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/chat_service.dart';
import 'package:job_connect/services/data_helpers_provider.dart';
import 'package:job_connect/services/document_picker_service.dart';
import 'package:job_connect/services/image_picker_provider.dart';
import 'package:job_connect/services/internet_check_provider.dart';
import 'package:job_connect/services/searchService.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/utils/theme.dart';
import 'package:provider/provider.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(),
          //child: AuthenticationWrapper(),
        ),
        Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance)),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<ChatService>(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => ImagesProvider()),
        ChangeNotifierProvider(create: (_) => SearchService()),
        ChangeNotifierProvider(create: (_) => DocumentsProvider()),
        ChangeNotifierProvider(create: (_) => DataHelpersProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: myTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          AuthenticationWrapper.id: (context) => AuthenticationWrapper(),
          LoginPage.id: (context) => LoginPage(),
          SignUpPage.id: (context) => const SignUpPage(),
          HomePage.id: (context) => const HomePage(),
          CategoriesPage.id: (context) => const CategoriesPage(),
          AccountPage.id: (context) => const AccountPage(),
          MyAdsPage.id: (context) => const MyAdsPage(),
          SellPage.id: (context) => const SellPage(),
          EmailVerificationScreen.id: (context) =>
              const EmailVerificationScreen(),
        },
      ),
    );
  }
}

//Decides whether to go to login page or home page
class AuthenticationWrapper extends StatefulWidget {
  static const id = "authWrapper";

  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id, channel.name, channel.description,
                  color: Colors.red,
                  icon: '@mipmap/ic_launcher',
                  playSound: true),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id, channel.name, channel.description,
                  color: Colors.red,
                  icon: '@mipmap/ic_launcher',
                  playSound: true),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      /*Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));*/

      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return Stack(
        children: [
          MainPagesWraper(),
        ],
      );
    }

    return Stack(
      children: [
        LoginPage(),
      ],
    );
  }
}
