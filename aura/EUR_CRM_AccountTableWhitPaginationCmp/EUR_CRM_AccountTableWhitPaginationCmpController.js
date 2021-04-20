({
    doInit: function (component, event, helper) {
        helper.doInit(component, event);
    },

    navigate: function (component, event, helper) {
        helper.navigate(component, event);
    },

    onClickAddToCart: function (component, event, helper) {
        helper.handleOnClickAddToCart(component);
    },

    resort: function (component, event, helper) {
        helper.handleResort(component, event);
    },

    handleKeyWordChange: function (component, event, helper) {
        helper.handleKeyWordChange(event);
    },
    addAll: function (component, event, helper) {
        helper.addAll(component, event);
    },
    select: function (component, event, helper) {
        helper.isSelectRow(component, event);
    }

});