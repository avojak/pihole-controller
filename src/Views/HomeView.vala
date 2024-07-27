/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.HomeView : Adw.Bin {

    private Gtk.Box box;
    private Gee.Map<string, PiholeController.ServerHomeGroup> home_groups = new Gee.HashMap<string, PiholeController.ServerHomeGroup> ();

    public HomeView () {
        Object (
            hexpand: true,
            vexpand: true
        );
    }

    construct {
        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
            hexpand = true,
            vexpand = true
        };
        //  box.append (carousel_overlay);
        //  box.append (carousel_indicator);
        //  box.append (genre_flow_box);

        var clamp = new Adw.Clamp () {
            orientation = Gtk.Orientation.HORIZONTAL,
            maximum_size = 1000,
            child = box
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            vscrollbar_policy = Gtk.PolicyType.AUTOMATIC
        };
        scrolled_window.set_child (clamp);

        child = scrolled_window;
    }

    public void set_servers (Gee.List<PiholeController.ServerConnectionDetails> servers) {
        foreach (var connection_details in servers) {
            add_server (connection_details);
        }
    }

    public void on_summary_data_received (int64 database_id, PiholeController.SummaryData summary_data) {
        if (!home_groups.has_key (database_id.to_string ())) {
            warning ("No home group found for database id: %s", database_id.to_string ());
            return;
        }
        home_groups.get (database_id.to_string ()).update_summary_data (summary_data);
    }

    public void on_top_items_received (int64 database_id, PiholeController.TopItems top_items) {
        if (!home_groups.has_key (database_id.to_string ())) {
            warning ("No home group found for database id: %s", database_id.to_string ());
            return;
        }
        home_groups.get (database_id.to_string ()).update_top_items (top_items);
    }

    public void add_server (PiholeController.ServerConnectionDetails connection_details) {
        if (home_groups.has_key (connection_details.id.to_string ())) {
            warning ("A server home group already exists for server %s", connection_details.id.to_string ());
            return;
        }
        var home_group = new PiholeController.ServerHomeGroup (connection_details);
        home_groups.set (connection_details.id.to_string (), home_group);
        box.append (home_group);
    }

    public void remove_server (int64 database_id) {
        if (!home_groups.has_key (database_id.to_string ())) {
            warning ("No home group found for database id: %s", database_id.to_string ());
            return;
        }
        PiholeController.ServerHomeGroup home_group;
        home_groups.unset (database_id.to_string (), out home_group);
        box.remove (home_group);
    }

}