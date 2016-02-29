defmodule ExCss.MarkupTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Markup.Node, as: MN

  let :html, do: TestHelper.fixture("simple.html")

  describe ".new" do
    it "returns the processed nodes with the correct data attached" do
      expected = %MN{
        id: 0,
        parent_id: nil,
        child_ids: MapSet.new([1, 3]),
        descendant_ids: MapSet.new([1, 2, 3, 4, 5, 6, 7, 8]),
        adjacent_sibling_id: nil,
        general_sibling_ids: MapSet.new([]),

        tag_name: "html",
        attributes: [],
        children: [
          %MN{
            id: 1,
            parent_id: 0,
            child_ids: MapSet.new([2]),
            descendant_ids: MapSet.new([2]),
            adjacent_sibling_id: 3,
            general_sibling_ids: MapSet.new([3]),

            tag_name: "head",
            attributes: [],
            children: [
              %MN{
                id: 2,
                parent_id: 1,
                child_ids: MapSet.new([]),
                descendant_ids: MapSet.new([]),
                adjacent_sibling_id: nil,
                general_sibling_ids: MapSet.new([]),

                tag_name: "title",
                attributes: [],
                children: ["This is a title"]
              }
            ]
          },
          %MN{
            id: 3,
            parent_id: 0,
            child_ids: MapSet.new([4, 5, 8]),
            descendant_ids: MapSet.new([4, 5, 6, 7, 8]),
            adjacent_sibling_id: nil,
            general_sibling_ids: MapSet.new([1]),

            tag_name: "body",
            attributes: [],
            children: [
              %MN{
                id: 4,
                parent_id: 3,
                child_ids: MapSet.new([]),
                descendant_ids: MapSet.new([]),
                adjacent_sibling_id: 5,
                general_sibling_ids: MapSet.new([5, 8]),

                tag_name: "h1",
                attributes: [],
                children: ["This is an article"]
              },
              %MN{
                id: 5,
                parent_id: 3,
                child_ids: MapSet.new([6, 7]),
                descendant_ids: MapSet.new([6, 7]),
                adjacent_sibling_id: 8,
                general_sibling_ids: MapSet.new([4, 8]),

                tag_name: "p",
                attributes: [],
                children: [
                  "This is some content, with ",
                  %MN{
                    id: 6,
                    parent_id: 5,
                    child_ids: MapSet.new([]),
                    descendant_ids: MapSet.new([]),
                    adjacent_sibling_id: 7,
                    general_sibling_ids: MapSet.new([7]),

                    tag_name: "strong",
                    attributes: [],
                    children: ["bold things"]
                  },
                  " and ",
                  %MN{
                    id: 7,
                    parent_id: 5,
                    child_ids: MapSet.new([]),
                    descendant_ids: MapSet.new([]),
                    adjacent_sibling_id: nil,
                    general_sibling_ids: MapSet.new([6]),

                    tag_name: "span",
                    attributes: [
                      {"style", "color: red;"}
                    ],
                    children: ["red things"]
                  },
                  "."
                ]
              },
              %MN{
                id: 8,
                parent_id: 3,
                child_ids: MapSet.new([]),
                descendant_ids: MapSet.new([]),
                adjacent_sibling_id: nil,
                general_sibling_ids: MapSet.new([4, 5]),

                tag_name: "footer",
                attributes: [],
                children: ["Copyright 1942"]
              }
            ]
          }
        ]
      }

      expect(ExCss.Markup.new(html)) |> to_eq(expected)
    end
  end
end
