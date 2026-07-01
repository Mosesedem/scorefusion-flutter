import '../constants/app_constants.dart';

String? normalizeUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return Uri.parse(value).toString();
  } catch (_) {
    return null;
  }
}

bool shouldBlockUrl(String? value) {
  final normalized = normalizeUrl(value);
  return normalized != null && AppConstants.blockedUrls.contains(normalized);
}

bool isUtilityUrl(String? url) {
  if (url == null || url.isEmpty) return true;
  return url.startsWith('about:blank') ||
      url.startsWith('file:') ||
      url.startsWith('data:') ||
      url.startsWith('blob:') ||
      url.startsWith('javascript:');
}

bool isExternalDomain(String? url) {
  if (url == null || url.isEmpty) return false;
  return !url.contains('getscorefusion.com');
}