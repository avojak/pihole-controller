/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.ServerDetails : GLib.Object {

    public int64 id { get; set; default = -1; }
    public string name { get; set; }
    public string address { get; set; }
    public int port { get; set; }
    public bool use_https { get; set; }
    public string api_token { get; set; }

    public string to_string () {
        var sb = new GLib.StringBuilder ();
        sb.append_printf ("id = %s\n", id.to_string ());
        sb.append_printf ("name = %s\n", name);
        sb.append_printf ("address = %s\n", address);
        sb.append_printf ("port = %d\n", port);
        sb.append_printf ("use_https = %s", use_https.to_string ());
        return sb.str;
    }

}