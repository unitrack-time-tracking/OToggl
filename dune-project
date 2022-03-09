(lang dune 2.0)
(name otoggl)
(version 0.3.1)
(source (github unitrack-time-tracking/OToggl))
(license MIT)
(authors "Christophe Riolo Uusivaara")
(maintainers "Christophe Riolo Uusivaara")

(generate_opam_files true)

(package
 (name otoggl)
 (synopsis "Bindings for Toggl API in OCaml")
 (description "Bindings for Toggl API in OCaml")
 (depends
  (ocaml (>= 4.08.0))
  (atdgen (and :build (>= 2)))
  (atdgen-runtime (>= 2))
  (base64 (>= 3))
  (containers (>= 3.6))
  (dune (>= 2.0))
  (piaf (>= 0))
  (ppx_deriving (and (>= 4) (< 5)))
  (ptime (>= 0))
  (alcotest :with-test)
  (alcotest-lwt :with-test)
  (odoc :with-doc)
))

(package
 (name dev)
 (synopsis "Dev dependencies for OToggl")
 (depends
  (dune-release (> 0))
  (merlin (> 0))
  (ocamlformat (> 0))
  (utop (> 0))
))
