open Types

module F (Client : module type of Piaf.Client) = struct
  let create_client ?config () =
    Client.create ?config @@ Uri.of_string "https://api.track.toggl.com"

  module TimeEntry = struct
    open Lwt_result

    let create t (client : Client.t) =
      let body =
        {time_entry= t} |> string_of_wrapped_time_entry |> Piaf.Body.of_string
      in
      Client.post client ~body "/api/v8/time_entries"
      >>= Util.status_200_or_error
      >|= data_time_entry_of_string
      >|= fun x -> x.data

    let start t (client : Client.t) =
      let body =
        {time_entry= t} |> string_of_wrapped_time_entry |> Piaf.Body.of_string
      in
      Client.post client ~body "/api/v9/time_entries/start"
      >>= Util.status_200_or_error
      >|= time_entry_of_string

    let stop (wid : wid) (tid : tid) (client : Client.t) =
      let body = Piaf.Body.empty in
      "/api/v9/workspaces/" ^ Int.to_string wid ^ "/time_entries/" ^ string_of_int tid ^ "/stop"
      |> Client.patch client ~body
      >>= Util.status_200_or_error
      >|= time_entry_of_string

    let current (client : Client.t) =
      Client.get client "/api/v9/me/time_entries/current"
      >>= Util.status_200_or_error
      >|= time_entry_of_string

    let details (tid : tid) (client : Client.t) =
      "/api/v8/time_entries/" ^ string_of_int tid
      |> Client.get client
      >>= Util.status_200_or_error
      >|= data_time_entry_of_string
      >|= fun x -> x.data

    let delete (tid : tid) (client : Client.t) =
      "/api/v8/time_entries/" ^ string_of_int tid
      |> Client.delete client
      >>= Util.status_200_or_error
      >|= tid_list_of_string

    let list ?start_date ?end_date (client : Client.t) =
      (* We will use timestamps set on UTC *)
      let tz_offset_s = 0 in
      let query = [] in
      let query =
        match end_date with
        | None ->
          query
        | Some date ->
          ("end_date", [Ptime.to_rfc3339 ~tz_offset_s date]) :: query
      in
      let query =
        match start_date with
        | None ->
          query
        | Some date ->
          ("start_date", [Ptime.to_rfc3339 ~tz_offset_s date]) :: query
      in
      Uri.make ~path:"/api/v9/me/time_entries" ~query ()
      |> Uri.to_string
      |> Client.get client
      >>= Util.status_200_or_error
      >|= time_entry_list_of_string

    let update
        tid
        ?description
        ?start
        ?stop
        ?duration
        ?tags
        ?project
        ?workspace
        ?duronly
        ?billable
        (client : Client.t)
      =
      let time_entry =
        CCOption.(
          Types.create_time_entry_update_request ?description ?start ?stop
            ?duration ?tags
            ?pid:(project >|= function None -> None | Some p -> Some p.id)
            ?wid:(workspace >|= fun w -> w.id)
            ?duronly ?billable ())
      in
      let body =
        create_wrapped_time_entry_update_request ~time_entry ()
        |> string_of_wrapped_time_entry_update_request
        |> Piaf.Body.of_string
      in
      Client.put client ~body @@ "/api/v8/time_entries/" ^ string_of_int tid
      >>= Util.status_200_or_error
      >|= data_time_entry_of_string
      >|= fun x -> x.data
  end

  module Workspace = struct
    let list (client : Client.t) =
      let open Lwt_result in
      Client.get client "/api/v8/workspaces"
      >>= Util.status_200_or_error
      >|= workspace_list_of_string
  end

  module Project = struct
    open Lwt_result

    let list wid (client : Client.t) =
      let open Lwt_result in
      "/api/v8/workspaces/" ^ string_of_int wid ^ "/projects"
      |> Client.get client
      >>= Util.status_200_or_error
      >|= project_list_of_string

    let create t (client : Client.t) =
      let body =
        {project= t} |> string_of_wrapped_project_request |> Piaf.Body.of_string
      in
      Client.post client ~body "/api/v8/projects"
      >>= Util.status_200_or_error
      >|= data_project_of_string
      >|= fun x -> x.data

    let delete pid (client : Client.t) =
      "/api/v8/projects/" ^ string_of_int pid
      |> Client.delete client
      >>= Util.status_200_or_error
      >|= pid_list_of_string
  end
end
