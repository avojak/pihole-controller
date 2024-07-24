/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class PiholeController.Core.SQLClient : GLib.Object {

    public string database_filename { get; construct; }

    protected static GLib.File database_directory = GLib.File.new_build_filename (GLib.Environment.get_user_data_dir (), "database");
    protected Sqlite.Database database;

    protected SQLClient (string database_filename) {
        Object (
            database_filename: database_filename
        );
    }

    construct {
        initialize_database ();
    }

    protected int? get_user_version () {
        var sql = "PRAGMA user_version";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return null;
        }

        if (statement.step () != Sqlite.ROW) {
            return null;
        }
        var num_columns = statement.column_count ();
        int? user_version = null;
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "user_version":
                    user_version = statement.column_int (i);
                    break;
                default:
                    break;
            }
        }
        statement.reset ();
        return user_version;
    }

    protected int bool_to_int (bool val) {
        return val ? 1 : 0;
    }

    protected bool int_to_bool (int val) {
        return val == 1;
    }

    protected void log_database_error (int errcode, string errmsg) {
        warning ("[%s] Database error: %d: %s", database_filename, errcode, errmsg);
    }

    private void initialize_database () {
        try {
            if (!database_directory.query_exists ()) {
                debug ("Database directory does not exist - creating it now");
                database_directory.make_directory_with_parents ();
            }
        } catch (GLib.Error e) {
            // TODO: Show an error message that we cannot proceed
            critical ("Error creating database directory: %s", e.message);
            return;
        }
        var db_file = GLib.File.new_build_filename (database_directory.get_path (), database_filename);
        if (Sqlite.Database.open_v2 (db_file.get_path (), out database) != Sqlite.OK) {
            // TODO: Show error message that we cannot proceed
            critical ("[%s] Can't open database: %d: %s", database_filename, database.errcode (), database.errmsg ());
            return;
        }

        initialize_tables ();
    }

    private void initialize_tables () {
        database.exec (get_create_tables_sql ());
        do_upgrades ();
    }

    private void do_upgrades () {
        int? user_version = get_user_version ();
        if (user_version == null) {
            warning ("[%s] Null user_version, skipping upgrades", database_filename);
            return;
        }
        if (user_version == 0) {
            debug ("[%s] SQLite user_version: %d, no upgrades to perform", database_filename, user_version);
        }
    }


    //  protected void set_user_version (int user_version) {
    //      var sql = @"PRAGMA user_version = $user_version";
    //      Sqlite.Statement statement;
    //      if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
    //          log_database_error (database.errcode (), database.errmsg ());
    //          return;
    //      }
    //      string err_msg;
    //      int ec = database.exec (statement.expanded_sql (), null, out err_msg);
    //      if (ec != Sqlite.OK) {
    //          log_database_error (ec, err_msg);
    //          debug ("SQL statement: %s", statement.expanded_sql ());
    //      }
    //      statement.reset ();
    //  }

    protected abstract string get_create_tables_sql ();


}