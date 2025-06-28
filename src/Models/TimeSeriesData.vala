/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

 public class PiholeController.TimeSeriesData : GLib.Object {

    public Json.Object raw_data { get; construct; }
    public Gee.Map<GLib.DateTime, int64?> domains_over_time { get; construct; }
    public Gee.Map<GLib.DateTime, int64?> ads_over_time { get; construct; }

    public TimeSeriesData.from_json (Json.Node json) {
        Object (
            raw_data: json.get_object ()
        );
    }

    construct {
        domains_over_time = new Gee.HashMap<GLib.DateTime, int64?> ();
        ads_over_time = new Gee.HashMap<GLib.DateTime, int64?> ();

        foreach (unowned string name in raw_data.get_members ()) {
            switch (name) {
                case "domains_over_time":
                    parse (domains_over_time, raw_data.get_object_member (name));
                    break;
                case "ads_over_time":
                    parse (ads_over_time, raw_data.get_object_member (name));
                    break;
                default:
                    warning ("Unexpected JSON member: %s", name);
                    break;
            }
        }
    }

    private void parse (Gee.Map<GLib.DateTime, int64?> values, Json.Object? data) {
        foreach (unowned string timestamp in data.get_members ()) {
            var date_time = new GLib.DateTime.from_unix_local (int.parse (timestamp));
            values.set (date_time, data.get_int_member (timestamp));
        }
    }

    public string to_string () {
        var sb = new GLib.StringBuilder ();
        sb.append ("=== Domains over time ===\n");
        var domains_over_time_keys = domains_over_time.keys;
        //  domains_over_time_keys.sort (GLib.DateTime.compare);
        foreach (var key in domains_over_time_keys) {
            sb.append_printf ("%s = %s\n", key.to_string (), domains_over_time.get (key).to_string ());
        }
        sb.append ("=== Ads over time ===\n");
        var ads_over_time_keys = ads_over_time.keys;
        //  ads_over_time_keys.sort (GLib.DateTime.compare);
        foreach (var key in ads_over_time_keys) {
            sb.append_printf ("%s = %s\n", key.to_string (), ads_over_time.get (key).to_string ());
        }
        return sb.str;
    }

}