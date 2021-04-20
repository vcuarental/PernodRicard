/**
 * Created by V. Kamenskyi on 12.09.2017.
 */
({
    init : function (cmp, event, helper) {
        helper.init(cmp, helper);
    },

    handleReorder : function (cmp, event, helper) {
        helper.reorder(cmp, helper, event.getSource().get('v.name'));
    },

    handleMove : function (cmp, event, helper) {
        helper.move(cmp, helper, event.getSource().get('v.name'));
    }
})