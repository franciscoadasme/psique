# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## Unreleased

### Fixed

- Raise when PSIQUE fails. ([8e5637c](https://github.com/franciscoadasme/psique/commit/8e5637c))
- Capture stderr when calling PSIQUE. ([96f5762](https://github.com/franciscoadasme/psique/commit/96f5762))

### Documentation

- Update README including Python API. ([1443b26](https://github.com/franciscoadasme/psique/commit/1443b26))

## v1.2 - 2026-03-27

### Fixed

- Ensure path is recognized as file in PSIQUE. ([4145593](https://github.com/franciscoadasme/psique/commit/4145593))

### CI

- Include README in python package. ([5b9ba35](https://github.com/franciscoadasme/psique/commit/5b9ba35))

## v1.1.4 - 2026-03-26

### Added

- Improve Python API. ([e0bc26e](https://github.com/franciscoadasme/psique/commit/e0bc26e))
- Add color to error output. ([f75906d](https://github.com/franciscoadasme/psique/commit/f75906d))
- Add JSON output. ([660fdc3](https://github.com/franciscoadasme/psique/commit/660fdc3))

### Fixed

- Exit on file not found gracefully. ([737b9dc](https://github.com/franciscoadasme/psique/commit/737b9dc))

## v1.1.3 - 2026-03-26

### Added

- Add Python wrapper. ([e0ce310](https://github.com/franciscoadasme/psique/commit/e0ce310))

### CI

- Bundle runtime DLLs in Windows artifact. ([066c17c](https://github.com/franciscoadasme/psique/commit/066c17c))
- Remove Intel-based MacOS build. ([d572781](https://github.com/franciscoadasme/psique/commit/d572781))
- Include Windows binaries. ([9d4db92](https://github.com/franciscoadasme/psique/commit/9d4db92))

## v1.1.2 - 2023-08-24

### Added

- Move out CLI from the [chem.cr](https://github.com/franciscoadasme/chem.cr) repository at [v0.6.0](https://github.com/franciscoadasme/chem.cr/blob/master/CHANGELOG.md#misc-2) to here.
- Add Method section to README. ([63bee80](https://github.com/franciscoadasme/psique/commit/63bee80))
- Add GitHub workflow to create release. ([03b412b](https://github.com/franciscoadasme/psique/commit/03b412b))

### Changed

- Bump chem.cr to v0.6. ([c1e1fe0](https://github.com/franciscoadasme/psique/commit/c1e1fe0))
- Use Chem::Format to select write type. ([94522ed](https://github.com/franciscoadasme/psique/commit/94522ed))
- Format citation. ([a3f459a](https://github.com/franciscoadasme/psique/commit/a3f459a))
- Use version in shard.yml. ([a4331b4](https://github.com/franciscoadasme/psique/commit/a4331b4))

### Documentation

- Update README. ([c5499a1](https://github.com/franciscoadasme/psique/commit/c5499a1))
- Update CLI help message. ([2f4893f](https://github.com/franciscoadasme/psique/commit/2f4893f))
- Better instructions for hooking to software. ([9187f40](https://github.com/franciscoadasme/psique/commit/9187f40))
- Update email. ([c9dc760](https://github.com/franciscoadasme/psique/commit/c9dc760))
- Minor tweaks to README. ([e81dad1](https://github.com/franciscoadasme/psique/commit/e81dad1))

### CI

- Fix build on MacOS. ([bc66791](https://github.com/franciscoadasme/psique/commit/bc66791))
- Fix permissions on release workflow. ([d05b215](https://github.com/franciscoadasme/psique/commit/d05b215))

## v1.0 - 2021-03-01

- Initial release at [v0.5.5](https://github.com/franciscoadasme/chem.cr/releases/tag/v0.5.5) within the [chem.cr](https://github.com/franciscoadasme/chem.cr) repository.
