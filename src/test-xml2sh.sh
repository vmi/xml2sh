#!/bin/bash

set -eu

. xml2sh.sh

eval $(xml2sh test-data/test02.xml)

xml2sh_get r xml2sh_dependencies_dependency 10
