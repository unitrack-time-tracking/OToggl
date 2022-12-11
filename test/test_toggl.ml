open Alcotest
open Toggl
open Types

let raise_error result =
  let open Lwt_result in
  result |> map_error (fun err -> Failure (Piaf.Error.to_string err)) |> get_exn

let get_datetime s =
  s |> Ptime.of_rfc3339 |> CCResult.get_exn |> function d, _, _ -> d

module TestNormalBehaviour = struct
  module Api = Api.F (TogglClient)

  let client = Lwt_result.return TogglClient.client

  let time_entry_request =
    create_time_entry_request ~pid:123 ~wid:777 ~billable:false
      ~start:(get_datetime "2013-03-05T07:58:58.000Z")
      ~duration:1200 ~description:"Meeting with possible clients"
      ~tags:["billed"] ()

  let time_entry =
    Toggl_v.create_time_entry ~id:436694100 ~pid:123 ~wid:777 ~uid:1
      ~billable:false
      ~start:(get_datetime "2013-03-05T07:58:58.000Z")
      ~duration:1200 ~description:"Meeting with possible clients"
      ~tags:["billed"]
      ~at:(get_datetime "2013-03-06T09:15:18+00:00")
      ()

  let projects =
    [
      create_project ~id:123 ~wid:777 ~name:"Very lucrative project"
        ~billable:false ~is_private:true ~active:true
        ~at:(get_datetime "2013-03-06T09:15:18+00:00")
        ~created_at:(get_datetime "2013-03-06T09:15:18+00:00")
        ();
      create_project ~id:32123 ~wid:777 ~name:"Factory server infrastructure"
        ~billable:true ~is_private:true ~active:true
        ~created_at:(get_datetime "2013-03-06T09:16:06+00:00")
        ~at:(get_datetime "2013-03-06T09:16:06+00:00")
        ();
    ]

  let workspaces =
    [
      create_workspace ~id:3134975 ~name:"John's personal ws" ~premium:true
        ~admin:true ~default_hourly_rate:50. ~default_currency:"USD"
        ~only_admins_may_create_projects:false
        ~only_admins_see_billable_rates:true ~rounding:1 ~rounding_minutes:15
        ~at:(get_datetime "2013-08-28T16:22:21+00:00")
        ~logo_url:"my_logo.png" ();
      create_workspace ~id:777 ~name:"My Company Inc" ~premium:true ~admin:true
        ~default_hourly_rate:40. ~default_currency:"EUR"
        ~only_admins_may_create_projects:false
        ~only_admins_see_billable_rates:true ~rounding:1 ~rounding_minutes:15
        ~at:(get_datetime "2013-08-28T16:22:21+00:00")
        ();
    ]

  open Lwt_result

  let test_start_time_entry _switch () =
    client
    >>= Api.TimeEntry.start time_entry_request
    >|= check Testables.Toggl.time_entry "Same time entry" time_entry
    |> raise_error

  let test_stop_time_entry _switch () =
    client
    >>= Api.TimeEntry.stop 436694100
    >|= check Testables.Toggl.time_entry "Same time entry" time_entry
    |> raise_error

  let test_create_time_entry _switch () =
    client
    >>= Api.TimeEntry.create time_entry_request
    >|= check Testables.Toggl.time_entry "Same time entry" time_entry
    |> raise_error

  let test_current_time_entry _switch () =
    client
    >>= Api.TimeEntry.current
    >|= check Testables.Toggl.time_entry "Same time entry" time_entry
    |> raise_error

  let test_time_entry_details _switch () =
    client
    >>= Api.TimeEntry.details 436694100
    >|= check Testables.Toggl.time_entry "Same time entry" time_entry
    |> raise_error

  let test_delete_time_entry _switch () =
    client
    >>= Api.TimeEntry.delete 436694100
    >|= check Alcotest.(list int) "Same workspaces" [436694100]
    |> raise_error

  let test_list_time_entries_no_query _switch () =
    client
    >>= Api.TimeEntry.list
    >|= check (list Testables.Toggl.time_entry) "Same projects" []
    |> raise_error

  let test_list_time_entries_query _switch () =
    client
    >>= Api.TimeEntry.list
          ~start_date:
            (CCOption.get_exn_or "Expected value" @@ Ptime.of_date (2020, 1, 1))
          ~end_date:
            (CCOption.get_exn_or "Expected value" @@ Ptime.of_date (2020, 1, 2))
    >|= check (list Testables.Toggl.time_entry) "Same projects" [time_entry]
    |> raise_error

  let test_list_time_entries_future _switch () =
    client
    >>= Api.TimeEntry.list
          ~start_date:
            (CCOption.get_exn_or "Expected value" @@ Ptime.of_date (4020, 1, 1))
          ~end_date:
            (CCOption.get_exn_or "Expected value" @@ Ptime.of_date (4020, 1, 2))
    >|= check (list Testables.Toggl.time_entry) "Same projects" []
    |> raise_error

  let test_list_workspaces _switch () =
    client
    >>= Api.Workspace.list
    >|= check (list Testables.Toggl.workspace) "Same workspaces" workspaces
    |> raise_error

  let test_list_projects _switch () =
    client
    >>= Api.Project.list 777
    >|= check (list Testables.Toggl.project) "Same projects" projects
    |> raise_error
