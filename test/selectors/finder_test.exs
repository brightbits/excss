defmodule ExCss.Selectors.FinderTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Markup.Node, as: MN

  describe ".find" do
    let :markup, do: ExCss.Markup.new(TestHelper.fixture("finding.html"))
    let :ids, do: MapSet.union(MapSet.new([markup.id]), markup.descendant_ids)

    describe "universal selector" do
      context "on its own" do
        it "returns all the node ids" do
          selector = TestHelper.parse_selector("*")

          resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
          expect(resulting_ids) |> to_eq(ids)
        end
      end
    end

    describe "type selector" do
      context "on its own" do
        it "returns only the node ids where the tag name matches" do
          selector = TestHelper.parse_selector("p")

          resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
          expect(resulting_ids) |> to_eq(MapSet.new([7,8,9,16]))
        end
      end

      context "with a single modifier" do
        context "class modifier" do
          it "returns only the node ids where the tag name matches and the tag has the class" do
            selector = TestHelper.parse_selector("p.para")

            resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
            expect(resulting_ids) |> to_eq(MapSet.new([8,16]))
          end
        end

        context "hash modifier" do
          it "returns only the node ids where the tag name matches and the id matches" do
            selector = TestHelper.parse_selector("p#this_para")

            resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
            expect(resulting_ids) |> to_eq(MapSet.new([9]))
          end
        end
      end
    end

    describe "descendant combinator" do
      context "wider descendants" do
        it "returns the correct nodes" do
          selector = TestHelper.parse_selector("body p.para")

          resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
          expect(resulting_ids) |> to_eq(MapSet.new([8, 16]))
        end
      end

      context "narrower descendants" do
        it "returns the correct nodes" do
          selector = TestHelper.parse_selector("div#page p.para")
          resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
          expect(resulting_ids) |> to_eq(MapSet.new([8]))

          selector = TestHelper.parse_selector("div.test p.para")
          resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
          expect(resulting_ids) |> to_eq(MapSet.new([16]))
        end
      end

      context "multiple levels" do
        it "returns the correct nodes" do
          selector = TestHelper.parse_selector("body div#page p.para")
          resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
          expect(resulting_ids) |> to_eq(MapSet.new([8]))

          selector = TestHelper.parse_selector("body.lol div#page p.para")
          resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
          expect(resulting_ids) |> to_eq(MapSet.new([]))

          selector = TestHelper.parse_selector(".para .para")
          resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
          expect(resulting_ids) |> to_eq(MapSet.new([16]))
        end
      end
    end
  end
end
