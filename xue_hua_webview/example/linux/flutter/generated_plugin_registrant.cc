//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <xue_hua_webview_linux/xue_hua_webview_linux_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) xue_hua_webview_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "XueHuaWebviewLinuxPlugin");
  xue_hua_webview_linux_plugin_register_with_registrar(xue_hua_webview_linux_registrar);
}
