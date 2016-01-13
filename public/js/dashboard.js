if(typeof(Dashboard) === "undefined") Dashboard = {}
Dashboard.layoutChangeHandler = function(board){
  var widgets = $('.dashboard-widget');
  for(i=0; i<widgets.length; i++){
    var id = $(widgets[i]).attr('widget-name');
    var model = widget_models[id];
    var sizex = $(widgets[i]).attr('data-sizex')
    var sizey = $(widgets[i]).attr('data-sizey')
    var row = $(widgets[i]).attr('data-row')
    var col = $(widgets[i]).attr('data-col')
    model.changeSize(sizex, sizey, row, col);
    model.pull();
  };
  Dashboard.saveLayout(board, widget_models);
};

Dashboard.saveLayout = function(board, widgets){
  var widgetsData = {};
  for(var id in widgets){
    model = widgets[id];
    widgetsData[ id ] = { row: model.row, col: model.col, sizex: model.sizex, sizey: model.sizey }
  }
  jQuery.ajax({
    url: "/boards/" + encodeURI(board) + "/layout",
    contentType: "application/json; charset=utf-8",
    type: "post",
    dataType: "json",
    data: JSON.stringify(widgetsData)
  });
};
