const std = @import("std");
const qt6 = @import("libqt6zig");
const QGuiApplication = qt6.QGuiApplication;
const QQmlApplicationEngine = qt6.QQmlApplicationEngine;
const QUrl = qt6.QUrl;

pub fn main(init: std.process.Init) !void {
    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QGuiApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    const engine = QQmlApplicationEngine.new();
    defer engine.delete();

    engine.onObjectCreationFailed(onFailed);
    engine.load2("src/libraries/qml/helloworld/main.qml");

    _ = QGuiApplication.exec();
}

fn onFailed(_: QQmlApplicationEngine, _: QUrl) callconv(.c) void {
    std.log.err("Failed to create QML object", .{});
    QGuiApplication.quit();
    std.process.exit(1);
}
