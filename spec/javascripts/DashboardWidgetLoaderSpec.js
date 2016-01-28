describe("Dashboard.WidgetLoade", function() {
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
    var loader = new Dashboard.WidgetLoader("my Board", "widget 1", "100", "100");
    
    loader.hasError(true);
    expect(loader.data()).toBe(null);
    loader.pull();
    expect(ajaxOptions.type).toBe("get"); 
    expect(ajaxOptions.url).toBe("/boards/my%20Board/widgets/widget%201");

    loader.pull_seccess_handler = function(id, html){};
    spyOn(loader, 'pull_seccess_handler');
    var data = "<html></html>" 
    ajaxOptions.success(data);
    expect(loader.pull_seccess_handler).toHaveBeenCalled;
    expect(loader.hasError()).toBe(false);
  });


  it("should set error when failed to pull data", function(){
    var loader = new Dashboard.WidgetLoader("myBoard", "widget1", "100", "100");
    expect(loader.data()).toBe(null);
    loader.pull();
    expect(ajaxOptions.type).toBe("get"); 
    expect(ajaxOptions.url).toBe("/boards/myBoard/widgets/widget1");

    ajaxOptions.error({});

    expect(loader.error()).toBe("Failed to connect to the JU server!");
    expect(loader.hasError()).toBe(true);
  });
});
