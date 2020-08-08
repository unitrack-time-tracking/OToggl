open Piaf

let status_200_or_error (response : Response.t) : (string, string) Lwt_result.t =
  let open Lwt in
  if Status.is_successful @@ Response.status response then
    Body.to_string response.body >|= CCResult.return
  else
    Body.to_string response.body >|= CCResult.fail
