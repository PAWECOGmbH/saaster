# Stellensuche.ch

## Update from saaster

1. Create update branch. (e.g update/saaster-dev)
2. Checkout to the newly created branch. (e.g update/saaster-dev)
3. Execute following commands:

``` bash
git remote add upstream https://github.com/PAWECOGmbH/saaster.git
git pull upstream development
```

4. If there are any conflicts, solve them. Then sync the branch with the remote.

5. Remove the upstream and verify that only two remotes are listed:
``` bash
git remote rm upstream
git remote -v

# Expected result of 'git remote -v'
origin  https://github.com/PAWECOGmbH/stellensuche.git (fetch)
origin  https://github.com/PAWECOGmbH/stellensuche.git (push)
```

6. Create pull request to development. (e.g update/saaster-dev -> development)
7. Merge pull request.
8. Done! Now the development branch should be updated.
