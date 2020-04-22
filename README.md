# DynamicInputsFor

Dynamically add/remove nested fields to your Phoenix forms from the client with a
thin JavaScript layer.

## Installation

1. The package can be installed by adding `dynamic_inputs_for` to your list of
   dependencies in `mix.exs`:

```elixir
def deps do
  [{:dynamic_inputs_for, "~> 1.1.0"}]
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

## Usage example

Imagine the following Ecto schemas:

```elixir
defmodule Shop do
  use Ecto.Schema

  schema "shops" do
    field :name, :string
    has_many :products, Product
  end
end

defmodule Product do
  use Ecto.Schema

  schema "products" do
    field :name, :string
    ...

    belongs_to(:shop, Shop)
  end
end
```

If you want to be able to dynamically add products in a form, use the
`dynamic_inputs_for` helper in combination with `dynamic_add_button` to generate
the form.

If you also want to allow the deletion of nested fields, this library follows the
strategy suggested in the
[Ecto.Changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html) documentation. Add a
separate boolean virtual field to the changeset function that will allow you to
manually mark the associated data for deletion and use the `dynamic_delete_button`
helper inside the function that you pass to `dynamic_inputs_for` to generate a delete
button for each associated data.

```elixir
defmodule Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    ...
    field :delete, :boolean, virtual: true

    belongs_to(:shop, Shop)
  end

  def changeset(product, params) do
    product
    |> cast(params, [:name, :delete])
    |> maybe_mark_for_deletion
  end

  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
```

```eex
<%= form_for @changeset, Routes.shop_path(@conn, :create), fn f -> %>
  <%= text_input f, :name %>

  <%= dynamic_inputs_for f, :products, %Product{}, fn f_product -> %>
    <%= text_input f_product, :name %>

    <%= dynamic_delete_button("Delete") %>
  <% end%>

  <%= dynamic_add_button :products, "Add" %>
<% end %>
```

If you want the new fields to have default values, you can pass them to the schema
you pass to `dynamic_inputs_for`. In the previous example `%Product{name: "ASDF"}`.

```eex
<%= dynamic_inputs_for f, :products, %Product{name: "ASDF"}, fn f_product -> %>
```

## Custom JavaScript events

When you add or delete an element, the events `dynamic:addedFields` and
`dynamic:deletedFields` are triggered. These events can be listened to modify the
nested fields or integrate them with third party javascript libraries.

```js
document.addEventListener(
  "dynamic:addedFields",
  function(e) {
    e.target.style.backgroundColor = "red";
  },
  false
);
```

or if you use jQuery

```js
$(document).on("dynamic:addedFields", e => {
  e.target.style.backgroundColor = "red";
});
```
