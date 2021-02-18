# Submit VASP calculations to Irdis5

This container submits VASP calculations to Iridis5.

## Configuration
### Environment variables

The process is configured through environment variables

| Variable     | Default                | Description                                                                                    |
| ------------ | ---------------------- | ---------------------------------------------------------------------------------------------- |
| `JOB_NAME`   | foldername             | The name of the job. Used to find jobs in the queue                                            |
| `JOB_EMAIL`  | n/a                    | The email address to send notification of finished calculations                                |
| `USERNAME`   | n/a                    | The Iridis5 account used for this calculation                                                  |
| `ALLOCATION` | n/a                    | Provides an environment variable that can be substituted in submit scripts                     |
| `VASP`       | `vasp.5.4.4.intel.std` | The name of the VASP executable on the cluster. Provide full path if this is not on your $PATH |
### Volumes

The container expects some externally mounted volumes to provide information

| Mount point  | Content                                                        |
| ------------ | -------------------------------------------------------------- |
| `/data/vasp` | Contains the VASP input files (INCAR,POSCAR,POTCAR,KPOINTS)    |
| `/ssh`       | Should mount the users private RSA key for password-less login |

> The container expects the private key to reside in `/ssh/id_rsa` with appropriate permissions.

## Usage

### Submitting jobs

You first need to compile a Docker container

```bash
docker build -t vasp-submit -f build/docker/vasp-submit/Dockerfile . 
```

You can then use the container with properly linked mount points and environment variables to submit jobs:

```bash
docker run --rm -it -v "$(pwd):/data/vasp" -v "$HOME/.ssh/my_rsa:/ssh/id_rsa" -e CLUSTER=my-cluster -e HOSTNAME=dns-name-of-cluster -e USERNAME=my-username -e ALLOCATION=my-allocation vasp-submit testing
```

This will:

* use the ssh key stored in `$HOME/.ssh/my_ssh`, the scripts for `mu-cluster`, which is reached at `dns-name-of-cluser`, and `my-username` as login.
* It also provides for an allocation environment variable that is substituted on submit scripts
* Finally, it expects the VASP input files in the `testing` folder, which is also used as the job-name on the clusters queue

### Collecting results

You can compile another Docker container to collect results back

```bash
docker build -t vasp-collect -f build/docker/vasp-collect/Dockerfile .
docker run --rm -it -v "$(pwd):/data/vasp" -v "$HOME/.ssh/my_rsa:/ssh/id_rsa" -e CLUSTER=my-cluster -e HOSTNAME=dns-name-of-cluster -e USERNAME=my-username vasp-collect testing
```

### Using aliases

It is highly recommended to use Aliases for the various docker commands. How you define these, depends on your operating system and shell capabilities. Here an example that could go into a `~/.bashrc` file:

```bash
alias vasp-submit='docker run --rm -it -v "$(pwd):/data/vasp" -v "$HOME/.ssh/my_rsa:/ssh/id_rsa" -e CLUSTER=my-cluster -e HOSTNAME=dns-name-of-cluster -e USERNAME=my-username -e ALLOCATION=my-allocation vasp-submit'
```

