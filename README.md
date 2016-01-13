# Excss

**TODO: Add description**

## Ref

https://github.com/tabatkins/parse-css

at: else if(code == 0x5c) { \\ escape outside a string, identlike thing..

rules:

Initial state, we're at -1, so peeking looks at the first character
Each consumer peeks before it consumes, if it doesn't want to consume it doesn't and returns no token

e.g.

"/* this */ is a test":-1("/* this */ is a test")
CommentsConsumer: is the next character a / and the one after a * ?
  - yes! consume those 2, consume until */
"/* this */ is a test":9(" is a test")
CommentsConsumer: is the next character a / and the one after a * ?
  - no! return state as is
WhitespaceConsumer: is the next character a whitespace?
  - yes! consume until not whitespace, return a single whitespace token
"/* thus */ is a test":10("is a test")


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add excss to your list of dependencies in `mix.exs`:

        def deps do
          [{:excss, "~> 0.0.1"}]
        end

  2. Ensure excss is started before your application:

        def application do
          [applications: [:excss]]
        end
