# Contributing

## Setup your development environment

You need Esy, you can install the latest version from [npm](https://npmjs.com):

```bash
yarn global add esy@latest
# Or
npm install -g esy@latest
```

Then run the `esy` command from this project root to install and build depenencies.

```bash
esy
```

This project uses [Dune](https://dune.build/) as a build system, if you add a dependency in your `package.json` file, don't forget to add it to your `dune` and `dune-project` files too.

### Running Examples

After building the project, you can run the example binaries with:

```bash
esy dune exec examples/<example>.exe
```

For instance, to run the `simple.ml` example, you can type:

```bash
esy dune exec examples/simple.exe
```

### Running Tests

You can run the test compiled executable:

```bash
esy test
```

### Building documentation

Documentation for the libraries in the project can be generated with:

```bash
esy doc
open-cli $(esy doc-path)
```

This assumes you have a command like [open-cli](https://github.com/sindresorhus/open-cli) installed on your system.

> NOTE: On macOS, you can use the system command `open`, for instance `open $(esy doc-path)`

### Releasing

To create a release and publish it on Opam, first update the `CHANGES.md` file with the last changes and the version that you want to release.
The, you can run the script `script/release.sh`. The script will perform the following actions:

- Create a tag with the version found in `otoggl.opam`, and push it to your repository.
- Create the distribution archive.
- Publish the distribution archive to a Github Release.
- Update the repository's `gh-pages` branch with the latest documentation.
- Submit a PR on Opam's repository.

From there, the CI/CD will take care of publishing your documentation, create a github release, and open a PR with your version on `opam-repository`.

### Repository Structure

The following snippet describes OToggl's repository structure.

```text
.
├── example/
|   Source for otoggl's examples. This links to the library defined in `lib/`.
│
├── lib/
|   Source for OToggl's library. Contains OToggl's core functionnalities.
│
├── test/
|   Unit tests and integration tests for OToggl.
│
├── dune-project
|   Dune file used to mark the root of the project and define project-wide parameters.
|   For the documentation of the syntax, see https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
│
├── LICENSE
│
├── package.json
|   Esy package definition.
|   To know more about creating Esy packages, see https://esy.sh/docs/en/configuration.html.
│
├── README.md
│
└── otoggl.opam
    Opam package definition.
    To know more about creating and publishing opam packages, see https://opam.ocaml.org/doc/Packaging.html.
```
