open Piaf

let status_200_or_error (response : Response.t) : (string, Error.t) Lwt_result.t
  =
  let open Lwt_result in
  if Status.is_successful @@ response.status
  then Body.to_string response.body
  else bind (Body.to_string response.body >|= fun s -> (`Msg s :> Error.t)) fail
