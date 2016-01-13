defmodule ConsumersStringTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "not opening a string" do
      it "returns no token and doesn't advance the state" do
        {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("abc"))
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "is opening a string" do
      it "returns a string token and advances the state until the end of the string" do
        {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("aaa\"this is a test\" test", 2))
        expect(new_state.pos) |> to_eq(18)
        expect(token) |> to_eq({:string, "this is a test"})
      end

      it "works with a single quoted string too" do
        {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("aaa'this is a test' test", 2))
        expect(new_state.pos) |> to_eq(18)
        expect(token) |> to_eq({:string, "this is a test"})
      end

      context "the string doesn't end before the EOF" do
        it "returns a string token and advances the state until the end of the string" do
          {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("aaa\"this is a test", 2))
          expect(new_state.pos) |> to_eq(18)
          expect(token) |> to_eq({:string, "this is a test"})
        end
      end

      context "the string has a new line that isn't escaped" do
        it "returns a bad string token and adds a warning" do
          {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("aaa\"this is a test\ncats\"", 2))
          expect(new_state.pos) |> to_eq(17)
          expect(token) |> to_eq({:bad_string, "this is a test"})
          expect(new_state.warnings) |> to_eq(["String wasn't closed before new line and the new line wasn't escaped"])
        end
      end

      context "the string has a new line that is escaped" do
        it "returns a string token" do
          {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("aaa\"this is a test\\\ncats\"", 2))
          expect(new_state.pos) |> to_eq(24)
          expect(token) |> to_eq({:string, "this is a testcats"})
        end
      end

      context "the string has an escape before the end of the file" do
        it "returns a string token" do
          {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("aaa\"this is a test\\", 2))
          expect(token) |> to_eq({:string, "this is a test"})
          expect(new_state.pos) |> to_eq(19)
        end
      end

      context "the string has an escaped quote" do
        it "returns a string token" do
          {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("aaa \"this is a \\\"test\" :)", 3))
          expect(token) |> to_eq({:string, "this is a \"test"})
          expect(new_state.pos) |> to_eq(21)
        end
      end

      context "the string has an escaped hex" do
        it "returns a string token" do
          {new_state, token} = ExCss.Consumers.String.accept(TestHelper.state_for("aaa \"this is a \\c582 :)\"", 3))
          expect(token) |> to_eq({:string, "this is a ł :)"})
          expect(new_state.pos) |> to_eq(23)
        end
      end
    end
  end
end
