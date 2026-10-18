const std = @import("std");
const qt6 = @import("libqt6zig");
const QGuiApplication = qt6.QGuiApplication;
const QQmlApplicationEngine = qt6.QQmlApplicationEngine;
const QAbstractListModel = qt6.QAbstractListModel;
const QModelIndex = qt6.QModelIndex;
const QVariant = qt6.QVariant;
const qnamespace_enums = qt6.qnamespace_enums;
const QUrl = qt6.QUrl;

var buf: [16]u8 = undefined;

pub fn main(init: std.process.Init) !void {
    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QGuiApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    const engine = QQmlApplicationEngine.new();
    defer engine.delete();

    const model = QAbstractListModel.new();
    defer model.delete();

    model.onRowCount(onRowCount);
    model.onData(onData);
    engine.onQuit(onQuit);
    engine.onObjectCreationFailed(onFailed);
    engine.rootContext().setContextProperty("my_model", model);
    engine.load2("src/libraries/qml/qml/main.qml");

    _ = QGuiApplication.exec();
}

fn onRowCount(_: QAbstractListModel, _: QModelIndex) callconv(.c) i32 {
    return 1000;
}

fn onData(_: QAbstractListModel, index: QModelIndex, role: i32) callconv(.c) QVariant {
    if (!index.isValid()) return .new();

    switch (role) {
        qnamespace_enums.ItemDataRole.DisplayRole => {
            const str = std.mem.print(&buf, "this is row {d}", .{index.row()}) catch
                @panic("failed to print");
            return .new24(str);
        },
        else => return .new(),
    }
}

fn onQuit(_: QQmlApplicationEngine) callconv(.c) void {
    QGuiApplication.quit();
}

fn onFailed(_: QQmlApplicationEngine, _: QUrl) callconv(.c) void {
    std.log.err("Failed to create QML object", .{});
    QGuiApplication.quit();
    std.process.exit(1);
}
