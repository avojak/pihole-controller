/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.StatisticTile : Adw.Bin {

    public string title { get; construct; }
    public string style_class { get; construct; }
    public string icon_name { get; construct; }

    private Gtk.Label value_label;

    public StatisticTile (string title, string style_class, string icon_name) {
        Object (
            title: title,
            style_class: style_class,
            icon_name: icon_name
        );
    }

    construct {
        add_css_class ("card");
        add_css_class ("statistics-card");
        add_css_class (style_class);

        var icon = new Gtk.Image.from_icon_name (icon_name) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.FILL,
            icon_size = Gtk.IconSize.LARGE,
            opacity = 0.5,
            margin_start = 16
        };

        var title_label = new Gtk.Label (title);
        title_label.add_css_class ("heading");

        value_label = new Gtk.Label ("--");
        value_label.add_css_class ("title-1");

        var grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            vexpand = true,
            margin_top = 16,
            margin_bottom = 16,
            margin_start = 16,
            margin_end = 16
        };
        grid.attach (title_label, 0, 0, 1, 1);
        grid.attach (value_label, 0, 1, 1, 1);
        grid.attach (icon, 1, 0, 1, 2);

        //  var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8) {
        //      hexpand = true,
        //      vexpand = true,
        //      margin_top = 8,
        //      margin_bottom = 8
        //  };
        //  box.append (title_label);
        //  box.append (value_label);

        //  var overlay = new Gtk.Overlay () {
        //      hexpand = true,
        //      vexpand = true,
        //      child = icon
        //  };
        //  overlay.add_overlay (box);

        child = grid;
    }

    public void set_value (string value) {
        value_label.set_text (value);
    }

}