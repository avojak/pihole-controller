/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.ServerRepository : GLib.Object {

    private PiholeController.Core.ServerDatabase database;
    private Gee.List<PiholeController.ServerDetails> servers;

    public ServerRepository (PiholeController.Core.ServerDatabase database) {
        this.database = database;
    }

    construct {
        servers = new Gee.ArrayList<PiholeController.ServerDetails> ();
    }
    
    public void save_server (PiholeController.ServerDetails server_details) {
        if (servers.contains (server_details)) {
            debug ("Updating server: %s", server_details.to_string ());
            database.update_server (server_details);
        } else {
            debug ("Saving new server: %s", server_details.to_string ());
            servers.add (server_details);
            database.insert_server (server_details);
        }
    }

}