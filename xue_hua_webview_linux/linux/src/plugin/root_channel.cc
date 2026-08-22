#include "plugin/xue_hua_webview_linux_plugin_private.h"
#include "common/method_channel_utils.h"

#include <libsoup/soup.h>

#include <cstring>

static void add_cookie_finished_cb(GObject* object,
                                   GAsyncResult* result,
                                   gpointer user_data) {
  FlMethodCall* method_call = FL_METHOD_CALL(user_data);
  GError* error = nullptr;
  webkit_cookie_manager_add_cookie_finish(WEBKIT_COOKIE_MANAGER(object), result,
                                          &error);
  if (error != nullptr) {
    respond(method_call, error_response("cookie_error", error->message));
    g_clear_error(&error);
  } else {
    respond(method_call, success_response());
  }
  g_object_unref(method_call);
}

static void clear_cookies_finished_cb(GObject* object,
                                      GAsyncResult* result,
                                      gpointer user_data) {
  FlMethodCall* method_call = FL_METHOD_CALL(user_data);
  GError* error = nullptr;
  webkit_website_data_manager_clear_finish(
      WEBKIT_WEBSITE_DATA_MANAGER(object), result, &error);
  if (error != nullptr) {
    respond(method_call, error_response("cookie_error", error->message));
    g_clear_error(&error);
  } else {
    respond(method_call, success_response(fl_value_new_bool(true)));
  }
  g_object_unref(method_call);
}

static void get_cookies_finished_cb(GObject* object,
                                    GAsyncResult* result,
                                    gpointer user_data) {
  FlMethodCall* method_call = FL_METHOD_CALL(user_data);
  GError* error = nullptr;
  GList* cookies = webkit_cookie_manager_get_cookies_finish(
      WEBKIT_COOKIE_MANAGER(object), result, &error);
  if (error != nullptr) {
    respond(method_call, error_response("cookie_error", error->message));
    g_clear_error(&error);
    g_object_unref(method_call);
    return;
  }

  FlValue* list = fl_value_new_list();
  for (GList* item = cookies; item != nullptr; item = item->next) {
    SoupCookie* cookie = static_cast<SoupCookie*>(item->data);
    FlValue* map = fl_value_new_map();
    fl_value_set_string_take(
        map, "name",
        fl_value_new_string(soup_cookie_get_name(cookie) != nullptr
                                ? soup_cookie_get_name(cookie)
                                : ""));
    fl_value_set_string_take(
        map, "value",
        fl_value_new_string(soup_cookie_get_value(cookie) != nullptr
                                ? soup_cookie_get_value(cookie)
                                : ""));
    fl_value_set_string_take(
        map, "domain",
        fl_value_new_string(soup_cookie_get_domain(cookie) != nullptr
                                ? soup_cookie_get_domain(cookie)
                                : ""));
    fl_value_set_string_take(
        map, "path",
        fl_value_new_string(soup_cookie_get_path(cookie) != nullptr
                                ? soup_cookie_get_path(cookie)
                                : "/"));
    fl_value_append_take(list, map);
  }

  g_list_free_full(cookies, reinterpret_cast<GDestroyNotify>(soup_cookie_free));
  respond(method_call, success_response(list));
  g_object_unref(method_call);
}

static WebKitWebsiteDataTypes website_data_types_from_args(FlValue* args) {
  FlValue* types = map_lookup(args, "dataTypes");
  if (types == nullptr || fl_value_get_type(types) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(types) == 0) {
    return WEBKIT_WEBSITE_DATA_ALL;
  }

  WebKitWebsiteDataTypes flags = static_cast<WebKitWebsiteDataTypes>(0);
  const size_t length = fl_value_get_length(types);
  for (size_t i = 0; i < length; i++) {
    FlValue* item = fl_value_get_list_value(types, i);
    const gchar* name = fl_value_get_string(item);
    if (name == nullptr) {
      continue;
    }
    if (strcmp(name, "all") == 0) {
      return WEBKIT_WEBSITE_DATA_ALL;
    }
    if (strcmp(name, "cookies") == 0) {
      flags = static_cast<WebKitWebsiteDataTypes>(flags |
                                                  WEBKIT_WEBSITE_DATA_COOKIES);
    } else if (strcmp(name, "httpCache") == 0) {
      flags = static_cast<WebKitWebsiteDataTypes>(
          flags | WEBKIT_WEBSITE_DATA_MEMORY_CACHE |
          WEBKIT_WEBSITE_DATA_DISK_CACHE |
          WEBKIT_WEBSITE_DATA_OFFLINE_APPLICATION_CACHE);
    } else if (strcmp(name, "localStorage") == 0) {
      flags = static_cast<WebKitWebsiteDataTypes>(
          flags | WEBKIT_WEBSITE_DATA_LOCAL_STORAGE);
    } else if (strcmp(name, "sessionStorage") == 0) {
      flags = static_cast<WebKitWebsiteDataTypes>(
          flags | WEBKIT_WEBSITE_DATA_SESSION_STORAGE);
    } else if (strcmp(name, "indexedDb") == 0) {
      flags = static_cast<WebKitWebsiteDataTypes>(
          flags | WEBKIT_WEBSITE_DATA_INDEXEDDB_DATABASES);
    }
  }
  if (flags == 0) {
    return static_cast<WebKitWebsiteDataTypes>(0);
  }
  return flags;
}

