/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.ServerHomeGroup : Adw.Bin {

    private class TopItem : GLib.Object {
        public string name { get; set; }
        public int64 value { get; set; }
        public double frequency { get; set; }
    }

    public unowned PiholeController.ServerConnectionDetails connection_details { get; construct; }

    //  private unowned PiholeController.SummaryData? current_summary_data;
    private int64 current_total_queries = 0;

    //  private Gtk.FlowBox summary_flow_box;
    private PiholeController.StatisticTile total_queries_tile;
    private PiholeController.StatisticTile queries_blocked_tile;
    private PiholeController.StatisticTile percent_blocked_tile;
    private PiholeController.StatisticTile blocklist_tile;

    private Gtk.ColumnView top_queries_table;
    private GLib.ListStore top_queries_list_store;
    private Gtk.ColumnView top_ads_table;
    private GLib.ListStore top_ads_list_store;

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
            margin_end = 16,
            selection_mode = Gtk.SelectionMode.NONE
        };
        summary_flow_box.append (total_queries_tile);
        summary_flow_box.append (queries_blocked_tile);
        summary_flow_box.append (percent_blocked_tile);
        summary_flow_box.append (blocklist_tile);

        var name_factory = new Gtk.SignalListItemFactory ();
        name_factory.setup.connect ((item) => {
            var list_item = (Gtk.ListItem) item;
            list_item.child = new Gtk.Label ("") {
                halign = Gtk.Align.START,
                ellipsize = Pango.EllipsizeMode.END
            };
        });
        name_factory.bind.connect ((item) => {
            var list_item = (Gtk.ListItem) item;
            var label = (Gtk.Label) list_item.child;
            var top_item = (TopItem) list_item.item;

            label.label = top_item.name;
            label.tooltip_text = top_item.name;
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

        var frequency_factory = new Gtk.SignalListItemFactory ();
        frequency_factory.setup.connect ((item) => {
            var list_item = (Gtk.ListItem) item;
            list_item.child = new Gtk.ProgressBar () {
                halign = Gtk.Align.FILL,
                valign = Gtk.Align.CENTER
            };
        });
        frequency_factory.bind.connect ((item) => {
            var list_item = (Gtk.ListItem) item;
            var progress_bar = (Gtk.ProgressBar) list_item.child;
            var top_item = (TopItem) list_item.item;

            progress_bar.fraction = top_item.frequency;
            progress_bar.tooltip_text = _("%.1f%% of %s".printf (top_item.frequency * 100.0, current_total_queries.to_string ()));
        });

        var top_queries_domain_column = new Gtk.ColumnViewColumn (_("Domain"), name_factory) {
            expand = true
        };
        var top_queries_hits_column = new Gtk.ColumnViewColumn (_("Hits"), value_factory) {
            expand = true
        };
        var top_queries_frequency_column = new Gtk.ColumnViewColumn (_("Frequency"), frequency_factory) {
            expand = false
        };
        top_queries_list_store = new GLib.ListStore (typeof (TopItem));
        top_queries_table = new Gtk.ColumnView (new Gtk.NoSelection (top_queries_list_store)) {
            margin_bottom = 8,
            margin_top = 8,
            margin_start = 8,
            margin_end = 8
        };
        top_queries_table.insert_column (0, top_queries_domain_column);
        top_queries_table.insert_column (1, top_queries_hits_column);
        top_queries_table.insert_column (2, top_queries_frequency_column);

        var top_queries_header = new Gtk.Label (_("Top Permitted Domains")) {
            margin_top = 8,
            margin_bottom = 8,
            margin_start = 8,
            margin_end = 8
        };
        top_queries_header.add_css_class ("heading");

        var top_queries_tile = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        top_queries_tile.add_css_class ("card");
        top_queries_tile.append (top_queries_header);
        top_queries_tile.append (top_queries_table);

        var top_ads_domain_column = new Gtk.ColumnViewColumn (_("Domain"), name_factory) {
            expand = true
        };
        var top_ads_hits_column = new Gtk.ColumnViewColumn (_("Hits"), value_factory) {
            expand = true
        };
        top_ads_list_store = new GLib.ListStore (typeof (TopItem));
        top_ads_table = new Gtk.ColumnView (new Gtk.NoSelection (top_ads_list_store)) {
            margin_bottom = 8,
            margin_top = 8,
            margin_start = 8,
            margin_end = 8
        };
        top_ads_table.insert_column (0, top_ads_domain_column);
        top_ads_table.insert_column (1, top_ads_hits_column);

        var top_ads_header = new Gtk.Label (_("Top Blocked Domains")) {
            margin_top = 8,
            margin_bottom = 8,
            margin_start = 8,
            margin_end = 8
        };
        top_ads_header.add_css_class ("heading");

        var top_ads_tile = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        top_ads_tile.add_css_class ("card");
        top_ads_tile.append (top_ads_header);
        top_ads_tile.append (top_ads_table);

        var top_items_flow_box = new Gtk.FlowBox () {
            orientation = Gtk.Orientation.HORIZONTAL,
            valign = Gtk.Align.START,
            hexpand = true,
            vexpand = false,
            column_spacing = 8,
            row_spacing = 8,
            homogeneous = true,
            min_children_per_line = 1,
            max_children_per_line = 2,
            margin_bottom = 16,
            margin_top = 16,
            margin_start = 16,
            margin_end = 16,
            selection_mode = Gtk.SelectionMode.NONE
        };
        top_items_flow_box.append (top_queries_tile);
        top_items_flow_box.append (top_ads_tile);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 16);
        box.append (summary_flow_box);
        box.append (top_items_flow_box);

        child = box;
    }

    public void update_summary_data (PiholeController.SummaryData summary_data) {
        current_total_queries = summary_data.dns_queries_today;
        Idle.add (() => {
            total_queries_tile.set_value ("%'d".printf (summary_data.dns_queries_today));
            queries_blocked_tile.set_value ("%'d".printf (summary_data.ads_blocked_today));
            percent_blocked_tile.set_value ("%.1f%%".printf (summary_data.ads_percentage_today));
            blocklist_tile.set_value ("%'d".printf (summary_data.domains_being_blocked));
            return false;
        });
    }

    public void update_top_items (PiholeController.TopItems top_items) {
        update_top_queries (top_items.top_queries);
        update_top_ads (top_items.top_ads);
    }

    private void update_top_queries (Gee.Map<string, int64?> top_queries) {
        top_queries_list_store.remove_all ();
        foreach (var entry in top_queries.entries) {
            top_queries_list_store.append (new TopItem () {
                name = entry.key,
                value = entry.value,
                frequency = current_total_queries == 0 ? 0.0 : ((double) entry.value / (double) current_total_queries)
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

    private void update_top_ads (Gee.Map<string, int64?> top_ads) {
        top_ads_list_store.remove_all ();
        foreach (var entry in top_ads.entries) {
            top_ads_list_store.append (new TopItem () {
                name = entry.key,
                value = entry.value
            });
        }
        top_ads_list_store.sort ((a, b) => {
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