// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:swp_app/features/class/presentation/pages/class_list_page.dart';

// void main() => runApp(const ProviderScope(child: AppRoot()));

// class AppRoot extends StatelessWidget {
//   const AppRoot({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ShadApp.custom(
//       themeMode: ThemeMode.system,
//       theme: ShadThemeData(
//         brightness: Brightness.light,
//         colorScheme: ShadSlateColorScheme.light(),
//         radius: BorderRadius.circular(14),
//       ),
//       darkTheme: ShadThemeData(
//         brightness: Brightness.dark,
//         colorScheme: ShadSlateColorScheme.dark(),
//         radius: BorderRadius.circular(14),
//       ),
//       appBuilder: (context) => MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: Theme.of(context),
//         builder: (context, child) => ShadAppBuilder(child: child!),
//         home: const ClassListPage(), // 👈 dùng trang của bạn
//       ),
//     );
//   }
// }
