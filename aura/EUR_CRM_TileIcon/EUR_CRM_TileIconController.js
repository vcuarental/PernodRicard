({
    handleSelectAction : function(cmp, event, helper) {
        if (cmp.get('v.isSelectable')) {
            cmp.set('v.isSelected', !cmp.get('v.isSelected'));
            let selectEvent = cmp.getEvent('select');
            selectEvent.setParams({
                'message' : cmp.get('v.isSelected') ? 'select' : 'deselect',
                'errors' : [],
                'data' : {
                    'id' : cmp.get('v.id'),
                    'name' : cmp.get('v.name'),
                    'isSelected' : cmp.get('v.isSelected'),
                    'orderIndex' : cmp.get('v.orderIndex')
                }
            });
            selectEvent.fire();
        }
    },

    toggleOptions : function (cmp, event, helper) {
        var  showOptions = cmp.get('v.showOptions');
        cmp.set('v.showOptions', !showOptions);
        cmp.getEvent('toggleOptions').setParams({
            'actions' : [showOptions ? 'hide' : 'show'],
            'data' : {
                'orderIndex' : cmp.get('v.orderIndex')
            }
        }).fire();
        event.stopPropagation();
    },

    onOptionInputChange : function (cmp, event, helper) {
        const fieldName = cmp.get('v.optionInputFieldName');
        var mapping = cmp.get('v.mapping') || {};
        const value = event.getSource().get('v.value') || cmp.get('v.optionInputMinValue');
        console.log('*** params:', event.getParams());
        if (fieldName) {
            mapping[cmp.get('v.id')] = { [fieldName] : value }
            cmp.set('v.mapping', mapping);
        }
    },

    stopPropagation : function (cmp, event, helper) {
        event.stopPropagation();
    }
});