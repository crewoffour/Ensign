# Contributing to Ensign

Thanks for your interest. A few ground rules keep the library
trustworthy:

- Rendering changes must pass the oracle. `tools/extract/README`
  covers the pipeline: reference-render against milsymbol, render with
  ensign-catalog, diff. New rendering features need new oracle rows.
- The generated icon library (`Sources/EnsignCore/Generated/`) is
  never edited by hand; it is rebuilt by `tools/extract/build-corpus.js`
  against the pinned milsymbol version.
- Symbol table questions are adjudicated against the standard (JMSML
  for 2525D-era content); decisions of record go in `ENSIGN_PLAN.md`.
- A render key must change when rendering changes and must not change
  when it does not. Bumping `RenderKey.version` is a minor-release
  event, called out in the CHANGELOG.
- `swift test` green, including the snapshot suite; re-record
  snapshots only with oracle-verified changes.

By contributing you agree your contributions are licensed under
Apache 2.0.
