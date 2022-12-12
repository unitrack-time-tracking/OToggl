open Piaf

let format_response message (response : Response.t)
    : (string, Error.t) Lwt_result.t
  =
  let ( let* ) = Lwt_result.bind in
  let* body = Body.to_string response.body in
  Buffer.add_string Format.stdbuf message ;
  Buffer.add_string Format.stdbuf "\n" ;
  Piaf.Response.pp_hum Format.str_formatter response ;
  Buffer.add_string Format.stdbuf "\n\n" ;
  Buffer.add_string Format.stdbuf body ;
  let s = Buffer.contents Format.stdbuf in
  Buffer.clear Format.stdbuf ; Lwt_result.return s

let status_200_or_error message (response : Response.t)
    : (string, Error.t) Lwt_result.t
  =
  let open Lwt_result in
  if Status.is_successful @@ response.status
  then Body.to_string response.body
  else
    bind
      (format_response message response >|= fun s -> (`Msg s :> Error.t))
      fail
