/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.ServerRepository : GLib.Object {

    private const string SECRET_SCHEMA_VERSION = "1";

    private PiholeController.Core.ServerDatabase database;
    //  private PiholeController.Core.SecretManager secret_manager;
    private Gee.List<PiholeController.ServerDetails> servers;

    private static Secret.Schema secret_schema = new Secret.Schema (
        APP_ID,
        Secret.SchemaFlags.NONE,
        "version", Secret.SchemaAttributeType.STRING, // Versioning number for the schema, NOT the application
        "database_id", Secret.SchemaAttributeType.INTEGER
    );

    public ServerRepository (PiholeController.Core.ServerDatabase database) {
        this.database = database;
        //  this.secret_manager = secret_manager;
        servers = database.get_servers ();
        foreach (var server in servers) {
            lookup_api_token (server);
        }
    }
    
    public void save_server (PiholeController.ServerDetails server_details) {
        if (servers.contains (server_details)) {
            debug ("Updating server: %s", server_details.to_string ());
            database.update_server (server_details);
            store_api_token (server_details);
        } else {
            debug ("Saving new server: %s", server_details.to_string ());
            servers.add (server_details);
            database.insert_server (server_details);
            store_api_token (server_details);
        }
    }

    public Gee.List<PiholeController.ServerDetails> get_servers () {
        return servers;
    }

    public void remove_server (PiholeController.ServerDetails server_details) {
        // If the server details were never persisted, there's nothing to delete
        if (server_details.id == -1) {
            return;
        }
        servers.remove (server_details);
        database.delete_server (server_details);
        remove_api_token (server_details);
    }

    private void store_api_token (PiholeController.ServerDetails server_details) {
        var attributes = build_secret_attributes (server_details.id);
        var label = build_secret_label (server_details.id);
        Secret.password_storev.begin (secret_schema, attributes, null, label, server_details.api_token, null, (obj, res) => {
            try {
                if (Secret.password_storev.end (res)) {
                    debug ("Stored secret: %s", label);
                } else {
                    warning ("Failed to store secret: %s", label);
                }
            } catch (GLib.Error e) {
                warning ("Error while storing secret %s: %s", label, e.message);
            }
        });
    }

    private void lookup_api_token (PiholeController.ServerDetails server_details) {
        Secret.password_lookupv.begin (secret_schema, build_secret_attributes (server_details.id), null, (obj, res) => {
            var label = build_secret_label (server_details.id);
            string? secret = null;
            try {
                secret = Secret.password_lookupv.end (res);
            } catch (GLib.Error e) {
                warning ("Error while looking up secret (%s): %s", label, e.message);
            }
            if (secret == null) {
                warning ("Failed to load secret: %s", label);
            } else {
                debug ("Loaded secret for %s", label);
                server_details.api_token = secret;
            }
        });
    }

    private void remove_api_token (PiholeController.ServerDetails server_details) {
        var label = build_secret_label (server_details.id);
        var attributes = build_secret_attributes (server_details.id);
        Secret.password_clearv.begin (secret_schema, attributes, null, (obj, res) => {
            try {
                if (Secret.password_clearv.end (res)) {
                    debug ("Cleared secret: %s", label);
                } else {
                    warning ("Failed to clear secret: %s", label);
                }
            } catch (GLib.Error e) {
                warning ("Error while clearing secret %s: %s", label, e.message);
            }
        });
    }

    private GLib.HashTable<string, string> build_secret_attributes (int64 id) {
        var attributes = new GLib.HashTable<string, string> (str_hash, str_equal);
        attributes.insert ("version", SECRET_SCHEMA_VERSION);
        attributes.insert ("database_id", id.to_string ());
        return attributes;
    }

    private string build_secret_label (int64 id) {
        return APP_ID + ":" + id.to_string ();
    }

}