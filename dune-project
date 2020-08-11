(lang dune 2.0)
(name otoggl)
(version 0.2.1)
(source (github christophe-riolo/otoggl))
(license MIT)
(authors "Christophe Riolo Uusivaara")
(maintainers "Christophe Riolo Uusivaara")

(generate_opam_files true)

(package
 (name otoggl)
 (synopsis "Bindings for Toggl API in OCaml")
 (description "\
Bindings for Toggl API in OCaml
")
 (depends
  (ocaml (>= 4.06.0))
  (dune (>= 2.0))
  (alcotest :with-test)
  (odoc :with-doc)
  base))
