# generated by zon2nix (https://github.com/Cloudef/zig2nix)

{
  lib,
  linkFarm,
  fetchurl,
  fetchgit,
  runCommandLocal,
  zig,
  name ? "zig-packages",
}:

with builtins;
with lib;

let
  unpackZigArtifact =
    { name, artifact }:
    runCommandLocal name { nativeBuildInputs = [ zig ]; } ''
      hash="$(zig fetch --global-cache-dir "$TMPDIR" ${artifact})"
      mv "$TMPDIR/p/$hash" "$out"
      chmod 755 "$out"
    '';

  fetchZig =
    {
      name,
      url,
      hash,
    }:
    let
      artifact = fetchurl { inherit url hash; };
    in
    unpackZigArtifact { inherit name artifact; };

  fetchGitZig =
    {
      name,
      url,
      hash,
      rev ? throw "rev is required, remove and regenerate the zon2json-lock file",
    }:
    let
      parts = splitString "#" url;
      url_base = elemAt parts 0;
      url_without_query = elemAt (splitString "?" url_base) 0;
    in
    fetchgit {
      inherit name rev hash;
      url = url_without_query;
      deepClone = false;
    };

  fetchZigArtifact =
    {
      name,
      url,
      hash,
      ...
    }@args:
    let
      parts = splitString "://" url;
      proto = elemAt parts 0;
      path = elemAt parts 1;
      fetcher = {
        "git+http" = fetchGitZig (
          args
          // {
            url = "http://${path}";
          }
        );
        "git+https" = fetchGitZig (
          args
          // {
            url = "https://${path}";
          }
        );
        http = fetchZig {
          inherit name hash;
          url = "http://${path}";
        };
        https = fetchZig {
          inherit name hash;
          url = "https://${path}";
        };
      };
    in
    fetcher.${proto};
in
linkFarm name [
  {
    name = "clap-0.10.0-oBajB434AQBDh-Ei3YtoKIRxZacVPF1iSwp3IX_ZB8f0";
    path = fetchZigArtifact {
      name = "clap";
      url = "https://github.com/Hejsil/zig-clap/archive/refs/tags/0.10.0.tar.gz";
      hash = "sha256-cbPGmVlIXwIuRPIfQoFXzwLulT4XEv8rQWcJUl1ueyo=";
    };
  }
  {
    name = "zigini-0.3.1-BSkB7XJGAAB2E-sKyzhTaQCBlYBL8yqzE4E_jmSY99sC";
    path = fetchZigArtifact {
      name = "zigini";
      url = "https://github.com/Kawaii-Ash/zigini/archive/2ed3d417f17fab5b0ee8cad8a63c6d62d7ac1042.tar.gz";
      hash = "sha256-Zj9uU6EEHkNZ1cPIDgDj1E2CEpbmPmpJYjSSFnxxdf0=";
    };
  }
  {
    name = "N-V-__8AAB9qAACwl56piR-krrhXSPxCvEskA52cmaTWXYk_";
    path = fetchZigArtifact {
      name = "ini";
      url = "https://github.com/ziglibs/ini/archive/e18d36665905c1e7ba0c1ce3e8780076b33e3002.tar.gz";
      hash = "sha256-RQ6OPJBqqH7PCL+xiI58JT7vnIo6zbwpLWn+byZO5iM=";
    };
  }
]
