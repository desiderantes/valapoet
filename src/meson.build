conf = configuration_data()
conf.set('prefix', get_option('prefix'))
conf.set('libdir', get_option('libdir'))
conf.set('PROJECT_NAME', 'valapoet')
conf.set('VERSION', meson.project_version())
conf.set('MAJOR_VERSION', MAJOR_VERSION)
conf.set('MINOR_VERSION', MINOR_VERSION)
conf.set('MICRO_VERSION', MICRO_VERSION)
conf.set('API_VERSION', API_VERSION)

sources = files(
    'type-name.vala',
    'pointer-type-name.vala',
    'array-type-name.vala',
    'parameterized-type-name.vala',
    'type-variable-name.vala',
    'name-allocator.vala',
    'method-spec.vala',
    'code-block.vala',
    'property-spec.vala',
    'attribute-spec.vala',
    'delegate-name.vala',
    'class-name.vala',
    'parameter-spec.vala',
    'vala-file.vala',
    'vala-writer.vala',
    'field-spec.vala',
    'type-spec.vala',
    'enum-spec.vala',
    'signal-spec.vala',
    'modifier.vala',
    'valadoc-spec.vala',
)

libvalapoet = library(
    'valapoet-' + API_VERSION,
    sources,
    vala_header: 'valapoet.h',
    vala_vapi: 'valapoet-' + API_VERSION + '.vapi',
    vala_gir: 'ValaPoet-' + API_VERSION + '.gir',
    dependencies: dependencies,
    vala_args: [
        '--abi-stability',
        '--enable-experimental',
        '--hide-internal',
    ],
    install: true,
)

valapoet_dep = declare_dependency(
    link_with: libvalapoet,
    include_directories: include_directories('.'),
    dependencies: dependencies,
)

pkgconfig.generate(
    libvalapoet,
    subdirs: 'valapoet-' + API_VERSION,
    version: API_VERSION,
    name: 'valapoet',
    filebase: 'valapoet-' + API_VERSION,
    description: 'A Vala API for generating .vala files',
)

if get_option('enable_valadoc')
    valadoc = find_program('valadoc', required: false)
    if valadoc.found()
        valapoet_docs = custom_target(
            'valapoet_apidocs',
            input: sources,
            output: 'ValaPoet-' + API_VERSION,
            command: [
                valadoc,
                '-o',
                meson.current_build_dir() / 'ValaPoet-' + API_VERSION,
                '--doclet',
                'devhelp',
                '--pkg',
                'gee-0.8',
                '--pkg',
                'gio-2.0',
                '--pkg',
                'glib-2.0',
                '--pkg',
                'gobject-2.0',
                '--force',
                '@INPUT@',
            ],
            install: true,
            install_dir: get_option('datadir') / 'devhelp' / 'books',
        )
    endif
endif
