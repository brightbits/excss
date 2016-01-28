defmodule StateTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State

  describe ".new" do
    it "returns the correct starting state" do
      expect(State.new("this is a test"))
      |> to_eq(%State{
        graphemes: {"t", "h","i","s"," ","i", "s", " ", "a", " ", "t", "e","s","t"},
        i: -1
      })
    end
  end

  describe ".peek" do
    let :start_index, do: -1
    let :state, do: ExCss.Lexer.State.new("this is a test", start_index)

    context "looking before 0" do
      it "returns nil" do
        expect(State.peek(state, 0)) |> to_be_nil # looking at -1
        expect(State.peek(state, -1)) |> to_be_nil # looking at -2
      end
    end

    context "looking after the end" do
      let :start_index, do: 13

      it "returns nil" do
        expect(State.peek(state)) |> to_be_nil # looking at 14
        expect(State.peek(state, 2)) |> to_be_nil # looking at 15
      end
    end

    context "looking in the right place" do
      it "returns the correct graphemes" do
        expect(State.peek(state)) |> to_eq("t")
        expect(State.peek(state, 2)) |> to_eq("h")
        expect(State.peek(state, 3)) |> to_eq("i")

        state = %{state | i: 10}

        expect(State.peek(state)) |> to_eq("e")
        expect(State.peek(state, 2)) |> to_eq("s")
        expect(State.peek(state, 3)) |> to_eq("t")
      end
    end

    context "looking too far forward" do
      it "gets stopped by the guard clause" do
        expect(fn -> State.peek(state, 4) end) |> to_have_raised(FunctionClauseError)
      end
    end
  end

  describe ".consume" do
    let :state, do: ExCss.Lexer.State.new("this")

    it "returns an updated state with the current grapheme" do
      state = State.consume(state)
      expect(state.i) |> to_eq(0)
      expect(state.grapheme) |> to_eq("t")

      state = State.consume(state)
      expect(state.i) |> to_eq(1)
      expect(state.grapheme) |> to_eq("h")

      state = State.consume(state)
      expect(state.i) |> to_eq(2)
      expect(state.grapheme) |> to_eq("i")

      state = State.consume(state)
      expect(state.i) |> to_eq(3)
      expect(state.grapheme) |> to_eq("s")

      state = State.consume(state)
      expect(state.i) |> to_eq(4)
      expect(state.grapheme) |> to_be_nil
    end
  end

  describe ".reconsume" do
    let :state, do: ExCss.Lexer.State.new("this", 2)

    it "returns an updated state with the previous grapheme" do
      state = State.reconsume(state)
      expect(state.i) |> to_eq(1)
      expect(state.grapheme) |> to_eq("h")

      state = State.reconsume(state)
      expect(state.i) |> to_eq(0)
      expect(state.grapheme) |> to_eq("t")
    end
  end
end
