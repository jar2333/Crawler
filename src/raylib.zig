pub const rl = @cImport({
    @cInclude("../vendor/raylib/src/raylib.h");
});

pub const rlgl = @cImport({
    @cInclude("../vendor/raylib/src/rlgl.h");
});

pub const rlnk = @cImport({
    @cInclude("./cinclude/raylib-nuklear.h");
});
