include Toggl_t
include Toggl_j
include Toggl_v

let create_time_entry_request
    ?billable
    ?description
    ?duration
    ?duronly
    ?project_id
    ?start
    ?start_date
    ?stop
    ?tag_action
    ?tag_ids
    ?tags
    ?task_id
    ?user_id
    ~workspace_id
    ()
  =
  let start =
    CCOption.get_or
      ~default:
        (Unix.time ()
        |> Ptime.of_float_s
        |> CCOption.get_exn_or "Couldn't convert unix time to datetime")
      start
  in
  Toggl_v.create_time_entry_request ~created_with:"otoggl" ~workspace_id
    ?project_id ?billable ?description ?duration ?duronly ~start ?start_date
    ?stop ?tag_action ?tag_ids ?tags ?task_id ?user_id ~wid:workspace_id
    ?tid:task_id ?pid:project_id ?uid:user_id ()
