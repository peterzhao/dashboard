window.console = window.console || { log: function(){}}; 
if(typeof(Log) === "undefined") {
 Log = {
   debug:  function(message){
     console.log('Debug', message);     
   },
   error:  function(message){
     console.log('Error', message);     
   }
 }
}

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
  self.changeSize = function(x, y){
    self.sizex = x;
    self.sizey = y;
  };
  self.pull = function(){
    $.ajax({
      url: "/board/" + self.board + "/widge/" + widgeId,
      contentType: "application/json; charset=utf-8",
      type: "get",
      dataType: "json",
      error: function(XMLHttpRequest, textStatus, errorThrown) {
       Log.error(arguments);
       },
      success: function(result){
        self.data(result);
      }
    });
  };
  self.startPull = function(){
    self.pull();
    setInterval(self.pull, 15000);
  };
};


