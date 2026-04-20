// import 'package:flutter/material.dart';
// import '../../../../app/routes.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/utils/validators.dart';
// import '../../../../core/widgets/app_text_field.dart';
// import '../../../../core/widgets/primary_button.dart';
// import '../widgets/sign_in_option.dart';

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final _email = TextEditingController();
//   final _password = TextEditingController();

//   bool emailError = false;
//   bool passError = false;
//   bool hidePass = true;
//   bool rememberMe = true;

//   void _validate() {
//     final e = _email.text.trim();
//     final p = _password.text.trim();

//     setState(() {
//       emailError = !Validators.isValidEmail(e);
//       passError = !Validators.isValidPassword(p);
//     });

//     if (!emailError && !passError) {
//       Navigator.pushReplacementNamed(context, AppRoutes.main);
//     }
//   }

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.bordeaux),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//         centerTitle: true,
//         title: const Text(
//           "Se connecter",
//           style: TextStyle(
//             color: AppColors.bordeaux,
//             fontSize: 18,
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           // ✅ padding أخف
//           padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ✅ Header minimal
//               Row(
//                 children: [
//                   Container(
//                     height: 52,
//                     width: 52,
//                     decoration: BoxDecoration(
//                       color: AppColors.soft,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: const Icon(Icons.storefront_rounded, color: AppColors.bordeaux, size: 26),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "ElFaddaoui",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w900,
//                             color: AppColors.text,
//                           ),
//                         ),
//                         SizedBox(height: 3),
//                         Text(
//                           "Magasin Général",
//                           style: TextStyle(
//                             fontSize: 12.5,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.muted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // ✅ Info box (خفيف)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.soft,
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.bolt_rounded, size: 18, color: AppColors.bordeaux),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         "Accédez à vos offres et à votre panier.",
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.text,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 14),

