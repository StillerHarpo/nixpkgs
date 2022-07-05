{ lib, buildKodiAddon, fetchzip, requests, inputstreamhelper }:

buildKodiAddon rec {
  pname = "invidious";
  namespace = "plugin.video.invidious";
  version = "0.1.0+matrix.1";

  src = fetchzip {
    url = "http://ftp.halifax.rwth-aachen.de/xbmc/addons/matrix/${namespace}/${namespace}-${version}.zip";
    sha256 = "4z2/YTso5KV6JHS/DOXll2lKOoVnW1i5MnpmV6ESXbM=";
  };

  propagatedBuildInputs = [
    requests
    inputstreamhelper
  ];

  meta = with lib; {
    homepage = "https://github.com/TheAssassin/kodi-invidious-plugin";
    description = "A privacy-friendly way of watching YouTube content. Uses the great Invidious web service's API to do the heavy lifting.";
    license = licenses.gpl2Only;
    maintainers = teams.kodi.members;
  };
}
