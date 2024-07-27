/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

public enum PiholeController.ServerStatus {

    ENABLED,
    DISABLED;

    public static ServerStatus from_string (string str) {
        switch (str) {
            case "enabled":
                return ENABLED;
            case "disabled":
                return DISABLED;
            default:
                assert_not_reached ();
        }
    }

    public string get_display_string () {
        switch (this) {
            case ENABLED:
                return "Enabled";
            case DISABLED:
                return "Disabled";
            default:
                assert_not_reached ();
        }
    }

}