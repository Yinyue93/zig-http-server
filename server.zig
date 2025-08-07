const std = @import("std");
const net = std.net;
const print = std.debug.print;

const index_html = @embedFile("static/index.html");
const not_found = @embedFile("static/404.html");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const address = try net.Address.parseIp("127.0.0.1", 8080);
    var server = try address.listen(.{});
    defer server.deinit();

    print("HTTP Server listening on http://127.0.0.1:8080\n", .{});
    print("Press Ctrl+C to stop the server\n", .{});

    while (true) {
        const conn = server.accept() catch |err| {
            print("Failed to accept connection: {}\n", .{err});
            continue;
        };
        handleConn(allocator, conn) catch |err| {
            print("Error handling connection: {}\n", .{err});
        };
    }
}

fn handleConn(alloc: std.mem.Allocator, conn: net.Server.Connection) !void {
    defer conn.stream.close();

    var buf: [4096]u8 = undefined;
    const n = conn.stream.read(&buf) catch |err| {
        print("Read error: {}\n", .{err});
        return;
    };
    if (n == 0) return;

    var lines = std.mem.splitSequence(u8, buf[0..n], "\r\n");
    const req_line = lines.next() orelse {
        try send(alloc, conn.stream,
            "400 Bad Request", "text/plain; charset=utf-8", "Bad Request");
        return;
    };

    var parts = std.mem.splitSequence(u8, req_line, " ");
    const method = parts.next() orelse return;
    const path = parts.next() orelse return;

    try route(alloc, conn.stream, method, path);
}

fn route(
    alloc: std.mem.Allocator,
    s: net.Stream,
    method: []const u8,
    path: []const u8,
) !void {
    if (!std.mem.eql(u8, method, "GET")) {
        try send(alloc, s, "405 Method Not Allowed",
                 "text/plain; charset=utf-8",
                 "Only GET requests are supported.");
        return;
    }

    if (std.mem.eql(u8, path, "/")) {
        try send(alloc, s, "200 OK", "text/html; charset=utf-8", index_html);

    } else if (std.mem.eql(u8, path, "/hello")) {
        try send(alloc, s, "200 OK", "text/plain; charset=utf-8",
                 "Hello from Zig HTTP Server! 👋");

    } else if (std.mem.eql(u8, path, "/api/status")) {
        const json =
\\{
\\  "status": "ok",
\\  "server": "Zig HTTP Server",
\\  "version": "1.0.0",
\\  "language": "Zig",
\\  "uptime": "running"
\\}
        ;
        try send(alloc, s, "200 OK", "application/json; charset=utf-8", json);

    } else if (std.mem.eql(u8, path, "/time")) {
        const ts = std.time.timestamp();
        var tmp: [128]u8 = undefined;
        const txt = try std.fmt.bufPrint(&tmp,
            "Current Unix timestamp: {}\nDate: {}", .{ ts, ts });
        try send(alloc, s, "200 OK", "text/plain; charset=utf-8", txt);

    } else if (std.mem.eql(u8, path, "/info")) {
        const info =
\\Zig HTTP Server Information
\\===========================
\\Server: Zig HTTP Server
\\Language: Zig
\\Port: 8080
\\Host: 127.0.0.1
\\
\\Features:
\\- HTTP/1.1 support
\\- Multiple content types
\\- JSON API responses
\\- Static HTML pages
\\- Error handling
\\
\\Built with Zig for performance and safety! ⚡
        ;
        try send(alloc, s, "200 OK", "text/plain; charset=utf-8", info);

    } else {
        try send(alloc, s, "404 Not Found",
                 "text/html; charset=utf-8", not_found);
    }
}

fn send(
    alloc: std.mem.Allocator,
    s: net.Stream,
    status: []const u8,
    ctype: []const u8,
    body: []const u8,
) !void {
    const hdr = try std.fmt.allocPrint(alloc,
        "HTTP/1.1 {s}\r\n" ++
        "Content-Type: {s}\r\n" ++
        "Content-Length: {}\r\n" ++
        "Connection: close\r\n" ++
        "Server: Zig-HTTP-Server/1.0\r\n" ++
        "\r\n",
        .{ status, ctype, body.len });
    defer alloc.free(hdr);

    try s.writeAll(hdr);
    try s.writeAll(body);
    print("Sent response: {s}\n", .{ status });
}
