{
  aiohttp,
  aiohttp-cors,
  aiorwlock,
  aiosignal,
  attrs,
  autoPatchelfHook,
  buildPythonPackage,
  fetchPypi,
  click,
  cloudpickle,
  colorama,
  colorful,
  cython,
  dm-tree,
  fastapi,
  filelock,
  frozenlist,
  fsspec,
  gpustat,
  grpcio,
  gym,
  jsonschema,
  lib,
  lz4,
  matplotlib,
  msgpack,
  numpy,
  opencensus,
  packaging,
  pandas,
  py-spy,
  prometheus-client,
  psutil,
  pyarrow,
  pydantic,
  python,
  pythonAtLeast,
  pythonOlder,
  pyyaml,
  requests,
  scikit-image,
  scipy,
  setproctitle,
  smart-open,
  starlette,
  tabulate,
  tensorboardx,
  uvicorn,
  virtualenv,
}:

let
  pname = "ray";
  version = "2.32.0";
in
buildPythonPackage rec {
  inherit pname version;
  format = "wheel";

  disabled = pythonOlder "3.10" || pythonAtLeast "3.13";

  src =
    let
      pyShortVersion = "cp${builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion}";
      binary-hash = (import ./binary-hashes.nix)."${pyShortVersion}" or { };
    in
    fetchPypi (
      {
        inherit pname version format;
        dist = pyShortVersion;
        python = pyShortVersion;
        abi = pyShortVersion;
        platform = "manylinux2014_x86_64";
      }
      // binary-hash
    );

  optional-dependencies = rec {
    data-deps = [
      pandas
      pyarrow
      fsspec
    ];

    serve-deps = [
      aiorwlock
      fastapi
      pandas
      starlette
      uvicorn
    ];

    tune-deps = [
      tabulate
      tensorboardx
    ];

    rllib-deps = tune-deps ++ [
      dm-tree
      gym
      lz4
      matplotlib
      scikit-image
      pyyaml
      scipy
    ];

    air-deps = data-deps ++ serve-deps ++ tune-deps ++ rllib-deps;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  pythonRelaxDeps = [
    "click"
    "grpcio"
    "protobuf"
    "virtualenv"
  ];

  dependencies = [
    attrs
    aiohttp
    aiohttp-cors
    aiosignal
    click
    cloudpickle
    colorama
    colorful
    cython
    filelock
    frozenlist
    gpustat
    grpcio
    jsonschema
    msgpack
    numpy
    opencensus
    packaging
    py-spy
    prometheus-client
    psutil
    pydantic
    pyyaml
    requests
    setproctitle
    smart-open
    virtualenv
  ];

  postInstall = ''
    chmod +x $out/${python.sitePackages}/ray/core/src/ray/{gcs/gcs_server,raylet/raylet}
  '';

  pythonImportsCheck = [ "ray" ];

  meta = {
    description = "Unified framework for scaling AI and Python applications";
    homepage = "https://github.com/ray-project/ray";
    changelog = "https://github.com/ray-project/ray/releases/tag/ray-${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ billhuang ];
    platforms = [ "x86_64-linux" ];
  };
}
