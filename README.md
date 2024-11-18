<br>

<p align="center">
    <img width=120 src="https://raw.githubusercontent.com/surrealdb/icons/main/surreal.svg" />
    &nbsp;
    <img width=120 src="https://sqimages.nyc3.digitaloceanspaces.com/D.png" />
</p>


<h3 align="center">An unofficial SurrealDB SDK for D</h3>

<br>

# SurrealDB.D

D programming language bindings for [SurrealDB](https://surrealdb.com) -- based on the [official C bindings](https://github.com/surrealdb/surrealdb.c).

## Prerequisites

- D compiler ( Either DMD or LDC -- GDC has not yet been tested)
- DUB package manager
- Rust toolchain _(for building SurrealDB)_
- Cargo

## Building

Run:

```bash
dub build
```

In the project's root directory. Dub will automatically build the SurrealDB Rust library during the D build process.


## Example Usage

```d
import std.stdio;
import surrealdb;

void main() {
    SrString err;
    SrSurreal* db;
    
    // Connect to database
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
    if (sr_use_ns(db, &err, "test\0".ptr) < 0) {
        writefln("Namespace error: %s", cast(string)err);
        sr_free_string(err);
        return;
    }

    if (sr_use_db(db, &err, "test\0".ptr) < 0) {
        writefln("Database error: %s", cast(string)err);
        sr_free_string(err);
        return;
    }

    // Create a record
    SrObject content = sr_object_new();
    scope(exit) sr_free_object(content);

    sr_object_insert_str(&content, "name\0".ptr, "John Doe\0".ptr);
    sr_object_insert_int(&content, "age\0".ptr, 30);
    sr_object_insert_str(&content, "email\0".ptr, "john@example.com\0".ptr);

    // Save the record
    SrObject* created;
    if (sr_create(db, &err, &created, "person\0".ptr, &content) < 0) {
        writefln("Create error: %s", cast(string)err);
        sr_free_string(err);
        return;
    }

    if (created !is null) {
        const(SrValue)* id = sr_object_get(created, "id\0".ptr);
        if (id !is null) {
            writeln("Created record with ID:");
            sr_value_print(id);
        }
        sr_free_object(*created);
    }
}
```

## Running the Example

After building the library, run the following to see the example in action:

```bash
dub run -c example
```

## Features

- Full SurrealDB API support
- Memory-safe bindings with scope-based cleanup
- Support for all SurrealDB data types
- Query execution and result handling
- Live query capabilities
- Transaction support
- Error handling

## API Documentation

### Connection Management
- `sr_connect` - Connect to a SurrealDB instance
- `sr_surreal_disconnect` - Disconnect from database
- `sr_use_ns` - Select a namespace
- `sr_use_db` - Select a database

### Data Operations
- `sr_create` - Create a new record
- `sr_query` - Execute a SurrealQL query
- `sr_select` - Select records
- `sr_select_live` - Set up live query

### Memory Management
- `sr_free_string` - Free string resources
- `sr_free_object` - Free object resources
- `sr_free_arr` - Free array resources
- `sr_free_arr_res_arr` - Free array result resources

## Configurations

The package provides two configurations:

1. `library` (default) - Builds as a library for use in other projects
2. `example` - Builds and runs the example application

## Project Structure

```
surrealdb/
├── source/
│   ├── app.d                 # Example application
│   ├── bindings/
│   │   └── surrealdb.d      # D bindings
│   └── surrealdb/           # Rust source
└── dub.json                 # Project configuration
```

## License

BSL 1.1

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Notes

- All strings passed to C functions _must_ be null-terminated -- or you're gonna have a bad time.
- Memory management should use `scope(exit)` for cleanup
- Error handling should check both return values and error strings