//               // ✅ Card خفيفة
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.03),
//                       blurRadius: 16,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const Text(
//                       "Connexion",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w900,
//                         color: AppColors.text,
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     AppTextField(
//                       label: "Email",
//                       hint: "Entrer votre email",
//                       controller: _email,
//                       keyboardType: TextInputType.emailAddress,
//                       prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.muted),
//                     ),
//                     if (emailError)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 6),
//                         child: Text(
//                           "Email invalide",
//                           style: TextStyle(
//                             color: AppColors.bordeaux,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),

//                     const SizedBox(height: 12),

//                     AppTextField(
//                       label: "Mot de passe",
//                       hint: "Entrer votre mot de passe",
//                       controller: _password,
//                       obscureText: hidePass,
//                       prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
//                       suffixIcon: IconButton(
//                         onPressed: () => setState(() => hidePass = !hidePass),
//                         icon: Icon(
//                           hidePass ? Icons.visibility_rounded : Icons.visibility_off_rounded,
//                           color: AppColors.muted,
//                         ),
//                       ),
//                     ),
//                     if (passError)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 6),
//                         child: Text(
//                           "Mot de passe invalide (min 8 caractères)",
//                           style: TextStyle(
//                             color: AppColors.bordeaux,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),

//                     const SizedBox(height: 10),

//                     // ✅ Row نظيفة (بدون ... و بدون overflow)
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: rememberMe,
//                           activeColor: AppColors.bordeaux,
//                           onChanged: (v) => setState(() => rememberMe = v ?? true),
//                         ),
//                         const Text(
//                           "Se souvenir de moi",
//                           style: TextStyle(
//                             fontSize: 12.5,
//                             fontWeight: FontWeight.w700,
//                             color: AppColors.muted,
//                           ),
//                         ),
//                         const Spacer(),
//                         GestureDetector(
//                           onTap: () => Navigator.pushNamed(context, AppRoutes.forgot),
//                           child: const Text(
//                             "Mot de passe oublié ?",
//                             style: TextStyle(
//                               color: AppColors.bordeaux,
//                               fontSize: 12.5,
//                               fontWeight: FontWeight.w900,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 10),

//                     PrimaryButton(
//                       text: "Se connecter",
//                       onPressed: _validate,
//                       height: 50,
//                       radius: 16,
//                     ),

//                     const SizedBox(height: 14),

//                     Row(
//                       children: [
//                         Expanded(child: Container(height: 1, color: AppColors.border)),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 10),
//                           child: Text(
//                             "ou",
//                             style: TextStyle(
//                               color: AppColors.muted,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                         ),
//                         Expanded(child: Container(height: 1, color: AppColors.border)),
//                       ],
//                     ),

//                     const SizedBox(height: 12),

//                     Row(
//                       children: const [
//                         Expanded(
//                           child: _SocialBtn(
//                             icon: Icons.g_mobiledata_rounded,
//                             label: "Google",
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: _SocialBtn(
//                             icon: Icons.apple_rounded,
//                             label: "Apple",
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),

//                     InkWell(
//                       borderRadius: BorderRadius.circular(14),
//                       onTap: () {},
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppColors.soft,
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
//                         ),
//                         child: const Row(
//                           children: [
//                             Icon(Icons.support_agent_rounded, color: AppColors.bordeaux, size: 20),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 "Besoin d’aide ? Support",
//                                 style: TextStyle(
//                                   fontSize: 12.5,
//                                   fontWeight: FontWeight.w700,
//                                   color: AppColors.text,
//                                 ),
//                               ),
//                             ),
//                             Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.muted),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               SignInOption(
//                 textBefore: "Vous n'avez pas un compte ?",
//                 actionText: "S'inscrire",
//                 onTap: () => Navigator.pushNamed(context, AppRoutes.signUp),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SocialBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const _SocialBtn({
//     required this.icon,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 46,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
//         color: Colors.white,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: AppColors.text, size: 22),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.w900,
//               color: AppColors.text,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';
import '../widgets/sign_in_option.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool emailError = false;
  bool passError = false;
  bool hidePass = true;
  bool rememberMe = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final e = _email.text.trim();
    final p = _password.text.trim();

    setState(() {
      emailError = !Validators.isValidEmail(e);
      passError = !Validators.isValidPassword(p);
    });

    if (!emailError && !passError) {
      context.read<AuthCubit>().signIn(e, p);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, s) {
        if (s.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.error!)),
          );
        }
        if (s.token != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.bordeaux),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: const Text(
            "Se connecter",
            style: TextStyle(
              color: AppColors.bordeaux,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, s) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: AppColors.soft,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: AppColors.bordeaux, size: 26),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ElFaddaoui",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Magasin Général",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt_rounded, size: 18, color: AppColors.bordeaux),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Accédez à vos offres et à votre panier.",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Connexion",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 12),

                          AppTextField(
                            label: "Email",
                            hint: "Entrer votre email",
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.muted),
                          ),
                          if (emailError)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                "Email invalide",
                                style: TextStyle(
                                  color: AppColors.bordeaux,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          AppTextField(
                            label: "Mot de passe",
                            hint: "Entrer votre mot de passe",
                            controller: _password,
                            obscureText: hidePass,
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => hidePass = !hidePass),
                              icon: Icon(
                                hidePass ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          if (passError)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                "Mot de passe invalide (min 8 caractères)",
                                style: TextStyle(
                                  color: AppColors.bordeaux,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: AppColors.bordeaux,
                                onChanged: (v) => setState(() => rememberMe = v ?? true),
                              ),
                              const Text(
                                "Se souvenir de moi",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, AppRoutes.forgot),
                                child: const Text(
                                  "Mot de passe oublié ?",
                                  style: TextStyle(
                                    color: AppColors.bordeaux,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          PrimaryButton(
                            text: s.loading ? "..." : "Se connecter",
                            onPressed: s.loading ? null : _submit,
                            height: 50,
                            radius: 16,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SignInOption(
                      textBefore: "Vous n'avez pas un compte ?",
                      actionText: "S'inscrire",
                      onTap: () => Navigator.pushNamed(context, AppRoutes.signUp),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}