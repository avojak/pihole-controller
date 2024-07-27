/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.Settings : GLib.Settings {

    public Settings () {
        Object (schema_id: APP_ID);
    }

    public bool window_maximized {
        get { return get_boolean ("window-maximized"); }
        set { set_boolean ("window-maximized", value); }
    }

    public int window_width {
        get { return get_int ("window-width"); }
        set { set_int ("window-width", value); }
    }

    public int window_height {
        get { return get_int ("window-height"); }
        set { set_int ("window-height", value); }
    }

    //  public bool auto_refresh {
    //      get { return get_boolean ("auto-refresh"); }
    //      set { set_boolean ("auto-refresh", value); }
    //  }

    //  public int top_domains {
    //      get { return get_int ("top-domains"); }
    //      set { set_int ("top-domains", value); }
    //  }

    //  public int top_clients {
    //      get { return get_int ("top-clients"); }
    //      set { set_int ("top-clients", value); }
    //  }

    //  public int top_blocked_clients {
    //      get { return get_int ("top-blocked-clients"); }
    //      set { set_int ("top-blocked-clients", value); }
    //  }

}
