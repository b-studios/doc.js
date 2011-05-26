$(function() {  

  var header = $("#header"),
      showButton = header.find("a.expand"),
      hideButton = header.find("a.collapse");

  header.find("#api-browser > ul").treeview({
    collapsed: true, 
    animated: 'fast',
    persist: 'cookie'
  });
  
  hideButton.click(function() {
    header.addClass("collapsed");
    hideButton.hide();
    showButton.show();
  });
  
  showButton.click(function() {
    header.removeClass("collapsed");
    hideButton.show();
    showButton.hide();
  });
});