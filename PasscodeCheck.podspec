Pod::Spec.new do |s|
    s.name          = 'PasscodeCheck'
    s.version       = '1.0'
    s.license       = 'Apache License 2.0'

    s.summary       = 'iMAS pascode-check, set passcode config profiles and check for conformance'
    s.description   = %[
        iOS does not offer a simple API check for developers to assess the security level of an iOS device. iMAS - PasscodeCheck security control offers open source code, which can be easily added to any iOS application bundle and release process.
    ]
    s.homepage      = 'https://github.com/project-imas/passcode-check'
    s.authors       = {
        'MITRE' => 'imas-proj-list@lists.mitre.org'
    }
    
    s.source        = {
        :git => 'https://github.com/project-imas/passcode-check.git',
        :tag => s.version.to_s
    }
    s.source_files  = 'PasscodeSet/PasscodeSet/iMAS_PasscodeCheck.{m,h}'
    s.frameworks    = 'Security'
    s.platform      = :ios
    s.ios.deployment_target = '6.1'
    s.requires_arc  = true
end