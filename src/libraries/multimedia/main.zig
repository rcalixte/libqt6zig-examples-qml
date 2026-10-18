const std = @import("std");
const qt6 = @import("libqt6zig");
const QGuiApplication = qt6.QGuiApplication;
const QQmlApplicationEngine = qt6.QQmlApplicationEngine;
const QVariant = qt6.QVariant;
const ArrayMap_constu8_QVariant = qt6.types.ArrayMap_constu8_QVariant;
const QUrl = qt6.QUrl;
const QMediaFormat = qt6.QMediaFormat;
const qmediaformat_enums = qt6.qmediaformat_enums;

pub fn main(init: std.process.Init) !void {
    const argv = try qt6.init(init.gpa, init.minimal.args);
    defer qt6.deinit(init.gpa, argv);
    var argc: i32 = @intCast(argv.len);
    const qapp: QGuiApplication = .new(init.arena.allocator(), &argc, argv);
    defer qapp.delete();

    const filters = try nameFilters(init.gpa);
    defer {
        for (filters) |filter|
            init.gpa.free(filter);
        init.gpa.free(filters);
    }

    const source_variant = QVariant.new24("sample-10s-720p.mp4");
    defer source_variant.delete();
    const filters_variant = QVariant.new25(init.gpa, filters);
    defer filters_variant.delete();
    const preferred_variant = QVariant.new4(0);
    defer preferred_variant.delete();

    var properties: ArrayMap_constu8_QVariant = .empty;
    defer properties.deinit(init.gpa);

    try properties.put(init.gpa, "source", source_variant);
    try properties.put(init.gpa, "nameFilters", filters_variant);
    try properties.put(init.gpa, "selectedNameFilter", preferred_variant);

    const engine = QQmlApplicationEngine.new();
    defer engine.delete();

    engine.setInitialProperties(init.gpa, properties);
    engine.onObjectCreationFailed(onFailed);
    engine.load2("src/libraries/multimedia/main.qml");

    _ = QGuiApplication.exec();
}

fn onFailed(_: QQmlApplicationEngine, _: QUrl) callconv(.c) void {
    std.log.err("Failed to create QML object", .{});
    QGuiApplication.quit();
    std.process.exit(1);
}

fn nameFilters(gpa: std.mem.Allocator) ![][]const u8 {
    const media_format = QMediaFormat.new();
    defer media_format.delete();

    const supported_formats = media_format.supportedFileFormats(gpa, qmediaformat_enums.ConversionMode.Decode);
    defer gpa.free(supported_formats);

    var results: std.ArrayList([]const u8) = .empty;

    for (supported_formats) |format| {
        const iter_format = QMediaFormat.new3(format);
        defer iter_format.delete();

        const mime = iter_format.mimeType();
        defer mime.delete();

        const suffixes = mime.suffixes(gpa);
        defer {
            for (suffixes) |suffix|
                gpa.free(suffix);
            gpa.free(suffixes);
        }

        if (!mime.isValid() or suffixes.len == 0)
            continue;

        const filter = QMediaFormat.fileFormatDescription(gpa, format);
        defer gpa.free(filter);

        const suffixes_str = try std.mem.join(gpa, " *.", suffixes);
        defer gpa.free(suffixes_str);

        const result = try gpa.print("{s} (*.{s})", .{ filter, suffixes_str });
        try results.append(gpa, result);
    }

    std.mem.sort([]const u8, results.items, {}, stringLessThan);

    return results.toOwnedSlice(gpa);
}

fn stringLessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}
