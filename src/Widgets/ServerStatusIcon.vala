/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.ServerStatusIcon : Adw.Bin {

    private Gtk.Stack stack;

    public ServerStatusIcon () {
        Object (
            halign: Gtk.Align.CENTER
        );
    }

    construct {
        var safe_icon = new Gtk.Image.from_icon_name ("shield-safe-symbolic");
        safe_icon.add_css_class ("success");
        var warning_icon = new Gtk.Image.from_icon_name ("shield-warning-symbolic");
        warning_icon.add_css_class ("warning");
        var danger_icon = new Gtk.Image.from_icon_name ("shield-danger-symbolic");
        danger_icon.add_css_class ("error");

        stack = new Gtk.Stack ();
        stack.add_named (safe_icon, "safe");
        stack.add_named (warning_icon, "warning");
        stack.add_named (danger_icon, "danger");

        stack.set_visible_child_name ("warning");

        set_child (stack);
    }

    public void show_safe () {
        stack.set_visible_child_name ("safe");
    }

    public void show_warning () {
        stack.set_visible_child_name ("warning");
    }

    public void show_danger () {
        stack.set_visible_child_name ("danger");
    }

}