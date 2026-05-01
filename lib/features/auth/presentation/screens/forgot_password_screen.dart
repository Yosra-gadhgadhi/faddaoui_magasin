// // import 'package:flutter/material.dart';
// // import '../../../../core/theme/app_colors.dart';
// // import '../../../../core/widgets/app_text_field.dart';
// // import '../../../../core/widgets/primary_button.dart';
// // import '../../../../app/routes.dart';

// // class ForgotPasswordScreen extends StatefulWidget {
// //   const ForgotPasswordScreen({super.key});

// //   @override
// //   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// // }

// // class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
// //   final _email = TextEditingController();
// //   bool emailError = false;

// //   @override
// //   void dispose() {
// //     _email.dispose();
// //     super.dispose();
// //   }

// //   void _sendOtp() {
// //     final e = _email.text.trim();
// //     setState(() => emailError = e.isEmpty || !e.contains('@'));

// //     if (!emailError) {
// //       Navigator.pushNamed(
// //         context,
// //         AppRoutes.otp,
// //         arguments: {'email': e},
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
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
// //           "Mot de passe oublié",
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
// //                         mainAxisSize: MainAxisSize.min, // ✅ هذا يثبت الوسط عموديًا
// //                         crossAxisAlignment: CrossAxisAlignment.stretch,
// //                         children: [
// //                           // ✅ Header
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
// //                                 child: const Icon(
// //                                   Icons.lock_reset_rounded,
// //                                   color: AppColors.bordeaux,
// //                                   size: 26,
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 12),
// //                               const Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(
// //                                       "Réinitialiser",
// //                                       style: TextStyle(
// //                                         fontSize: 18,
// //                                         fontWeight: FontWeight.w900,
// //                                         color: AppColors.text,
// //                                       ),
// //                                     ),
// //                                     SizedBox(height: 3),
// //                                     Text(
// //                                       "Recevez un code OTP par email",
// //                                       style: TextStyle(
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

// //                           // ✅ Card
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
// //                                 const Text(
// //                                   "Email",
// //                                   style: TextStyle(
// //                                     fontSize: 15,
// //                                     fontWeight: FontWeight.w800,
// //                                     color: AppColors.text,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 10),

// //                                 AppTextField(
// //                                   label: "Adresse email",
// //                                   hint: "Entrer votre email",
// //                                   controller: _email,
// //                                   keyboardType: TextInputType.emailAddress,
// //                                   prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.muted),
// //                                 ),

// //                                 if (emailError)
// //                                   const Padding(
// //                                     padding: EdgeInsets.only(top: 6),
// //                                     child: Text(
// //                                       "Email invalide",
// //                                       style: TextStyle(
// //                                         color: AppColors.bordeaux,
// //                                         fontSize: 12,
// //                                         fontWeight: FontWeight.w700,
// //                                       ),
// //                                     ),
// //                                   ),

// //                                 const SizedBox(height: 14),

// //                                 PrimaryButton(
// //                                   text: "Envoyer le code",
// //                                   onPressed: _sendOtp,
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

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _email = TextEditingController();
//   bool emailError = false;

//   @override
//   void dispose() {
//     _email.dispose();
//     super.dispose();
//   }

//   void _send() {
//     final e = _email.text.trim();
//     setState(() => emailError = e.isEmpty || !e.contains('@'));
//     if (emailError) return;

//     context.read<AuthCubit>().requestReset(e);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, s) {
//         if (s.error != null) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.error!)));
//         }
//         if (s.resetToken != null && s.emailForReset != null) {
//           Navigator.pushNamed(
//             context,
//             AppRoutes.otp,
//             arguments: {
//               "email": s.emailForReset!,
//               "resetToken": s.resetToken!, // ✅ token
//             },
//           );
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
//             "Mot de passe oublié",
//             style: TextStyle(color: AppColors.bordeaux, fontSize: 18, fontWeight: FontWeight.w900),
//           ),
//         ),
//         body: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return BlocBuilder<AuthCubit, AuthState>(
//                 builder: (context, s) {
//                   return SingleChildScrollView(
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                       child: Center(
//                         child: ConstrainedBox(
//                           constraints: const BoxConstraints(maxWidth: 420),
//                           child: Padding(
//                             padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Container(
//                                       height: 52,
//                                       width: 52,
//                                       decoration: BoxDecoration(
//                                         color: AppColors.soft,
//                                         borderRadius: BorderRadius.circular(16),
//                                         border: Border.all(color: AppColors.border),
//                                       ),
//                                       child: const Icon(Icons.lock_reset_rounded, color: AppColors.bordeaux, size: 26),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     const Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Réinitialiser",
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.w900,
//                                               color: AppColors.text,
//                                             ),
//                                           ),
//                                           SizedBox(height: 3),
//                                           Text(
//                                             "Le serveur va générer un reset token",
//                                             style: TextStyle(
//                                               fontSize: 12.5,
//                                               fontWeight: FontWeight.w600,
//                                               color: AppColors.muted,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Container(
//                                   padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(20),
//                                     border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withValues(alpha: 0.03),
//                                         blurRadius: 16,
//                                         offset: const Offset(0, 10),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                                     children: [
//                                       const Text(
//                                         "Email",
//                                         style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text),
//                                       ),
//                                       const SizedBox(height: 10),
//                                       AppTextField(
//                                         label: "Adresse email",
//                                         hint: "Entrer votre email",
//                                         controller: _email,
//                                         keyboardType: TextInputType.emailAddress,
//                                         prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.muted),
//                                       ),
//                                       if (emailError)
//                                         const Padding(
//                                           padding: EdgeInsets.only(top: 6),
//                                           child: Text(
//                                             "Email invalide",
//                                             style: TextStyle(color: AppColors.bordeaux, fontSize: 12, fontWeight: FontWeight.w700),
//                                           ),
//                                         ),
//                                       const SizedBox(height: 14),
//                                       PrimaryButton(
//                                         text: s.loading ? "..." : "Envoyer",
//                                         onPressed: s.loading ? null : _send,
//                                         height: 48,
//                                         radius: 16,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
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

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../app/routes.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final _email = TextEditingController();
  bool emailError = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    final e = _email.text.trim();

    setState(() {
      emailError = e.isEmpty || !e.contains("@");
    });

    if (emailError) return;

    context.read<AuthCubit>().requestReset(e);
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, s) {

        if (s.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(s.error!)));
        }

        if (s.resetToken != null && s.emailForReset != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.otp,
            arguments: {
              "email": s.emailForReset!,
              "resetToken": s.resetToken!,
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(tr3(context, fr: "Mot de passe oublié", en: "Forgot password", ar: "نسيت كلمة المرور")),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, s) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  AppTextField(
                    label: tr3(context, fr: "Email", en: "Email", ar: "البريد الإلكتروني"),
                    hint: tr3(context, fr: "Entrer votre email", en: "Enter your email", ar: "أدخل بريدك الإلكتروني"),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline),
                  ),

                  if (emailError)
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        tr3(context, fr: "Email invalide", en: "Invalid email", ar: "بريد إلكتروني غير صالح"),
                        style: TextStyle(
                          color: AppColors.bordeaux,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  PrimaryButton(
                    text: s.loading ? "..." : tr3(context, fr: "Envoyer", en: "Send", ar: "إرسال"),
                    onPressed: s.loading ? null : _send,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
