const std = @import("std");
const qt6 = @import("libqt6zig");
const QGuiApplication = qt6.QGuiApplication;
const QQmlApplicationEngine = qt6.QQmlApplicationEngine;
const QUrl = qt6.QUrl;
const qtenvironmentvariables = qt6.qtenvironmentvariables;

// extern "c" fn setenv(name: [*:0]const u8, value: [*:0]const u8, replace: c_int) c_int;

pub fn main(init: std.process.Init) !void {
    if (init.environ_map.get("QT_IM_MODULE") == null) {
        // does not work, global Zig env is *always* read-only
        // try init.environ_map.put("QT_IM_MODULE", "qtvirtualkeyboard");
        // uncomment to use setenv instead (where supported)
        // _ = setenv("QT_IM_MODULE", "qtvirtualkeyboard", 1);
        _ = qtenvironmentvariables.qputenv("QT_IM_MODULE", "qtvirtualkeyboard");
    }

    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QGuiApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    const engine = QQmlApplicationEngine.new();
    defer engine.delete();

    engine.onQuit(onQuit);
    engine.onObjectCreationFailed(onFailed);

    engine.load2("src/libraries/restricted-extras/virtualkeyboard/main.qml");

    _ = QGuiApplication.exec();
}

fn onQuit(_: QQmlApplicationEngine) callconv(.c) void {
    QGuiApplication.quit();
}

fn onFailed(_: QQmlApplicationEngine, _: QUrl) callconv(.c) void {
    std.log.err("Failed to create QML object", .{});
    QGuiApplication.quit();
    std.process.exit(1);
}
