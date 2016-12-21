#!/usr/bin/env bash

# NOTE: This script has been adapted from content generated by github.com/conda-forge/conda-smithy

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
UPLOAD_OWNER="scitools"
IMAGE_NAME="pelson/obvious-ci:latest_x64"
LABEL_NAME="main"

if [ ! -z ${BINSTAR_TOKEN+x} ]; then
    export UPLOAD_CHANNELS="--upload-channels $UPLOAD_OWNER/label/${LABEL_NAME}"
else
    export UPLOAD_CHANNELS=""
fi
echo "upload_channels = ${UPLOAD_CHANNELS}"

config=$(cat <<CONDARC

channels:
 - ${UPLOAD_OWNER}
 - defaults

show_channel_urls: True

CONDARC
)

cat << EOF | docker run -i \
                        -v ${REPO_ROOT}:/conda-recipes \
                        -a stdin -a stdout -a stderr \
                        $IMAGE_NAME \
                        bash || exit $?

# Export token so that conda-build (a sub-process) has access to it.
export BINSTAR_TOKEN=${BINSTAR_TOKEN}

export CONDA_NPY='19'
export PYTHONUNBUFFERED=1
echo "$config" > ~/.condarc

conda config --add channels scitools
conda config --set show_channel_urls True

# Update both conda-build-all and conda-build to get latest "numpy x.x" specification support.
conda install --yes --quiet -c conda-forge conda-build-all conda-build==2.0.10
conda update --yes --force conda
conda install -n root --yes --quiet jinja2 anaconda-client

# A lock sometimes occurs with incomplete builds. The lock file is stored in build_artefacts.
conda clean --lock

conda install --yes anaconda-client
conda install --yes conda-build
conda info
unset LANG
yum install -y expat-devel git autoconf libtool texinfo check-devel gcc-gfortran

conda-build-all /conda-recipes --inspect-channels $UPLOAD_OWNER/label/${LABEL_NAME} ${UPLOAD_CHANNELS} --matrix-condition "numpy >=1.8,<=1.10" "python >=2.7,<3|>=3.4,<3.5|>=3.5,<3.6"

EOF
