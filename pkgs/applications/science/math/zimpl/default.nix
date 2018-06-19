{ stdenv, fetchurl, zlib, gmp }:

let version = "3.3.4";
in stdenv.mkDerivation {

  name = "zimpl-${version}";

  src = fetchurl {
    url = "http://zimpl.zib.de/download/zimpl-${version}.tgz";
    sha256 = "1ciym192fnvz5hd9kk59ad0nipgb4b0y1xi37mr5kx2da8hznqik";
  };

  buildInputs = [ zlib gmp ];

  meta = with stdenv.lib; {
    description = "An mathematical modeling language for optimization problems";
    homepage = https://www.zimpl.zib.de/;
    license = licenses.LGPL;
    platforms = platforms.unix;
    maintainers = [ maintainers.StillerHarpo ];
  };
}
