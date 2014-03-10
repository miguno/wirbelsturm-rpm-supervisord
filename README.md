# wirbelsturm-rpm-supervisord

Builds an RPM of [supervisord v3.x](http://www.supervisord.org/), using [fpm](https://github.com/jordansissel/fpm).

Unfortunately both RHEL 6 as well as EPEL for RHEL 6 only ship with a very outdated supervisor version 2.x, but we
really want version 3.x.  The scripts in this project help to close that gap.

---

Table of Contents

* <a href="#bootstrap">Bootstrapping</a>
* <a href="#supported-os">Supported target operating systems</a>
* <a href="#usage">Usage</a>
    * <a href="#overview">Overview of approach</a>
    * <a href="#build">Building the RPM</a>
    * <a href="#verify">Verifying the RPM</a>
* <a href="#easy-way-out">Too complicated? Download a pre-generated RPM</a>
* <a href="#contributing">Contributing</a>
* <a href="#license">License</a>

---

<a name="bootstrap"></a>

# Bootstrapping

After a fresh checkout of this git repo you should first bootstrap the code.

    $ ./bootstrap

Basically, the bootstrapping will ensure that you have a suitable [fpm](https://github.com/jordansissel/fpm) setup.
If you already have `fpm` installed and configured you may try skipping the bootstrapping step.


<a name="supported-os"></a>

# Supported operating systems

## OS of the build server

It is recommended to run these scripts on a RHEL OS family machine.


## Target operating systems

The RPM files are built for the following operating system and architecture:

* RHEL 6 OS family (e.g. RHEL 6, CentOS 6, Amazon Linux), 64 bit


<a name="usage"></a>

# Usage

Unfortunately building an RPM for supervisord is still a bit involved at the moment, i.e. it requires a few
manual steps.


<a name="overview"></a>

## Overview of approach

The workflow is as follows:

* Get an existing RPM of supervisord 3.x that is compatible with RHEL 6.  We need this for a) getting the OS-specific
  helper scripts and b) to understand pre/post installation scripts embedded in the RPM.  The latter is required
  because `fpm` cannot detect this.  Also, the existing RPM helps to detect any additional dependencies of supervisord
  (which fpm, again, cannot detect when installing from PyPI).
    * The helper scripts are requried to e.g. start supervisord via `service supervisord start`.
    * Of course the big assumption is that the OS-specific helper scripts and the pre/post installation steps are
      compatible with our target OS version.
* We build a draft RPM with `fpm` by downloading and packaging the latest supervisord sources from PyPI.
* We unpack this draft RPM locally and augment its directory tree with the OS-specific files from the existing RPM.
* We manually create the required pre/post installation scripts (based on the existing RPM).
* We re-package the modified directory tree into a final RPM.

Yep, this is kinda dirty but it works!

_Note: We could have used a pre-built supervisord 3.x from a third-party but for security reasons we decided against_
_that.  We confirmed that the files of the existing RPM we are using to augment "our" RPM are ok._


<a name="build"></a>

## Building the RPM

### Prepare the build scripts

    # Get an existing supervisord 3.x that is compatible with RHEL/CentOS 6, and unpack it locally.
    $ mkdir existing-rpm
    $ cd existing-rpm/
    $ wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/presbrey:/py/EL6/noarch/supervisor-3.0-13.1.noarch.rpm
    $ rpm2cpio supervisor-3.0-13.1.noarch.rpm | cpio -idmv

    # Understand which pre/post installation steps are required by the supervisord RPM for RHEL/CentOS/Fedora.
    # We will manually create the corresponding scripts and instruct fpm to include those.  For instance, the
    # 'postinstall' snippet will be added to our RPM file via fpm's '--after-install' option.
    $ rpm -qp --scripts supervisor-3.0-13.1.noarch.rpm
    postinstall scriptlet (using /bin/sh):
    /sbin/chkconfig --add supervisord || :
    preuninstall scriptlet (using /bin/sh):
    if [ $1 = 0 ]; then
        /sbin/service supervisord stop > /dev/null 2>&1 || :
        /sbin/chkconfig --del supervisord || :
    fi

    # Now create the appropriate shell scripts so that we can instruct fpm to include those.  For instance, the
    # 'postinstall' snippet will be added to our RPM file via fpm's '--after-install' option.
    $ cd ..
    $ vi post-install.sh
    $ vi pre-uninstall.sh


### Build the actual RPM

    $ mkdir our-rpm
    $ cd our-rpm/

    # Step 1: Build a first draft of our rpm by pulling the latest supervisord sources from PyPI
    $ ../supervisord-rpm-step1.sh   # Creates e.g. 'supervisor-3.0.el6.noarch.rpm'
    # Extract the contents locally
    $ rpm2cpio supervisor-3.0.el6.noarch.rpm | cpio -idmv
    # Copy additional values (e.g. init scripts) from the existing RPM over to our local decompressed RPM
    $ cp -r ../existing-rpm/etc ../existing-rpm/var .
    # Copy docs and, very importantly, the LICENSE of supervisord
    $ cp -r ../existing-rpm/usr/share ./usr
    # Delete the draft RPM
    $ rm supervisor-3.0.el6.noarch.rpm
    # Step 2: Repackage the updated directory tree, which contains the latest supervisord code (from PyPI) plus the
    # additional OS helper files from the existing RPM.
    $ ../supervisord-rpm-step2.sh  # update version string etc. if needed

    => supervisor-3.0.el6.x86_64.rpm (fpm will tell you the full path to the file)


<a name="verify"></a>

## Verify the RPM

You can verify the proper creation of the RPM file with:

    $ rpm -qpi supervisor-*.rpm    # show package info
    $ rpm -qpR supervisor-*.rpm    # show package dependencies
    $ rpm -qpl supervisor-*.rpm    # show contents of package


<a name="easy-way-out"></a>

# Too complicated? Download a pre-generated RPM

You can also download a pre-generated RPM for the RHEL 6 OS family (64 bit):

* [supervisor-3.0.el6.x86_64.rpm](https://s3.amazonaws.com/yum.miguno.com/bigdata/redhat/6/x86_64/supervisor-3.0.el6.x86_64.rpm)


<a name="contributing"></a>

# Contributing to wirbelsturm-rpm-supervisord

Code contributions, bug reports, feature requests etc. are all welcome.

If you are new to GitHub please read [Contributing to a project](https://help.github.com/articles/fork-a-repo) for how
to send patches and pull requests to wirbelsturm-rpm-supervisord.


<a name="license"></a>

# License

Copyright © 2014 Michael G. Noll

See [LICENSE](LICENSE) for licensing information.
