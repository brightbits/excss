defmodule ExCss.Markup.Node do
  def set_id({tag_name, attributes, children} = node, id) do
    attributes = [{:excss_id, id}] ++ Enum.filter(attributes, fn ({name, value}) -> name != :excss_id end)
    {tag_name, attributes, children}
  end

  def id({_, attributes, _}) do
    attribute = Enum.find(attributes, fn ({name, value}) -> name == :excss_id end)

    if attribute do
      elem(attribute, 1)
    else
      raise "No excss_id found on node"
    end
  end

  def set_children({tag_name, attributes, _}, children) do
     {tag_name, attributes, children}
  end

  def children({_, _, children}) do
    children
  end

  def text(node) do
    Floki.text(node)
  end
end
