defmodule ExCss.MarkupTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  describe ".new" do
    let(:html) do
      """
        <html>
          <head>
            <title>This is a title</title>
          </head>
          <body>
            <h1>This is an article</h1>
            <p>This is some content, with <strong>bold things</strong> and <span style="color: red;">red things</span>.</p>

            <footer>Copyright 1942</footer>
          </body>
        </html>
      """
    end

    it "returns the nodes of the html with excss ids correctly" do
      expected = {"html", [{:excss_id, 0}],
        [
          {"head", [{:excss_id, 1}],
            [
              {"title", [{:excss_id, 2}], ["This is a title"]}
            ]
          },
          {"body", [{:excss_id, 3}],
            [
              {"h1", [{:excss_id, 4}], ["This is an article"]},
              {"p", [{:excss_id, 5}],
                [
                  "This is some content, with ",
                  {"strong", [{:excss_id, 6}], ["bold things"]},
                  " and ",
                  {"span", [{:excss_id, 7}, {"style", "color: red;"}], ["red things"]},
                  "."
                ]
              },
              {"footer", [{:excss_id, 8}], ["Copyright 1942"]}
            ]}
        ]
      }

      expect(ExCss.Markup.new(html)) |> to_eq(expected)
    end
  end
end
