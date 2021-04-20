/**
 * Created by V. Kamenskyi on 18.09.2017.
 */
({
    handleClick : function (cmp, event, helper) {
        event.stopPropagation();
        helper.handleSelection(cmp, event, helper);
    }
})