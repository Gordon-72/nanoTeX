@echo off

rem     ------------------------------------------------------------------------------
rem     This is file install-nanotex.bat, version 0.1 beta 2020-05-26
rem
rem     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
rem     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
rem     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
rem     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
rem     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
rem     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
rem     SOFTWARE.
rem     ------------------------------------------------------------------------------

rem ---------------------------------------------------------
rem Set the variable for the installation directory
rem ---------------------------------------------------------
set CURRDIR=%~dp0
set base=%CURRDIR%2020
rem set PATH=%CURRDIR%\2020\bin;%PATH%

echo ...Downloading the installer from http://mirror.ctan.org/systems/texlive/tlnet/

rem ---------------------------------------------------------
rem Download install-tl.zip and unzip it
rem ---------------------------------------------------------
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest http://mirror.ctan.org/systems/texlive/tlnet/install-tl.zip -OutFile %CURRDIR%install-tl.zip"
powershell -Command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('install-tl.zip', '.'); }"
rem ---------------------------------------------------------
rem Alternative way to decompress .zip archive:
rem powershell Expand-Archive -Path install-tl.zip -DestinationPath %CURRDIR%
rem ---------------------------------------------------------

echo ###Installer downloaded

rem pause

echo ...Setting up the installation directory

rem ---------------------------------------------------------
rem Move the installation files in the current directory:
rem ---------------------------------------------------------
cd install-tl-*
move * %CURRDIR%
move tlpkg %CURRDIR%
move texmf-dist %CURRDIR%
cd ..

rem cd auxfiles
rem move * %CURRDIR%
rem cd ..

rem ---------------------------------------------------------
rem Create the nanotex.profile file from nanotex.profile.win:
rem ---------------------------------------------------------
powershell -Command "(gc nanotex.profile.win) -replace '<BASE>', '%base%' | Out-File -encoding ASCII nanotex.profile"
powershell -Command "(gc nanotex.profile) -replace '\\', '/' | Out-File -encoding ASCII nanotex.profile"

echo ###Installation directory ready

rem pause

echo ...Installing TeX Live infrastructure and basic packages

rem ---------------------------------------------------------
rem Install the TeXLive infrastructure:
rem ---------------------------------------------------------
@echo on
@echo | install-tl-windows.bat -no-gui -profile=nanotex.profile
@echo off

rem ---------------------------------------------------------
rem Install a minimal set of packages:
rem ---------------------------------------------------------

setlocal enabledelayedexpansion
rem Forse non servono le virgolette
set "pkgs-min="
for /F %%a in (pkgs-minimal.txt) do set "pkgs-min=!pkgs-min! %%a"
set "pkgs-math="
for /F %%a in (pkgs-mathematics.txt) do set "pkgs-math=!pkgs-math! %%a"
set "pkgs-grk="
for /F %%a in (pkgs-greek.txt) do set "pkgs-grk=!pkgs-grk! %%a"

@echo on
call "%base%\bin\win32\tlmgr" path add
call "%base%\bin\win32\tlmgr" install latex-bin luahbtex tlshell kpathsea lua-alt-getopt luahbtex luatex texworks %pkgs-min%
@echo off

echo ###Infrastructure and basic packages installed

rem pause

echo ...Installing additional packages

choice /c yn /n /m "Installing mathematics support. Do you want to continue? Press y [yes] or n [no])"
if %ERRORLEVEL%==1 goto math
if %ERRORLEVEL%==2 goto greekchoice

:math
@echo on
call "%base%\bin\win32\tlmgr" install %pkgs-math%
@echo off

:greekchoice
choice /c yn /n /m "Installing greek support. Do you want to continue? Press y [yes] or n [no])"
if %ERRORLEVEL%==1 goto greek
if %ERRORLEVEL%==2 goto finishchoice

:greek
@echo on
call "%base%\bin\win32\tlmgr" install %pkgs-grk%
@echo off

:finishchoice

echo ###Additional packages installed

rem pause 

echo ###Clean up the installation directory

rem ---------------------------------------------------------
rem Clean up the installation directory
rem ---------------------------------------------------------

del install-tl.*
del install-tl-windows.*
del nanotex.profile
del pkgs-*
rmdir /s /q tlpkg
rmdir /s /q texmf-dist
del nanotex.profile.win
rem rmdir /s /q auxfiles
for /d %%G in ("install-tl-*") do rmdir /s /q "%%~G"

echo ##############################
echo .                            .
echo nanoTeX installed successfully!
echo .                            .
echo ##############################

pause 
