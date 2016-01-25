defmodule ExCss.Parser.Stylesheet do
  import ExCss.Utils.PrettyPrint
  defstruct rules: []

  def pretty_print(stylesheet), do: pretty_print(stylesheet, 0)
  def pretty_print(stylesheet, indent) do
    pretty_out("Stylesheet:", indent)
    pretty_out("Rules:", indent + 1)

    for r <- Tuple.to_list(stylesheet.rules) do
      r.__struct__.pretty_print(r, indent + 2)
    end
  end
end
