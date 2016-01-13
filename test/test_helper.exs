Pavlov.start()

defmodule TestHelper do
  def state_for(str), do: state_for(str, -1)
  def state_for(str, -1) do
    %{str: str, pos: -1, warnings: [], line: 0, column: -1, last_line_length: nil}
  end
  def state_for(str, pos) do
    %{str: str, pos: pos, warnings: [], char: String.at(str, pos), line: 0, column: pos, last_line_length: nil}
  end
end
