FROM ocaml/opam:debian-11-ocaml-${VERSION}@sha256:07a3ace7acb3b5b8129d1695098896303871e1212648e58cfce4b0d4e4a1cac0
USER 1000:1000
WORKDIR /home/opam
RUN for pkg in $(opam pin list --short); do opam pin remove "$pkg"; done
RUN opam repository remove -a multicore || true
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN opam init --reinit -ni
ENV OPAMDOWNLOADJOBS="1"
ENV OPAMERRLOGLEN="0"
ENV OPAMSOLVERTIMEOUT="500"
ENV OPAMPRECISETRACKING="1"
COPY --chown=1000:1000 otoggl.opam CHANGES.md CONTRIBUTING.md LICENSE README.md dune-project ./otoggl/
COPY --chown=1000:1000 example/ ./otoggl/example
COPY --chown=1000:1000 lib/ ./otoggl/lib
COPY --chown=1000:1000 test/ ./otoggl/test
RUN opam update --depexts
RUN opam install --deps-only ./otoggl && opam install -v ./otoggl ; \
    res=$?; \
    test "$res" != 31 && exit "$res"; \
    export OPAMCLI=2.0; \
    build_dir=$(opam var prefix)/.opam-switch/build; \
    failed=$(ls "$build_dir"); \
    for pkg in $failed; do \
    if opam show -f x-ci-accept-failures: "$pkg" | grep -qF "\"debian-11\""; then \
    echo "A package failed and has been disabled for CI using the 'x-ci-accept-failures' field."; \
    fi; \
    done; \
    exit 1
ENV OPAMCRITERIA="+removed,+count[version-lag,solution]"
ENV OPAMEXTERNALSOLVER="builtin-0install"
RUN opam update --depexts
RUN opam remove ./otoggl && opam install --deps-only ./otoggl && opam install -v ./otoggl ; \
    res=$?; \
    test "$res" != 31 && exit "$res"; \
    export OPAMCLI=2.0; \
    build_dir=$(opam var prefix)/.opam-switch/build; \
    failed=$(ls "$build_dir"); \
    for pkg in $failed; do \
    if opam show -f x-ci-accept-failures: "$pkg" | grep -qF "\"debian-11\""; then \
    echo "A package failed and has been disabled for CI using the 'x-ci-accept-failures' field."; \
    fi; \
    done; \
    exit 1
