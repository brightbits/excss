defmodule ConsumersDashMatchTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "doesn't match |" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.DashMatch.accept(TestHelper.state_for("="))
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches |" do
      context "next char is a =" do
        it "returns an dash match" do
          {new_state, token} = ExCss.Lexer.Consumers.DashMatch.accept(TestHelper.state_for("|="))
          expect(new_state.pos) |> to_eq(1)
          expect(token) |> to_eq({:dash_match, {}})
        end
      end

      context "next char is a |" do
        it "returns a column token" do
          {new_state, token} = ExCss.Lexer.Consumers.DashMatch.accept(TestHelper.state_for("||"))
          expect(new_state.pos) |> to_eq(1)
          expect(token) |> to_eq({:column, {}})
        end
      end

      context "next char is something else" do
        it "returns a delim token" do
          {new_state, token} = ExCss.Lexer.Consumers.DashMatch.accept(TestHelper.state_for("|cat"))
          expect(new_state.pos) |> to_eq(0)
          expect(token) |> to_eq({:delim, {"|"}})
        end
      end
    end
  end
end
