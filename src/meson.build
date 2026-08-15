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
    'signal-spec.vala',
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
    ],
    install: true,
)

valapoet_dep = declare_dependency(
    link_with: libvalapoet,
    include_directories: include_directories('.'),
    dependencies: dependencies,
)

# we should replace this with gnome.generate_gir()
if g_ir_compiler.found()
    custom_target(
        'libvalapoet-typelib',
        command: [
            g_ir_compiler,
            '--shared-library',
            'libvalapoet-@0@.so'.format(API_VERSION),
            '--output',
            '@OUTPUT@',
            meson.current_build_dir() / 'ValaPoet-' + API_VERSION + '.gir',
        ],
        output: 'ValaPoet-' + API_VERSION + '.typelib',
        depends: libvalapoet,
        install: true,
        install_dir: join_paths(get_option('libdir'), 'girepository-1.0'),
    )
endif

pkgconfig.generate(
    libvalapoet,
    subdirs: 'valapoet-' + API_VERSION,
    version: API_VERSION,
    name: 'valapoet',
    filebase: 'valapoet-' + API_VERSION,
    description: 'A Vala API for generating .vala files',
)

if get_option('enable_valadoc')
    valadoc = find_program('valadoc')
    valapoet_docs = custom_target(
        'valapoet_apidocs',
        input: sources,
        install: true,
        # FIXME: Installing to tmp, so the target will be built
        #        the problem is we cannot access a subfolder of the
        #        buildtarget via the output parameter.
        #        Find a nicer solution
        install_dir: get_option('datadir') / 'devhelp' / 'books',
        command: [
            valadoc,
            '-o',
            meson.current_build_dir() / 'ValaPoet-' + API_VERSION,
            '--doclet',
            'devhelp',
            '@INPUT@',
            '--force',
        ],
        output: 'ValaPoet-' + API_VERSION,
    )

    install_subdir(
        meson.current_build_dir() / 'ValaPoet-' + API_VERSION / 'ValaPoet-' + API_VERSION,
        install_dir: get_option('datadir') / 'devhelp' / 'books',
    )
endif
