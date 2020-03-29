#!/bin/sh
export AE_SH_PATH="`realpath $0`"
export AE_SH_DIR="`dirname ${AE_SH_PATH}`"

oosh_link() {
    ln -fs ${AE_SH_DIR}"/oosh" "/usr/local/bin/oosh"
    ln -fs ${AE_SH_DIR}"/bin/oocc" /usr/local/bin/oocc
}

oosh || oosh_link
