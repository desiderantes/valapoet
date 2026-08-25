project('valapoet', 'vala', 'c', meson_version: '>= 1.10.0', version: '0.2.0')

valac = meson.get_compiler('vala')

glib_version = '2.80'

pkgconfig = import('pkgconfig')
gnome = import('gnome')

dependencies = [
    dependency('glib-2.0', version: '>=@0@'.format(glib_version)),
    dependency('gobject-2.0', version: '>=@0@'.format(glib_version)),
    dependency('gio-2.0', version: '>=@0@'.format(glib_version)),
]

version_split = meson.project_version().split('.')
MAJOR_VERSION = version_split[0]
MINOR_VERSION = version_split[1]
MICRO_VERSION = version_split[2]
API_VERSION = version_split[0] + '.' + version_split[1]
add_project_arguments(
    ['--abi-stability', '--hide-internal', '--enable-experimental'],
    language: 'vala',
)

subdir('src')
if get_option('enable_tests')
    subdir('test')
endif
