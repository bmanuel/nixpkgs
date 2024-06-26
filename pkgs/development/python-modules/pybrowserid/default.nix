{ lib, buildPythonPackage, fetchPypi
, requests, mock }:

buildPythonPackage rec {
  pname = "pybrowserid";
  version = "0.14.0";

  src = fetchPypi {
    pname = "PyBrowserID";
    inherit version;
    sha256 = "1qvi79kfb8x9kxkm5lw2mp42hm82cpps1xknmsb5ghkwx1lpc8kc";
  };

  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [ mock ];

  meta = with lib; {
    description = "Python library for the BrowserID Protocol";
    homepage    = "https://github.com/mozilla/PyBrowserID";
    license     = licenses.mpl20;
    maintainers = with maintainers; [ ];
  };
}
