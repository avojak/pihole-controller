/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.PreferencesDialog : Adw.PreferencesWindow {

    public PreferencesDialog (PiholeController.MainWindow main_window) {
        Object (
            transient_for: main_window
        );
    }

    construct {
        var servers_page = new PiholeController.ServersPreferencePage ();
        servers_page.server_saved.connect ((server_details) => {
            server_saved (server_details);
        });
        servers_page.server_deleted.connect ((server_details) => {

        });
        add (servers_page);
    }

    public signal void server_saved (PiholeController.ServerDetails details);

}