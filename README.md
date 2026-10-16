# Todo App

A simple todo-list application built with Node.js and Express. It serves a browser-based interface and exposes a REST API for managing todo items.

## Requirements

- Node.js and npm

## Run locally

```sh
npm install
npm run dev
```

The app listens on port `3000`. By default, it uses SQLite and stores its database at `/etc/todos/todo.db`. Set `SQLITE_DB_LOCATION` to use a different database file.

## API

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/items` | List todo items |
| `POST` | `/items` | Add a todo item |
| `PUT` | `/items/:id` | Update a todo item |
| `DELETE` | `/items/:id` | Delete a todo item |

## Docker

Build and run the application:

```sh
docker build -t todo-app .
docker run --rm -p 3000:3000 -v todo-data:/data todo-app
```

The named volume preserves the SQLite database between container runs. Open
`http://localhost:3000` to use the application.
