/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.WelcomeView : Adw.Bin {

    public unowned PiholeController.MainWindow main_window { get; construct; }

    public WelcomeView (PiholeController.MainWindow main_window) {
        Object (
            main_window: main_window
        );
    }

    construct {
        var header_bar = new Adw.HeaderBar ();

        var import_button = new Gtk.Button.with_label (_("Add a Server")) {
            halign = Gtk.Align.CENTER,
            action_name = "app.add-server"
        };
        import_button.add_css_class ("pill");
        import_button.add_css_class ("suggested-action");

        var import_spinner = new Gtk.Spinner ();

        var import_grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 16);
        import_grid.append (import_button);
        import_grid.append (import_spinner);

        var status_page = new Adw.StatusPage () {
            title = _("No Pi-hole Servers"),
            //  description = _("Add a Pi-hole server to control"),
            icon_name = "shield-warning-symbolic",
            child = import_grid
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = status_page
        };
        toolbar_view.add_top_bar (header_bar);

        child = toolbar_view;        
    }

}