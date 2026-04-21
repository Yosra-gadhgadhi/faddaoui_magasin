// // import 'package:flutter/material.dart';
// // import '../../../../core/theme/app_colors.dart';
// // import '../../../../core/widgets/app_text_field.dart';
// // import '../../../../core/widgets/primary_button.dart';
// // import '../../../../app/routes.dart';

// // class ResetPasswordScreen extends StatefulWidget {
// //   const ResetPasswordScreen({super.key});

// //   @override
// //   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// // }

// // class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
// //   final _newPassword = TextEditingController();
// //   final _confirmPassword = TextEditingController();

// //   bool hideNew = true;
// //   bool hideConfirm = true;

// //   bool passError = false;
// //   bool confirmError = false;

// //   @override
// //   void dispose() {
// //     _newPassword.dispose();
// //     _confirmPassword.dispose();
// //     super.dispose();
// //   }

// //   void _confirm(String email, String otp) {
// //     final np = _newPassword.text.trim();
// //     final cp = _confirmPassword.text.trim();

// //     setState(() {
// //       passError = np.length < 8;
// //       confirmError = cp != np;
// //     });

// //     if (!passError && !confirmError) {
// //       Navigator.pushReplacementNamed(context, AppRoutes.signIn);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
// //     final email = (args['email'] ?? '') as String;
// //     final otp = (args['otp'] ?? '') as String;

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         surfaceTintColor: Colors.transparent,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.bordeaux),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         centerTitle: true,
// //         title: const Text(
// //           "Nouveau mot de passe",
// //           style: TextStyle(
// //             color: AppColors.bordeaux,
// //             fontSize: 18,
// //             fontWeight: FontWeight.w900,
// //           ),
// //         ),
// //       ),
// //       body: SafeArea(
// //         child: LayoutBuilder(
// //           builder: (context, constraints) {
// //             return SingleChildScrollView(
// //               child: ConstrainedBox(
// //                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
// //                 child: Center(
// //                   child: ConstrainedBox(
// //                     constraints: const BoxConstraints(maxWidth: 420),
// //                     child: Padding(
// //                       padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
// //                       child: Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         crossAxisAlignment: CrossAxisAlignment.stretch,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               Container(
// //                                 height: 52,
// //                                 width: 52,
// //                                 decoration: BoxDecoration(
// //                                   color: AppColors.soft,
// //                                   borderRadius: BorderRadius.circular(16),
// //                                   border: Border.all(color: AppColors.border),
// //                                 ),
// //                                 child: const Icon(Icons.password_rounded, color: AppColors.bordeaux, size: 26),
// //                               ),
// //                               const SizedBox(width: 12),
// //                               Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     const Text(
// //                                       "Sécuriser le compte",
// //                                       style: TextStyle(
// //                                         fontSize: 18,
// //                                         fontWeight: FontWeight.w900,
// //                                         color: AppColors.text,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 3),
// //                                     Text(
// //                                       email,
// //                                       maxLines: 1,
// //                                       overflow: TextOverflow.ellipsis,
// //                                       style: const TextStyle(
// //                                         fontSize: 12.5,
// //                                         fontWeight: FontWeight.w600,
// //                                         color: AppColors.muted,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 12),

// //                           Container(
// //                             padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
// //                             decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(20),
// //                               border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   color: Colors.black.withValues(alpha: 0.03),
// //                                   blurRadius: 16,
// //                                   offset: const Offset(0, 10),
// //                                 ),
// //                               ],
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.stretch,
// //                               children: [
// //                                 AppTextField(
// //                                   label: "Nouveau mot de passe",
// //                                   hint: "Entrer un nouveau mot de passe",
// //                                   controller: _newPassword,
// //                                   obscureText: hideNew,
// //                                   prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
// //                                   suffixIcon: IconButton(
// //                                     onPressed: () => setState(() => hideNew = !hideNew),
// //                                     icon: Icon(
// //                                       hideNew ? Icons.visibility_rounded : Icons.visibility_off_rounded,
// //                                       color: AppColors.muted,
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 if (passError)
// //                                   const Padding(
// //                                     padding: EdgeInsets.only(top: 6),
// //                                     child: Text(
// //                                       "Mot de passe trop court (min 8)",
// //                                       style: TextStyle(
// //                                         color: AppColors.bordeaux,
// //                                         fontSize: 12,
// //                                         fontWeight: FontWeight.w700,
// //                                       ),
// //                                     ),
// //                                   ),

// //                                 const SizedBox(height: 10),

// //                                 AppTextField(
// //                                   label: "Confirmer le mot de passe",
// //                                   hint: "Retaper le mot de passe",
// //                                   controller: _confirmPassword,
// //                                   obscureText: hideConfirm,
// //                                   prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
// //                                   suffixIcon: IconButton(
// //                                     onPressed: () => setState(() => hideConfirm = !hideConfirm),
// //                                     icon: Icon(
// //                                       hideConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
// //                                       color: AppColors.muted,
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 if (confirmError)
// //                                   const Padding(
// //                                     padding: EdgeInsets.only(top: 6),
// //                                     child: Text(
// //                                       "Les mots de passe ne correspondent pas",
// //                                       style: TextStyle(
// //                                         color: AppColors.bordeaux,
// //                                         fontSize: 12,
// //                                         fontWeight: FontWeight.w700,
// //                                       ),
// //                                     ),
// //                                   ),

// //                                 const SizedBox(height: 14),

