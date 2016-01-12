if(typeof(Dashboard) === "undefined") Dashboard = {}
Dashboard.layoutChangeHandler = function(board){
  var widges = $('.dashboard-widge');
  for(i=0; i<widges.length; i++){
    var id = $(widges[i]).attr('widge-name');
    var model = widge_models[id];
    var sizex = $(widges[i]).attr('data-sizex')
    var sizey = $(widges[i]).attr('data-sizey')
    var row = $(widges[i]).attr('data-row')
    var col = $(widges[i]).attr('data-col')
    model.changeSize(sizex, sizey, row, col);
    model.pull();
  };
  Dashboard.saveLayout(board, widge_models);
};

Dashboard.saveLayout = function(board, widges){
  var widgesData = {};
  for(var id in widges){
    model = widges[id];
    widgesData[ id ] = { row: model.row, col: model.col, sizex: model.sizex, sizey: model.sizey }
  }
  jQuery.ajax({
    url: "/boards/" + encodeURI(board) + "/layout",
    contentType: "application/json; charset=utf-8",
    type: "post",
    dataType: "json",
    data: JSON.stringify(widgesData)
  });
};
