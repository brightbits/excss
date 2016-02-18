defmodule ExCss.Selectors.FinderTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Markup.Node, as: MN

  describe ".find" do
    let :markup, do: ExCss.Markup.new(TestHelper.fixture("finding.html"))
    let :ids, do: ExCss.Markup.Node.ids(markup)

    describe "universal selector" do
      context "on its own" do
        it "returns all the node ids" do
          IO.puts Floki.raw_html(markup)
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
          expect(resulting_ids) |> to_eq([7,8,9])
        end
      end

      context "with a single modifier" do
        context "class modifier" do
          it "returns only the node ids where the tag name matches and the tag has the class" do
            selector = TestHelper.parse_selector("p.para")

            resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
            expect(resulting_ids) |> to_eq([8])
          end
        end

        context "hash modifier" do
          it "returns only the node ids where the tag name matches and the id matches" do
            selector = TestHelper.parse_selector("p#this_para")

            resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
            expect(resulting_ids) |> to_eq([9])
          end
        end
      end
    end

    describe "descendant combinator" do
      it "returns the correct ids" do
        selector = TestHelper.parse_selector("body p.para")

        resulting_ids = ExCss.Selectors.Finder.find(markup, selector)
        expect(resulting_ids) |> to_eq([8])
      end
    end
  end
end
