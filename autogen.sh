#!/bin/sh

autoreconf --verbose --install || (echo "autoreconf failed" && exit 1)

