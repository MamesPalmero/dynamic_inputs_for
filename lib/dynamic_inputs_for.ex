defmodule DynamicInputsFor do
  @moduledoc """
  Helpers to create HTML forms with nested fields that can be created and deleted dynamically from
  the client.

  The functions in this module extend the functionality of `Phoenix.HTML.Form.inputs_for/4` to
  return the html of a form with nested fields grouped in HTML tags with a class called `fields` and
  the necessary anchors to add javascript that allows to add more fields dynamically from the
  client.
  """

  import Phoenix.HTML
  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag

  @doc """
  It works like `Phoenix.HTML.Form.inputs_for/4`, but it also returns an HTML tag with the
  information needed to add and delete fields from the client. The template argument is used to
  generate the new nested fields.
  The `dynamic_button_to_add/3` function generates the button to add the fields.

  ## Options

    * `:wrapper_tag` - HTML tag name to wrap the fields.

    * `:wrapper_attrs` - HTML attributes for the wrapper.

  See `Phoenix.HTML.Form.inputs_for/4` for other options.
  """
  def dynamic_inputs_for(form, association, template, options \\ [], fun)
      when is_atom(association) or is_binary(association) do
    {wrapper_attrs, options} = Keyword.pop(options, :wrapper_attrs, [])
    {wrapper_class, wrapper_attrs} = Keyword.pop(wrapper_attrs, :class, "")
    {wrapper_tag, options} = Keyword.pop(options, :wrapper_tag, :div)

    wrapper_attrs =
      Keyword.merge(wrapper_attrs, data_assoc: association, class: "fields " <> wrapper_class)

    # Remove the parameters of the form to force that the prepended values are always rendered
    form_template =
      form.source
      |> form.impl.to_form(
        %{form | params: %{}},
        association,
        Keyword.put(options, :prepend, [template])
      )
      |> hd()

    html_template =
      wrapper_tag
      |> content_tag([fun.(form_template)], wrapper_attrs)
      |> safe_to_string()

    [
      inputs_for(form, association, options, fn form_assoc ->
        wrapper_attrs = Keyword.put(wrapper_attrs, :data_assoc_index, form_assoc.index)
        content_tag(wrapper_tag, [fun.(form_assoc)], wrapper_attrs)
      end),
      content_tag(wrapper_tag, [],
        id: "dynamic_info_#{association}",
        style: "display: none;",
        data: [
          assoc: [template: html_template, id: form_template.id, name: form_template.name],
          assoc: association
        ]
      )
    ]
  end

  @doc """
  Creates a button to add more nested fields to the fields generated with `dynamic_inputs_for/4`.
  """
  def dynamic_button_to_add(association, content)
      when is_atom(association) or is_binary(association) do
    dynamic_button_to_add(association, content, [])
  end

  def dynamic_button_to_add(association, attrs, do: block)
      when (is_atom(association) or is_binary(association)) and is_list(attrs) do
    dynamic_button_to_add(association, block, attrs)
  end

  def dynamic_button_to_add(association, content, attrs)
      when (is_atom(association) or is_binary(association)) and is_list(attrs) do
    content_tag(
      :button,
      content,
      Keyword.merge(attrs, type: "button", data_assoc: association, data_assoc_add: "")
    )
  end
end
