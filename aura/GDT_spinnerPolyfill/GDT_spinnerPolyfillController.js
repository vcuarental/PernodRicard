({
  toggle: function(component, event, helper) {
    $A.util.toggleClass(helper.getSpinner(component), 'slds-hide');
  },
  show: function(component, event, helper) {
    $A.util.removeClass(helper.getSpinner(component), 'slds-hide');
  },
  hide: function(component, event, helper) {
    $A.util.addClass(helper.getSpinner(component), 'slds-hide');
  }
})