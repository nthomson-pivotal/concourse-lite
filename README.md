# Concourse Lite

A simple Vagrant setup for running Concourse 3.14 locally for testing etc. 

**Warning:** This does not setup Concourse in a secure manner, and should only be used for local installations.

## Usage

Pre-requisites for use are:

- Virtualbox
- Vagrant
- Vagrant Disk Size plugin (`vagrant plugin install vagrant-disksize`)

Checkout the project and then run:

`vagrant up`

Once complete, Concouse will be accessible via the browser at:

`http://localhost:8080`

The default credentials are username `admin` and password `admin`.

There is also a convenience script provided to login via `fly`:

```./fly-login.sh

fly -t local pipelines```

To tear down the setup run:

`vagrant destroy`