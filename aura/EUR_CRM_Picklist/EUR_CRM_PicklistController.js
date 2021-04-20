({
    doInit: function(cmp, event, helper) {
        helper.setInputLabel(cmp);
    },

    resetLabel: function(cmp, event, helper) {
        helper.setInputLabel(cmp);
    },

    toggleOptions: function(cmp, event, helper) {
        var isOpen = cmp.get('v.isOpen');
        cmp.set('v.isOpen', true);
        setTimeout(function(){
            cmp.find('optionsList').getElement().focus();
        }, 1);
    },

    blurInput: function(cmp, event, helper) {
        cmp.find('optionsInput').getElement().blur();
    },

    leave: function(cmp, event, helper) {
        cmp.set('v.isOpen', false);
    },

    selectOption: function(cmp, event, helper) {
        helper.selectOptionHandler(cmp, event, helper);
    }
})