// //                                 PrimaryButton(
// //                                   text: "Confirmer",
// //                                   onPressed: () => _confirm(email, otp),
// //                                   height: 48,
// //                                   radius: 16,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/widgets/app_text_field.dart';
// import '../../../../core/widgets/primary_button.dart';
// import '../../../../app/routes.dart';
// import '../state/auth_cubit.dart';
// import '../state/auth_state.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _newPassword = TextEditingController();
//   final _confirmPassword = TextEditingController();

//   bool hideNew = true;
//   bool hideConfirm = true;

//   bool passError = false;
//   bool confirmError = false;

//   @override
//   void dispose() {
//     _newPassword.dispose();
//     _confirmPassword.dispose();
//     super.dispose();
//   }

//   void _confirm(String resetToken) {
//     final np = _newPassword.text.trim();
//     final cp = _confirmPassword.text.trim();

//     setState(() {
//       passError = np.length < 8;
//       confirmError = cp != np;
//     });

//     if (!passError && !confirmError) {
//       context.read<AuthCubit>().resetPassword(resetToken, np);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
//     final email = (args['email'] ?? '') as String;
//     final resetToken = (args['resetToken'] ?? '') as String;

//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, s) {
//         if (s.error != null) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.error!)));
//         }
//         if (s.passwordResetDone) {
//           Navigator.pushReplacementNamed(context, AppRoutes.signIn);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           surfaceTintColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.bordeaux),
//             onPressed: () => Navigator.pop(context),
//           ),
//           centerTitle: true,
//           title: const Text(
//             "Nouveau mot de passe",
//             style: TextStyle(color: AppColors.bordeaux, fontSize: 18, fontWeight: FontWeight.w900),
//           ),
//         ),
//         body: SafeArea(
//           child: BlocBuilder<AuthCubit, AuthState>(
//             builder: (context, s) {
//               return SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           height: 52,
//                           width: 52,
//                           decoration: BoxDecoration(
//                             color: AppColors.soft,
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: AppColors.border),
//                           ),
//                           child: const Icon(Icons.password_rounded, color: AppColors.bordeaux, size: 26),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Sécuriser le compte",
//                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text),
//                               ),
//                               const SizedBox(height: 3),
//                               Text(
//                                 email,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     Container(
//                       padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.03),
//                             blurRadius: 16,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           AppTextField(
//                             label: "Nouveau mot de passe",
//                             hint: "Entrer un nouveau mot de passe",
//                             controller: _newPassword,
//                             obscureText: hideNew,
//                             prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
//                             suffixIcon: IconButton(
//                               onPressed: () => setState(() => hideNew = !hideNew),
//                               icon: Icon(hideNew ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppColors.muted),
//                             ),
//                           ),
//                           if (passError)
//                             const Padding(
//                               padding: EdgeInsets.only(top: 6),
//                               child: Text(
//                                 "Mot de passe trop court (min 8)",
//                                 style: TextStyle(color: AppColors.bordeaux, fontSize: 12, fontWeight: FontWeight.w700),
//                               ),
//                             ),

//                           const SizedBox(height: 10),

//                           AppTextField(
//                             label: "Confirmer le mot de passe",
//                             hint: "Retaper le mot de passe",
//                             controller: _confirmPassword,
//                             obscureText: hideConfirm,
//                             prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
//                             suffixIcon: IconButton(
//                               onPressed: () => setState(() => hideConfirm = !hideConfirm),
//                               icon: Icon(hideConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppColors.muted),
//                             ),
//                           ),
//                           if (confirmError)
//                             const Padding(
//                               padding: EdgeInsets.only(top: 6),
//                               child: Text(
//                                 "Les mots de passe ne correspondent pas",
//                                 style: TextStyle(color: AppColors.bordeaux, fontSize: 12, fontWeight: FontWeight.w700),
//                               ),
//                             ),

//                           const SizedBox(height: 14),

//                           PrimaryButton(
//                             text: s.loading ? "..." : "Confirmer",
//                             onPressed: s.loading ? null : () => _confirm(resetToken),
//                             height: 48,
//                             radius: 16,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../app/routes.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool hideNew = true;
  bool hideConfirm = true;

  bool passError = false;
  bool confirmError = false;

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _confirm(String resetToken) {
    final np = _newPassword.text.trim();
    final cp = _confirmPassword.text.trim();

    setState(() {
      passError = np.length < 8;
      confirmError = cp != np;
    });

    if (!passError && !confirmError) {
      context.read<AuthCubit>().resetPassword(resetToken, np);
    }
  }

  @override
  Widget build(BuildContext context) {

    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final email = (args['email'] ?? '') as String;
    final resetToken = (args['resetToken'] ?? '') as String;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, s) {

        if (s.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.error!)),
          );
        }

        if (s.passwordResetDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr3(context, fr: "Mot de passe changé", en: "Password changed", ar: "تم تغيير كلمة المرور"),
              ),
            ),
          );

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.signIn,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(tr3(context, fr: "Nouveau mot de passe", en: "New password", ar: "كلمة مرور جديدة")),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              Text(email),

              const SizedBox(height: 20),

              AppTextField(
                label: tr3(context, fr: "Nouveau mot de passe", en: "New password", ar: "كلمة مرور جديدة"),
                controller: _newPassword,
                obscureText: hideNew, hint: '',
              ),

              const SizedBox(height: 12),

              AppTextField(
                label: tr3(context, fr: "Confirmer", en: "Confirm", ar: "تأكيد"),
                controller: _confirmPassword,
                obscureText: hideConfirm, hint: '',
              ),

              const SizedBox(height: 20),

              PrimaryButton(
                text: tr3(context, fr: "Confirmer", en: "Confirm", ar: "تأكيد"),
                onPressed: () => _confirm(resetToken),
              )
            ],
          ),
        ),
      ),
    );
  }
}
