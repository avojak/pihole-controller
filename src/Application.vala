/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Application : Adw.Application {

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { "about", on_about_activate },
        { "preferences", on_preferences_activate },
        { "add-server", on_add_server_activate }
    };

    private static GLib.Once<PiholeController.Application> instance;
    public static unowned PiholeController.Application get_instance () {
        return instance.once (() => { return new PiholeController.Application (); });
    }

    public static PiholeController.Core.Settings settings;

    private PiholeController.MainWindow main_window;
    private PiholeController.PreferencesDialog? preferences_dialog;

    static construct {
        settings = new PiholeController.Core.Settings ();
    }

    public Application () {
        Object (
            application_id: APP_ID
        );
    }

    protected override void activate () {
        var client = PiholeController.Core.Client.get_instance ();

        main_window = new PiholeController.MainWindow (this);
        main_window.show ();

        client.load_servers_async.begin ((obj, res) => {
            var servers = client.load_servers_async.end (res);
            foreach (var connection_details in servers) {
                client.connection_manager.open (connection_details);
            }
            main_window.set_servers (servers);
        });

        client.connection_manager.server_version_received.connect (main_window.on_server_version_received);
        client.connection_manager.summary_data_received.connect (main_window.on_summary_data_received);
        client.connection_manager.top_items_received.connect (main_window.on_top_items_received);

        client.server_repository.server_removed.connect (main_window.on_server_removed);
        client.server_repository.server_removed.connect (client.connection_manager.close);
    }

    public override void startup () {
        base.startup ();

        add_action_entries (ACTION_ENTRIES, this);

        set_accels_for_action ("app.preferences", { "<control>comma" });
    }

    private void on_about_activate () {
        var about_window = new Adw.AboutWindow () {
            transient_for = main_window,
            application_icon = APP_ID,
            application_name = APP_NAME,
            developer_name = DEVELOPER_NAME,
            version = VERSION,
            comments = _("Control your Pi-hole servers"),
            website = "https://github.com/avojak/pihole-controller",
            issue_url = "https://github.com/avojak/pihole-controller/issues",
            developers = { "%s <%s>".printf (DEVELOPER_NAME, DEVELOPER_EMAIL) },
            designers = { "%s %s".printf (DEVELOPER_NAME, DEVELOPER_WEBSITE) },
            copyright = "© 2023 %s".printf (DEVELOPER_NAME),
            license_type = Gtk.License.GPL_3_0
        };
        about_window.present ();
    }

    private void on_preferences_activate () {
        preferences_dialog = new PiholeController.PreferencesDialog (main_window);
        preferences_dialog.close_request.connect (() => {
            // Ensure we don't have any lingering handlers for device connection changes
            preferences_dialog.dispose ();
            preferences_dialog = null;
            return true;
        });

        preferences_dialog.server_saved.connect (PiholeController.Core.Client.get_instance ().server_repository.save_server);
        preferences_dialog.server_saved.connect (PiholeController.Core.Client.get_instance ().connection_manager.open);
        preferences_dialog.server_saved.connect (main_window.add_server);
        preferences_dialog.server_removed.connect (PiholeController.Core.Client.get_instance ().server_repository.remove_server);
        preferences_dialog.set_servers (PiholeController.Core.Client.get_instance ().server_repository.get_servers ());
        preferences_dialog.show ();
    }

    private void on_add_server_activate () {
        on_preferences_activate ();
        preferences_dialog.set_visible_page_name ("servers");
    }

    public static int main (string[] args) {
        var app = PiholeController.Application.get_instance ();
        return app.run (args);
    }

}
