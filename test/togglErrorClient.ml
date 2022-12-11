open Piaf
include Client

let client = Obj.magic None

let post
    (_t : t)
    ?(headers : (string * string) list option)
    ?(body : Body.t option)
    path
  =
  ignore (headers, body, path) ;
  Lwt_result.fail @@ `Connect_error "connection error"

let patch
    (_t : t)
    ?(headers : (string * string) list option)
    ?(body : Body.t option)
    path
  =
  ignore (headers, body, path) ;
  Lwt_result.fail @@ `Connect_error "connection error"

let get (_t : t) ?(headers : (string * string) list option) path =
  ignore (headers, path) ;
  Lwt_result.fail @@ `Connect_error "connection error"

let delete
    (_t : t)
    ?(headers : (string * string) list option)
    ?(body : Body.t option)
    path
  =
  ignore (headers, body, path) ;
  Lwt_result.fail @@ `Connect_error "connection error"
