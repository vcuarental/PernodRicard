({
    showSpinner: function(component){
            var spinner = component.find("spinner");
            $A.util.removeClass(spinner, "slds-hide");
        }
})