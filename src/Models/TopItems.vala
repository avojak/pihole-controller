/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

public class PiholeController.TopItems : GLib.Object {

    public Json.Object raw_data { get; construct; }

    public Gee.Map<string, int64?> top_queries { get; construct; }
    public Gee.Map<string, int64?> top_ads { get; construct; }

    public TopItems.from_json (Json.Node json) {
        Object (
            raw_data: json.get_object ()
        );
    }

    construct {
        top_queries = new Gee.HashMap<string, int64?> ();
        top_ads = new Gee.HashMap<string, int64?> ();

        foreach (unowned string name in raw_data.get_members ()) {
            switch (name) {
                case "top_queries":
                    var top_queries_data = raw_data.get_member (name).get_object ();
                    foreach (unowned string query in top_queries_data.get_members ()) {
                        top_queries.set (query, top_queries_data.get_int_member (query));
                    }
                    break;
                case "top_ads":
                    var top_ads_data = raw_data.get_member (name).get_object ();
                    foreach (unowned string ad in top_ads_data.get_members ()) {
                        top_ads.set (ad, top_ads_data.get_int_member (ad));
                    }
                    break;
                default:
                    warning ("Unexpected JSON member: %s", name);
                    break;
            }
        }
                
    }

}