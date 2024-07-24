/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.ServersPreferencePage : Adw.PreferencesPage {

    private Adw.PreferencesGroup servers_group;
    private Gtk.Widget placeholder_row;
    private Gee.List<PiholeController.ServerPreferenceGroup> groups = new Gee.ArrayList<PiholeController.ServerPreferenceGroup> ();

    public ServersPreferencePage () {
        Object (
            name: "servers",
            title: _("Servers"),
            icon_name: "application-x-executable-symbolic"
        );
    }

    construct {
        var add_button = new Gtk.Button () {
            child = new Adw.ButtonContent () {
                icon_name = "list-add-symbolic",
                label = _("Add Server")
            }
        };
        add_button.add_css_class ("flat");
        add_button.add_css_class ("image-text-button");

        servers_group = new Adw.PreferencesGroup () {
            title = _("Pi-hole Servers"),
            header_suffix = add_button
        };

        placeholder_row = new Gtk.Label (_("No servers configured"));
        placeholder_row.add_css_class ("dim-label");
        servers_group.add (placeholder_row);

        // TODO: Add delete row

        add (servers_group);
        //  foreach (var entry in Pixels.Core.Client.get_instance ().libretro_core_manager.get_cores_by_manufacturer ().entries) {
        //      var manufacturer_group = new Adw.PreferencesGroup () {
        //          title = entry.key
        //      };
        //      foreach (var core in entry.value) {
        //          manufacturer_group.add (create_core_row (core));
        //      }
        //      add (manufacturer_group);
        //  }

        add_button.clicked.connect (() => {
            // Collapse the other groups
            foreach (var group in groups) {
                group.expanded = false;
            }
            var server_details = new PiholeController.ServerDetails () {
                name = "Pi-hole",
                address = "",
                port = 80,
                use_https = false,
                api_token = ""
            };
            var group = new PiholeController.ServerPreferenceGroup.from_details (server_details, true);
            group.delete_button_clicked.connect (() => {
                groups.remove (group);
                server_deleted (server_details);
                Idle.add (() => {
                    servers_group.remove (group);
                    if (groups.size == 0) {
                        servers_group.add (placeholder_row);
                    }
                    return false;
                });
            });
            group.save_button_clicked.connect (() => {
                server_saved (server_details);
            });
            groups.add (group);
            servers_group.add (group);
            if (groups.size == 1) {
                servers_group.remove (placeholder_row);
            }
        });
    }

    public signal void server_saved (PiholeController.ServerDetails details);
    public signal void server_deleted (PiholeController.ServerDetails details);

}