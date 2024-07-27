/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.Client : GLib.Object {

    private static GLib.Once<PiholeController.Core.Client> instance;
    public static unowned PiholeController.Core.Client get_instance () {
        return instance.once (() => { return new PiholeController.Core.Client (); });
    }

    public PiholeController.Core.ServerRepository server_repository { get; construct; }
    public PiholeController.Core.ServerConnectionManager connection_manager { get; construct; }

    private Client () {
    }

    construct {
        server_repository = new PiholeController.Core.ServerRepository (PiholeController.Core.ServerDatabase.get_instance ());
        connection_manager = PiholeController.Core.ServerConnectionManager.get_instance ();
    }

    public async Gee.List<PiholeController.ServerConnectionDetails> load_servers_async () {
        GLib.SourceFunc callback = load_servers_async.callback;
        Gee.List<PiholeController.ServerConnectionDetails> result = new Gee.ArrayList<PiholeController.ServerConnectionDetails> ();

        new GLib.Thread<bool> ("scan-cores", () => {
            result = server_repository.get_servers ();
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        return result;
    }

}