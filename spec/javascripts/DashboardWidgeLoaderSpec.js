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

  it("should pull data successfully", function(){
    var loader = new Dashboard.WidgeLoader("my Board", "widge 1", "100", "100");
    expect(loader.data()).toBe(null);
    loader.pull();
    expect(ajaxOptions.type).toBe("get"); 
    expect(ajaxOptions.dataType).toBe("json"); 
    expect(ajaxOptions.url).toBe("/boards/my%20Board/widges/widge%201");

    var data = {"boo": "foo"}; 
    ajaxOptions.success(data);

    expect(loader.data()).toBe(data);
    expect(loader.hasError()).toBe(false);
  });

  it("should pull data with error", function(){
    var loader = new Dashboard.WidgeLoader("myBoard", "widge1", "100", "100");
    expect(loader.data()).toBe(null);
    loader.pull();
    expect(ajaxOptions.type).toBe("get"); 
    expect(ajaxOptions.dataType).toBe("json"); 
    expect(ajaxOptions.url).toBe("/boards/myBoard/widges/widge1");

    var data = {"error": "broken connection"}; 
    ajaxOptions.success(data);

    expect(loader.hasError()).toBe(true);
    expect(loader.error()).toBe(data.error);
  });

  it("should set error when failed to pull data", function(){
    var loader = new Dashboard.WidgeLoader("myBoard", "widge1", "100", "100");
    expect(loader.data()).toBe(null);
    loader.pull();
    expect(ajaxOptions.type).toBe("get"); 
    expect(ajaxOptions.dataType).toBe("json"); 
    expect(ajaxOptions.url).toBe("/boards/myBoard/widges/widge1");

    ajaxOptions.error();

    expect(loader.error()).toBe("Failed to update data from the dashboard server.");
    expect(loader.hasError()).toBe(true);
  });
});
