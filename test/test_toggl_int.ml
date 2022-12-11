open Lwt
open Lwt.Syntax
open Toggl

(* Create the authenticated client using the token in environment *)
let username = Sys.getenv_opt "toggl_token" |> Option.value ~default:"token"

let password = "api_token"

let run_name =
  Random.self_init () ;
  let run_id =
    Sys.getenv_opt "GITHUB_RUN_ID" |> CCOption.get_or ~default:"Test run"
  in
  let workflow =
    Sys.getenv_opt "GITHUB_WORKFLOW" |> CCOption.get_or ~default:""
  in
  workflow ^ run_id ^ Int.to_string @@ Random.int 1_000_000_000

module Client = Auth.Client (struct
  let auth = Auth.Basic {username; password}
end)

open Api.F (Client)

let get_or_failwith = function
  | Ok x ->
    x
  | Error e ->
    failwith @@ Piaf.Error.to_string e

let client = create_client () >|= get_or_failwith

(* Utility functions for writing tests *)
let wait value =
  let* _ = Lwt_unix.sleep 2. in
  return value

let get_workspace _switch =
  client
  >>= Workspace.list
  >|= get_or_failwith
  >|= List.filter (fun ({name; _} : Types.workspace) -> name = "Personal")
  >|= List.hd

let delete_run_project _switch ({id; name; _} : Types.project) =
  print_string @@ "Deleting project " ^ Int.to_string id ^ " : " ^ name ^ "\n" ;
  client
  >>= Project.delete id
  >|= get_or_failwith
  >>= wait
  >|= fun pids ->
  Alcotest.(check (list int) "Same project deleted" [id] pids) ;
  print_string @@ "Deleted project " ^ Types.string_of_pid_list pids ^ "\n" ;
  pids

let create_run_project
    switch
    ?(name = run_name)
    ?(billable = false)
    ?(is_private = false)
    ?(active = false)
    ?(auto_estimates = false)
    ?(estimated_hours = false)
    ?(actual_hours = 0)
    ?(template = false)
    ?template_id
    ?cid
    ?color
    ?hex_color
    ({id= wid; _} : Types.workspace)
  =
  let project_request =
    Types.create_project_request ~wid ~name ~billable ~is_private ~active
      ~auto_estimates ~estimated_hours ~actual_hours ~template ?template_id ?cid
      ?color ?hex_color ()
  in
  let project =
    client >>= Project.create project_request >|= get_or_failwith >>= wait
  in
  Lwt_switch.add_hook (Some switch) (fun () ->
      project >>= delete_run_project switch >|= ignore) ;
  project

let get_project _switch ({id; _} : Types.workspace) =
  client >>= Project.list id >|= get_or_failwith >|= List.hd

let delete_time_entry _switch ({id; _} : Types.time_entry) =
  print_string @@ "Deleting time entry " ^ Int.to_string id ^ "\n" ;
  client
  >>= TimeEntry.delete id
  >|= get_or_failwith
  >>= wait
  >|= fun tids ->
  Alcotest.(check (list int) "Same time entry deleted" [id] tids) ;
  print_string @@ "Deleted time entry " ^ Types.string_of_tid_list tids ^ "\n" ;
  tids

let create_time_entry
    ~pid
    ?(description = "Test time entry")
    ?(start = Types.datetime_of_string "\"2020-01-01T00:00:00Z\"")
    ?stop
    ?(duration = 3600)
    ?tags
    ?duronly
    ?billable
    switch
  =
  let time_entry =
    client
    >>= TimeEntry.create
          (Types.create_time_entry_request ~pid ~description ?tags ~start ?stop
             ~duration ?duronly ?billable ())
    >|= get_or_failwith
    >>= wait
  in
  Lwt_switch.add_hook (Some switch) (fun () ->
      time_entry >>= delete_time_entry switch >|= ignore) ;
  time_entry

let stop_time_entry _switch ({id; _} : Types.time_entry) =
  client
  >>= TimeEntry.stop id
  >|= get_or_failwith
  >>= wait
  >|= fun te ->
  print_string @@ "Stopped time entry " ^ Int.to_string te.id ^ "\n" ;
  te

let start_time_entry switch ({id; wid; _} : Types.project) =
  let time_entry =
    client
    >>= TimeEntry.start
          (Types.create_time_entry_request ~wid ~pid:id
             ~description:"Test time entry" ())
    >|= get_or_failwith
    >>= wait
  in
  Lwt_switch.add_hook (Some switch) (fun () ->
      time_entry >>= delete_time_entry switch >|= ignore) ;
  time_entry

