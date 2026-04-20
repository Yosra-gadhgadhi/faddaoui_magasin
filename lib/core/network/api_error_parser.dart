import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

String parseApiError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;

    // backend returns {message: "..."}
    if (data is Map && data["message"] != null) {
      return data["message"].toString();
    }

    // no response => network layer issue
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "Erreur réseau (serveur non accessible). Vérifie baseUrl + ATS + serveur.";
    }

    return e.message ?? "Erreur réseau";
  }
  if (e is FormatException) {
    return e.message;
  }
  if (e is TypeError) {
    return "Réponse serveur invalide.";
  }
  if (e is MissingPluginException) {
    return "Plugin non disponible (secure storage). Redémarre complètement l'application.";
  }
  if (e is PlatformException) {
    return e.message?.trim().isNotEmpty == true
        ? e.message!
        : "Erreur plateforme (${e.code}).";
  }
  if (e is Exception || e is Error) {
    final raw = e.toString().trim();
    if (raw.isNotEmpty) {
      return raw.startsWith("Exception: ") ? raw.substring(11) : raw;
    }
  }
  return "Erreur inattendue (${e.runtimeType}).";
}
