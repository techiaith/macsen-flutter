import 'package:flutter/material.dart';
//
// // Generic Interface for all BLoCs
abstract class BlocBase {
   void dispose();
}

//
// // Generic BLoC provider
// class BlocProvider<T extends Bloc> extends StatefulWidget {
//
//   BlocProvider({
//     Key key,
//     @required this.child,
//     @required this.bloc,
//   }): super(key: key);
//
//   final T bloc;
//   final Widget child;
//
//   @override
//   _BlocProviderState<T> createState() => _BlocProviderState<T>();
//
//   static T of<T extends BlocBase>(BuildContext context){
//     _BlocProviderInherited<T> provider = context.findAncestorWidgetOfExactType<BlocProvider<T>>();
//     return provider?.bloc;
//   }
//
//
//
//   static Type _typeOf<T>() => T;
// }
//
//
// class _BlocProviderState<T extends BlocBase> extends State<BlocProvider<T>>{
//
//   @override
//   void dispose(){
//     widget.bloc.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context){
//     return widget.child;
//   }
// }
//
// class _BlocProviderInherited<T> extends InheritedWidget {
//   _BlocProviderInherited({
//     Key key,
//     @required Widget child,
//     @required this.bloc,
//   }) : super(key: key, child: child);
//
//   final T bloc;
//
//   @override
//   bool updateShouldNotify(_BlocProviderInherited oldWidget) => false;
// }