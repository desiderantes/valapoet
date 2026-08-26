test_sources = [
    # 1:1 Spec & Core Unit Tests
    'attribute-spec-test',
    'valadoc-spec-test',
    'code-block-test',
    'type-name-test',
    'type-spec-test',
    'enum-spec-test',
    'error-domain-spec-test',
    'method-spec-test',
    'field-spec-test',
    'property-spec-test',
    'parameter-spec-test',
    'signal-spec-test',
    'vala-file-test',
    'name-allocator-test',

    # E2E & Feature Integration Sample Tests
    'hello-world-test',
    'string-sample-test',
    'gee-list-sample-test',
    'gee-set-sample-test',
    'gee-map-sample-test',
    'signal-sample-test',
    'error-domain-sample-test',
    'generics-sample-test',
    'contract-sample-test',
    'property-sample-test',
    'async-method-sample-test',
    'delegate-sample-test',
    'constructors-destructors-sample-test',
    'ownership-sample-test',
    'struct-interface-sample-test',
    'parameter-directions-pointers-test',
    'dbus-sample-test',
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
