# DynamicInputsFor

Dynamically add/remove nested fields to your Phoenix forms from the client with a
thin JavaScript layer (WIP).

## Installation

1. The package can be installed by adding `dynamic_inputs_for` to your list of
   dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dynamic_inputs_for,
     git: "https://github.com/MamesPalmero/dynamic_inputs_for.git", branch: "master"}
  ]
end
```

2. Then add `dynamic_inputs_for` to your list of dependencies in `package.json` and
   run `npm install`. For the default Phoenix structure, in `assets/package.json`:

```json
"dependencies": {
  "dynamic_inputs_for": "file:../deps/dynamic_inputs_for"
}
```

3. Finally, don't forget to import the module. For the default Phoenix structure, in
   `assets/js/app.js`:

```js
import "dynamic_inputs_for";
```
