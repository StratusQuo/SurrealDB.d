import std.stdio;
import std.string;
import core.stdc.stdlib;
import core.stdc.string;
import surrealdb;

void main() {
    SrString err;
    SrSurreal* db;
    
    // Connect to database
    writeln("Connecting to database...");
    auto endpoint = "mem://\0".ptr;
    if (sr_connect(&err, &db, endpoint) < 0) {
        if (err.length > 0) {
            writefln("Connection error: %s", cast(string)err);
            sr_free_string(err);
        }
        return;
    }
    scope(exit) sr_surreal_disconnect(db);

    // Use namespace and database
    auto ns = "test\0".ptr;
    if (sr_use_ns(db, &err, ns) < 0) {
        writefln("Namespace error: %s", cast(string)err);
        sr_free_string(err);
        return;
    }

    auto dbname = "test\0".ptr;
    if (sr_use_db(db, &err, dbname) < 0) {
        writefln("Database error: %s", cast(string)err);
        sr_free_string(err);
        return;
    }

    // Create a person record
    SrObject content = sr_object_new();
    scope(exit) sr_free_object(content);

    auto name_key = "name\0".ptr;
    auto name_val = "John Doe\0".ptr;
    sr_object_insert_str(&content, name_key, name_val);

    auto age_key = "age\0".ptr;
    sr_object_insert_int(&content, age_key, 30);

    auto email_key = "email\0".ptr;
    auto email_val = "john@example.com\0".ptr;
    sr_object_insert_str(&content, email_key, email_val);

    // Create the record
    SrObject* created;
    auto resource = "person\0".ptr;
    if (sr_create(db, &err, &created, resource, &content) < 0) {
        writefln("Create error: %s", cast(string)err);
        sr_free_string(err);
        return;
    }

    if (created !is null) {
        auto id_key = "id\0".ptr;
        const(SrValue)* id = sr_object_get(created, id_key);
        if (id !is null) {
            writeln("Created record with ID:");
            sr_value_print(id);
        }
        sr_free_object(*created);
    }

    // Query all persons
    SrObject vars = sr_object_new();
    scope(exit) sr_free_object(vars);

    SrArrRes* results;
    auto query = "SELECT * FROM person;\0".ptr;
    if (sr_query(db, &err, &results, query, &vars) < 0) {
        writefln("Query error: %s", cast(string)err);
        sr_free_string(err);
        return;
    }

    if (results !is null) {
        writeln("\nQuery results:");
        foreach (i; 0..results.ok.len) {
            sr_value_print(&results.ok.arr[i]);
        }
        sr_free_arr_res_arr(results, 1);
    }

    writeln("\nCompleted successfully!");
}