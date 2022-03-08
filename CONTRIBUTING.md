# Contributing

## Prerequisites

You need Opam. To install it, follow the instructions on [the opam webpage](https://opam.ocaml.org/doc/Install.html).

You obviously need to have Git installed if you want to contribute too.

## Setting up your repository

Fork and clone the repository. You will then probably want to create a local
switch. Choose your favorite OCaml version from the list and create your switch

```sh
opam switch list-available
opam switch create . <version chosen> --deps-only --with-test --with-doc
eval $(opam env)
```

The installation of the dependencies can take some time as they are compiled.

To run the integration tests you will also need a Toggl token that you can find
from your Toggl account.

```sh
export toggl_token=<your token>
```

You may want to use [direnv](https://github.com/direnv/direnv/) to load it
automatically and ease your workflow.

## Building and testing

This project uses [Dune](https://dune.build/) as a build system. To build the
project just run `dune build` at the root of the project To run the tests you
also use the same command with an argument:

```sh
dune build                    # compile the project
dune build @test/runtest      # run the unit tests
dune build @test/runtest-slow # run the unit tests and the integration tests
dune build @test/runtest -w   # run the unit tests every time you modify the project (watch mode)
```

If you want to perform manual testing, you can use `utop`, and the `Toggl` module will be accessible:

```sh
dune utop
```

## Updating the dependencies

There are two Opam packages : `otoggl.opam` is the main package and `dev.opam`
is a fake package that contains the development dependencies.

To update the dependencies, modify the `dune-project` file and build with `dune build`, that will regenerate
the Opam files. Once this is done, reinstall the dependencies:

```sh
dune build
opam install . --deps-only -td
```

## Running Examples

After building the project, you can run the example binaries with:

```bash
dune exec examples/<example>.exe
```

For instance, to run the `simple.ml` example, you can type:

```bash
dune exec examples/simple.exe
```

### Building documentation

Documentation for the libraries in the project can be generated with:

```bash
dune build @doc
```

The documentation is generated in the build directory `_build/default/_doc/_html`

--------------------------------------------------------------------------------

### Releasing

To create a release and publish it on Opam, first update the `CHANGES.md` file with the last changes and the version that you want to release.
The, you can run the script `script/release.sh`. The script will perform the following actions:

- Create a tag with the version found in `otoggl.opam`, and push it to your repository.
- Create the distribution archive.
- Publish the distribution archive to a Github Release.
- Update the repository's `gh-pages` branch with the latest documentation.
- Submit a PR on Opam's repository.

From there, the CI/CD will take care of publishing your documentation, create a github release, and open a PR with your version on `opam-repository`.

## Repository Structure

The following snippet describes OToggl's repository structure.

```text
.
├── dune-project
|   Dune file used to mark the root of the project and define project-wide parameters.
|   For the documentation of the syntax, see https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
│
├── LICENSE
│
├── README.md
│
├── example/
|   Source for otoggl's examples. This links to the library defined in `lib/`.
│
├── lib/
|   Source for OToggl's library. Contains OToggl's core functionnalities.
│
├── test/
|   Unit tests and integration tests for OToggl.
│
├── otoggl.opam
|   Opam package definition (generated).
|   To know more about creating and publishing opam packages, see https://opam.ocaml.org/doc/Packaging.html.
│
└── dev.opam
    Opam package for development dependencies (generated)
```
