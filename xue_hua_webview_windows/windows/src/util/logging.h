#pragma once

#include <windows.h>

#include <string>
#include <string_view>

namespace xue_hua_webview_windows::util {

inline void LogWarning(std::string_view message) {
  std::string output = "[xue_hua_webview_windows] ";
  output.append(message);
  output.append("\n");
  OutputDebugStringA(output.c_str());
}

} // namespace xue_hua_webview_windows::util
