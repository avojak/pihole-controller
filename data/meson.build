install_data(
    'assets' / 'icons' / '@0@.svg'.format(application_id),
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps'
    # rename: '@0@.svg'.format(application_id)
)

schema_data = configuration_data()
schema_data.set('APPLICATION_ID', application_id)
schema_data.set('SCHEMA_PATH', application_schema_path)
configure_file(
    input: 'com.avojak.piholecontroller.gschema.xml.in',
    output: '@0@.gschema.xml'.format(application_id),
    configuration: schema_data,
    install: true,
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

desktop_data = configuration_data()
desktop_data.set('APPLICATION_ID', application_id)
i18n.merge_file(
    input: configure_file(
        input: 'com.avojak.piholecontroller.desktop.in.in',
        output: 'com.avojak.piholecontroller.desktop.in',
        configuration: desktop_data
    ),
    output: '@0@.desktop'.format(application_id),
    type: 'desktop',
    po_dir: meson.source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

appstream_data = configuration_data()
appstream_data.set('APPLICATION_ID', application_id)
i18n.merge_file(
    input: configure_file(
        input: 'com.avojak.piholecontroller.appdata.xml.in.in',
        output: 'com.avojak.piholecontroller.appdata.xml.in',
        configuration: appstream_data
    ),
    output: '@0@.appdata.xml'.format(application_id),
    po_dir: meson.source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

resources_data = configuration_data()
resources_data.set('RESOURCE_PATH', application_resource_path)
resources_data.set('APPLICATION_ID', application_id)
asresources = gnome.compile_resources(
  'as-resources',
  configure_file(
    input: 'com.avojak.piholecontroller.gresource.xml.in',
    output: 'com.avojak.piholecontroller.gresource.xml',
    configuration: resources_data
  ),
  source_dir: 'data'
)