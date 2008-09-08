#!/bin/sh

if [ $(basename $(pwd)) != 'nautilus-dropbox' ]; then
    echo "This script must be run from the nautilus-dropbox folder"
    exit -1
fi

# creating a debian package is super bitchy and mostly hard to script

set -e

# get version
CURVER=$(awk '/^AC_INIT/{sub("AC_INIT\(\[nautilus-dropbox\],", ""); sub("\)", ""); print $0}' configure.in)

# clean old package build
rm -rf nautilus-dropbox{-,_}*

# first generate package binary
make dist

# untar package
tar xjf nautilus-dropbox-$CURVER.tar.bz2

# go into package dir
cd nautilus-dropbox-$CURVER

# now run dh_make, please hit enter
dh_make -c gpl -e rian@getdropbox.com -f ../nautilus-dropbox-0.4.0.tar.bz2 -s -p nautilus-dropbox

# now fill up all files
cat > debian/copyright <<EOF
This package was debianized by Rian Hunter <rian@getdropbox.com> on
$(date -R).

It was downloaded from http://dl.getdropbox.com/u/5143/nautilus-dropbox-$CURVER.tar.bz2

Upstream Author(s): 

    Rian Hunter <rian@getdropbox.com>

Copyright: 

    Copyright (C) 2008 Evenflow, Inc.

License:

    This package is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
 
    This package is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this package; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

On Debian systems, the complete text of the GNU General
Public License can be found in \`/usr/share/common-licenses/GPL'.

The Debian packaging is (C) 2008, Rian Hunter <rian@getdropbox.com> and
is licensed under the GPL, see above.

# Please also look if there are files or directories which have a
# different copyright/license attached and list them here.
EOF


cat > debian/nautilus-dropbox.postinst<<EOF
#!/bin/sh
# postinst script for nautilus-dropbox
#
# see: dh_installdeb(1)

# summary of how this script can be called:
#        * <postinst> \`configure' <most-recently-configured-version>
#        * <old-postinst> abort-upgrade' <new version>
#        * <conflictor's-postinst> \`abort-remove' \`in-favour' <package>
#          <new-version>
#        * <postinst> \`abort-remove'
#        * <deconfigured's-postinst> \`abort-deconfigure' \`in-favour'
#          <failed-install-package> <version> \`removing'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

case "\$1" in
    configure)
	gtk-update-icon-cache /usr/share/icons/hicolor > /dev/null 2>&1
	;;

    abort-upgrade|abort-remove|abort-deconfigure)
    ;;

    *)
        echo "postinst called with unknown argument '\$1'" >&2
        exit 1
    ;;
esac

set -e

# dh_installdeb will replace this with shell code automatically
# generated by other debhelper scripts.

#DEBHELPER#

exit 0
EOF

rm debian/README.Debian

cat > debian/control <<EOF
Source: nautilus-dropbox
Section: gnome
Priority: optional
Maintainer: Rian Hunter <rian@getdropbox.com>
Build-Depends: debhelper (>= 5), autotools-dev, libnautilus-extension-dev, libnotify-dev, libglib2.0-dev (>= 2.16.3-1)
Standards-Version: 3.7.2

Package: nautilus-dropbox
Architecture: any
Depends: nautilus (>= 2.20), wget, libnotify1 (>= 0.4.4), libglib2.0-0 (>= 2.16.3-1), \${shlibs:Depends}, \${misc:Depends}
Description: Dropbox integration for Nautilus
 Nautilus Dropbox is an extension that integrates
 the Dropbox web service with your GNOME Desktop.
 .
 Check out http://www.getdropbox.com/
Homepage: http://www.getdropbox.com/
EOF

dpkg-buildpackage -j4
