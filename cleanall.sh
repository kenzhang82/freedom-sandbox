#!/bin/sh

curdir=`pwd`

for x in ./ ./rocket-chip ./sifive-blocks ./rocket-chip/chisel3 ./rocket-chip/firrtl ./rocket-chip/hardfloat ./rocket-chip/torture; do
    echo "Cleaning up $x"
    cd $x; git clean -xdf; cd $curdir
done
