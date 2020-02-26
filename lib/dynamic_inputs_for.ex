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
  The `dynamic_add_button/3` function generates the button to add the fields.

  ## Options

    * `:wrapper_tag` - HTML tag name to wrap the fields.

    * `:wrapper_attrs` - HTML attributes for the wrapper.

    * `:association_alias` - the name to be used in the form to generate the id of the element
      that has the template and is used to generate the fields, defaults the name of the
      association. It is usable to avoid conflicts with repeated ids when an association is
      called several times or there are different associations with the same name.

    * `:only_mark_deleted` - create an input called `delete` with `"true"` value and add the
      `deleted-fields` class to the wrapper to choose how to handle after validation errors. By
      default when a group of nested inputs is deleted the content is deleted, to avoid HTML
      validations, it is hidden and the input called `delete` with `"true"` value is created.

  See `Phoenix.HTML.Form.inputs_for/4` for other options.
  """
  def dynamic_inputs_for(form, association, template, options \\ [], fun)
      when is_atom(association) or is_binary(association) do
    {wrapper_attrs, options} = Keyword.pop(options, :wrapper_attrs, [])
    {wrapper_tag, options} = Keyword.pop(options, :wrapper_tag, :div)
    {only_mark_deleted, options} = Keyword.pop(options, :only_mark_deleted, false)
    {association_alias, options} = Keyword.pop(options, :association_alias, association)

    wrapper_attrs = Keyword.update(wrapper_attrs, :class, "fields", &("fields " <> &1))
    wrapper_attrs = Keyword.put(wrapper_attrs, :data_assoc, association_alias)

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
        fields_for_association(form_assoc, fun, wrapper_tag, wrapper_attrs, only_mark_deleted)
      end),
      content_tag(wrapper_tag, [],
        id: "dynamic_info_#{association_alias}",
        style: "display: none;",
        data: [
          assoc: [
            template: html_template,
            id: form_template.id,
            name: form_template.name,
            only_mark_deleted: only_mark_deleted
          ],
          assoc: association_alias
        ]
      )
    ]
  end

  defp fields_for_association(
         %Phoenix.HTML.Form{params: %{"delete" => "true"}} = form,
         fun,
         wrapper_tag,
         wrapper_attrs,
         true
       ) do
    wrapper_attrs = Keyword.update(wrapper_attrs, :class, "", &(&1 <> " deleted-fields"))
    hidden_input = hidden_input(form, :delete)
    content_tag(wrapper_tag, [fun.(form), hidden_input], wrapper_attrs)
  end

  defp fields_for_association(
         %Phoenix.HTML.Form{params: %{"delete" => "true"}} = form,
         _fun,
         wrapper_tag,
         wrapper_attrs,
         _only_mark_deleted
       ) do
    wrapper_attrs = Keyword.update(wrapper_attrs, :class, "", &(&1 <> " deleted-fields"))
    wrapper_attrs = Keyword.put(wrapper_attrs, :style, "display: none;")
    hidden_input = hidden_input(form, :delete)
    content_tag(wrapper_tag, [hidden_input], wrapper_attrs)
  end

  defp fields_for_association(form, fun, wrapper_tag, wrapper_attrs, _only_mark_deleted) do
    content_tag(wrapper_tag, [fun.(form)], wrapper_attrs)
  end

  @doc """
  Creates a button to add more nested fields to the fields generated with `dynamic_inputs_for/5`.
  """
  def dynamic_add_button(association, content)
      when is_atom(association) or is_binary(association) do
    dynamic_add_button(association, content, [])
  end

  def dynamic_add_button(association, attrs, do: block)
      when (is_atom(association) or is_binary(association)) and is_list(attrs) do
    dynamic_add_button(association, block, attrs)
  end

  def dynamic_add_button(association, content, attrs)
      when (is_atom(association) or is_binary(association)) and is_list(attrs) do
    content_tag(
      :button,
      content,
      Keyword.merge(attrs, type: "button", data_assoc: association, data_assoc_add: "")
    )
  end

  @doc """
  Creates a button to mark association for deletion. When the button is pressed, a hidden input
  called `delete` is created and set to `"true"`. For this button to work, it must be called within
  the function that is passed to `dynamic_inputs_for/5`.
  """
  def dynamic_delete_button(content) do
    dynamic_delete_button(content, [])
  end

  def dynamic_delete_button(attrs, do: block) when is_list(attrs) do
    dynamic_delete_button(block, attrs)
  end

  def dynamic_delete_button(content, attrs) when is_list(attrs) do
    content_tag(
      :button,
      content,
      Keyword.merge(attrs, type: "button", data_assoc_delete: "")
    )
  end
end
