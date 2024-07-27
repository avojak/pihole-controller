/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.ServerConnectionManager : GLib.Object {

    private static GLib.Once<PiholeController.Core.ServerConnectionManager> instance;
    public static unowned PiholeController.Core.ServerConnectionManager get_instance () {
        return instance.once (() => { return new PiholeController.Core.ServerConnectionManager (); });
    }

    private Gee.Map<string, PiholeController.Core.ServerConnection> connections;

    construct {
        connections = new Gee.HashMap<string, PiholeController.Core.ServerConnection> ();
    }

    public void open (PiholeController.ServerConnectionDetails connection_details) {
        var database_id = connection_details.id;
        if (connections.has_key (connection_details.id.to_string ())) {
            warning ("A connection thread already exists for server %s", database_id.to_string ());
            return;
        }
        var connection = new PiholeController.Core.ServerConnection (connection_details);
        connection.server_version_received.connect ((server_version) => {
            server_version_received (connection_details.id, server_version);
        });
        connection.summary_data_received.connect ((summary_data) => {
            summary_data_received (connection_details.id, summary_data);
        });
        connection.top_items_received.connect ((top_items) => {
            top_items_received (connection_details.id, top_items);
        });
        connection.closed.connect (() => {
            connections.unset (database_id.to_string (), null);
        });
        connections.set (database_id.to_string (), connection);
        connection.open ();
    }

    public void close_all () {
        Gee.Set<string> database_ids = new Gee.HashSet<string> ();
        database_ids.add_all (connections.keys);
        foreach (var database_id in database_ids) {
            do_close (database_id);
        }
    }

    //  public void close (PiholeController.ServerConnectionDetails connection_details) {
    //      do_close (connection_details.id);
    //  }

    public void close (int64 database_id) {
        do_close (database_id.to_string ());
    }

    private void do_close (string database_id) {
        PiholeController.Core.ServerConnection connection;
        connections.unset (database_id, out connection);
        connection.close ();
    }

    public void test (PiholeController.ServerConnectionDetails connection_details) {
        var client = new PiholeController.Core.PiholeRestClient (connection_details);
        client.get_version.begin ((obj, res) => {
            PiholeController.ServerVersion? version = client.get_version.end (res);
            if (version == null) {
                debug ("null");
                return;
            }
            debug (version.core_current);
        });
    }

    public signal void server_version_received (int64 database_id, PiholeController.ServerVersion server_version);
    public signal void summary_data_received (int64 database_id, PiholeController.SummaryData summary_Data);
    public signal void top_items_received (int64 database_id, PiholeController.TopItems top_items);

}