end

module TestNotFound = struct
  module Api = Api.F (TogglClient)
  open Lwt_result

  let client = Lwt_result.return TogglClient.client

  let test_stop_time_entry _switch () =
    client
    >>= Api.TimeEntry.stop 0
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Says that url is not found" "not_found")
    |> Lwt.map Result.get_error

  let test_list_projects _switch () =
    client
    >>= Api.Project.list 0
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Says that url is not found" "not_found")
    |> Lwt.map Result.get_error

  let test_time_entry_details _switch () =
    client
    >>= Api.TimeEntry.details 0
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Says that url is not found" "not_found")
    |> Lwt.map Result.get_error

  let test_delete_time_entry _switch () =
    client
    >>= Api.TimeEntry.delete 0
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Says that url is not found" "not_found")
    |> Lwt.map Result.get_error
end

module TestConnectionError = struct
  module Api = Api.F (TogglErrorClient)
  open Lwt_result

  let client = Lwt_result.return TogglErrorClient.client

  let test_stop_time_entry _switch () =
    client
    >>= Api.TimeEntry.stop 0
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Returns error" "Connect Error: connection error")
    |> Lwt.map Result.get_error

  let test_list_projects _switch () =
    client
    >>= Api.Project.list 0
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Returns error" "Connect Error: connection error")
    |> Lwt.map Result.get_error

  let test_start_time_entry _switch () =
    client
    >>= Api.TimeEntry.start
          (create_time_entry_request
             ~description:"Meeting with possible clients" ())
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Returns error" "Connect Error: connection error")
    |> Lwt.map Result.get_error

  let test_create_time_entry _switch () =
    client
    >>= Api.TimeEntry.create
          (create_time_entry_request
             ~description:"Meeting with possible clients" ())
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Returns error" "Connect Error: connection error")
    |> Lwt.map Result.get_error

  let test_current_time_entry _switch () =
    client
    >>= Api.TimeEntry.current
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Returns error" "Connect Error: connection error")
    |> Lwt.map Result.get_error

  let test_time_entry_details _switch () =
    client
    >>= Api.TimeEntry.stop 0
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Returns error" "Connect Error: connection error")
    |> Lwt.map Result.get_error

  let test_delete_time_entry _switch () =
    client
    >>= Api.TimeEntry.delete 0
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Returns error" "Connect Error: connection error")
    |> Lwt.map Result.get_error

  let test_list_workspaces _switch () =
    client
    >>= Api.Workspace.list
    |> map_error Piaf.Error.to_string
    |> map_error (check string "Returns error" "Connect Error: connection error")
    |> Lwt.map Result.get_error
end

open Alcotest_lwt

let normal_behaviour_suite =
  TestNormalBehaviour.
    [
      test_case "Creating time entry response is parsed" `Quick
        test_create_time_entry;
      test_case "Starting time entry response is parsed" `Quick
        test_start_time_entry;
      test_case "Stopping time entry response is parsed" `Quick
        test_stop_time_entry;
      test_case "Getting current time entry response is parsed" `Quick
        test_current_time_entry;
      test_case "Getting specified time entry response is parsed" `Quick
        test_time_entry_details;
      test_case "Deleting specified time entry response is parsed" `Quick
        test_delete_time_entry;
      test_case "Getting all time entries without query response is parsed"
        `Quick test_list_time_entries_no_query;
      test_case "Getting all time entries with query response is parsed" `Quick
        test_list_time_entries_query;
      test_case "Getting no time entries with query is parsed" `Quick
        test_list_time_entries_future;
      test_case "Getting all workspaces response is parsed" `Quick
        test_list_workspaces;
      test_case "Getting all projects response is parsed" `Quick
        test_list_projects;
    ]

let not_found_suite =
  TestNotFound.
    [
      test_case "Stopping time entry response is parsed" `Quick
        test_stop_time_entry;
      test_case "Getting all projects response is parsed" `Quick
        test_list_projects;
      test_case "Getting specified time entry response is parsed" `Quick
        test_time_entry_details;
      test_case "Deleting specified time entry response is parsed" `Quick
        test_delete_time_entry;
    ]

let error_suite =
  TestConnectionError.
    [
      test_case "Creating time entry response returns error" `Quick
        test_create_time_entry;
      test_case "Starting time entry response returns error" `Quick
        test_start_time_entry;
      test_case "Stopping time entry response returns error" `Quick
        test_stop_time_entry;
      test_case "Getting current time entry response returns error" `Quick
        test_current_time_entry;
      test_case "Getting specified time entry response returns error" `Quick
        test_time_entry_details;
      test_case "Deleting specified time entry response returns error" `Quick
        test_delete_time_entry;
      test_case "Getting all workspaces response returns error" `Quick
        test_list_workspaces;
      test_case "Getting all projects response returns error" `Quick
        test_list_projects;
    ]
