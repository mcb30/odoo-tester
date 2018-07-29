# Odoo automated unit test runner

[![Build Status](https://travis-ci.org/unipartdigital/odoo-tester.svg?branch=master)](https://travis-ci.org/unipartdigital/odoo-tester)

This is a recipe for building a [Docker](https://www.docker.com/)
container suitable for running automated unit tests on
[Odoo](https://github.com/odoo/odoo) modules.  The container is built
using [Fedora](https://getfedora.org/) and the latest Odoo branch.
Almost all dependencies are provided using official Fedora packages.

The resulting container is published on Docker Hub as
[`unipartdigital/odoo-tester`](https://hub.docker.com/r/unipartdigital/odoo-tester/).

## Building

To build and publish the container image:

    docker build -t unipartdigital/odoo-tester .
    docker push unipartdigital/odoo-tester

## Running

To run Odoo within the container:

    docker run -it --rm unipartdigital/odoo-tester

Any extra arguments will be appended to the `odoo-bin` command line.
For example, to install the `product` module:

    docker run -it --rm unipartdigital/odoo-tester -i product

## Extending

The primary use case for this container image is to allow for the
automated testing of external Odoo modules.  An external module may
include a `Dockerfile` such as:

    FROM unipartdigital/odoo-tester
    ADD addons/my_module /opt/odoo-addons/my_module
    CMD ["--test-enable", "-i", "my_module"]

Tests can then be run (from within the external module's directory)
using:

    docker build -t my_module-tester .
    docker run -it --rm my_module-tester

These commands can be invoked as part of a continuous integration
system such as [Travis CI](https://travis-ci.org/), to ensure that the
module's automated tests are run automatically for every commit and
pull request.
