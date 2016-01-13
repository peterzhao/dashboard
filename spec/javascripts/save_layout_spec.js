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
    var widgets = {'widget1':{ row: 1, col:1, sizex:2, sizey: 2 }, 'widget2':{row: 1, col:2, sizex:1, sizey: 3 }} 
    Dashboard.saveLayout("my Board", widgets);
    expect(ajaxOptions.type).toBe("post"); 
    expect(ajaxOptions.dataType).toBe("json"); 
    expect(ajaxOptions.url).toBe("/boards/my%20Board/layout");
    expect(ajaxOptions.data).toBe('{"widget1":{"row":1,"col":1,"sizex":2,"sizey":2},"widget2":{"row":1,"col":2,"sizex":1,"sizey":3}}');
  });
});
