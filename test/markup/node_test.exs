defmodule ExCss.Markup.NodeTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Markup.Node, as: MN

  let :floki_node do
    {"p", [{"potato", "42"}], [
      "This is a test ",
      {"strong", [], ["to see"]},
      ", if the test ",
      {"span", [{"style", "color: #0f0;"}], ["passes!"]}
    ]}
  end

  let :subject_node, do: ExCss.Markup.Node.new(floki_node)

  describe ".new" do
    it "takes a floki node and recursively converts it to a excss node" do
      expected = %MN{
        tag_name: "p",
        attributes: [{"potato", "42"}],
        children: [
          "This is a test ",
          %MN{
            tag_name: "strong",
            attributes: [],
            children: ["to see"]
          },
          ", if the test ",
          %MN{
            tag_name: "span",
            attributes: [{"style", "color: #0f0;"}],
            children: ["passes!"]
          }
        ]
      }

      expect(subject_node) |> to_eq(expected)
    end
  end

  describe ".text" do
    it "returns all the text nodes joined together, from all the way down" do
      expect(MN.text(subject_node)) |> to_eq("This is a test to see, if the test passes!")
    end
  end

  describe ".attr" do
    let :subject do
      %ExCss.Markup.Node{attributes: [{"abc", "123"}]}
    end

    context "the attribute doesn't exist" do
      it "returns an empty string" do
        expect(MN.attr(subject, "nope")) |> to_eq("")
      end
    end

    context "the attribute exists" do
      it "returns the attribute value" do
        expect(MN.attr(subject, "abc")) |> to_eq("123")
      end
    end
  end

  describe ".classes" do
    let :subject do
      %ExCss.Markup.Node{attributes: [{"class", "abc def hij "}]}
    end

    it "returns an array of the classes" do
      expect(MN.classes(subject)) |> to_eq(["abc", "def", "hij"])
    end
  end

  describe ".class?" do
    let :subject do
      %ExCss.Markup.Node{attributes: [{"class", "col-md-4 col-lg-2"}]}
    end

    context "the class doesn't exist" do
      it "returns false" do
        expect(MN.class?(subject, "col-xs-8")) |> to_eq(false)
      end
    end

    context "the class exists" do
      it "returns true" do
        expect(MN.class?(subject, "col-lg-2")) |> to_eq(true)
      end
    end
  end

  describe ".tag_name?" do
    let :subject do
      %ExCss.Markup.Node{tag_name: "strong"}
    end

    context "the tag name definitely doesn't match" do
      it "returns false" do
        expect(MN.tag_name?(subject, "long")) |> to_eq(false)
      end
    end

    context "the tag name matches case insensitively" do
      it "returns true" do
        expect(MN.tag_name?(subject, "STRONG")) |> to_eq(true)
        expect(MN.tag_name?(subject, "strong")) |> to_eq(true)
      end
    end
  end
end
