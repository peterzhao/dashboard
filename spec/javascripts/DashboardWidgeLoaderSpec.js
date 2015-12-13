describe("Dashboard.WidgeLoade", function() {
  var ajax;
  var ajaxOptions;
  beforeEach(function() {
    ajax = jQuery.ajax;
    ajaxOptions;
    jQuery.ajax = function(options){
      ajaxOptions = options;
    };
  });
  afterEach(function() {
    jQuery.ajax = ajax;
  });

  it("should pull data", function(){
    var loader = new Dashboard.WidgeLoader("myBoard", "widge1", "100", "100");
    expect(loader.data()).toBe(null);
    loader.pull();
    expect(ajaxOptions.type).toBe("get"); 
    expect(ajaxOptions.dataType).toBe("json"); 
    expect(ajaxOptions.url).toBe("/board/myBoard/widge/widge1");

    var data = {"boo": "foo"}; 
    ajaxOptions.success(data);

    expect(loader.data()).toBe(data);
  });
});
