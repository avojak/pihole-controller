/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.GeneralPreferencePage : Adw.PreferencesPage {

    public GeneralPreferencePage () {
        Object (
            name: "general",
            title: _("General"),
            icon_name: "preferences-other-symbolic"
        );
    }

    construct {

    }

}