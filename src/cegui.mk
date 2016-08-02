# This file is part of MXE.
# See index.html for further information.

PKG             := cegui
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 9726a2b505fb
$(PKG)_CHECKSUM := 14b3da7f1f89693192cd9afbf2126f4519508245ed156de893828e31ce676e9e
$(PKG)_SUBDIR   := $(PKG)-$(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$(PKG)-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://bitbucket.org/$(PKG)/$(PKG)/get/$($(PKG)_VERSION).tar.bz2
$(PKG)_DEPS     := gcc expat freeglut freeimage freetype libxml2 pcre xerces devil glm glew

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://bitbucket.org/cegui/cegui/downloads' | \
    $(SED) -n 's,.*href=.*get/v\([0-9]*-[0-9]*-[0-9]*\)\.tar.*,\1,p' | \
    $(SED) 's,-,.,g' | \
    $(SORT) -V | \
    tail -1
endef

# track dev branch v0-8 until next release
define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://bitbucket.org/cegui/cegui/commits/branch/v0-8' | \
    $(SED) -n 's,.*cegui/cegui/commits/\([^?]\{12\}\).*at=.*,\1,p' | \
    head -1
endef

# Use pkg-config to set FREEIMAGE_LIB and GLEW_STATIC to prevent "_imp__" errors
# freeimage and xerces don't have shared builds - disable with $(CMAKE_STATIC_BOOL)
define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' \
        -DCEGUI_BUILD_STATIC_CONFIGURATION=$(CMAKE_STATIC_BOOL) \
        -DCEGUI_INSTALL_PKGCONFIG=ON \
        -DCEGUI_SAMPLES_ENABLED=OFF \
        -DCEGUI_BUILD_TESTS=OFF \
        -DCEGUI_BUILD_APPLICATION_TEMPLATES=OFF \
        -DCEGUI_BUILD_LUA_MODULE=OFF \
        -DCEGUI_BUILD_PYTHON_MODULES=OFF \
        -DCEGUI_BUILD_XMLPARSER_XERCES=$(CMAKE_STATIC_BOOL) \
        -DCEGUI_BUILD_XMLPARSER_LIBXML2=OFF \
        -DCEGUI_BUILD_XMLPARSER_EXPAT=ON \
        -DCEGUI_BUILD_XMLPARSER_TINYXML=OFF \
        -DCEGUI_BUILD_XMLPARSER_RAPIDXML=OFF \
        -DCEGUI_BUILD_IMAGECODEC_CORONA=OFF \
        -DCEGUI_BUILD_IMAGECODEC_DEVIL=OFF \
        -DCEGUI_BUILD_IMAGECODEC_FREEIMAGE=$(CMAKE_STATIC_BOOL) \
        -DCEGUI_BUILD_IMAGECODEC_PVR=OFF \
        -DCEGUI_BUILD_IMAGECODEC_SDL2=OFF \
        -DCEGUI_BUILD_IMAGECODEC_SILLY=OFF \
        -DCEGUI_BUILD_IMAGECODEC_STB=ON \
        -DCEGUI_BUILD_IMAGECODEC_TGA=ON \
        -DCEGUI_BUILD_RENDERER_DIRECT3D10=ON \
        -DCEGUI_BUILD_RENDERER_DIRECT3D11=OFF \
        -DCEGUI_BUILD_RENDERER_DIRECT3D9=ON \
        -DCEGUI_BUILD_RENDERER_DIRECTFB=OFF \
        -DCEGUI_BUILD_RENDERER_IRRLICHT=OFF \
        -DCEGUI_BUILD_RENDERER_NULL=ON \
        -DCEGUI_BUILD_RENDERER_OGRE=OFF \
        -DCEGUI_BUILD_RENDERER_OPENGL=ON \
        -DCEGUI_BUILD_RENDERER_OPENGL3=ON \
        -DCEGUI_BUILD_RENDERER_OPENGLES=OFF \
        -DCMAKE_CXX_FLAGS="`$(TARGET)-pkg-config --cflags glew freeimage`" \
        $(SOURCE_DIR)

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    '$(TARGET)-g++' \
        -W -Wall -ansi -pedantic \
        '$(2).cpp' -o '$(PREFIX)/$(TARGET)/bin/test-cegui.exe' \
        `$(TARGET)-pkg-config --cflags --libs CEGUI-0-OPENGL glut gl`
endef
