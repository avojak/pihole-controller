# SPDX-FileCopyrightText: 2024 Andrew Vojak
# SPDX-License-Identifier: GPL-3.0-or-later

conf_data = configuration_data()
conf_data.set('APP_ID', application_id)
conf_data.set('APP_NAME', application_name)
conf_data.set('VERSION', '@0@@1@'.format(meson.project_version(), version_suffix))
conf_data.set('RESOURCE_PATH', application_resource_path)
conf_data.set('DEVELOPER_NAME', 'Andrew Vojak')
conf_data.set('DEVELOPER_EMAIL', 'andrew.vojak@gmail.com')
conf_data.set('DEVELOPER_WEBSITE', 'https://avojak.com')

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

pixels_files = files(
    'Application.vala',
    'MainWindow.vala',
    'Core' / 'Client.vala',
    'Core' / 'SecretManager.vala',
    'Core' / 'ServerDatabase.vala',
    'Core' / 'ServerRepository.vala',
    'Core' / 'Settings.vala',
    'Core' / 'SQLClient.vala',
    'Models' / 'ServerDetails.vala',
    'Views' / 'WelcomeView.vala',
    'Views' / 'Preferences' / 'ServersPreferencePage.vala',
    'Widgets' / 'PreferencesDialog.vala',
    'Widgets' / 'ServerPreferenceGroup.vala',
    'Widgets' / 'ServerStatusIcon.vala'
)

executable(
    application_id,
    pixels_files,
    config_header,
    asresources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gtk4', version: '>= 4.11.3'),
        dependency('gee-0.8'),
        dependency('libadwaita-1', version: '>= 1.5'),
        dependency('sqlite3'),
        dependency('libsecret-1')
        # dependency('libsoup-3.0'),
        # dependency('rest-1.0')
    ],
    vala_args: vala_args,
    install: true
)