/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.ServerPreferenceGroup : Adw.PreferencesGroup {

    public unowned PiholeController.ServerDetails details { get; construct; }
    public bool expanded { get; set; }

    private Adw.EntryRow name_row;
    private Adw.EntryRow address_row;
    private Adw.SwitchRow https_row;
    private Adw.PasswordEntryRow api_token_row;

    private string? saved_name = null;
    private string? saved_address = null;
    private bool? saved_use_https = null;
    private string? saved_api_token = null;

    private Gtk.Button save_button;

    public ServerPreferenceGroup.from_details (PiholeController.ServerDetails details, bool expanded = false) {
        Object (
            margin_bottom: 12,
            details: details,
            expanded: expanded
        );
    }

    private ServerPreferenceGroup () {
    }

    construct {
        saved_name = details.name;
        saved_address = details.address;
        saved_use_https = details.use_https;
        saved_api_token = details.api_token;

        name_row = new Adw.EntryRow () {
            title = _("Server Name")
        };
        address_row = new Adw.EntryRow () {
            title = _("IP Address or Hostname")
        };
        https_row = new Adw.SwitchRow () {
            title = _("Use HTTPS")
        };
        api_token_row = new Adw.PasswordEntryRow () {
            title = _("API Token")
        };

        save_button = new Gtk.Button () {
            child = new Adw.ButtonContent () {
                label = _("Save"),
                icon_name = "document-save-symbolic"
            },
            tooltip_text = _("Save Server"),
            sensitive = false
        };
        save_button.add_css_class ("suggested-action");

        var delete_button = new Gtk.Button () {
            child = new Adw.ButtonContent () {
                label = _("Remove"),
                icon_name = "user-trash-symbolic"
            },
            tooltip_text = _("Remove Server")
        };
        delete_button.add_css_class ("destructive-action");

        var control_buttons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8) {
            homogeneous = true,
            margin_bottom = 8,
            margin_top = 8,
            margin_start = 8,
            margin_end = 8
        };
        control_buttons.append (delete_button);
        control_buttons.append (save_button);

        var status_icon = new PiholeController.ServerStatusIcon ();

        var row = new Adw.ExpanderRow () {
            expanded = expanded
        };
        row.add_prefix (status_icon);
        row.add_row (name_row);
        row.add_row (address_row);
        row.add_row (https_row);
        row.add_row (api_token_row);
        row.add_row (control_buttons);

        // Update the expander row when one of the properties changes
        name_row.bind_property ("text", row, "title", GLib.BindingFlags.DEFAULT);
        address_row.bind_property ("text", row, "subtitle", GLib.BindingFlags.DEFAULT);

        name_row.bind_property ("text", details, "name", GLib.BindingFlags.DEFAULT);
        address_row.bind_property ("text", details, "address", GLib.BindingFlags.DEFAULT);
        https_row.bind_property ("active", details, "use_https", GLib.BindingFlags.DEFAULT);
        api_token_row.bind_property ("text", details, "api_token", GLib.BindingFlags.DEFAULT);
        //  port_row.bind_property ("text", details, "port", GLib.BindingFlags.DEFAULT);

        bind_property ("expanded", row, "expanded", GLib.BindingFlags.BIDIRECTIONAL);

        // Validation handlers
        name_row.changed.connect (validate_entries);
        address_row.changed.connect (validate_entries);
        https_row.notify["active"].connect (validate_entries);
        api_token_row.changed.connect (validate_entries);

        add (row);

        save_button.clicked.connect (() => {
            save_button_clicked ();
            saved_name = details.name;
            saved_address = details.address;
            saved_use_https = details.use_https;
            saved_api_token = details.api_token;
            save_button.sensitive = false;
        });
        delete_button.clicked.connect (() => {
            delete_button_clicked ();
        });

        name_row.set_text (details.name);
        address_row.set_text (details.address);
        https_row.set_active (details.use_https);
        api_token_row.set_text (details.api_token);
        validate_entries ();

        // TODO: Don't want to do this every time we add a group
        //  Idle.add (() => {
        //      address_row.grab_focus ();
        //      return false;
        //  });
    }

    private void validate_entries () {
        var is_valid = true;
        is_valid = validate_not_empty (name_row) && is_valid;
        is_valid = validate_not_empty (address_row) && is_valid;
        is_valid = validate_not_empty (api_token_row) && is_valid;

        var is_changed = false;
        is_changed = is_changed || (name_row.text != saved_name);
        is_changed = is_changed || (address_row.text != saved_address);
        is_changed = is_changed || (https_row.active != saved_use_https);
        is_changed = is_changed || (api_token_row.text != saved_api_token);

        save_button.sensitive = is_valid && is_changed;
    }

    private bool validate_not_empty (Adw.EntryRow row) {
        if (row.text.length == 0) {
            row.add_css_class ("error");
            return false;
        }
        row.remove_css_class ("error");
        return true;
    }

    public signal void delete_button_clicked ();
    public signal void save_button_clicked ();

}