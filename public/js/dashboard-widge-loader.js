if(typeof(Dashboard) === "undefined") Dashboard = {}
Dashboard.WidgeLoader = function(board, widgeId, base_width, base_height){
  var self = this;
  self.board = board,
  self.widgeId = widgeId;
  self.base_width = base_width;
  self.base_height = base_height;
  self.sizex = 1;
  self.sizey = 1;
  self.data = ko.observable(null);
  self.error = ko.observable(null);
  self.hasError = ko.observable(false);
  self.changeSize = function(x, y){
    self.sizex = x;
    self.sizey = y;
  };

  self.pull = function(){
    jQuery.ajax({
      url: "/board/" + self.board + "/widge/" + widgeId,
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


