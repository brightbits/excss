defmodule ExCss.Markup.NodeTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Markup.Node, as: MN

  describe ".set_id" do
    context "no excss_id attribute" do
      it "adds an excss_id attribute with the given value" do
        expect(MN.set_id({"h1", [{"id", "test"}], [:a, :b]}, 42)) |>
          to_eq({"h1", [{:excss_id, 42}, {"id", "test"}], [:a, :b]})
      end
    end

    context "already has excss_id attribute" do
      it "sets the excss_id attribute to the given value" do
        expect(MN.set_id({"h1", [{:excss_id, 40}, {"id", "test"}], [:a, :b]}, 42)) |>
          to_eq({"h1", [{:excss_id, 42}, {"id", "test"}], [:a, :b]})
      end
    end
  end

  describe ".id" do
    context "no excss_id attribute" do
      it "raises an error" do
        expect(fn -> MN.id({"h1", [{"id", "test"}], []}) end) |>
          to_have_raised(RuntimeError)
      end
    end

    context "has excss_id attribute" do
      it "returns the value" do
        expect(MN.id({"h1", [{:excss_id, 42}, {"id", "test"}], []})) |>
          to_eq(42)
      end
    end
  end

  describe ".set_children" do
    it "sets the children to the given value" do
      expect(MN.set_children({"h1", [1, 2, 3], [:a, :b]}, [:a, :b, :c])) |>
        to_eq({"h1", [1, 2, 3], [:a, :b, :c]})
    end
  end

  describe ".children" do
    it "returns them" do
      expect(MN.children({"h1", [], [:a, :b, :c]})) |>
        to_eq([:a, :b, :c])
    end
  end
end
