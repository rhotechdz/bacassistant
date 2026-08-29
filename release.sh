#!/bin/bash
git add pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | cut -d' ' -f2)
git commit -m "Bump version to $VERSION"
git tag v$VERSION
git push origin main
git push origin --tags