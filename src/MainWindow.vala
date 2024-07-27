/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.MainWindow : Adw.ApplicationWindow {

    private Gtk.Stack base_stack;

    private PiholeController.HomeView home_view;
    //  private PiholeController.StatisticsView statistics_view;

    private Adw.NavigationView navigation_view;

    private Adw.ViewSwitcher view_switcher;
    private Adw.ViewSwitcherBar view_switcher_bar;
    private Adw.ViewStack view_stack;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            title: APP_NAME,
            width_request: 200,
            height_request: 360
        );
    }

    construct {
        if (APP_ID.has_suffix ("Devel")) {
            add_css_class ("devel");
        }

        var app_menu = new GLib.Menu ();
        app_menu.append (_("Preferences"), "app.preferences");
        app_menu.append (_("About %s").printf (APP_NAME), "app.about");

        var menu = new GLib.Menu ();
        menu.append_section (null, app_menu);

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            menu_model = menu,
            tooltip_text = _("Menu")
        };

        var import_button = new Gtk.Button () {
            icon_name = "list-add-symbolic",
            tooltip_text = _("Import"),
            action_name = "app.import"
        };

        //  library_view = new PiholeController.LibraryView ();
        //  library_view.game_selected.connect (on_game_selected);

        home_view = new PiholeController.HomeView ();

        view_stack = new Adw.ViewStack ();
        view_stack.add_titled_with_icon (home_view, "home", _("Home"), "go-home-symbolic");
        //  view_stack.add_titled_with_icon (library_view, "library", _("Library"), "library-symbolic");

        view_switcher_bar = new Adw.ViewSwitcherBar () {
            stack = view_stack
        };
        view_switcher = new Adw.ViewSwitcher () {
            stack = view_stack,
            policy = Adw.ViewSwitcherPolicy.WIDE
        };

        var header_bar = new Adw.HeaderBar () {
            title_widget = view_switcher
        };
        header_bar.pack_start (import_button);
        header_bar.pack_end (menu_button);

        var toolbar_view = new Adw.ToolbarView () {
            content = view_stack
        };
        toolbar_view.add_top_bar (header_bar);
        toolbar_view.add_bottom_bar (view_switcher_bar);

        var breakpoint = new Adw.Breakpoint (Adw.BreakpointCondition.parse ("max-width: 550sp"));
        var switcher_bar_type = GLib.Value (typeof (bool));
        switcher_bar_type.set_boolean (true);
        breakpoint.add_setter (view_switcher_bar, "reveal", switcher_bar_type);
        var header_bar_type = GLib.Value (typeof (GLib.Object));
        breakpoint.add_setter (header_bar, "title-widget", header_bar_type);

        var welcome_view = new PiholeController.WelcomeView (this);
        //  welcome_view.games_selected.connect (on_games_to_import);
        //  welcome_view.game_directory_selected.connect ((directory) => {
        //      PiholeController.Application.settings.game_directory = directory.get_path ();
        //      base_stack.set_visible_child_name ("view-switcher");

        //      PiholeController.Core.Client.get_instance ().load_library_async.begin ((obj, res) => {
        //          var games = PiholeController.Core.Client.get_instance ().load_library_async.end (res);
        //          set_library_games (games);
        //      });
        //  });

        navigation_view = new Adw.NavigationView ();
        var home_page = new Adw.NavigationPage (toolbar_view, "Home");
        navigation_view.add (home_page);

        base_stack = new Gtk.Stack ();
        //  base_stack.add_named (loading_view, "loading");
        //  //  base_stack.add_named (view_switcher, "view-switcher");
        base_stack.add_named (navigation_view, "view-switcher");
        base_stack.add_named (welcome_view, "welcome");

        set_content (base_stack);
        add_breakpoint (breakpoint);

        set_default_size (PiholeController.Application.settings.window_width, PiholeController.Application.settings.window_height);
        if (PiholeController.Application.settings.window_maximized) {
            maximize ();
        }

        close_request.connect (() => {
            PiholeController.Core.ServerConnectionManager.get_instance ().close_all ();
            save_window_state ();
            return Gdk.EVENT_PROPAGATE;
        });
        notify["maximized"].connect (save_window_state);

        base_stack.set_visible_child_name ("welcome");
        view_stack.set_visible_child_name ("home");

        // Connect to signals
    }

    public void set_servers (Gee.List<PiholeController.ServerConnectionDetails> servers) {
        Idle.add (() => {
            if (servers.size == 0) {
                base_stack.set_visible_child_name ("welcome");
            } else {
                home_view.set_servers (servers);
                base_stack.set_visible_child_name ("view-switcher");
            }
            return false;
        }, GLib.Priority.DEFAULT);
    }

    public void add_server (PiholeController.ServerConnectionDetails connection_details) {
        Idle.add (() => {
            home_view.add_server (connection_details);
            return false;
        }, GLib.Priority.DEFAULT);
    }

    public void on_server_version_received (int64 database_id, PiholeController.ServerVersion server_version) {
        // TODO
    }

    public void on_summary_data_received (int64 database_id, PiholeController.SummaryData summary_data) {
        home_view.on_summary_data_received (database_id, summary_data);
    }

    public void on_top_items_received (int64 database_id, PiholeController.TopItems top_items) {
        home_view.on_top_items_received (database_id, top_items);
    }

    public void on_server_removed (int64 database_id) {
        home_view.remove_server (database_id);
    }

    private void save_window_state () {
        if (maximized) {
            PiholeController.Application.settings.window_maximized = true;
        } else {
            PiholeController.Application.settings.window_maximized = false;
            PiholeController.Application.settings.window_width = get_size (Gtk.Orientation.HORIZONTAL);
            PiholeController.Application.settings.window_height = get_size (Gtk.Orientation.VERTICAL);
        }
    }

}
