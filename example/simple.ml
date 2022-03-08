(* We first create an authenticated client by providing credentials *)

module Client = Toggl.Auth.Client (struct
  (* let auth = Toggl.Auth.Basic {username= "user"; password= "passwd"} *)
  (* or *)
  let auth = Toggl.Auth.ApiToken (Sys.getenv "toggl_token")
end)

(* Then we create our authenticated API from it *)
module Api = Toggl.Api.F (Client)

(* We can then make our calls to the API, using the Types module to create our
   requests *)

open Lwt_result

let _ =
  Api.create_client ()
  >>= Api.Workspace.list
  >|= List.hd
  >|= (fun workspace -> workspace.name)
  |> Lwt_main.run
  |> Result.get_ok
  |> print_string
