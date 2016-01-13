defmodule ExCss.Tokenizer do
  def new(str) do
    %{str: str, pos: -1, warnings: []}
  end

  def next(state) do
    consumers = [
      ExCss.Consumers.Comment,
      ExCss.Consumers.Whitespace,
      ExCss.Consumers.String,
      # ExCss.Consumers.Hashes
    ]

    visit_consumers(state, consumers)
  end

  defp visit_consumers(state, []), do: raise "Unable to match the input to a consumer"
  defp visit_consumers(state, [consumer | consumers]) do
    {state, token} = consumer.accept(state)

    case token do
      nil -> visit_consumers(state, consumers)
      token -> {state, token}
    end
  end
end
