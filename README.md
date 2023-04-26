# opensearch-operator-assets

### 1. releasing / packaging along with integratin tests running:

#### Options:
- `--version`: opensearch version, default: `2.2.0`
- `--platform`: target platform, default: `linux`
- `--plugins`: plugins to install in the tarball, default: `security asynchronous-search cross-cluster-replication`

#### Run:
1. `cd release`
2. ```
   bash run.sh

   # or
    
   bash run.sh --version 2.2.0 --platform linux
   
   # or to set plugins and their tag versions (default to 0 if not set)
   bash run.sh \
       --version 2.2.0 \
       --platform linux \
       --plugins "security asynchronous-search:2 cross-cluster-replication:0"
   ```
