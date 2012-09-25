$(function() {
  $("h1").lettering();

  $("pre code").each(function(index, element) {
    var $el = $(element);
    var lines = $el.html().split(/\n/);
    var matches = lines[0].match(/^#!(\w+)/); 
    if (matches && matches.length > 1) {
      $el.html(lines.slice(1, lines.length).join("\n"));
      $el.addClass("brush: " + matches[1]);
    } else {
      $el.addClass("brush: ruby");
    }
  });

  SyntaxHighlighter.config.tagName = "code";

  SyntaxHighlighter.all({ 
    "gutter": false,
    "quick-code": false,
    "auto-links": false
  });

  $("h3").each(function(index, h3) {
    $h3 = $(h3);
    $h3.attr("id", $h3.text().split(" ")[0].toLowerCase());
  });
});
