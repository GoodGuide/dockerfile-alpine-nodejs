This directory holds a file which provides a simple HTTP service for the purpose of benchmarking NodeJS perf via ApacheBench. The intention is to compare performance of the Musl build under Alpine versus the official glibc build provided by Node core.

An example of how to run the benchmark:

```shell
make build-sample-isolated-runtime
utils/bm/benchmark alpine-nodejs:isolated
```
