#!/bin/bash -e

# Make the C++ symbols be backwards compatible with gcc versions
# prior to 5.1. In particular, the openzwave library suffers
# from this problem.
export CXXFLAGS=-D_GLIBCXX_USE_CXX11_ABI=0

rm -rf node_modules
if [ -z "${ADDON_ARCH}" ]; then
  TARFILE_SUFFIX=
else
  NODE_VERSION="$(node --version)"
  TARFILE_SUFFIX="-${ADDON_ARCH}-${NODE_VERSION/\.*/}"
fi
if [ "${ADDON_ARCH}" == "linux-arm" ]; then
  # We assume that CC and CXX are pointing to the cross compilers
  yarn --ignore-scripts --production
  npm rebuild --arch=armv6l --target_arch=arm
else
  yarn install --production
fi

rm -f SHA256SUMS
sha256sum package.json *.js LICENSE > SHA256SUMS
find node_modules -type f -exec sha256sum {} \; >> SHA256SUMS
TARFILE="$(npm pack)"
tar xzf ${TARFILE}
rm ${TARFILE}
TARFILE_ARCH="${TARFILE/.tgz/${TARFILE_SUFFIX}.tgz}"
cp -r node_modules ./package
tar czf ${TARFILE_ARCH} package
rm -rf package
echo "Created ${TARFILE_ARCH}"
