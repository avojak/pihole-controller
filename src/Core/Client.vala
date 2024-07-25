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

    private Client () {
    }

    construct {
        server_repository = new PiholeController.Core.ServerRepository (PiholeController.Core.ServerDatabase.get_instance ());
    }

}