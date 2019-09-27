# Used by "mix format"
[
  import_deps: [:ecto, :ecto_sql],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 80,
  subdirectories: ["priv/*/migrations"]
]
