defmodule ExCss.Utils.PrettyPrint do
  def pretty_out(_, _ \\ 0)
  
  def pretty_out(str, indent) when is_binary(str) do
    IO.puts "#{String.ljust("", indent, ?\s)}#{str}"
  end

  def pretty_out(object, indent) when is_map(object) do
    object.__struct__.pretty_print(object, indent)
  end

  def pretty_out(list, indent) when is_list(list) do
    for thing <- list do
      thing.__struct__.pretty_print(thing, indent)
    end
  end

  def pretty_out(tuple, indent) when is_tuple(tuple) do
    pretty_out(Tuple.to_list(tuple), indent)
  end

  def pretty_out(nil, indent) do
    pretty_out("(empty)", indent)
  end
end