static void clear_website_data_finished_cb(GObject* object,
                                           GAsyncResult* result,
                                           gpointer user_data) {
  FlMethodCall* method_call = FL_METHOD_CALL(user_data);
  GError* error = nullptr;
  webkit_website_data_manager_clear_finish(
      WEBKIT_WEBSITE_DATA_MANAGER(object), result, &error);
  if (error != nullptr) {
    respond(method_call, error_response("storage_error", error->message));
    g_clear_error(&error);
  } else {
    respond(method_call, success_response());
  }
  g_object_unref(method_call);
}

void root_method_call_cb(FlMethodChannel* channel,
                                FlMethodCall* method_call,
                                gpointer user_data) {
  XueHuaWebviewLinuxPlugin* self = static_cast<XueHuaWebviewLinuxPlugin*>(user_data);
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "createWebView") == 0) {
    LinuxWebView* webview = create_linux_webview(self);
    if (webview == nullptr) {
      respond(method_call, error_response("creation_error",
                                          "Unable to create Linux WebView."));
      return;
    }
    respond(method_call, success_response(fl_value_new_int(webview->id)));
    return;
  }

  WebKitWebContext* context = webkit_web_context_get_default();
  WebKitCookieManager* cookie_manager =
      webkit_web_context_get_cookie_manager(context);
  WebKitWebsiteDataManager* website_data_manager =
      webkit_web_context_get_website_data_manager(context);

  if (strcmp(method, "clearCookies") == 0) {
    g_object_ref(method_call);
    webkit_website_data_manager_clear(
        website_data_manager, WEBKIT_WEBSITE_DATA_COOKIES, 0, nullptr,
        clear_cookies_finished_cb, method_call);
    return;
  }

  if (strcmp(method, "setCookie") == 0) {
    const gchar* name = map_lookup_string(args, "name");
    const gchar* value = map_lookup_string(args, "value");
    const gchar* domain = map_lookup_string(args, "domain");
    const gchar* path = map_lookup_string(args, "path");
    if (name == nullptr || strlen(name) == 0 || value == nullptr ||
        domain == nullptr || strlen(domain) == 0) {
      respond(method_call,
              error_response("invalid_cookie",
                             "Cookie name, value, and domain are required."));
      return;
    }

    SoupCookie* cookie =
        soup_cookie_new(name, value, domain, path != nullptr ? path : "/", -1);
    g_object_ref(method_call);
    webkit_cookie_manager_add_cookie(cookie_manager, cookie, nullptr,
                                     add_cookie_finished_cb, method_call);
    soup_cookie_free(cookie);
    return;
  }

  if (strcmp(method, "getCookies") == 0) {
    const gchar* url = map_lookup_string(args, "url");
    if (url == nullptr || strlen(url) == 0) {
      respond(method_call,
              error_response("invalid_url", "A non-empty URL is required."));
      return;
    }

    g_object_ref(method_call);
    webkit_cookie_manager_get_cookies(cookie_manager, url, nullptr,
                                      get_cookies_finished_cb, method_call);
    return;
  }

  if (strcmp(method, "clearWebsiteData") == 0) {
    WebKitWebsiteDataTypes types = website_data_types_from_args(args);
    if (types == static_cast<WebKitWebsiteDataTypes>(0)) {
      respond(method_call, success_response());
      return;
    }
    gint64 since_ms = map_lookup_int(args, "sinceMilliseconds", 0);
    GTimeSpan timespan = 0;
    if (since_ms > 0) {
      const gint64 now_us = g_get_real_time();
      const gint64 since_us = since_ms * 1000;
      if (now_us > since_us) {
        timespan = now_us - since_us;
      }
    }
    g_object_ref(method_call);
    webkit_website_data_manager_clear(
        website_data_manager, types, timespan, nullptr,
        clear_website_data_finished_cb, method_call);
    return;
  }

  respond(method_call,
          FL_METHOD_RESPONSE(fl_method_not_implemented_response_new()));
}
