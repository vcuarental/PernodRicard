({
    setInputLabel: function(cmp) {
        var options = cmp.get('v.options');
        var selectedOptions = [];
        options.forEach(function(option) {
            if(option.selected) selectedOptions.push(option.label);
        });
        if(selectedOptions.length) {
            cmp.set('v.inputPlaceholder', selectedOptions.join(', '));
        } else {
            cmp.set('v.inputPlaceholder', 'Select an Option');
        }
    },

    selectOptionHandler: function(cmp, event, helper) {
        var options = cmp.get('v.options');
        // fix for FF
        var path = event.path || (event.composedPath && event.composedPath());
        var el = path.filter(function(el) {
            return el.className && typeof(el.className) == 'string' && el.className.indexOf('slds-listbox__option') > -1;
        })[0];
        var optionIndex = parseInt(el.getAttribute('id').split('-')[1]);
        options.forEach(function(option, index) {
            if(index == optionIndex) option.selected = !option.selected;
        });
        cmp.set('v.options', options);
        //cmp.find('optionsInput').getElement().focus();
        //cmp.set('v.isOpen', true);
        helper.setInputLabel(cmp);
        helper.sendSelectedValues(cmp);
    },

    sendSelectedValues: function(cmp) {
        var options = cmp.get('v.options');
        var index = cmp.get('v.index');
        var selectedOptions = [];
        var populateValuesEvent = cmp.getEvent("populateValuesEvent");
        options.forEach(function(option) {
            if(option.selected) selectedOptions.push(option.label);
        });
        populateValuesEvent.setParams({
            values: selectedOptions,
            index: index
        });
        populateValuesEvent.fire();
    }
})