/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.ServerHomeGroup : Adw.Bin {

    private class TopItem : GLib.Object {
        public string name { get; set; }
        public int64 value { get; set; }
    }

    public unowned PiholeController.ServerConnectionDetails connection_details { get; construct; }

    //  private Gtk.FlowBox summary_flow_box;
    private PiholeController.StatisticTile total_queries_tile;
    private PiholeController.StatisticTile queries_blocked_tile;
    private PiholeController.StatisticTile percent_blocked_tile;
    private PiholeController.StatisticTile blocklist_tile;

    private Gtk.ColumnView top_queries_table;
    private GLib.ListStore top_queries_list_store;
    private Gtk.ColumnView top_ads_table;

    public ServerHomeGroup (PiholeController.ServerConnectionDetails connection_details) {
        Object (
            connection_details: connection_details
        );
    }

    construct {
        total_queries_tile = new PiholeController.StatisticTile (_("Total Queries"), "total-queries-card", "search-global-symbolic");
        queries_blocked_tile = new PiholeController.StatisticTile (_("Queries Blocked"), "queries-blocked-card", "hand-openyay-symbolic");
        percent_blocked_tile = new PiholeController.StatisticTile (_("Percent Blocked"), "percent-blocked-card", "security-high-symbolic");
        blocklist_tile = new PiholeController.StatisticTile (_("Blocklist"), "blocklist-card", "view-list-symbolic");

        var summary_flow_box = new Gtk.FlowBox () {
            orientation = Gtk.Orientation.HORIZONTAL,
            valign = Gtk.Align.START,
            hexpand = true,
            vexpand = false,
            column_spacing = 8,
            row_spacing = 8,
            homogeneous = true,
            min_children_per_line = 1,
            max_children_per_line = 4,
            margin_bottom = 16,
            margin_top = 16,
            margin_start = 16,
            margin_end = 16
        };
        summary_flow_box.append (total_queries_tile);
        summary_flow_box.append (queries_blocked_tile);
        summary_flow_box.append (percent_blocked_tile);
        summary_flow_box.append (blocklist_tile);

        var name_factory = new Gtk.SignalListItemFactory ();
        name_factory.setup.connect ((item) => {
            var list_item = (Gtk.ListItem) item;
            list_item.child = new Gtk.Label ("") {
                halign = Gtk.Align.START
            };
        });
        name_factory.bind.connect ((item) => {
            var list_item = (Gtk.ListItem) item;
            var label = (Gtk.Label) list_item.child;
            var top_item = (TopItem) list_item.item;

            label.label = top_item.name;
        });

        var value_factory = new Gtk.SignalListItemFactory ();
        value_factory.setup.connect ((item) => {
            var list_item = (Gtk.ListItem) item;
            list_item.child = new Gtk.Label ("") {
                halign = Gtk.Align.START
            };
        });
        value_factory.bind.connect ((item) => {
            var list_item = (Gtk.ListItem) item;
            var label = (Gtk.Label) list_item.child;
            var top_item = (TopItem) list_item.item;

            label.label = top_item.value.to_string ();
        });

        var domain_column = new Gtk.ColumnViewColumn (_("Domain"), name_factory);
        var hits_column = new Gtk.ColumnViewColumn (_("Hits"), value_factory);
        top_queries_list_store = new GLib.ListStore (typeof (TopItem));
        top_queries_table = new Gtk.ColumnView (new Gtk.NoSelection (top_queries_list_store));
        top_queries_table.insert_column (0, domain_column);
        top_queries_table.insert_column (1, hits_column);

        top_ads_table = new Gtk.ColumnView (null);

        var top_items_flow_box = new Gtk.FlowBox () {
            orientation = Gtk.Orientation.HORIZONTAL,
            valign = Gtk.Align.START,
            hexpand = true,
            vexpand = false,
            column_spacing = 8,
            row_spacing = 8,
            homogeneous = true,
            min_children_per_line = 1,
            max_children_per_line = 4,
            margin_bottom = 16,
            margin_top = 16,
            margin_start = 16,
            margin_end = 16
        };
        top_items_flow_box.append (top_queries_table);
        top_items_flow_box.append (top_ads_table);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 16);
        box.append (summary_flow_box);
        box.append (top_items_flow_box);

        child = box;
    }

    public void update_summary_data (PiholeController.SummaryData summary_data) {
        Idle.add (() => {
            total_queries_tile.set_value ("%'d".printf (summary_data.dns_queries_today));
            queries_blocked_tile.set_value ("%'d".printf (summary_data.ads_blocked_today));
            percent_blocked_tile.set_value ("%.1f%%".printf (summary_data.ads_percentage_today));
            blocklist_tile.set_value ("%'d".printf (summary_data.domains_being_blocked));
            return false;
        });
    }

    public void update_top_items (PiholeController.TopItems top_items) {
        top_queries_list_store.remove_all ();
        foreach (var entry in top_items.top_queries.entries) {
            top_queries_list_store.append (new TopItem () {
                name = entry.key,
                value = entry.value
            });
        }
        top_queries_list_store.sort ((a, b) => {
            var item_a = (TopItem) a;
            var item_b = (TopItem) b;
            if (item_a.value == item_b.value) {
                return 0;
            } else if (item_a.value > item_b.value) {
                return -1;
            }
            return 1;
        });
    }

}