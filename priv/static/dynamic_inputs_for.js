"use strict";

(function() {
  var LAST_NUMBER = /\d+(?=\D*$)/;

  function stringToHTML(str) {
    var parser = new DOMParser();
    var doc = parser.parseFromString(str, "text/html");

    return doc.body.firstChild;
  }

  function getFieldsTemplate(infoElement) {
    var id = infoElement.getAttribute("data-assoc-id");
    var name = infoElement.getAttribute("data-assoc-name");
    var index = new Date().getTime();
    var template = stringToHTML(
      infoElement.getAttribute("data-assoc-template")
    );

    template.setAttribute("data-assoc-index", index);
    template.querySelectorAll("[name^='" + name + "']").forEach(function(el) {
      el.name = el.name.replace(LAST_NUMBER, index);
    });
    template.querySelectorAll("[id^='" + id + "']").forEach(function(el) {
      el.id = el.id.replace(LAST_NUMBER, index);
    });
    template.querySelectorAll("[for^='" + id + "']").forEach(function(el) {
      el.htmlFor = el.htmlFor.replace(LAST_NUMBER, index);
    });

    return template;
  }

  function handleAddFields(e) {
    var element = e.target;

    if (element.hasAttribute("data-assoc-add")) {
      var assoc = element.getAttribute("data-assoc");
      var infoElement = document.querySelector("#dynamic_info_" + assoc);
      var template = getFieldsTemplate(infoElement);

      infoElement.parentElement.insertBefore(template, infoElement);

      var customEvent = new CustomEvent("dynamic:addFields", {
        bubbles: true,
        cancelable: true
      });
      template.dispatchEvent(customEvent);
    }
  }

  function handleRemoveFields(e) {
    var element = e.target;

    if (element.hasAttribute("data-assoc-delete")) {
      var wrapperElement = element.closest(".fields");
      var assoc = wrapperElement.getAttribute("data-assoc");
      var infoElement = document.querySelector("#dynamic_info_" + assoc);
      var index = wrapperElement.getAttribute("data-assoc-index");
      var input = document.createElement("input");

      input.type = "hidden";
      input.name = infoElement.getAttribute("data-assoc-name") + "[delete]";
      input.name = input.name.replace(LAST_NUMBER, index);
      input.value = "true";

      wrapperElement.innerHTML = "";
      wrapperElement.appendChild(input);
      wrapperElement.style.display = "none";

      var customEvent = new CustomEvent("dynamic:deleteFields", {
        bubbles: true,
        cancelable: true
      });
      wrapperElement.dispatchEvent(customEvent);
    }
  }

  window.addEventListener("click", handleAddFields, false);
  window.addEventListener("click", handleRemoveFields, false);
})();
