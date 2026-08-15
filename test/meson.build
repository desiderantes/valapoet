libvala_dep = dependency('libvala-0.56', version: '>= 0.56.0')

test_sources = [
    'hello-world-test.vala',
    'string-sample-test.vala',
    'gee-list-sample-test.vala',
    'gee-set-sample-test.vala',
    'gee-map-sample-test.vala',
    'signal-sample-test.vala',
    'error-domain-sample-test.vala',
    'generics-sample-test.vala',
    'contract-sample-test.vala',
    'name-allocator-test.vala',
    'property-sample-test.vala',
    'async-method-sample-test.vala',
    'delegate-sample-test.vala',
    'constructors-destructors-sample-test.vala',
    'ownership-sample-test.vala',
    'struct-interface-sample-test.vala',
    'parameter-directions-pointers-test.vala',
    'dbus-sample-test.vala',
    'methods-syntax-support-test.vala',
    'readme-sample-test.vala',
]

foreach t : test_sources
    test_name = t.split('.')[0]

    test(
        test_name,
        executable(
            test_name,
            files(t, 'valapoet-test-util.vala'),
            dependencies: [
                dependency('gee-0.8'),
                libvala_dep,
                valapoet_dep,
            ],
            vala_args: ['--pkg', 'gee-0.8', '--pkg', 'libvala-0.56'],
            pie: true,
            install: false,
        ),
    )
endforeach
