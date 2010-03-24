@echo off
:: Initialise the environment
	:: These values are as they are for Chris Morgan.
	cd ..\..
	set PAL=%cd%
	cd \
	set ROOT=%cd%
	set PYTHONPATH=F:\PortableApps\pymodules\Sphinx-0.6.5;F:\PortableApps\pymodules\docutils;F:\PortableApps\pymodules\docutils\extras;F:\PortableApps\pymodules\Jinja2-2.3.1;F:\PortableApps\pymodules\Pygments-1.3.1
	set SPHINXBUILD=F:\PortableApps\Python25\python.exe F:\PortableApps\pymodules\Sphinx-0.6.5\sphinx-build.py
	set makensis=%ROOT%:\PortableApps\UnicodeNSISPortable\App\NSIS\makensis.exe
	set PAI=%ROOT%:\PortableApps\PortableApps.comInstallerU\PortableApps.comInstallerU.exe

:: Build the manual
	cd "%PAL%\Other\Source\Manual"
	make.bat release
	cd ..

:: Build PALG
	"%makensis%" "%PAL%\Other\Source\GeneratorWizard.nsi"

:: Build PAL
	"%PAL%\PortableApps.comLauncherGenerator.exe" "%PAL%"

:: Build installer
	"%PAI%" "%PAL%"

:: End
	:: go back where we started
	cd %PAL%\Other\Source
