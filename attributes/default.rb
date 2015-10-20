# encoding: utf-8
# This file is part of the Mconf project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

mconf_dir = "/var/mconf"

default['mconf']['user'] = "mconf"
default['mconf']['dir'] = mconf_dir
default['mconf']['tools']['dir'] = "#{mconf_dir}/tools"
default['mconf']['log']['dir'] = "#{mconf_dir}/log"

# set true if you want your Mconf-Live server to act as a standalone server or
# if you want a recording server that will query for encrypted recordings
default['mconf']['recording_server']['enabled'] = true
default['mconf']['recording_server']['private_key_path'] = "/usr/local/bigbluebutton/core/scripts/private.pem"
default['mconf']['recording_server']['public_key_path'] = "/usr/local/bigbluebutton/core/scripts/public.pem"
default['mconf']['recording_server']['get_recordings_url'] = nil

default['mconf']['branding']['logo'] = "logo.png"
default['mconf']['branding']['copyright_message'] = "© 2015 <a href='http://www.mconf.org' target='_blank'>http://www.mconf.org</a>"
default['mconf']['branding']['background'] = ""

default['mconf']['config_xml']['show_recording_notification'] = true

default['bbb']['bigbluebutton']['repo_url'] = "http://mconf-live-ci.nuvem.ufrgs.br/apt/production"
default['bbb']['bigbluebutton']['key_url'] = "http://mconf-live-ci.nuvem.ufrgs.br/apt/public.asc"
default['bbb']['bigbluebutton']['components'] = ["mconf-trusty" , "main"]
default['bbb']['bigbluebutton']['package_name'] = "mconf-live"

default['ffmpeg']['git_revision'] = "n2.4.2"
default['ffmpeg']['compile_flags'] = [ "--enable-x11grab",
                                       "--enable-gpl",
                                       "--enable-version3",
                                       "--enable-postproc",
                                       "--enable-libvorbis",
                                       "--enable-libvpx",
                                       "--enable-librtmp" ]
