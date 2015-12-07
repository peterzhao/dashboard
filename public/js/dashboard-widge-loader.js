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
Dashboard.WidgeLoader = function(board, widgeId){
  var self = this;
  self.board = board,
  self.widgeId = widgeId;
  self.data = ko.observable(null);
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
    setTimeout(self.pull, 500);
  };
};


