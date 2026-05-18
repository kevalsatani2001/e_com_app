import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/product_repository.dart';
import 'logic/bloc/product_bloc.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ProductRepository(),
      child: BlocProvider(
        create: (context) => ProductBloc(
          repository: context.read<ProductRepository>(),
        ),
        child: MaterialApp(
          title: 'Bloc Store',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            useMaterial3: true,
          ),
          home: const MainNavigationScreen(),
        ),
      ),
    );
  }
}