const std = @import("std");
const qt6 = @import("libqt6zig");
const QGuiApplication = qt6.QGuiApplication;
const QQmlApplicationEngine = qt6.QQmlApplicationEngine;
const QSurfaceFormat = qt6.QSurfaceFormat;
const QQuick3D = qt6.QQuick3D;
const QUrl = qt6.QUrl;

pub fn main(init: std.process.Init) !u8 {
    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QGuiApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    QSurfaceFormat.setDefaultFormat(QQuick3D.idealSurfaceFormat1(4));

    const engine = QQmlApplicationEngine.new();
    defer engine.delete();

    engine.onObjectCreationFailed(onFailed);
    engine.load2("src/libraries/restricted-extras/quick3d/main.qml");

    const objects = engine.rootObjects(init.gpa);
    defer init.gpa.free(objects);

    if (objects.len == 0) {
        std.log.err("No objects found in the QML file", .{});
        return 1;
    }

    return @intCast(QGuiApplication.exec());
}

fn onFailed(_: QQmlApplicationEngine, _: QUrl) callconv(.c) void {
    std.log.err("Failed to create QML object", .{});
    QGuiApplication.quit();
}
