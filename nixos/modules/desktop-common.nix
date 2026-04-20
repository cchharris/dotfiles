# Common desktop environment features (audio, printing, applications)
# Shared between GNOME and Hyprland configurations
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.desktop-common;
in {
  options.cchharris.nixos.desktop-common = {
    enable = lib.mkEnableOption "common desktop environment features";
  };

  config = lib.mkIf cfg.enable {
    # Audio with PipeWire (shared by both GNOME and Hyprland)
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Printing (shared by both)
    services.printing.enable = true;

    # Common desktop applications
    programs.firefox.enable = true;

    # Force Microsoft Edge to use dark theme via managed policy
    environment.etc."opt/edge/policies/managed/dark-theme.json".text = builtins.toJSON {
      ForceDarkModeEnabled = true;
    };

    # UPower — required by AstalBattery (hyprpanel battery widget uses D-Bus)
    services.upower.enable = true;

    # Bluetooth manager (used by hyprpanel bluetooth widget)
    services.blueman.enable = true;

    # 1Password GUI + SSH agent (polkit integration required for system unlock)
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "cchharris" ];
    };

    # KDE Connect (phone integration: notifications, clipboard sync, file transfer)
    programs.kdeconnect.enable = true;

    # KDE Connect / GSConnect firewall ports (required on all DEs)
    networking.firewall = {
      allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
      allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
    };

    # Common desktop packages
    environment.systemPackages = with pkgs; [
      (microsoft-edge.override {
        commandLineArgs = [
          "--use-angle=vulkan"
          "--enable-features=Vulkan"
          "--disable-gpu-memory-buffer-video-frames"
        ];
      })
      discord
      bluez-tools  # bt-device/bt-adapter required by HyprPanel bluetooth menu
      libva-utils  # provides vainfo for diagnosing VA-API / hardware decode issues

      # GStreamer codec plugins (H.264, H.265, AV1, VP8/9, MP3, etc.)
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav  # ffmpeg backend (covers most proprietary formats)
    ];
  };
}
