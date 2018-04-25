{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.monetdb;

in {
  ###### interface
  options = {
    services.monetdb = {

      enable = mkEnableOption {
        description = "MonetDB database server";
      };

      package = mkOption {
        default = pkgs.monetdb;
        defaultText = "pkgs.monetdb";
        type = types.package;
        description = "MonetDB package to use.";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/monetdb";
        description = "Data directory for dbfarm.";
      };

      port = mkOption {
        default = "50000";
        description = "Port to listen on.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.extraUsers.monetdb = 
      { name = "monetdb";
        uid = config.ids.uids.monetdb;
        description = "MonetDB user";
        home = cfg.dataDir;
      };

    users.extraGroups.monetdb.gid = config.ids.gids.monetdb;

    environment.systemPackages = [ cfg.package ];

    systemd.services.monetdb = {
      description = "MonetDB server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ cfg.package ];
      preStart =
        ''
          # Initialise the database.
          if [[ ! -e ${cfg.dataDir}/.merovingian_properties ]]; then
            mkdir -m 0700 -p ${cfg.dataDir}
            chown -R "monetdb" ${cfg.dataDir}
            ${cfg.package}/bin/monetdbd create ${cfg.dataDir}
            ${cfg.package}/bin/monetdbd set port=${cfg.port} ${cfg.dataDir}
          fi
        '';
      serviceConfig.ExecStart = "${cfg.package}/bin/monetdbd start -n ${cfg.dataDir}";
      serviceConfig.ExecStop = "${cfg.package}/bin/monetdbd stop ${cfg.dataDir}";
      unitConfig.RequiresMountsFor = "${cfg.dataDir}";
    };

  };

}
