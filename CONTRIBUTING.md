# Contributing

## Getting started

Clone the repository.

```sh
git clone 
```

Pull all changes from the remote repository before making code changes.

```sh
git pull origin main
```

## Branch naming convention

Create a new branch.

```sh
git checkout -b "feature/some-new-feature"
```

Use one of these branch naming conventions:

- `feature/some-feature` - for creating new features and tasks
- `bugfix/some-fix` - for fixing bugs
- `refactor/some-refactoring` - for chores and code clean up
- `docs/some-documentation` - for documentation

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

## Diagramming

## Creating diagrams with Draw.io

All diagrams should end in the `.drawio.svg` file format.

### Generating diagrams with KubeDiagrams

Download [KubeDiagrams](https://github.com/philippemerle/KubeDiagrams).

```sh
pipx install KubeDiagrams
```

Make sure you're in the `docs/images` folder.

```sh
kubectl get all -o yaml | kube-diagrams -o diagram.png -
```
