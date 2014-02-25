#!/bin/bash
#
# This script is step 1 of packaging Supervisord 3.x as RHEL6/CentOS6 RPM using fpm.

### CONFIGURATION BEGINS ###

MAINTAINER="<michael@michael-noll.com>"

### CONFIGURATION ENDS ###

echo "Step 1: Building a pre-RPM for Supervisord based on PyPI..."

# Build the RPM
fpm -s python -t rpm -a all \
    -n supervisor \
    --maintainer "$MAINTAINER" \
    -p supervisor-VERSION.el6.ARCH.rpm \
    -a "noarch" \
    --description "Fake -- will define actual description in build step 2" \
    supervisor

echo "You can verify the proper creation of the RPM file with:"
echo "  \$ rpm -qpi supervisor-*.rpm    # show package info"
echo "  \$ rpm -qpR supervisor-*.rpm    # show package dependencies"
echo "  \$ rpm -qpl supervisor-*.rpm    # show contents of package"

