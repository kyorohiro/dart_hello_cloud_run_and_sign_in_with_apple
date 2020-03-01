

```
$ gcloud auth login
$ gcloud config set run/region asia-northeast1
$ gcloud builds submit --tag gcr.io/firefirestyle/helloworld
$ gcloud beta run deploy --image gcr.io/firefirestyle/helloworld --platform managed
```