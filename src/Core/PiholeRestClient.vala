/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.PiholeRestClient : GLib.Object {

    private struct QueryParam {
        string name;
        string value;
    }

    public unowned PiholeController.ServerConnectionDetails connection_details { get; construct; }

    private Rest.Proxy proxy;

    public PiholeRestClient (PiholeController.ServerConnectionDetails connection_details) {
        Object (
            connection_details: connection_details
        );
    }

    construct {
        var protocol = connection_details.use_https ? "https://" : "http://";
        var address = connection_details.address;
        var port = connection_details.port.to_string ();
        var url_format = @"$protocol$address:$port/admin/api.php";
        proxy = new Rest.Proxy (url_format, false);
        debug (proxy.url_format);
    }

    public void test (PiholeController.ServerConnectionDetails connection_details) {
        var call = proxy.new_call ();
        call.set_method ("GET");
        call.set_function ("versions");
        call.invoke_async.begin (null, (obj, res) => {
            try {
                call.invoke_async.end (res);
                debug (call.get_status_code ().to_string ());
            } catch (GLib.Error e) {
                warning (e.message);
            }
        });
    }

    public async PiholeController.ServerVersion? get_version () {
        PiholeController.ServerVersion? response = null;
        GLib.SourceFunc callback = get_version.callback;
        new GLib.Thread<void> ("get-version-%s".printf (connection_details.id.to_string ()), () => {
            response = http_get ({{"versions", ""}}, (root) => {
                return gobject_deserialize (root, typeof (PiholeController.ServerVersion));
            }, false) as PiholeController.ServerVersion;
            Idle.add ((owned) callback);
        });
        yield;
        return response;
    }

    public async PiholeController.SummaryData? get_summary () {
        PiholeController.SummaryData? response = null;
        GLib.SourceFunc callback = get_summary.callback;
        new GLib.Thread<void> ("get-summary-%s".printf (connection_details.id.to_string ()), () => {
            response = http_get ({{"summaryRaw", ""}}, (root) => {
                return new PiholeController.SummaryData.from_json (root);
            }) as PiholeController.SummaryData;
            Idle.add ((owned) callback);
        });
        yield;
        return response;
    }

    public async PiholeController.TopItems? get_top_items (int num_items) {
        PiholeController.TopItems? response = null;
        GLib.SourceFunc callback = get_top_items.callback;
        new GLib.Thread<void> ("get-top-items-%s".printf (connection_details.id.to_string ()), () => {
            response = http_get ({{"topItems", num_items.to_string ()}}, (root) => {
                return new PiholeController.TopItems.from_json (root);
            }) as PiholeController.TopItems;
            Idle.add ((owned) callback);
        });
        yield;
        return response;
    }

    private GLib.Object? http_get (QueryParam[] query_params, ResponseDeserializer deserialize_func, bool requires_auth = true) {
        if (requires_auth && (connection_details.api_token == null)) {
            warning ("Requested call requires API token, but none provided");
            return null;
        }
        var call = proxy.new_call ();
        call.set_method ("GET");
        //  call.set_function (function);
        foreach (var query in query_params) {
            call.add_param (query.name, query.value);
        }
        if (connection_details.api_token != null) {
            call.add_param ("auth", connection_details.api_token);
        }

        // Execute the request
        try {
            if (!call.sync ()) {
                warning ("Failed to execute HTTP GET request");
                return null;
            }
        } catch (GLib.Error e) {
            warning ("Error executing HTTP GET request: %s", e.message);
            return null;
        }
        var payload = call.get_payload ();

        debug (call.get_status_code ().to_string ());
        debug (payload);

        // Parse the response
        var parser = new Json.Parser ();
        try {
            if (!parser.load_from_data (payload)) {
                warning ("Failed to parse JSON payload");
                return null;
            }
        } catch (GLib.Error e) {
            warning ("Error while parsing JSON payload: %s", e.message);
            return null;
        }

        return deserialize_func (parser.get_root ());
        //  return Json.gobject_deserialize (response_type, parser.get_root ());
    }

    private delegate GLib.Object? ResponseDeserializer (Json.Node root);

    private GLib.Object? gobject_deserialize (Json.Node root, GLib.Type response_type) {
        return Json.gobject_deserialize (response_type, root);
    } 

//      public Pihole.TimeSeriesData? get_time_series_data () {
//          return new Pihole.TimeSeriesData.from_json (http_client.get_time_series_data ());
//      }

//      public Pihole.SummaryData get_summary () {
//          return new Pihole.SummaryData.from_json (http_client.get_summary ());
//      }

//      public void enable () {
//          http_client.enable ();
//      }

//      public void disable (int seconds) {
//          if (seconds <= 0) {
//              // TODO
//              return;
//          }
//          http_client.disable (seconds);
//      }

}