(* let get_time_entry _switch (time_entry : Types.time_entry) = *)
(*   client >>= TimeEntry.details time_entry.id >|= get_or_failwith >>= wait *)

let get_current_time_entry _switch =
  client >>= TimeEntry.current >|= get_or_failwith >>= wait

let list_time_entries ?start_date ?end_date (pid : Types.pid) _switch =
  client
  >>= TimeEntry.list ?start_date ?end_date
  >|= get_or_failwith
  >|= List.filter (fun (te : Types.time_entry) -> te.pid = Some pid)
  >>= wait

let update_time_entry
    t
    ?description
    ?start
    ?stop
    ?duration
    ?tags
    ?project
    ?workspace
    ?duronly
    ?billable
    _switch
  =
  client
  >>= TimeEntry.update t ?description ?start ?stop ?duration ?tags ?project
        ?workspace ?duronly ?billable
  >|= get_or_failwith
  >>= wait

(* Tests *)
let test_start_get_stop_delete switch () =
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = start_time_entry switch project in
  let* _ = get_current_time_entry switch in
  let* _ = stop_time_entry switch time_entry in
  let* _ = delete_time_entry switch time_entry in
  return ()

let test_start_stop_delete switch () =
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = start_time_entry switch project in
  let* time_entry = stop_time_entry switch time_entry in
  let* _ = delete_time_entry switch time_entry in
  return ()

let test_start_get_delete switch () =
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = start_time_entry switch project in
  let* _ = get_current_time_entry switch in
  let* _ = delete_time_entry switch time_entry in
  return ()

let test_start_delete switch () =
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = start_time_entry switch project in
  let* _ = get_current_time_entry switch in
  let* _ = delete_time_entry switch time_entry in
  return ()

let test_create_get_delete switch () =
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = create_time_entry switch ~pid:project.id in
  (* let* time_entry = get_time_entry switch time_entry in *)
  let* _ = delete_time_entry switch time_entry in
  return ()

let test_create_and_list_start_date_before switch () =
  let start_date = Ptime_clock.now () in
  let one_h = Ptime.Span.of_int_s 3600 in
  let start_date = Ptime.sub_span start_date one_h in
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = start_time_entry switch project in
  let* time_entry = stop_time_entry switch time_entry in
  let* time_entries = list_time_entries ?start_date project.id switch in
  let* _ =
    return
    @@ Alcotest.(check (list Testables.Toggl.time_entry))
         "One issue" [time_entry] time_entries
  in
  return ()

let test_create_and_list_end_date_after switch () =
  let end_date = Ptime_clock.now () in
  let one_h = Ptime.Span.of_int_s 3600 in
  let end_date = Ptime.add_span end_date one_h in
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = start_time_entry switch project in
  let* time_entry = stop_time_entry switch time_entry in
  let* time_entries = list_time_entries ?end_date project.id switch in
  let* _ =
    return
    @@ Alcotest.(check (list Testables.Toggl.time_entry))
         "One issue" [time_entry] time_entries
  in
  return ()

let test_create_and_list_start_date_after switch () =
  let start_date = Ptime_clock.now () in
  let one_h = Ptime.Span.of_int_s 3600 in
  let start_date = Ptime.add_span start_date one_h in
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = start_time_entry switch project in
  let* _ = stop_time_entry switch time_entry in
  let* time_entries = list_time_entries ?start_date project.id switch in
  let* _ =
    return
    @@ Alcotest.(check (list Testables.Toggl.time_entry))
         "No issue" [] time_entries
  in
  return ()

let test_create_and_list_end_date_before switch () =
  let end_date = Ptime_clock.now () in
  let one_h = Ptime.Span.of_int_s 3600 in
  let end_date = Ptime.sub_span end_date one_h in
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* time_entry = start_time_entry switch project in
  let* _ = stop_time_entry switch time_entry in
  let* time_entries = list_time_entries ?end_date project.id switch in
  let* _ =
    return
    @@ Alcotest.(check (list Testables.Toggl.time_entry))
         "No issue" [] time_entries
  in
  return ()

