/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.PreferencesDialog : Adw.PreferencesWindow {

    private PiholeController.ServersPreferencePage servers_page;

    public PreferencesDialog (PiholeController.MainWindow main_window) {
        Object (
            transient_for: main_window
        );
    }

    construct {
        servers_page = new PiholeController.ServersPreferencePage ();
        servers_page.server_saved.connect ((connection_details) => {
            server_saved (connection_details);
        });
        servers_page.server_removed.connect ((connection_details) => {
            server_removed (connection_details);
        });

        //  var page = new Adw.PreferencesPage ();

        add (new PiholeController.GeneralPreferencePage ());
        add (servers_page);
        //  add (page);
    }

    public void set_servers (Gee.List<PiholeController.ServerConnectionDetails> servers) {
        servers_page.set_servers (servers);
    }

    public signal void server_saved (PiholeController.ServerConnectionDetails details);
    public signal void server_removed (PiholeController.ServerConnectionDetails details);

}