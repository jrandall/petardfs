#!/bin/sh

autoreconf --verbose --install -I macros || (echo "autoreconf failed" && exit 1)

