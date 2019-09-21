"use strict";

(function() {
  function stringToHTML(str) {
    var parser = new DOMParser();
    var doc = parser.parseFromString(str, "text/html");

    return doc.body.firstChild;
  }

  function getFieldsTemplate(infoElement) {
    var lastNumber = /\d+(?=\D*$)/;
    var id = infoElement.getAttribute("data-assoc-id");
    var name = infoElement.getAttribute("data-assoc-name");
    var index = new Date().getTime();
    var template = stringToHTML(
      infoElement.getAttribute("data-assoc-template")
    );

    template.setAttribute("data-assoc-index", index);
    template.querySelectorAll("[name^='" + name + "']").forEach(function(el) {
      el.name = el.name.replace(lastNumber, index);
    });
    template.querySelectorAll("[id^='" + id + "']").forEach(function(el) {
      el.id = el.id.replace(lastNumber, index);
    });
    template.querySelectorAll("[for^='" + id + "']").forEach(function(el) {
      el.htmlFor = el.htmlFor.replace(lastNumber, index);
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

  window.addEventListener("click", handleAddFields, false);
})();
