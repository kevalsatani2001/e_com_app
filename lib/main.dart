import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/product_repository.dart';
import 'logic/bloc/product_bloc.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StoreApp());
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ProductRepository(),
      child: BlocProvider(
        create: (context) => ProductBloc(
          repository: context.read<ProductRepository>(),
        ),
        child: MaterialApp(
          title: 'Store',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const MainNavigationScreen(),
        ),
      ),
    );
  }
}
