# Zig HTTP Server

A simple HTTP server implementation written in Zig programming language.

## Features

- Basic HTTP/1.1 server
- Multiple endpoints with different content types
- JSON API responses
- HTML pages
- 404 error handling
- Method validation

## Prerequisites

- Zig compiler (version 0.11.0 or later)
- Windows, macOS, or Linux

## Building and Running

### Build the server
```bash
zig build
```

### Run the server
```bash
zig build run
```

Alternatively, you can run directly:
```bash
zig run server.zig
```

### Run tests
```bash
zig build test
```

## Usage

Once the server is running, it will listen on `http://localhost:8080`. You can access the following endpoints:

- **GET /** - Home page with navigation links
- **GET /hello** - Simple text response
- **GET /api/status** - JSON status response
- **GET /time** - Current Unix timestamp

## Example Requests

### Home Page
```bash
curl http://localhost:8080/
```

### Hello Endpoint
```bash
curl http://localhost:8080/hello
```

### API Status
```bash
curl http://localhost:8080/api/status
```

### Current Time
```bash
curl http://localhost:8080/time
```

## Project Structure

```
zig-http-server/
├── server.zig      # Main HTTP server implementation
├── build.zig       # Zig build configuration
└── README.md       # Project documentation
```

## Server Implementation Details

The server includes:

- **HttpServer struct**: Main server implementation
- **Connection handling**: Accepts and processes HTTP connections
- **Request parsing**: Parses HTTP request method and path
- **Routing**: Routes requests to appropriate handlers
- **Response generation**: Sends proper HTTP responses with headers
- **Error handling**: Graceful error handling for connections

## Stopping the Server

To stop the server, press `Ctrl+C` in the terminal.

## License

This project is open source and available under the MIT License.