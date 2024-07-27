/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.ServerVersion : GLib.Object {

    public bool core_update { get; set; }
    public bool web_update { get; set; }
    public bool FTL_update { get; set; }
    public bool docker_update { get; set; }
    public string core_current { get; set; }
    public string web_current { get; set; }
    public string FTL_current { get; set; }
    public string docker_current { get; set; }
    public string core_latest { get; set; }
    public string web_latest { get; set; }
    public string FTL_latest { get; set; }
    public string docker_latest { get; set; }
    public string core_branch { get; set; }
    public string web_branch { get; set; }
    public string FTL_branch { get; set; }

    public string to_string () {
        var sb = new GLib.StringBuilder ();
        sb.append_printf ("core_update = %s\n", core_update.to_string ());
        sb.append_printf ("web_update = %s\n", web_update.to_string ());
        sb.append_printf ("FTL_update = %s\n", FTL_update.to_string ());
        sb.append_printf ("docker_update = %s\n", docker_update.to_string ());
        sb.append_printf ("core_current = %s\n", core_current);
        sb.append_printf ("web_current = %s\n", web_current);
        sb.append_printf ("FTL_current = %s\n", FTL_current);
        sb.append_printf ("docker_current = %s\n", docker_current);
        sb.append_printf ("core_latest = %s\n", core_latest);
        sb.append_printf ("web_latest = %s\n", web_latest);
        sb.append_printf ("FTL_latest = %s\n", FTL_latest);
        sb.append_printf ("docker_latest = %s\n", docker_latest);
        sb.append_printf ("core_branch = %s\n", core_branch);
        sb.append_printf ("web_branch = %s\n", web_branch);
        sb.append_printf ("FTL_branch = %s\n", FTL_branch);
        return sb.str;
    }
}