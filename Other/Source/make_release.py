#!/usr/bin/env python

import os
from ConfigParser import RawConfigParser

appinfo = RawConfigParser()
appinfo.read(os.path.abspath(os.path.dirname(__file__)
    + os.path.sep + '..'
    + os.path.sep + '..'
    + os.path.sep + 'App'
    + os.path.sep + 'AppInfo'
    + os.path.sep + 'appinfo.ini'))

release = appinfo.get('Version', 'DisplayVersion')
directory = 'PortableApps.com Launcher %s' % release

if 'Alpha' in release or 'Beta' in release or 'Release Candidate' in release:
    parent_directory = 'PortableApps.com Launcher Test'
else:
    parent_directory = 'PortableApps.com Launcher'

installer_filename = 'PortableApps.comLauncher_%s.paf.exe' % release.replace(' ', '_')

# Piped to `sftp chriswombat,portableapps@frs.sourceforge.net`
print 'cd "/home/pfs/project/p/po/portableapps/%s"' % parent_directory
print '-mkdir "%s"' % directory # -, don't halt if it already exists
print 'cd "%s"' % directory
print '-rm %s' % installer_filename # delete it if it exists
print 'put %s' % installer_filename
