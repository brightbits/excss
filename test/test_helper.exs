Pavlov.start()

defmodule TestHelper do
  @fixtures_path Path.join([File.cwd!, "test", "fixtures"])

  def fixture(filename) do
    File.read!(Path.join(@fixtures_path, filename))
  end
end
