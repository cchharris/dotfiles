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

    # Force-install the "Claude in Chrome" extension via managed policy — same
    # mechanism as the Edge dark-theme policy above, pointed at Chrome's policy
    # dir instead. Note: force-installed extensions can't be disabled/removed
    # from chrome://extensions (shown as "installed by your administrator").
    environment.etc."opt/chrome/policies/managed/claude-extension.json".text = builtins.toJSON {
      ExtensionInstallForcelist = [
        "fcoeoabgfenejglbffodgkkbkcdhcgfn;https://clients2.google.com/service/update2/crx"
      ];
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
          # Force XWayland. Edge 150 on native Wayland SIGSEGVs ~4min after
          # a VA-API "vaEndPicture failed, internal decoding error" during
          # video playback (2 reproductions, 2026-09-13: 19:47:14->19:49:25,
          # 19:54:42->19:58:55) — looks like delayed memory corruption from
          # the failed hw decode, not tied to any user action in between.
          "--ozone-platform=x11"
        ];
      })
      google-chrome  # needed for the "Claude in Chrome" extension — Edge doesn't support it
      discord
      bluez-tools  # bt-device/bt-adapter required by HyprPanel bluetooth menu
      libva-utils  # provides vainfo for diagnosing VA-API / hardware decode issues

      gimp

      # GStreamer codec plugins (H.264, H.265, AV1, VP8/9, MP3, etc.)
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav  # ffmpeg backend (covers most proprietary formats)
    ];
  };
}
