#include "plugin/xue_hua_webview_linux_plugin_private.h"
#include "common/method_channel_utils.h"

G_DEFINE_TYPE(XueHuaWebviewLinuxPlugin,
              xue_hua_webview_linux_plugin,
              g_object_get_type())

static void xue_hua_webview_linux_plugin_dispose(GObject* object) {
  XueHuaWebviewLinuxPlugin* self =
      reinterpret_cast<XueHuaWebviewLinuxPlugin*>(object);

  self->disposing = TRUE;
  if (self->webviews != nullptr) {
    g_hash_table_destroy(self->webviews);
    self->webviews = nullptr;
  }
  detach_linux_webview_host(self);
  g_clear_object(&self->root_channel);
  g_clear_object(&self->registrar);

  G_OBJECT_CLASS(xue_hua_webview_linux_plugin_parent_class)->dispose(object);
}

static void xue_hua_webview_linux_plugin_class_init(
    XueHuaWebviewLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = xue_hua_webview_linux_plugin_dispose;
}

static void xue_hua_webview_linux_plugin_init(XueHuaWebviewLinuxPlugin* self) {
  self->next_webview_id = 1;
  self->webviews = g_hash_table_new_full(g_direct_hash, g_direct_equal, nullptr,
                                         destroy_linux_webview);
}

void xue_hua_webview_linux_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  XueHuaWebviewLinuxPlugin* plugin = reinterpret_cast<XueHuaWebviewLinuxPlugin*>(
      g_object_new(xue_hua_webview_linux_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));
  plugin->root_channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "com.kurban.xue_hua_webview_linux", method_codec());

  fl_method_channel_set_method_call_handler(plugin->root_channel,
                                            root_method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);
  g_object_unref(plugin);
}
