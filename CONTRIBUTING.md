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
kubectl apply -k apps/shop
```

Get the URL for the online retail store.

```sh
kubectl get ingress ui
```

Teardown the online retail store.

```sh
kubectl delete -k apps/shop
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
