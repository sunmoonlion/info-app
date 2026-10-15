# Info Consumer Contract Locks

Knowfeed App does not own the Knowledge ingestion schema. The editable source of
truth remains `knowbase-app/contracts/`.

`knowbase-provider-lock.json` pins the compatible contract major and schema
SHA-256 consumed by Info. Contract CI must download or check out the Knowledge
provider artifact, set `KNOWBASE_ARTIFACT_CONTRACT_PATH`, and run the Info
consumer tests. Updating the lock without a passing provider/consumer test is
not a valid contract upgrade.
