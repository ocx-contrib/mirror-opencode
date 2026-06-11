# tests/smoke.star — stable across upstream opencode releases.
# Branch on the typed platform constant; never a string compare.
OPENCODE = "opencode.exe" if ocx.target_platform.os == ocx.os.Windows else "opencode"

# opencode is a bun-compiled binary. The darwin/amd64 (Intel) slice is tested on
# the arm64 macos-14 runner via Rosetta 2 (GitHub has no native Intel runner).
# Rosetta mis-reports AVX support in cpuid, so bun's JavaScriptCore JIT emits AVX
# instructions Rosetta can't execute → SIGILL (exit 132). This is a runtime JIT
# path, so the -baseline build doesn't avoid it. Disabling the JSC JIT forces the
# interpreter, which runs cleanly under Rosetta. Harmless on every other platform
# (native execution), so set it for all legs to keep the test uniform.
RUN_ENV = {"BUN_JSC_useJIT": "0"}

# Tier 1 + 2: liveness on the composed PATH + semver version shape.
# `opencode --version` prints a bare "X.Y.Z" — assert the shape, never the value.
r_version = ocx.run(OPENCODE, "--version", env=RUN_ENV)
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior on hermetic input — deterministic, offline.
# `completion bash` generates a yargs completion script with a stable marker.
r_comp = ocx.run(OPENCODE, "completion", "bash", env=RUN_ENV)
expect.ok(r_comp)
expect.contains(r_comp.stdout, "opencode-completions")
