/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

public class PiholeController.SummaryData : GLib.Object {

    public Json.Object raw_data { get; construct; }

    public int64 domains_being_blocked { get; construct; }
    public int64 dns_queries_today { get; construct; }
    public int64 ads_blocked_today { get; construct; }
    public double ads_percentage_today { get; construct; }
    public int64 unique_domains { get; construct; }
    public int64 queries_forwarded { get; construct; }
    public int64 queries_cached { get; construct; }
    public int64 clients_ever_seen { get; construct; }
    public int64 unique_clients { get; construct; }
    public int64 dns_queries_all_types { get; construct; }
    public PiholeController.ServerStatus status { get; construct; }
    public PiholeController.ReplyData reply_data { get; construct; }
    public int64 dns_queries_all_replies { get; construct; }
    public PiholeController.ServerPrivacyLevel privacy_level { get; construct; }
    public PiholeController.GravityLastUpdatedData gravity_last_updated { get; construct; }

    public SummaryData.from_json (Json.Node json) {
        Object (
            raw_data: json.get_object ()
        );
    }

    construct {
        reply_data = new PiholeController.ReplyData ();
        // Pi-hole uses the PHP number_format function for summary data, and
        // uses the default decimal and thousands separators ('.', and ',' 
        // respectively).
        // See: https://github.com/pi-hole/web/blob/master/api_FTL.php#L50
        foreach (unowned string name in raw_data.get_members ()) {
            switch (name) {
                case "domains_being_blocked":
                    domains_being_blocked = raw_data.get_int_member (name);
                    break;
                case "dns_queries_today":
                    dns_queries_today = raw_data.get_int_member (name);
                    break;
                case "ads_blocked_today":
                    ads_blocked_today = raw_data.get_int_member (name);
                    break;
                case "ads_percentage_today":
                    ads_percentage_today = raw_data.get_double_member (name);
                    break;
                case "unique_domains":
                    unique_domains = raw_data.get_int_member (name);
                    break;
                case "queries_forwarded":
                    queries_forwarded = raw_data.get_int_member (name);
                    break;
                case "queries_cached":
                    queries_cached = raw_data.get_int_member (name);
                    break;
                case "clients_ever_seen":
                    clients_ever_seen = raw_data.get_int_member (name);
                    break;
                case "unique_clients":
                    unique_clients = raw_data.get_int_member (name);
                    break;
                case "dns_queries_all_types":
                    dns_queries_all_types = raw_data.get_int_member (name);
                    break;
                case "status":
                    status = PiholeController.ServerStatus.from_string (raw_data.get_string_member (name));
                    break;
                case "reply_UNKNOWN":
                    reply_data.data.set (PiholeController.ReplyData.Type.UNKNOWN, raw_data.get_int_member (name));
                    break;
                case "reply_NODATA":
                    reply_data.data.set (PiholeController.ReplyData.Type.NODATA, raw_data.get_int_member (name));
                    break;
                case "reply_NXDOMAIN":
                    reply_data.data.set (PiholeController.ReplyData.Type.NXDOMAIN, raw_data.get_int_member (name));
                    break;
                case "reply_CNAME":
                    reply_data.data.set (PiholeController.ReplyData.Type.CNAME, raw_data.get_int_member (name));
                    break;
                case "reply_IP":
                    reply_data.data.set (PiholeController.ReplyData.Type.IP, raw_data.get_int_member (name));
                    break;
                case "reply_DOMAIN":
                    reply_data.data.set (PiholeController.ReplyData.Type.DOMAIN, raw_data.get_int_member (name));
                    break;
                case "reply_RRNAME":
                    reply_data.data.set (PiholeController.ReplyData.Type.RRNAME, raw_data.get_int_member (name));
                    break;
                case "reply_SERVFAIL":
                    reply_data.data.set (PiholeController.ReplyData.Type.SERVFAIL, raw_data.get_int_member (name));
                    break;
                case "reply_REFUSED":
                    reply_data.data.set (PiholeController.ReplyData.Type.REFUSED, raw_data.get_int_member (name));
                    break;
                case "reply_NOTIMP":
                    reply_data.data.set (PiholeController.ReplyData.Type.NOTIMP, raw_data.get_int_member (name));
                    break;
                case "reply_OTHER":
                    reply_data.data.set (PiholeController.ReplyData.Type.OTHER, raw_data.get_int_member (name));
                    break;
                case "reply_DNSSEC":
                    reply_data.data.set (PiholeController.ReplyData.Type.DNSSEC, raw_data.get_int_member (name));
                    break;
                case "reply_NONE":
                    reply_data.data.set (PiholeController.ReplyData.Type.NONE, raw_data.get_int_member (name));
                    break;
                case "reply_BLOB":
                    reply_data.data.set (PiholeController.ReplyData.Type.BLOB, raw_data.get_int_member (name));
                    break;
                case "dns_queries_all_replies":
                    dns_queries_all_replies = raw_data.get_int_member (name);
                    break;
                case "privacy_level":
                    privacy_level = (PiholeController.ServerPrivacyLevel) raw_data.get_int_member (name);
                    break;
                case "gravity_last_updated":
                    gravity_last_updated = new PiholeController.GravityLastUpdatedData.from_json (raw_data.get_object_member (name));
                    break;
                default:
                    warning ("Unexpected JSON member: %s", name);
                    break;
            }
        }
    }

    //  private int parse_formatted_integer (string str) {
    //      return int.parse (str.replace (",", ""));
    //  }

    public string to_string () {
        var sb = new GLib.StringBuilder ();
        sb.append ("=== Summary ===\n");
        sb.append_printf ("domains_being_blocked = %s\n", domains_being_blocked.to_string ());
        sb.append_printf ("dns_queries_today = %s\n", dns_queries_today.to_string ());
        sb.append_printf ("ads_blocked_today = %s\n", ads_blocked_today.to_string ());
        sb.append_printf ("ads_percentage_today = %.2f\n", ads_percentage_today);
        sb.append_printf ("unique_domains = %s\n", unique_domains.to_string ());
        sb.append_printf ("queries_forwarded = %s\n", queries_forwarded.to_string ());
        sb.append_printf ("queries_cached = %s\n", queries_cached.to_string ());
        sb.append_printf ("clients_ever_seen = %s\n", clients_ever_seen.to_string ());
        sb.append_printf ("unique_clients = %s\n", unique_clients.to_string ());
        sb.append_printf ("dns_queries_all_types = %s\n", dns_queries_all_types.to_string ());
        sb.append_printf ("status = %s\n", status.get_display_string ());
        sb.append_printf ("dns_queries_all_replies = %s\n", dns_queries_all_replies.to_string ());
        sb.append_printf ("privacy_level = %d\n", privacy_level);
        sb.append_printf ("gravity_last_updated = %s\n", gravity_last_updated.to_string ());
        return sb.str;
    }

}