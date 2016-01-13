defmodule ExCss.Parser.AtRule do
  defstruct name: nil, prelude: [], block: nil
end

defmodule ExCss.Parser.QualifiedRule do
  defstruct prelude: [], block: nil
end

defmodule ExCss.Parser.Declaration do
  defstruct name: nil, value: [], important: false
end

defmodule ExCss.Parser.Function do
  defstruct name: nil, value: []
end

defmodule ExCss.Parser.SimpleBlock do
  defstruct associated_token: nil, value: []
end

defmodule ExCss.Parser.Stylesheet do
  defstruct rules: []
end
