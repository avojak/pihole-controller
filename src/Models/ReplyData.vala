/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

public class PiholeController.ReplyData : GLib.Object {

    public enum Type {
        UNKNOWN,
        NODATA,
        NXDOMAIN,
        CNAME,
        IP,
        DOMAIN,
        RRNAME,
        SERVFAIL,
        REFUSED,
        NOTIMP,
        OTHER,
        DNSSEC,
        NONE,
        BLOB;

        public static Type[] get_all_values () {
            return new Type[] {
                UNKNOWN,
                NODATA,
                NXDOMAIN,
                CNAME,
                IP,
                DOMAIN,
                RRNAME,
                SERVFAIL,
                REFUSED,
                NOTIMP,
                OTHER,
                DNSSEC,
                NONE,
                BLOB
            };
        }
    }

    public Gee.Map<ReplyData.Type, int64?> data { get; construct; }

    construct {
        data = new Gee.HashMap<ReplyData.Type, int64?> ();
        foreach (var type in ReplyData.Type.get_all_values ()) {
            data.set (type, 0);
        }
    }

}