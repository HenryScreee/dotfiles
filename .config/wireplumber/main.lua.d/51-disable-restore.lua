rule = {
  matches = {
    {
      { "node.name", "matches", "firefox" },
    },
  },
  apply_properties = {
    ["state.restore-props"] = false,
  },
}
