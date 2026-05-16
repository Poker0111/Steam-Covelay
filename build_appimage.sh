#!/bin/bash

rm -rf build AppDir *.AppImage
mkdir build

cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
cmake --build . --config Release

cmake --install . --prefix ../AppDir
cd ..

echo "Download tools."
wget -qN https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
wget -qN https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage

chmod +x linuxdeploy*.AppImage

export QMAKE=/usr/bin/qmake6
export EXTRA_QT_PLUGINS=qml

./linuxdeploy-x86_64.AppImage --appdir AppDir --plugin qt --output appimage

echo "Ready! Enjoy."