({
    afterRender: function (component, helper) {
        this.superAfterRender();

        helper.setTableWidth();
    },
});