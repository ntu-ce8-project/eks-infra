# k6 load testing

## Run tests locally

To run tests locally.

```sh
k6 run test.js
```

## Run tests on Grafana Cloud

Generate your Personal API Token. Go to Testing & synthetics > Performance > Settings > Personal token.

Login with your Personal API Token.

```sh
k6 cloud login --token <PERSONAL-API-TOKEN>
```

To run tests on the cloud.

```sh
k6 cloud test.js
```
