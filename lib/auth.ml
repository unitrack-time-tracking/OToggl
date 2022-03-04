module type Client = module type of Piaf.Client

type t =
  | Basic of {
      username: string;
      password: string;
    }
  | ApiToken of string

let create_header (meth : t) : (string, string) result =
  let create_basic_credentials ~username ~password =
    match Base64.encode (username ^ ":" ^ password) with
    | Ok creds ->
      Ok ("Basic " ^ creds)
    | Error (`Msg e) ->
      Error e
  in
  match meth with
  | ApiToken token ->
    create_basic_credentials ~username:token ~password:"api_token"
  | Basic {username; password} ->
    create_basic_credentials ~username ~password

module Client (Authentication : sig
  val auth : t
end) : Client with type t = Piaf.Client.t = struct
  include Piaf.Client

  let header = create_header Authentication.auth |> CCResult.get_or_failwith

  let add_authorization = function
    | None ->
      Some ["Authorization", header]
    | Some headers ->
      Some (CCList.Assoc.set ~eq:CCString.equal "Authorization" header headers)

  let request client ?headers =
    let headers = add_authorization headers in
    request client ?headers

  let head client ?headers =
    let headers = add_authorization headers in
    head client ?headers

  let get client ?headers =
    let headers = add_authorization headers in
    get client ?headers

  let post client ?headers =
    let headers = add_authorization headers in
    post client ?headers

  let put client ?headers =
    let headers = add_authorization headers in
    put client ?headers

  let patch client ?headers =
    let headers = add_authorization headers in
    patch client ?headers

  let delete client ?headers =
    let headers = add_authorization headers in
    delete client ?headers

  module Oneshot = struct
    let head ?config ?headers =
      let headers = add_authorization headers in
      Oneshot.head ?config ?headers

    let get ?config ?headers =
      let headers = add_authorization headers in
      Oneshot.get ?config ?headers

    let post ?config ?headers =
      let headers = add_authorization headers in
      Oneshot.post ?config ?headers

    let put ?config ?headers =
      let headers = add_authorization headers in
      Oneshot.put ?config ?headers

    let patch ?config ?headers =
      let headers = add_authorization headers in
      Oneshot.patch ?config ?headers

    let delete ?config ?headers =
      let headers = add_authorization headers in
      Oneshot.delete ?config ?headers

    let request ?config ?headers =
      let headers = add_authorization headers in
      Oneshot.request ?config ?headers
  end
end
