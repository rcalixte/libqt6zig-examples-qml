const std = @import("std");
const qt6 = @import("libqt6zig");
const QApplication = qt6.QApplication;
const QWidget = qt6.QWidget;
const QVBoxLayout = qt6.QVBoxLayout;
const QQuickWidget = qt6.QQuickWidget;
const QUrl = qt6.QUrl;
const qquickwidget_enums = qt6.qquickwidget_enums;
const QLabel = qt6.QLabel;
const qnamespace_enums = qt6.qnamespace_enums;
const QPushButton = qt6.QPushButton;
const QQuickItem = qt6.QQuickItem;
const QObject = qt6.QObject;
const QMetaObject = qt6.QMetaObject;
const QGenericArgument = qt6.QGenericArgument;
const QQmlEngine = qt6.QQmlEngine;

var label: QLabel = undefined;
var ret: QGenericArgument = undefined;
var root: QQuickItem = undefined;

pub fn main(init: std.process.Init) !void {
    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    const widget = QWidget.new2();
    defer widget.delete();

    const layout = QVBoxLayout.new(widget);
    const quick_widget = QQuickWidget.new2();
    errdefer quick_widget.delete();
    quick_widget.setResizeMode(qquickwidget_enums.ResizeMode.SizeRootObjectToView);

    const url = QUrl.fromLocalFile("src/libraries/quick/main.qml");
    defer url.delete();

    quick_widget.setSource(url);

    if (quick_widget.status() == qquickwidget_enums.Status.Error) {
        const errors = quick_widget.errors(init.gpa);
        defer init.gpa.free(errors);
        for (errors) |err| {
            const err_str = err.toString(init.gpa);
            defer {
                init.gpa.free(err_str);
                err.delete();
            }
            std.log.err("{s}", .{err_str});
        }
        return error.QuickWidgetError;
    }

    quick_widget.engine().onQuit(onQuit);

    label = QLabel.new3("### Click inside the shaded area above.");
    label.setTextFormat(qnamespace_enums.TextFormat.MarkdownText);
    const button = QPushButton.new3("Reset the counter");

    layout.addWidget2(quick_widget, 1);
    layout.addWidget(label);
    layout.addWidget(button);

    root = quick_widget.rootObject();
    const root_meta = root.metaObject();
    const label_meta = label.metaObject();
    const root_signal = "tapped(QString)";
    const label_slot = "setText(QString)";
    const signal_index = root_meta.indexOfSignal(root_signal);
    const slot_index = label_meta.indexOfSlot(label_slot);
    if (signal_index < 0) {
        std.log.err("Could not find `{s}` signal", .{root_signal});
        return error.SignalNotFound;
    }
    if (slot_index < 0) {
        std.log.err("Could not find `{s}` slot", .{label_slot});
        return error.SlotNotFound;
    }

    const root_method = root_meta.method(signal_index);
    defer root_method.delete();
    const label_method = label_meta.method(slot_index);
    defer label_method.delete();

    ret = QGenericArgument.new3();
    defer ret.delete();

    _ = QObject.connect2(root, root_method, label, label_method);
    button.onClicked(onClicked);

    widget.setWindowTitle("Qt 6 Quick Example");
    widget.resize(450, 400);
    widget.show();

    _ = QApplication.exec();
}

fn onClicked(_: QPushButton) callconv(.c) void {
    _ = QMetaObject.invokeMethod4(root, "reset", ret);
    label.setText("### Counter reset from Zig!");
}

fn onQuit(_: QQmlEngine) callconv(.c) void {
    QApplication.quit();
}
