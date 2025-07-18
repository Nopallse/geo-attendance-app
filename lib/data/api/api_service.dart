import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import './endpoints.dart';
import 'package:absensi_app/utils/device_utils.dart';
import 'package:absensi_app/utils/shared_prefs_utils.dart';

class ApiService {
  final String baseUrl = ApiEndpoints.baseUrl;
  final Logger logger = Logger();

  // Get auth headers with token and device ID
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true, bool isJson = true}) async {
    // Get device ID from SharedPrefs via DeviceUtils
    String deviceId = await DeviceUtils.getDeviceId();
    logger.d("Device ID used in request: $deviceId");

    Map<String, String> headers = {
      "Device_Id": deviceId,
    };

    if (isJson) {
      headers["Content-Type"] = "application/json";
    }

    // Add CORS headers for web platform
    if (kIsWeb) {
      headers["Access-Control-Allow-Origin"] = "*";
      headers["Access-Control-Allow-Methods"] = "GET, POST, PATCH, DELETE, OPTIONS";
      headers["Access-Control-Allow-Headers"] = "Origin, Content-Type, Accept, Device_Id";
    }

    return headers;
  }

  // Perform GET request
  Future<Map<String, dynamic>> get(
      String endpoint, {
        bool requiresAuth = true,
        Map<String, String>? queryParams,
      }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      var uri = Uri.parse('$baseUrl$endpoint');

      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      logger.d("GET Request: $uri");
      
      // For web platform, first make an OPTIONS request
      if (kIsWeb) {
        try {
          final optionsResponse = await http.Request('OPTIONS', uri).send();
          logger.d("OPTIONS Response Status: ${optionsResponse.statusCode}");
        } catch (e) {
          logger.w("OPTIONS request failed: $e");
          // Continue with GET request even if OPTIONS fails
        }
      }

      final response = await http.get(uri, headers: headers);
      logger.d("Response Status: ${response.statusCode}");
      logger.d("Response Body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...");

      return _handleResponse(response);
    } catch (e) {
      logger.e("GET Error: $e");
      return {"success": false, "message": "Network error occurred: $e"};
    }
  }

  // Perform POST request
  Future<Map<String, dynamic>> post(
      String endpoint, {
        required Map<String, dynamic> body,
        bool requiresAuth = true,
      }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final url = Uri.parse('$baseUrl$endpoint');

      logger.d("POST Request: $url");
      logger.d("POST Body: $body");

      // For web platform, first make an OPTIONS request
      if (kIsWeb) {
        try {
          final optionsResponse = await http.Request('OPTIONS', url).send();
          logger.d("OPTIONS Response Status: ${optionsResponse.statusCode}");
        } catch (e) {
          logger.w("OPTIONS request failed: $e");
          // Continue with POST request even if OPTIONS fails
        }
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      logger.d("Response Status: ${response.statusCode}");
      logger.d("Response Body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...");

      return _handleResponse(response);
    } catch (e) {
      logger.e("POST Error: $e");
      return {"success": false, "message": "Network error occurred: $e"};
    }
  }

  // Perform PATCH request
  Future<Map<String, dynamic>> patch(
      String endpoint, {
        Map<String, dynamic>? body,
        bool requiresAuth = true,
      }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final url = Uri.parse('$baseUrl$endpoint');

      logger.d("PATCH Request: $url");
      if (body != null) {
        logger.d("PATCH Body: $body");
      }

      // For web platform, first make an OPTIONS request
      if (kIsWeb) {
        try {
          final optionsResponse = await http.Request('OPTIONS', url).send();
          logger.d("OPTIONS Response Status: ${optionsResponse.statusCode}");
        } catch (e) {
          logger.w("OPTIONS request failed: $e");
          // Continue with PATCH request even if OPTIONS fails
        }
      }

      final response = await http.patch(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      logger.d("Response Status: ${response.statusCode}");
      logger.d("Response Body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...");

      return _handleResponse(response);
    } catch (e) {
      logger.e("PATCH Error: $e");
      return {"success": false, "message": "Network error occurred: $e"};
    }
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      // Check if response is HTML (indicating CORS or other server issues)
      if (response.body.trim().startsWith('<!DOCTYPE html>') || 
          response.body.trim().startsWith('<html')) {
        logger.e("Received HTML response instead of JSON");
        return {
          "success": false,
          "message": "Server returned HTML instead of JSON. This might be a CORS issue.",
          "statusCode": response.statusCode
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": data};
      } else {
        String errorMessage = data["error"] ?? "Unknown error occurred";
        return {"success": false, "message": errorMessage, "statusCode": response.statusCode};
      }
    } catch (e) {
      logger.e("Response parsing error: $e");
      return {
        "success": false,
        "message": "Failed to process response",
        "statusCode": response.statusCode
      };
    }
  }
}