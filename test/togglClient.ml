open Piaf
include Client

let time_entry =
  {json|
{
  "data": {
    "id": 436694100,
    "pid": 123,
    "wid": 777,
    "uid": 1,
    "billable": false,
    "start": "2013-03-05T07:58:58.000Z",
    "duration": 1200,
    "description": "Meeting with possible clients",
    "created_with": "trackoclock",
    "tags": [
      "billed"
    ],
    "at": "2013-03-06T09:15:18Z"
  }
}
|json}

let time_entries =
  {json|
[
  {
    "id": 436694100,
    "pid": 123,
    "wid": 777,
    "uid": 1,
    "billable": false,
    "start": "2013-03-05T07:58:58.000Z",
    "duration": 1200,
    "description": "Meeting with possible clients",
    "created_with": "trackoclock",
    "tags": [
      "billed"
    ],
    "at": "2013-03-06T09:15:18Z"
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
  | "/api/v8/time_entries" ->
    Lwt_result.return (Response.of_string `OK ~body:time_entry)
  | "/api/v8/time_entries/start" ->
    Lwt_result.return (Response.of_string `OK ~body:time_entry)
  | _ ->
    Lwt_result.return (Response.of_string ~body:"not_found" `Not_found)

let put
    (_t : t)
    ?(headers : (string * string) list option)
    ?(body : Body.t option)
    path
  =
  ignore (headers, body) ;
  match path with
  | "/api/v8/time_entries/436694100/stop" ->
    Lwt_result.return (Response.of_string `OK ~body:time_entry)
  | _ ->
    Lwt_result.return (Response.of_string ~body:"not_found" `Not_found)

let get (_t : t) ?(headers : (string * string) list option) path =
  ignore headers ;
  match path with
  | "/api/v8/workspaces/777/projects" ->
    Lwt_result.return (Response.of_string `OK ~body:projects)
  | "/api/v8/time_entries/current" ->
    Lwt_result.return (Response.of_string `OK ~body:time_entry)
  | "/api/v8/time_entries/436694100" ->
    Lwt_result.return (Response.of_string `OK ~body:time_entry)
  | "/api/v8/time_entries" ->
    Lwt_result.return (Response.of_string `OK ~body:"[]")
  | "/api/v8/time_entries?start_date=2020-01-01T00:00:00Z&end_date=2020-01-02T00:00:00Z"
    ->
    Lwt_result.return (Response.of_string `OK ~body:time_entries)
  | "/api/v8/time_entries?start_date=4020-01-01T00:00:00Z&end_date=4020-01-02T00:00:00Z"
    ->
    Lwt_result.return (Response.of_string `OK ~body:"[]")
  | "/api/v8/workspaces" ->
    Lwt_result.return (Response.of_string `OK ~body:workspaces)
  | _ ->
    Lwt_result.return (Response.of_string ~body:"not_found" `Not_found)

let delete
    (_t : t)
    ?(headers : (string * string) list option)
    ?(body : Body.t option)
    path
  =
  ignore (headers, body) ;
  match path with
  | "/api/v8/time_entries/436694100" ->
    Lwt_result.return (Response.of_string `OK ~body:"[436694100]")
  | _ ->
    Lwt_result.return (Response.of_string ~body:"not_found" `Not_found)
