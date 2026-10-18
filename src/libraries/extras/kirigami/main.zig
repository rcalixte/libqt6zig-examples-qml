const std = @import("std");
const qt6 = @import("libqt6zig");
const QApplication = qt6.QApplication;
const KIconTheme = qt6.KIconTheme;
const KLocalizedString = qt6.KLocalizedString;
const QQuickStyle = qt6.QQuickStyle;
const QQmlApplicationEngine = qt6.QQmlApplicationEngine;
const KLocalizedQmlContext = qt6.KLocalizedQmlContext;
const QUrl = qt6.QUrl;

pub fn main(init: std.process.Init) !u8 {
    KIconTheme.initTheme();

    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    KLocalizedString.setApplicationDomain("tutorial");
    QApplication.setOrganizationName("KDE");
    QApplication.setOrganizationDomain("kde.org");
    QApplication.setApplicationName("Qt 6 Kirigami Example");
    QApplication.setDesktopFileName("org.kde.tutorial");

    _ = QApplication.setStyle2("breeze");
    if (!init.environ_map.contains("QT_QUICK_CONTROLS_STYLE"))
        QQuickStyle.setStyle("org.kde.desktop");

    const engine = QQmlApplicationEngine.new();
    defer engine.delete();

    const context = KLocalizedQmlContext.new2(engine);

    engine.rootContext().setContextObject(context);
    engine.onObjectCreationFailed(onFailed);
    engine.load2("src/libraries/extras/kirigami/main.qml");

    const objects = engine.rootObjects(init.gpa);
    defer init.gpa.free(objects);

    if (objects.len == 0) {
        std.log.err("No objects found in the QML file", .{});
        return 1;
    }

    return @intCast(QApplication.exec());
}

fn onFailed(_: QQmlApplicationEngine, _: QUrl) callconv(.c) void {
    std.log.err("Failed to create QML object", .{});
    QApplication.quit();
    std.process.exit(1);
}
