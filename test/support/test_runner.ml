(** Main entry point for our test runner.

    This aggregates all the test suites and call Alcotes to run them. When
    creating a new test suite, don't forget to add it here! *)

let () =
  Lwt_main.run
  @@ Alcotest_lwt.run "Toggl unit tests"
       [
         "Normal behaviour", Otoggl_test.Test_toggl.normal_behaviour_suite;
         "Page not found", Otoggl_test.Test_toggl.not_found_suite;
         "Error case", Otoggl_test.Test_toggl.error_suite;
         ( "Toggl integration tests",
           Otoggl_test.Test_toggl_int.no_exception_suite );
       ]
