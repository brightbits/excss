Pavlov.start()

defmodule TestHelper do
  @fixtures_path Path.join([File.cwd!, "test", "fixtures"])

  import Pavlov.Syntax.Expect

  def fixture(filename) do
    File.read!(Path.join(@fixtures_path, filename))
  end

  def expect_next_token(state, expected_token, expected_i, expected_next_grapheme) do
    {actual_state, actual_token} = ExCss.Lexer.next(state)

    expect(actual_token) |> is_eq(expected_token)
    expect(actual_state.i) |> is_eq(expected_i)
    expect(ExCss.Lexer.State.peek(actual_state)) |> is_eq(expected_next_grapheme)

    actual_state
  end

  defp is_eq(expectation, nil) do
    expectation |> to_be_nil
  end

  defp is_eq(expectation, value) do
    expectation |> to_eq(value)
  end
end
