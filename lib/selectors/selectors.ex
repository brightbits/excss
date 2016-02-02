defmodule ExCss.Selectors do
  def visit(stylesheet) do
    stylesheet
    |> ExCss.Selectors.Nodes.StyleRule.visit
    |> ExCss.Selectors.Specificity.visit
  end
end
