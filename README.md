Blockchain Explorer
===================

Inspect details of Ethereum blocks in real-time.

# Getting started

Blockchain Explorer connects directly to an Ethereum RPC server from the
browser, no server components other than a running ethereum node are necessary.

Just build it:

```bash
$ git clone https://github.com/shmookey/bc-explore
$ cd bc-explore
$ elm-package install
$ mkdir build
$ ln -s `pwd`/resources build/resources
$ make
```

And navigate to repository directory in your browser. You'll need to enable
CORS support in geth (e.g. `--rpccors=http://yoursite.com:8080`) with the URL 
domain and port for your web content.


