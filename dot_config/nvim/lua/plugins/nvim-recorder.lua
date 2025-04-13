return {
    "chrisgrieser/nvim-recorder",
    dependencies = "rcarriga/nvim-notify",
    keys = {
        -- these must match the keys in the mapping config below
        { "q", desc = " Start Recording" },
        { "Q", desc = " Play Recording" },
    },
    opts = {
        mapping = {
            startStopRecording = "q",
            playMacro = "Q",
        },
    },
}
