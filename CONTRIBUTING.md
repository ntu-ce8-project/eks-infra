# Contributing

## Getting started

Clone the repository.

```sh
git clone 
```

Stash your changes or commit them locally.

```sh
git stash
```

Pull all changes from the remote repository. Do this before you push your code changes.

```sh
git pull --rebase
```

After pulling the changes you can unstash, commit, and push your changes.

```sh
git stash pop
```

## Deployment

Deploy the online retail store.

```sh
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
kubectl wait --for=condition=available deployments --all
```

Get the URL for the online retail store.

```sh
kubectl get service ui
```

Teardown the online retail store.

```sh
kubectl delete -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
```

## Generating diagrams

Download [KubeDiagrams](https://github.com/philippemerle/KubeDiagrams).

```sh
pipx install KubeDiagrams
```

Make sure you're in the `docs/images` folder.

```sh
kubectl get all -o yaml | kube-diagrams -o diagram.png -
```
