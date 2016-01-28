Pavlov.start()

defmodule TestHelper do
  @fixtures_path Path.join([File.cwd!, "test", "fixtures"])

  import Pavlov.Syntax.Expect

  def fixture(filename) do
    File.read!(Path.join(@fixtures_path, filename))
  end

  def expect_next_token(state, expected_token, expected_i, expected_next_grapheme) do
    {actual_state, actual_token} = ExCss.Lexer.next(state)

    expect(actual_token) |> to_eq(expected_token)
    expect(actual_state.i) |> to_eq(expected_i)
    expect(ExCss.Lexer.State.peek(actual_state)) |> to_eq(expected_next_grapheme)

    actual_state
  end
end
