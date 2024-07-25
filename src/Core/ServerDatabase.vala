/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class PiholeController.Core.ServerDatabase : PiholeController.Core.SQLClient {

    private static GLib.Once<PiholeController.Core.ServerDatabase> instance;
    public static unowned PiholeController.Core.ServerDatabase get_instance () {
        return instance.once (() => { return new PiholeController.Core.ServerDatabase (); });
    }

    private ServerDatabase () {
        Object (
            database_filename: "pihole-controller.db"
        );
    }

    public void insert_server (PiholeController.ServerDetails server_details) {
        var sql = """
            INSERT INTO servers (name, address, port, use_https) 
            VALUES ($NAME, $ADDRESS, $PORT, $USE_HTTPS);
            """;

        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }

        statement.bind_text (1, server_details.name);
        statement.bind_text (2, server_details.address);
        statement.bind_int (3, server_details.port);
        statement.bind_int (4, bool_to_int (server_details.use_https));

        string err_msg;
        int ec = database.exec (statement.expanded_sql (), null, out err_msg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, err_msg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        } else {
            server_details.id = database.last_insert_rowid ();
        }
        statement.reset ();
    }

    public void update_server (PiholeController.ServerDetails server_details) {
        var sql = """
            UPDATE servers
            SET name = $NAME, address = $ADDRESS, port = $PORT, use_https = $USE_HTTPS
            WHERE id = $ID;
            """;

        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }
        statement.bind_text (1, server_details.name);
        statement.bind_text (2, server_details.address);
        statement.bind_int (3, server_details.port);
        statement.bind_int (4, bool_to_int (server_details.use_https));
        statement.bind_int64 (5, server_details.id);

        string err_msg;
        int ec = database.exec (statement.expanded_sql (), null, out err_msg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, err_msg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    public Gee.List<PiholeController.ServerDetails> get_servers () {
        var servers = new Gee.ArrayList<PiholeController.ServerDetails> ();

        var sql = "SELECT * FROM servers;";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return servers;
        }

        while (statement.step () == Sqlite.ROW) {
            servers.add (parse_server_row (statement));
        }
        statement.reset ();

        return servers;
    }

    public void delete_server (PiholeController.ServerDetails server_details) {
        var sql = "DELETE FROM servers WHERE id=$ID;";

        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }

        statement.bind_int64 (1, server_details.id);

        string err_msg;
        int ec = database.exec (statement.expanded_sql (), null, out err_msg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, err_msg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    private PiholeController.ServerDetails parse_server_row (Sqlite.Statement statement) {
        var num_columns = statement.column_count ();
        var server_details = new PiholeController.ServerDetails ();
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "id":
                    server_details.id = statement.column_int64 (i);
                    break;
                case "name":
                    server_details.name = statement.column_text (i);
                    break;
                case "address":
                    server_details.address = statement.column_text (i);
                    break;
                case "port":
                    server_details.port = statement.column_int (i);
                    break;
                case "use_https":
                    server_details.use_https = int_to_bool (statement.column_int (i));
                    break;
                default:
                    break;
            }
        }
        return server_details;
    }

    public override string get_create_tables_sql () {
        return """
        CREATE TABLE IF NOT EXISTS "servers" (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "name" TEXT NOT NULL,
            "address" TEXT NOT NULL,
            "port" INTEGER NOT NULL,
            "use_https" BOOL NOT NULL
        );
        """;
    }

}