let test_modify_time_entry switch () =
  let* workspace = get_workspace switch in
  let* project = create_run_project switch workspace in
  let* te0 = create_time_entry ~pid:project.id switch in
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry "Expected initial state"
         {
           id= te0.id;
           workspace_id= 4436316;
           project_id= Some project.id;
           tags= [];
           billable= false;
           start=
             CCOption.get_exn_or "Expected value"
             @@ Ptime.of_date_time ((2020, 1, 1), ((0, 0, 0), 0));
           stop=
             Some
               (CCOption.get_exn_or "Expected value"
               @@ Ptime.of_date_time ((2020, 1, 1), ((1, 0, 0), 0)));
           duration= 3600;
           description= "Test time entry";
           duronly= false;
           user_id= 4179541;
           at= te0.at;
           server_deleted_at= None;
           tag_ids= [];
           task_id= None;
           tid= None;
           pid= None;
           wid= None;
           uid= None;
         }
         te0
  in
  let* te1 =
    update_time_entry te0.id
      ~stop:(Ptime.add_span te0.start (Ptime.Span.of_int_s 1800))
      switch
  in
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry "Stop time modified"
         {
           te0 with
           stop= Ptime.add_span te0.start (Ptime.Span.of_int_s 1800);
           at= te1.at;
         }
         te1
  in
  let* te2 = update_time_entry te1.id ~duration:7200 switch in
  (* 2h *)
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry
         "Duration and stop time modified"
         {
           te1 with
           duration= 7200;
           stop= Ptime.add_span te1.start (Ptime.Span.of_int_s 7200);
           at= te2.at;
         }
         te2
  in
  let* te3 = update_time_entry te2.id ~description:"New description" switch in
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry "Description modified"
         {te2 with description= "New description"; at= te3.at}
         te3
  in
  let* te4 =
    update_time_entry te3.id
      ~start:
        (Ptime.add_span te3.start (Ptime.Span.of_int_s 60)
        |> CCOption.get_exn_or "Expected value")
      switch
  in
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry "Start and stop times modified"
         {
           te3 with
           start=
             CCOption.get_exn_or "Expected value"
             @@ Ptime.add_span te3.start (Ptime.Span.of_int_s 60);
           stop= Ptime.add_span te4.start (Ptime.Span.of_int_s te3.duration);
           at= te4.at;
         }
         te4
  in
  let* te5 = update_time_entry te4.id ~tags:["foo"] switch in
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry "Tags modified"
         {te4 with tags= ["foo"]; at= te5.at}
         te5
  in
  let* te6 = update_time_entry te5.id ~project:None switch in
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry "Project nullified"
         {te5 with pid= None; at= te6.at}
         te6
  in
  let* workspace = get_workspace switch in
  let* project =
    create_run_project ~name:("New " ^ project.name) switch workspace
  in
  let* te6' = update_time_entry te5.id ~project:(Some project) switch in
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry "Project added"
         {te5 with pid= Some project.id; at= te6'.at}
         te6'
  in
  (* TODO test modifying workspace after creating a new one maybe *)
  let* te7 = update_time_entry te6'.id ~duronly:true switch in
  let* _ =
    return
    @@ Alcotest.check Testables.Toggl.time_entry "duronly set to true"
         {te6' with duronly= true; at= te7.at}
         te7
  in
  (* Cannot test billable without a premium workspace *)
  return ()

let no_exception_suite =
  Alcotest_lwt.
    [
      test_case
        "Start, get current, stop and delete time entry work without exception"
        `Slow test_start_get_stop_delete;
      test_case
        "Start, get current and delete time entry work without exception" `Slow
        test_start_get_delete;
      test_case "Start, stop and delete time entry work without exception" `Slow
        test_start_stop_delete;
      test_case "Start and delete time entry work without exception" `Slow
        test_start_delete;
      test_case "Create, get by id and delete a time entry without exception"
        `Slow test_create_get_delete;
      test_case
        "Create time entry then list all with start_date before should return \
         it"
        `Slow test_create_and_list_start_date_before;
      test_case
        "Create time entry then list all with end_date after should return it"
        `Slow test_create_and_list_end_date_after;
      test_case
        "Create time entry then list all with start_date after should return \
         nothing"
        `Slow test_create_and_list_start_date_after;
      test_case
        "Create time entry then list all with end_date before should return \
         nothing"
        `Slow test_create_and_list_end_date_before;
      test_case "Create time entry then modify it" `Slow test_modify_time_entry;
    ]
