return {
  "ggandor/leap.nvim",
  enabled = true,
	lazy = false,
  config = function(_, opts)
    local leap = require("leap")
    leap.add_default_mappings(true)
  end,
}
