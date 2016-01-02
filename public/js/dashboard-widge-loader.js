if(typeof(Dashboard) === "undefined") Dashboard = {}
Dashboard.WidgeLoader = function(board, id, base_width, base_height, sizex, sizey){
  var self = this;
  self.board = board,
  self.id = id;
  self.base_width = base_width;
  self.base_height = base_height;
  self.sizex = sizex;
  self.sizey = sizey;
  self.row = 1;
  self.col = 1;
  self.data = ko.observable(null);
  self.error = ko.observable(null);
  self.hasError = ko.observable(false);

  self.changeSize = function(sizex, sizey, row, col){
    self.sizex = sizex;
    self.sizey = sizey;
    self.row = row;
    self.col = col;
  };

  self.pull = function(){
    if(typeof(debug) != "undefined" && debug == true) return;
    jQuery.ajax({
      url: "/board/" + encodeURI(self.board) + "/widge/" + encodeURI(id),
      contentType: "application/json; charset=utf-8",
      type: "get",
      dataType: "json",
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        self.error("Failed to update data from the dashboard server.");
        self.hasError(true);
      },
      success: function(result){
        if(result.error == null){
          self.data(result);
          self.hasError(false);
        }else{
          self.error(result.error);
          self.hasError(true);
        }
      }
    });
  };
  self.startPull = function(){
    self.pull();
    setInterval(self.pull, 15000);
  };
};


