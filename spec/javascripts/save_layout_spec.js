describe("Dashboard.saveLayout", function() {
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

  it("should save layout successfully", function(){
    var widgets = {'widget1':{ row: 1, col:1, sizex:2, sizey: 2 }, 'widget2':{row: 1, col:2, sizex:1, sizey: 3 }};
    Dashboard.saveLayout("my Board", widgets);
    expect(ajaxOptions.type).toBe("post"); 
    expect(ajaxOptions.dataType).toBe("json"); 
    expect(ajaxOptions.url).toBe("/boards/my%20Board/layout");
    expect(ajaxOptions.data).toBe('{"widget1":{"row":1,"col":1,"sizex":2,"sizey":2},"widget2":{"row":1,"col":2,"sizex":1,"sizey":3}}');
    spyOn(Dashboard, 'pull');
    ajaxOptions.success();
    expect(Dashboard.pull).toHaveBeenCalled();
  });

  it("should pull all widgets", function(){
    var widget1 = {'pull': function(){}};
    var widget2 = {'pull': function(){}};
    var widgets = {'widget1': widget1, 'widget2':widget2};
    spyOn(widget1, 'pull');
    spyOn(widget2, 'pull');
    Dashboard.pull(widgets);
    expect(widget1.pull).toHaveBeenCalled();
    expect(widget2.pull).toHaveBeenCalled();
  });
});
