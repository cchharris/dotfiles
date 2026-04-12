return {
    "chrisgrieser/nvim-recorder",
    dependencies = "rcarriga/nvim-notify",
    keys = {
        -- these must match the keys in the mapping config below
        { "q", desc = "<Recorder>  Start/stop recording macro" },
        { "Q", desc = "<Recorder>  Play macro" },
    },
    opts = {
        mapping = {
            startStopRecording = "q",
            playMacro = "Q",
        },
    },
}
