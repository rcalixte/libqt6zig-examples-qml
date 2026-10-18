const std = @import("std");
const qt6 = @import("libqt6zig");
const QCoreApplication = qt6.QCoreApplication;
const qnamespace_enums = qt6.qnamespace_enums;
const QtWebEngineQuick = qt6.QtWebEngineQuick;
const QGuiApplication = qt6.QGuiApplication;
const QQmlApplicationEngine = qt6.QQmlApplicationEngine;
const QUrl = qt6.QUrl;

pub fn main(init: std.process.Init) !void {
    QCoreApplication.setOrganizationName("Qt 6 WebEngine Example");
    QCoreApplication.setAttribute(qnamespace_enums.ApplicationAttribute.AA_ShareOpenGLContexts);
    QtWebEngineQuick.initialize();

    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QGuiApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    const engine = QQmlApplicationEngine.new();
    defer engine.delete();

    engine.onObjectCreationFailed(onFailed);
    engine.load2("src/libraries/webengine/main.qml");

    _ = QGuiApplication.exec();
}

fn onFailed(_: QQmlApplicationEngine, _: QUrl) callconv(.c) void {
    std.log.err("Failed to create QML object", .{});
    QGuiApplication.quit();
    std.process.exit(0);
}
