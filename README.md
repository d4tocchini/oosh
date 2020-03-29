# oosh

> object-oriented-like convention for namespaceing ZSH scripts

**WARNING** yet to evolve from personal tool to proper OSS, v1 todos:

[ ] remove hard coded `rc` file
[ ] legit install scripts
[ ] composable within existing zsh configs
[ ] OS support beyond darwin

## install

```sh
npm i -g d4tocchini/oosh
```

## usage

scripts for an example project can be namespaced in a object like syntaxt like so, `example/pkg.sh`:

```sh
`space pkg`
function () {
    `mod example`
    `fn hello` () {
        echo "Greetings \"${1}\", from $0"
    }
}
```

to load and use the script object:

```sh
oosh
src example/pkg.sh
pkg.example.hello "bob"
```


