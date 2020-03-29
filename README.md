# oosh

> object-oriented-like convention for namespaceing ZSH scripts

**WARNING** yet to evolve from personal tool to proper OSS, v1 todos:

* [ ] remove hard coded `rc` file
* [ ] legit install scripts
* [ ] composable within existing zsh configs
* [ ] OS support beyond darwin
* [ ] remove bin/oocc & cc/*, establish plugin arch or something...

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
    `fn rebuild` () {
        node-gyp rebuild
    }
}
```

to load and use the script object:

```sh
oosh 
cd example
. ./pkg.sh
pkg.example.hello "bob"
```

use in `package.json`:

```json
{
  "name": "example",
  "version": "0.0.1",
  "description": "",
  "main": "index.js",
  "scripts": {
    "rebuild": "oosh '. pkg.sh; pkg.example.rebuild;'",
    "bench": "oosh '. pkg.sh; pkg.example.bench;'",
    "test": "oosh '. pkg.sh; pkg.example.test;'"
  },
  "author": "",  
  "dependencies": {},
  "devDependencies": {
    "oosh": "d4tocchini/oosh",
    "node-gyp: "*"
  }
}
```

