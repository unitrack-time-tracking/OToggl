open Piaf
include Client

let client = Obj.magic None

let time_entry =
  {json|
{
  "at": "2013-03-06T09:15:18Z",
  "billable": false,
  "description": "Meeting with possible clients",
  "duration": -1362470338,
  "duronly": false,
  "id": 436694100,
  "pid": 123,
  "project_id": 123,
  "start": "2013-03-05T07:58:58.000Z",
  "server_deleted_at": null,
  "tags": [
    "billed"
  ],
  "task_id": null,
  "uid": 1,
  "user_id": 1,
  "wid": 777,
  "workspace_id": 777
}
|json}

let time_entries =
  {json|
[
  {
    "at": "2013-03-06T09:15:18Z",
    "billable": false,
    "description": "Meeting with possible clients",
    "duration": -1362470338,
    "duronly": false,
    "id": 436694100,
    "pid": 123,
    "project_id": 123,
    "start": "2013-03-05T07:58:58.000Z",
    "server_deleted_at": null,
    "tags": [
      "billed"
    ],
    "task_id": null,
    "uid": 1,
    "user_id": 1,
    "wid": 777,
    "workspace_id": 777
  }
]
|json}

let projects =
  {json|
[
  {
    "id": 123,
    "wid": 777,
    "cid": 987,
    "name": "Very lucrative project",
    "billable": false,
    "is_private": true,
    "active": true,
    "at": "2013-03-06T09:15:18+00:00",
    "created_at": "2013-03-06T09:15:18+00:00"
  },
  {
    "id": 32123,
    "wid": 777,
    "cid": 123,
    "name": "Factory server infrastructure",
    "billable": true,
    "is_private": true,
    "active": true,
    "at": "2013-03-06T09:16:06+00:00",
    "created_at": "2013-03-06T09:16:06+00:00"
  }
]
|json}

let workspaces =
  {json|
[
  {
    "id": 3134975,
    "name": "John's personal ws",
    "premium": true,
    "admin": true,
    "default_hourly_rate": 50,
    "default_currency": "USD",
    "only_admins_may_create_projects": false,
    "only_admins_see_billable_rates": true,
    "rounding": 1,
    "rounding_minutes": 15,
    "at": "2013-08-28T16:22:21+00:00",
    "logo_url": "my_logo.png"
  },
  {
    "id": 777,
    "name": "My Company Inc",
    "premium": true,
    "admin": true,
    "default_hourly_rate": 40,
    "default_currency": "EUR",
    "only_admins_may_create_projects": false,
    "only_admins_see_billable_rates": true,
    "rounding": 1,
    "rounding_minutes": 15,
    "at": "2013-08-28T16:22:21+00:00"
  }
]
|json}

let post
    (_t : t)
    ?(headers : (string * string) list option)
    ?(body : Body.t option)
    path
  =
  ignore (headers, body) ;
  match path with
  | "/api/v9/workspaces/777/time_entries" ->
    Lwt_result.return (Response.of_string `OK ~body:time_entry)
  | url ->
    Lwt_result.return
      (Response.of_string ~body:("not_found: " ^ url) `Not_found)

let patch
    (_t : t)
    ?(headers : (string * string) list option)
    ?(body : Body.t option)
    path
  =
  ignore (headers, body) ;
  match path with
  | "/api/v9/workspaces/777/time_entries/436694100/stop" ->
    Lwt_result.return (Response.of_string `OK ~body:time_entry)
  | url ->
    Lwt_result.return
      (Response.of_string ~body:("not_found: " ^ url) `Not_found)

let get (_t : t) ?(headers : (string * string) list option) path =
  ignore headers ;
  match path with
  | "/api/v9/workspaces/777/projects" ->
    Lwt_result.return (Response.of_string `OK ~body:projects)
  | "/api/v9/me/time_entries/current" ->
    Lwt_result.return (Response.of_string `OK ~body:time_entry)
  (* | "/api/v9/time_entries/436694100" -> *)
  (*   Lwt_result.return (Response.of_string `OK ~body:time_entry) *)
  | "/api/v9/me/time_entries" ->
    Lwt_result.return (Response.of_string `OK ~body:"[]")
  | "/api/v9/me/time_entries?start_date=2020-01-01T00:00:00Z&end_date=2020-01-02T00:00:00Z"
    ->
    Lwt_result.return (Response.of_string `OK ~body:time_entries)
  | "/api/v9/me/time_entries?start_date=4020-01-01T00:00:00Z&end_date=4020-01-02T00:00:00Z"
    ->
    Lwt_result.return (Response.of_string `OK ~body:"[]")
  | "/api/v9/workspaces" ->
    Lwt_result.return (Response.of_string `OK ~body:workspaces)
  | url ->
    Lwt_result.return
      (Response.of_string ~body:("not_found: " ^ url) `Not_found)

let delete
    (_t : t)
    ?(headers : (string * string) list option)
    ?(body : Body.t option)
    path
  =
  ignore (headers, body) ;
  match path with
  | "/api/v9/workspaces/777/time_entries/436694100" ->
    Lwt_result.return (Response.of_string `OK ~body:"[436694100]")
  | url ->
    Lwt_result.return
      (Response.of_string ~body:("not_found: " ^ url) `Not_found)
