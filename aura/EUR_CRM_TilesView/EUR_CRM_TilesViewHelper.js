({

    innerData : {
        resultRecords: []
    },

    doInitHelper: function (cmp) {
        this.innerData.resultRecords = cmp.get('v.resultRecords');
    },

    toggleTileSelectionHandler: function (cmp, event) {
        var resultRecords = this.innerData.resultRecords;
        var records = cmp.get('v.records');
        var i = event.getParam('data').orderIndex;
        var isSelected = event.getParam('data').isSelected;
        resultRecords[i] = isSelected ? records[i] : {};
        this.innerData.resultRecords = resultRecords;
        //cmp.set('v.resultRecords', resultRecords);
    },

    setResultRecordsHandler: function (cmp, event) {
        cmp.set('v.resultRecords', this.innerData.resultRecords);
    },

    handleDisplayMore : function (cmp, helper) {
        if (cmp.get('v.records').length > cmp.find('iteration').get('v.end')) {
            cmp.set('v.isReady', false);
        }
    },

    toggleOptions : function (cmp, event, helper) {
        var actions = event.getParam('actions');
        if (!$A.util.isEmpty(actions) && actions[0] === 'show') {
            helper.createConditions(cmp, helper, event.getSource().get('v.orderIndex'));
        }
    },

    saveConditions : function (cmp, event, helper) {
        var index = cmp.get('v.selection').orderIndex;
        var conditionsCmp = cmp.get('v.details');
        var productId = cmp.get('v.records')[index]['ProductID__c'];
        conditionsCmp.saveAsTemplate();
        var tile = [].concat(cmp.find('tile'))[index];
        tile.set('v.options', cmp.get('v.details'));
        cmp.set('v.selection', null);

        var freeProdData = cmp.get('v.dataSource');
        freeProdData.conditions[productId] = {
            'pbEntryGrouping' : conditionsCmp.get('v.template'),
            'pbegItems' : conditionsCmp.get('v.lineItems')
        }
        cmp.set('v.dataSource', freeProdData);
        console.log(conditionsCmp);
        var evt = cmp.getEvent('onConditionsModalSave');
        evt.setParams({'who': conditionsCmp.getLocalId(), 'data':conditionsCmp});
        evt.fire();
        cmp.set('v.visible', false);
    },

    createConditions : function (cmp, helper, index) {
        var records = cmp.get('v.records');
        var record = records[index];
        var recordId = record.recordId || record.Id || record.id || record.ID;
        // var productId = record['ProductID__c'];
        record.orderIndex = index;
        var pbeg;
        var pbegItems;
        var freeProdData = cmp.get('v.dataSource');
        if (freeProdData.conditions && freeProdData.conditions[recordId]) {
            pbeg = freeProdData.conditions[recordId].pbEntryGrouping;
            pbegItems = freeProdData.conditions[recordId].pbegItems;
        } else {
            pbeg = cmp.get('v.getPriceBookEntryGrouping')(cmp.get('v.pbEntryGrouping'), recordId) || cmp.get('v.tileDetails').template;
            pbegItems = pbeg && !$A.util.isEmpty(pbeg.Price_Book_Entry_Grouping_Items__r) ? pbeg.Price_Book_Entry_Grouping_Items__r : cmp.get('v.tileDetails').lineItems;
        }
        var modal = cmp.find('modal-conditions');
        modal.set('v.modalHeader', 'Promotion result for' + ' <strong>' + (record.Name || record.name || record.NAME || '""') + '</strong>');
        $A.createComponent(
            'c:FreeItemsConditionsConstructor',
            {
                'aura:id' : 'conditions-for-' + recordId,
                'template' : pbeg,
                'lineItems' : pbegItems,
                'canChangeCalcType' : true,
                'validity' : modal.getReference('v.validity')
            },
            function (newCmp, status, errorMessage) {
                if (status === 'SUCCESS') {
                    cmp.set('v.selection', record);
                    cmp.set('v.details', newCmp);
                    modal.set('v.visible', true);
                } else if (status === 'INCOMPLETE') {
                    console.log("No response from server or client is offline.");
                } else if (status === 'ERROR') {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    }
});