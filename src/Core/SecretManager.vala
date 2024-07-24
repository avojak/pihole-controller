/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.SecretManager : GLib.Object {

    private static GLib.Once<PiholeController.Core.SecretManager> instance;
    public static unowned PiholeController.Core.SecretManager get_instance () {
        return instance.once (() => { return new PiholeController.Core.SecretManager (); });
    }

    private const string SCHEMA_VERSION = "1";

    private static Secret.Schema schema = new Secret.Schema (
        APP_ID,
        Secret.SchemaFlags.NONE,
        "version", Secret.SchemaAttributeType.STRING, // Versioning number for the schema, NOT the application
        "database_id", Secret.SchemaAttributeType.INTEGER
    );

    private SecretManager () {
    }

    public void store_secret (int id, string secret) throws GLib.Error {
        debug ("Storing secret for id: %s", id.to_string ());
        var attributes = new GLib.HashTable<string, string> (str_hash, str_equal);
        attributes.insert ("version", SCHEMA_VERSION);
        attributes.insert ("database_id", id.to_string ());
        var label = APP_ID + ":" + id.to_string ();
        Secret.password_storev.begin (schema, attributes, null, label, secret, null, (obj, async_res) => {
            try {
                if (Secret.password_store.end (async_res)) {
                    debug ("Stored secret: %s", label);
                } else {
                    // TODO: Handle this better
                    warning ("Failed to store secret: %s", label);
                }
            } catch (GLib.Error e) {
                warning ("Error while storing password: %s", e.message);
            }
        });
    }

}