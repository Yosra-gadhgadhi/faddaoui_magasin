// import 'package:flutter/material.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/widgets/app_text_field.dart';
// import '../../../../core/widgets/primary_button.dart';
// import '../../../../app/routes.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _name = TextEditingController();
//   final _email = TextEditingController();
//   final _password = TextEditingController();
//   final _confirmPassword = TextEditingController();

//   bool hidePass = true;
//   bool hideConfirm = true;

//   @override
//   void dispose() {
//     _name.dispose();
//     _email.dispose();
//     _password.dispose();
//     _confirmPassword.dispose();
//     super.dispose();
//   }

//   void _register() {
//     // UI فقط (تبدّلها لاحقًا بالـ API/Firebase)
//     Navigator.pushReplacementNamed(context, AppRoutes.signIn);
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
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: const Text(
//           "S'inscrire",
//           style: TextStyle(
//             color: AppColors.bordeaux,
//             fontSize: 18,
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ✅ Header
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
//                     child: const Icon(
//                       Icons.person_add_alt_1_rounded,
//                       color: AppColors.bordeaux,
//                       size: 26,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Créer un compte",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w900,
//                             color: AppColors.text,
//                           ),
//                         ),
//                         SizedBox(height: 3),
//                         Text(
//                           "Rejoignez ElFaddaoui",
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

//               // ✅ Card Inscription
//               Container(
//                 padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
//                       "Inscription",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w800,
//                         color: AppColors.text,
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     AppTextField(
//                       label: "Nom complet",
//                       hint: "Entrer votre nom",
//                       controller: _name,
//                       prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.muted),
//                     ),

//                     const SizedBox(height: 10),

//                     AppTextField(
//                       label: "Email",
//                       hint: "Entrer votre email",
//                       controller: _email,
//                       keyboardType: TextInputType.emailAddress,
//                       prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.muted),
//                     ),

//                     const SizedBox(height: 10),

//                     AppTextField(
//                       label: "Mot de passe",
//                       hint: "Créer un mot de passe",
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

//                     const SizedBox(height: 10),

//                     AppTextField(
//                       label: "Confirmer le mot de passe",
//                       hint: "Retaper le mot de passe",
//                       controller: _confirmPassword,
//                       obscureText: hideConfirm,
//                       prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
//                       suffixIcon: IconButton(
//                         onPressed: () => setState(() => hideConfirm = !hideConfirm),
//                         icon: Icon(
//                           hideConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
//                           color: AppColors.muted,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 14),

//                     PrimaryButton(
//                       text: "Créer mon compte",
//                       onPressed: _register,
//                       height: 48,
//                       radius: 16,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 14),

//               // ✅ Bottom link
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Vous avez déjà un compte ?",
//                     style: TextStyle(
//                       color: AppColors.muted,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   GestureDetector(
//                     onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signIn),
//                     child: const Text(
//                       "Se connecter",
//                       style: TextStyle(
//                         color: AppColors.bordeaux,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool hidePass = true;
  bool hideConfirm = true;

  bool nameError = false;
  bool emailError = false;
  bool passError = false;
  bool confirmError = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _register() {
    final n = _name.text.trim();
    final e = _email.text.trim();
    final p = _password.text.trim();
    final c = _confirmPassword.text.trim();

    setState(() {
      nameError = n.isEmpty;
      emailError = e.isEmpty || !e.contains("@");
      passError = p.length < 8;
      confirmError = c != p;
    });

    if (!nameError && !emailError && !passError && !confirmError) {
      context.read<AuthCubit>().signUp(n, e, p);
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
        // Après inscription, rediriger vers la page de connexion
        if (s.token != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Compte créé, connectez-vous.")),
          );
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
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
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            "S'inscrire",
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
                          child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.bordeaux, size: 26),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Créer un compte",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Rejoignez ElFaddaoui",
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
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                            "Inscription",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 10),

                          AppTextField(
                            label: "Nom complet",
                            hint: "Entrer votre nom",
                            controller: _name,
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.muted),
                          ),
                          if (nameError)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                "Nom obligatoire",
                                style: TextStyle(color: AppColors.bordeaux, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ),

                          const SizedBox(height: 10),

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
                                style: TextStyle(color: AppColors.bordeaux, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ),

                          const SizedBox(height: 10),

                          AppTextField(
                            label: "Mot de passe",
                            hint: "Créer un mot de passe",
                            controller: _password,
                            obscureText: hidePass,
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => hidePass = !hidePass),
                              icon: Icon(hidePass ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: AppColors.muted),
                            ),
                          ),
                          if (passError)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                "Min 8 caractères",
                                style: TextStyle(color: AppColors.bordeaux, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ),

                          const SizedBox(height: 10),

                          AppTextField(
                            label: "Confirmer le mot de passe",
                            hint: "Retaper le mot de passe",
                            controller: _confirmPassword,
                            obscureText: hideConfirm,
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => hideConfirm = !hideConfirm),
                              icon: Icon(hideConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: AppColors.muted),
                            ),
                          ),
                          if (confirmError)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                "Les mots de passe ne correspondent pas",
                                style: TextStyle(color: AppColors.bordeaux, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ),

                          const SizedBox(height: 14),

                          PrimaryButton(
                            text: s.loading ? "..." : "Créer mon compte",
                            onPressed: s.loading ? null : _register,
                            height: 48,
                            radius: 16,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous avez déjà un compte ?",
                          style: TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signIn),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(color: AppColors.bordeaux, fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
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
