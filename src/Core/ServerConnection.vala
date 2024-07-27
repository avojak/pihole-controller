/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.ServerConnection : GLib.Object {

    public unowned PiholeController.ServerConnectionDetails connection_details { get; construct; }

    private Thread<void>? connection_thread;
    private Cancellable cancellable = new Cancellable ();

    private PiholeController.Core.PiholeRestClient rest_client;

    public ServerConnection (PiholeController.ServerConnectionDetails connection_details) {
        Object (
            connection_details: connection_details
        );
    }

    construct {
        rest_client = new PiholeController.Core.PiholeRestClient (connection_details);
    }

    public void open () {
        if (cancellable.is_cancelled ()) {
            warning ("Server connection already cancelled");
            return;
        }
        connection_thread = new GLib.Thread<void> ("pihole-%s".printf (connection_details.id.to_string ()), () => {
            while (!cancellable.is_cancelled ()) {
                try {
                    cancellable.set_error_if_cancelled ();
                } catch (GLib.Error e) {
                    return;
                }
                poll_server_version ();
                poll_summary_data ();
                poll_top_items ();
                Thread.usleep ((ulong) GLib.TimeSpan.SECOND * 5); // 5 seconds
            }
        });
        // When the connection_details object is created, the API token is not yet known.
        // We want to re-attempt to poll for certain data once the async function to load
        // the token completes.
        connection_details.notify["api-token"].connect (() => {
            poll_summary_data ();
            poll_top_items ();
        });
    }

    public void close () {
        cancellable.cancel ();
        closed ();
    }

    private void poll_server_version () {
        rest_client.get_version.begin ((obj, res) => {
            var version = rest_client.get_version.end (res);
            if (version == null) {
                debug ("null");
                return;
            }
            server_version_received (version);
        });
    }

    private void poll_summary_data () {
        rest_client.get_summary.begin ((obj, res) => {
            var summary = rest_client.get_summary.end (res);
            if (summary == null) {
                debug ("null");
                return;
            }
            summary_data_received (summary);
        });
    }

    private void poll_top_items () {
        rest_client.get_top_items.begin (10, (obj, res) => {
            var top_items = rest_client.get_top_items.end (res);
            if (top_items == null) {
                debug ("null");
                return;
            }
            top_items_received (top_items);
        });
    }

    public signal void server_version_received (PiholeController.ServerVersion server_version);
    public signal void summary_data_received (PiholeController.SummaryData summary_data);
    public signal void top_items_received (PiholeController.TopItems top_items);
    public signal void closed ();

}