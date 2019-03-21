{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.isync;
in {

  options.services.isync = {
    enable = mkEnableOption "Isync, a software to dispose your mailbox(es) as a local Maildir(s)";

    install = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to install a user service for Isync. Once
        the service is started, emails will be fetched automatically.

        The service must be manually started for each user with
        <command>systemctl --user start isync</command> or globally through
        <option>services.isync.enable</option>.
      '';
   };

    path = mkOption {
      type = types.listOf types.path;
      default = [];
      example = literalExample "[ pkgs.pass pkgs.bash pkgs.notmuch ]";
      description = "List of derivations to put in Isync's path.";
    };

    onCalendar = mkOption {
      type = types.str;
      default = "*:0/3"; # every 3 minutes
      description = "How often is isync started. Default is <literal>*:0/3</literal> meaning every 3 minutes. See <refentrytitle>systemd.time</refentrytitle<manvolnum>7</manvolnum> for more information about the format.";
    };

    timeoutStartSec = mkOption {
      type = types.str;
      default = "120sec"; # Kill if still alive after 2 minutes
      description = "How long waiting for isync before killing it. Default is '120sec' meaning every 2 minutes. See <refentrytitle>systemd.time</refentrytitle<manvolnum>7</manvolnum> for more information about the format.";
    };
  };
  config = mkIf (cfg.enable || cfg.install) {
    systemd.user.services.isync = {
      description = "Isync: a software to dispose your mailbox(es) as a local Maildir(s)";
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = "${pkgs.isync}/bin/mbsync -Va";
        TimeoutStartSec = cfg.timeoutStartSec;
      };
      path = cfg.path;
    };
    environment.systemPackages = [ pkgs.isync ];
    systemd.user.timers.isync = {
      description = "isync timer";
      timerConfig               = {
        OnCalendar = cfg.onCalendar;
        # start immediately after computer is started:
        Persistent = "true";
      };
      wantedBy = mkIf cfg.enable [ "default.target" ];
    };
  };
}
