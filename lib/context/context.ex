defmodule ExCss.Context do
  defstruct stylesheets: [], markup: nil

  @t __MODULE__

  def new(html) do
    markup = ExCss.Markup.new(html)
    stylesheets =
      markup
      |> ExCss.Markup.find_nodes("style")
      |> Enum.map(fn (style_node) ->
        text = ExCss.Markup.Node.text(style_node)

        ExCss.Parser.parse(text)
      end)

    %@t{markup: markup, stylesheets: stylesheets}
  end

  defp calculate_styles do

  end
end
