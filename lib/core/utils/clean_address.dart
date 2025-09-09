String cleanCityName(String raw) {
  // "City" 또는 "of"만 단어 단위로 제거
  var cleaned = raw
      .replaceAll(RegExp(r'\bCity\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'\bof\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+'), ' ') // 여러 공백은 하나로
      .trim(); // 앞뒤 공백 제거

  return cleaned;
}