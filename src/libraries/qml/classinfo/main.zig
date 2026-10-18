// This example needs to be built similar to the following command:
// zig build classinfo -Dqtprivate-paths={"/usr/include/x86_64-linux-gnu/qt6/QtCore/6.8.2","/usr/include/x86_64-linux-gnu/qt6/QtCore/6.8.2/QtCore/private"}

const std = @import("std");
const qt6 = @import("libqt6zig");
const QGuiApplication = qt6.QGuiApplication;
const QQmlApplicationEngine = qt6.QQmlApplicationEngine;
const QMetaObject = qt6.QMetaObject;
const QObject = qt6.QObject;
const QVariant = qt6.QVariant;
const ArrayMap_constu8_QVariant = qt6.types.ArrayMap_constu8_QVariant;
const QUrl = qt6.QUrl;
const QMetaObjectBuilder = qt6.QMetaObjectBuilder;

var shelf_meta: ?QMetaObject = null;

pub fn main(init: std.process.Init) !void {
    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QGuiApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    const shelf = QObject.new();
    defer shelf.delete();

    shelf.onMetaObject(onMetaObject);

    // equivalent of QML:
    // Shelf {
    //   QtObject { objectName: "Book" }
    //   QtObject { objectName: "Lamp" }
    //   QtObject { objectName: "Plant" }
    // }
    for ([_][]const u8{ "Book", "Lamp", "Plant" }) |name| {
        const item = QObject.new();
        item.setObjectName(name);
        try appendToDefault(init.gpa, shelf, item);
    }

    const text = try describe(init.gpa, shelf);
    defer init.gpa.free(text);

    const variant = QVariant.new24(text);
    defer variant.delete();

    var properties: ArrayMap_constu8_QVariant = .empty;
    defer properties.deinit(init.gpa);

    try properties.put(init.gpa, "description", variant);

    const engine = QQmlApplicationEngine.new();
    defer engine.delete();

    engine.setInitialProperties(init.gpa, properties);
    engine.onObjectCreationFailed(onFailed);
    engine.load2("src/libraries/qml/classinfo/main.qml");

    _ = QGuiApplication.exec();
}

fn onFailed(_: QQmlApplicationEngine, _: QUrl) callconv(.c) void {
    std.log.err("Failed to create QML object", .{});
    QGuiApplication.quit();
    std.process.exit(1);
}

fn onMetaObject(self: QObject) callconv(.c) QMetaObject {
    if (shelf_meta) |shelf| return shelf;

    const builder = QMetaObjectBuilder.new();
    defer builder.delete();

    builder.setClassName("Shelf");
    builder.setSuperClass(self.superMetaObject());
    _ = builder.addClassInfo("DefaultProperty", "items");

    shelf_meta = builder.toMetaObject();

    return shelf_meta.?;
}

fn defaultProperty(object: QObject) ![:0]const u8 {
    const mo = object.metaObject();
    const index = mo.indexOfClassInfo("DefaultProperty");
    if (index < 0) return error.NoDefaultProperty;
    const info = mo.classInfo(index);
    defer info.delete();

    return info.value();
}

fn appendToDefault(gpa: std.mem.Allocator, object: QObject, child: QObject) !void {
    const prop = try defaultProperty(object);
    child.setParent(object);

    const current = object.property(prop);
    defer current.delete();
    const old = current.toString(gpa);
    defer gpa.free(old);

    const name = child.objectName(gpa);
    defer gpa.free(name);

    const joined = if (old.len == 0)
        name
    else
        try gpa.print("{s}, {s}", .{ old, name });

    defer if (old.len != 0)
        gpa.free(joined);

    const updated = QVariant.new24(joined);
    defer updated.delete();
    _ = object.setProperty(prop, updated);
}

fn describe(gpa: std.mem.Allocator, object: QObject) ![]const u8 {
    const prop = try defaultProperty(object);
    const value = object.property(prop);
    defer value.delete();

    const value_str = value.toString(gpa);
    defer gpa.free(value_str);

    return gpa.print("{s}.{s}: {s}", .{
        object.metaObject().className(), prop, value_str,
    });
}
