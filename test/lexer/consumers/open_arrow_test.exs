defmodule ConsumersOpenArrowTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "doesn't match <" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.OpenArrow.accept(TestHelper.state_for("<a<!--test", 0))
        expect(new_state.pos) |> to_eq(0)
        expect(token) |> to_be_nil
      end
    end

    context "matches <" do
      context "next 3 are !--" do
        it "returns a cdo and advances 4 char" do
          {new_state, token} = ExCss.Lexer.Consumers.OpenArrow.accept(TestHelper.state_for("<a<!--test", 1))
          expect(token) |> to_eq({:cdo, {}})
          expect(new_state.pos) |> to_eq(5)
        end
      end

      context "next 3 aren't !--" do
        it "returns a delim of < advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.OpenArrow.accept(TestHelper.state_for("<a<!--test"))
          expect(new_state.pos) |> to_eq(0)
          expect(token) |> to_eq({:delim, {"<"}})
        end
      end
    end
  end
end
