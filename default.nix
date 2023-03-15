let
  pkgs = import <nixpkgs> {};
  gollum = pkgs.gollum;
  dockerTools = pkgs.dockerTools;
in
dockerTools.buildImage {
  name = "gollum";
  tag = "latest";
  copyToRoot = pkgs.buildEnv {
    name = "mygollum-root";
    paths = [ pkgs.gollum pkgs.busybox ];
    pathsToLink = [ "/bin" ];
  };

  config = {
    Cmd = [ "/bin/gollum" ];
    WorkingDir = "/wiki";
    Volumes = { "/wiki" = {}; };
  };
}
