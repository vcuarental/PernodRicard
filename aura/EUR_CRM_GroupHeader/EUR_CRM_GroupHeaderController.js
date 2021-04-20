({
    handleButtonClick : function (cmp, event, helper) {
        var who = event.getSource().get('v.name');
        switch (who) {
            case 'showMore' :
                cmp.get('v.parent').showMore();
                break;
            default : break;
        }
    },

    onGroupSelect : function (cmp, event, helper) {
        var selection = cmp.get('v.groups').find(item => event.getSource().get('v.type') === item.Id);
        if (selection) {
            cmp.get('v.parent').setGroup(selection.Id);
            cmp.set('v.group', selection);
        }
    },

    onSearchScopeSelect : function (cmp, event) {
        cmp.set('v.searchField', cmp.get('v.searchFields').find(item => item.name === event.getParam('value')));
        cmp.find('search').set('v.value', '');
        cmp.get('v.parent').search('', cmp.get('v.searchField.name') || 'Name');
    },

    onSearch : function (cmp, event) {
        cmp.get('v.parent').search(event.getSource().get('v.value'), cmp.get('v.searchField.name') || 'Name');
    },

    addSelectedToPreview : function (cmp) {
        var el = cmp.find('add-selected-to-preview-btn').getElement();
        el.disabled = true;
        setTimeout($A.getCallback(() => {el.disabled = false}), 1500);
        setTimeout($A.getCallback(() => {
            cmp.get('v.parent').addSelectedToPreview();
        }), 25);
    },

    addAllToPreview : function (cmp, event) {
        cmp.set('v.disabled', true);
        setTimeout($A.getCallback(() => {cmp.set('v.disabled', false);}), 2500);
        cmp.get('v.parent').addAllToPreview();
    },

    playDynamicIcon : function (cmp) {
        var icon = cmp.find('dynamicIcon');
        icon.set('v.type', 'ellie');
        setTimeout($A.getCallback(() => {
            icon.set('v.type', 'trend');
        }), 1);
    },

    switchToFilters : function (cmp) {
        var group = cmp.get('v.parent');
        var compoundId = group.getLocalId() + 'Compound';
        var compound = group.get('v.parent').find(compoundId);
        compound.switchToFilters();
    }
})