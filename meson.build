# SPDX-FileCopyrightText: 2024 Andrew Vojak
# SPDX-License-Identifier: GPL-3.0-or-later

project('com.avojak.piholecontroller', 'vala', 'c', version: '0.1.0')

if get_option('profile') == 'development'
  profile = '.Devel'
  name_suffix = ' (Development)'
  path_suffix = 'Devel/'
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD').stdout().strip()
  if vcs_tag == ''
    version_suffix = '-devel'
  else
    version_suffix = '-@0@'.format(vcs_tag)
  endif
else
  profile = ''
  name_suffix = ''
  path_suffix = ''
  version_suffix = ''
endif

gnome = import('gnome')
i18n = import('i18n')

# application_id = meson.project_name() #'@0@@1@'.format(meson.project_name(), profile)
application_id = '@0@@1@'.format(meson.project_name(), profile)
application_schema_path = '/com/avojak/piholecontroller/@0@'.format(path_suffix)
application_resource_path = '/com/avojak/piholecontroller/@0@'.format(path_suffix)
application_name = 'Pi-hole Controller@0@'.format(name_suffix)

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(application_id), language: 'c')
add_global_arguments('-DG_LOG_DOMAIN="@0@"'.format(application_id), language: 'c')

vala_args = [
    '--pkg', 'posix',
    '--pkg', 'linux',
    '--vapidir', join_paths(meson.current_source_dir(), 'vapi')
]

# asresources = gnome.compile_resources(
#   'as-resources',
#   'data' / 'gresource.xml',
#   source_dir: 'data'
# )

subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('build-aux' / 'meson' / 'post_install.py')