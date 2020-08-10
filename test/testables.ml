open Alcotest

module Toggl = struct
  open Toggl.Types

  let time_entry : time_entry testable =
    (module struct
      type t = time_entry

      let pp = pp_time_entry

      let equal = equal_time_entry
    end)

  let project : project testable =
    (module struct
      type t = project

      let pp = pp_project

      let equal = equal_project
    end)

  let workspace : workspace testable =
    (module struct
      type t = workspace

      let pp = pp_workspace

      let equal = equal_workspace
    end)
end
