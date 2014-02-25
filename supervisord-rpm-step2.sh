#!/bin/bash
#
# This script is step 2 of packaging Supervisord 3.x as RHEL6/CentOS6 RPM using fpm.
#
# You must run this script from the directory that contains the updated/augmented directory tree based on the draft RPM
# created in step 1 (i.e. usually via "../supervisord-rpm-step2.sh").  This is required so that the paths in the
# created RPM are correct (e.g. /usr/foo instead of /our-rpm/usr/foo) -- maybe a future code change can improve this.
#

### CONFIGURATION BEGINS ###

MAINTAINER="<michael@michael-noll.com>"

### CONFIGURATION ENDS ###

echo "Building an RPM for Supervisord..."

MY_DIR=`dirname $0`
MY_DIR_ABS_PATH=`readlink -f $MY_DIR`

# Build the RPM
fpm -s dir -t rpm -a all \
    -n supervisor \
    -v 3.0b2 \
    --maintainer "$MAINTAINER" \
    --url http://supervisord.org/ \
    --vendor Supervisord.org \
    --description "A System for Allowing the Control of Process State on UNIX" \
    -p $MY_DIR_ABS_PATH/supervisor-VERSION.el6.ARCH.rpm \
    -a "x86_64" \
    -d "/bin/bash" \
    -d "/bin/sh" \
    -d "/sbin/chkconfig" \
    -d "/sbin/service" \
    -d "/usr/bin/python" \
    -d "python-meld3 >= 0.6.5" \
    -d "python-setuptools" \
    -d "rpmlib(CompressedFileNames) <= 3.0.4-1" \
    -d "rpmlib(FileDigests) <= 4.6.0-1" \
    -d "rpmlib(PartialHardlinkSets) <= 4.0.4-1" \
    -d "rpmlib(PayloadFilesHavePrefix) <= 4.0-1" \
    -d "rpmlib(PayloadIsXz) <= 5.2-1" \
    --after-install $MY_DIR_ABS_PATH/post-install.sh \
    --before-remove $MY_DIR_ABS_PATH/pre-uninstall.sh \
    .

echo "You can verify the proper creation of the RPM file with:"
echo "  \$ rpm -qpi supervisor-*.rpm    # show package info"
echo "  \$ rpm -qpR supervisor-*.rpm    # show package dependencies"
echo "  \$ rpm -qpl supervisor-*.rpm    # show contents of package"

