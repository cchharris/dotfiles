{
  lib,
  makeWrapper,
  runCommand,
  bash,
  jq,
  xdotool,
}:
let
  src = ./nvimunity.sh;
  binName = "nvimunity";
  deps = [ bash jq xdotool ];
in
runCommand "${binName}" {
  nativeBuildInputs = [ makeWrapper ];
  meta.mainProgram = "${binName}";
} ''
  mkdir -p $out/bin
  install -m +x ${src} $out/bin/${binName}
  wrapProgram $out/bin/${binName} \
    --prefix PATH : ${lib.makeBinPath deps}
''
