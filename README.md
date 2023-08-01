# build engine

Scripts to build our custom Flutter Engine.

* ./build_engine/mac_build_and_upload.sh - builds the engine for MacOS and pushes it to GCS
* ./build_engine/win_build_and_upload.sh - builds gen_snapshot for windows and pushes it to GCS
* ./build_engine/linux_build_and_upload.sh - builds gen_snapshot for linux and pushes it to GCS


## Cloud Config

You can access our linux GHA instance via:

gcloud compute ssh --zone "us-central1-a" "gha@gha-runner-1" --project "code-push-prod"
 