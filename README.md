# OToggl

[![Actions Status](https://github.com/christophe-riolo/otoggl/workflows/CI/badge.svg)](https://github.com/christophe-riolo/otoggl/actions)

Bindings for Toggl API in OCaml.

[Toggl Tracking](https://tack.toggl.com) is a time tracking solution that comes
with multiple features that would be out of scope of this document.

This project tries to implement as many features as possible, starting with the
ones needed to implement a basic time tracker synchronized with Toggl. As the
Toggl API is quite rich and this is a one person's work, if you need specific
endpoints to be implemented, please
[file an issue](https://github.com/unitrack-time-tracking/OToggl/issues).

## Installation

This package is not yet released on Opam so for the moment you need to pin it to
this repository:

```bash
opam pin add otoggl https://github.com/unitrack-time-tracking/OToggl.git#0.2.1
opam install otoggl
```

## Overview

### Module `Toggl.Auth`

This module contains the necessary modules and functors to create an
authenticated client to connect to the Toggl Tracking API.

## Module `Toggl.Api`

This module contains a functor, which takes as argument a Client module created
with the previous module, and which then gives access to the following modules.

### `TimeEntry`

A time entry is the basic time tracking unit. It consists in a task with a
description and certain time attributes (start and end times, duration), as well
as specific identifiers (own id, workspace, user, project) and tags.

This module contains the manipulation functions to start, stop, create, get ,
delete and modify time entries.

### `Project`

A project regroups time entries. A time entry can have at most one project, and
we can get statistics by project.

### `Workspace`

In Toggl, a Workspace is a high level entity that regroups projects and time
entries, and it can have specific settings as well. 

## Contributing

Take a look at our [Contributing Guide](CONTRIBUTING.md).
