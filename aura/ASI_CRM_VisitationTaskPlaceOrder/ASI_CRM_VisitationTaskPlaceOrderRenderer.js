({

// Your renderer method overrides go here
  afterRender : function(component, helper) {
    this.superAfterRender(); 
    var targetComponent = component.find("mainContainer");
    if (targetComponent) {
      var element = targetComponent.getElement()

      element.addEventListener("touchmove", function(e) {
          e.stopPropagation();
      }, false); 
    }
  }
})