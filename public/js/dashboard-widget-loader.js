if(typeof(Dashboard) === "undefined") Dashboard = {}
Dashboard.WidgetLoader = function(board, id, base_width, base_height, pull_inteval, sizex, sizey){
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
  self.pull_inteval = pull_inteval;

  self.changeSize = function(sizex, sizey, row, col){
    self.sizex = sizex;
    self.sizey = sizey;
    self.row = row;
    self.col = col;
  };

  self.pull = function(){
    if(typeof(debug) != "undefined" && debug == true) return;
    jQuery.ajax({
      url: "/boards/" + encodeURI(self.board) + "/widgets/" + encodeURI(id),
      contentType: "text/html; charet=utf-8",
      type: "get",
      error: function(XMLHttpRequest) {
        if(typeof(XMLHttpRequest.responseJSON) == "undefined")
          self.error("Failed to connect to the JU server!");
        else
          self.error(XMLHttpRequest.responseJSON.message);
        self.hasError(true);
      },
      success: function(result){
        if(typeof(self.pull_success_handler) != "undefined")
           self.pull_success_handler(self.id, result);
        self.hasError(false);
      }
    });
  };
  self.startPull = function(){
    self.pull();
    setInterval(self.pull, self.pull_inteval);
  };
};


