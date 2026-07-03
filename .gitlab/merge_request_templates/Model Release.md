## Model release

- [ ] Model ID and exact immutable revision are recorded in `values/gx10.yaml`.
- [ ] LiteLLM and vLLM images are pinned by immutable digest.
- [ ] Model license and source were reviewed.
- [ ] `trustRemoteCode` remains false, or an approved exception is linked.
- [ ] Context, concurrency, memory, and quantization settings were benchmarked together.
- [ ] `sh scripts/validate-helm.sh` passed.
- [ ] Rendered manifest was reviewed.

## Expected effect

- [ ] Stable `company-code` alias remains unchanged.
- [ ] One vLLM pod will be recreated.
- [ ] Planned interruption is acceptable.
- [ ] Rollback commit is identified.
