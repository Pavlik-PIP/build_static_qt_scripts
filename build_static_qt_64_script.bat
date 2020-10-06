@echo off
rem ====================CONFIGURE BEFORE RUN SCRIPT!!======================
set QtStaticDir=C:\Qt\5.13.1_64_Static
set QtSrcDir=D:\Downloads\qt-everywhere-src-5.13.1
set MingwDir=C:\Qt\Tools\mingw730_64
set OpenSSLdir=C:\OpenSSL-Win64
set LANG = en
rem =======================================================================

if not exist %QtStaticDir% (
    mkdir %QtStaticDir%
    if ERRORLEVEL 1 (
        goto :error
    )
)
set OldDir=%CD%

cd /D %QtSrcDir%

PATH = %MingwDir%\bin;%MingwDir%\opt\bin;%SystemRoot%\system32;%SystemRoot%

set FILE_TO_PATCH=%QtSrcDir%\qtbase\mkspecs\win32-g++\qmake.conf
echo %FILE_TO_PATCH%
if exist %FILE_TO_PATCH%.patched goto skipPatch
type %FILE_TO_PATCH%>%FILE_TO_PATCH%.patched
echo.>>%FILE_TO_PATCH%
echo QMAKE_LFLAGS += -static -static-libgcc>>%FILE_TO_PATCH%
echo QMAKE_CFLAGS_RELEASE -= -O2>>%FILE_TO_PATCH%
echo QMAKE_CFLAGS_RELEASE += -Os -momit-leaf-frame-pointer>>%FILE_TO_PATCH%
echo DEFINES += QT_STATIC_BUILD>>%FILE_TO_PATCH%
:skipPatch

set QT_INSTALL_PREFIX = %QtStaticDir%

cmd /C "configure.bat -static -release -platform win32-g++ -prefix %QtStaticDir% -opensource -confirm-license -openssl -I %OpenSSLdir%\include -L %OpenSSLdir% -c++std c++14 -c++std c++17 -opengl desktop -qt-zlib -qt-pcre -qt-libpng -qt-libjpeg -qt-freetype -make libs -nomake examples -nomake tests"
if ERRORLEVEL 1 goto :error

mingw32-make -r -k -j4
if ERRORLEVEL 1 goto :error

mingw32-make -k install
if ERRORLEVEL 1 goto :error

set FILE_TO_PATCH=%QtStaticDir%\mkspecs\win32-g++\qmake.conf
echo.>>%FILE_TO_PATCH%
echo CONFIG += static>>%FILE_TO_PATCH%

echo ============BUILT!============
goto exitX
:error
echo ============ERROR!============
:exitX
pause
cd /D %OldDir%