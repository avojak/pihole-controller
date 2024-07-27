/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

public class PiholeController.GravityLastUpdatedData : GLib.Object {

    public class Relative : GLib.Object {
        public int days { get; construct; }
        public int hours { get; construct; }
        public int minutes { get; construct; }

        public string to_string () {
            var sb = new GLib.StringBuilder ();
            sb.append_printf ("days = %d\n", days);
            sb.append_printf ("hours = %d\n", hours);
            sb.append_printf ("minutes = %d\n", minutes);
            return sb.str;
        }
    }

    public Json.Object raw_data { get; construct; }

    public bool file_exists { get; construct; }
    public GLib.DateTime absolute { get; construct; }
    public Relative relative { get; construct; }

    public GravityLastUpdatedData.from_json (Json.Object raw_data) {
        Object (
            raw_data: raw_data
        );
    }

    construct {
        foreach (unowned string name in raw_data.get_members ()) {
            switch (name) {
                case "file_exists":
                    file_exists = raw_data.get_boolean_member (name);
                    break;
                case "absolute":
                    absolute = new GLib.DateTime.from_unix_utc (raw_data.get_int_member (name));
                    break;
                case "relative":
                    relative = Json.gobject_deserialize (typeof (Relative), raw_data.get_member (name)) as Relative;
                    break;
                default:
                    warning ("Unexpected JSON member: %s", name);
                    break;
            }
        }
    }

    public string to_string () {
        var sb = new GLib.StringBuilder ();
        sb.append_printf ("file_exists = %s\n", file_exists.to_string ());
        sb.append_printf ("absolute = %s\n", absolute.to_string ());
        sb.append_printf ("relative = %s\n", relative.to_string ());
        return sb.str;
    }
}