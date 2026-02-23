# phpmydump-explorer
Explore and extract data from phpMyAdmin SQL dumps using streaming parsing and insert indexing without loading the entire file into memory.

## Screenshots

### Table explorer
![Explorer](docs/screenshots/screenshot01.png)

### Table selection
![Selection](docs/screenshots/screenshot02.png)

### Export result
![Export](docs/screenshots/screenshot03.png)

## Usage

Load a SQL dump by passing the database file as a GET parameter:

```text
http://localhost/phpmydump-explorer/?db=backup.sql
```

The `db` parameter indicates the SQL dump file to parse.

> Note: This is a temporary interface and may change in future versions.
