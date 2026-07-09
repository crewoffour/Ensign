# Snapshot references

Committed golden renders for the snapshot suite (SnapshotTests.swift).
Each `<sidc>.png` here is rendered fresh on every `swift test` run and
compared pixel-by-pixel with tolerance; the files in this directory are
the test list.

To record or refresh, from the package root:

```
swift run -c release ensign-catalog render tools/extract/sidcs-maritime.txt Tests/EnsignRenderTests/Snapshots 200
```

Re-record only after an intentional rendering change that the milsymbol
oracle in tools/extract has verified. The oracle referees changes
against milsymbol; these snapshots freeze the verified result so plain
`swift test` catches regressions with no Node in the loop.
