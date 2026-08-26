test_sources = [
    'hello-world-test',
    'string-sample-test',
    'gee-list-sample-test',
    'gee-set-sample-test',
    'gee-map-sample-test',
    'signal-sample-test',
    'error-domain-sample-test',
    'generics-sample-test',
    'contract-sample-test',
    'name-allocator-test',
    'property-sample-test',
    'async-method-sample-test',
    'delegate-sample-test',
    'constructors-destructors-sample-test',
    'ownership-sample-test',
    'struct-interface-sample-test',
    'parameter-directions-pointers-test',
    'dbus-sample-test',
    'methods-syntax-support-test',
    'readme-sample-test',
]

foreach t : test_sources

    test(
        t,
        executable(
            t,
            files(t + '.vala', 'valapoet-test-util.vala'),
            dependencies: [
                dependency('gee-0.8'),
                valapoet_dep,
            ],
            pie: true,
            install: false,
        ),
    )
endforeach
