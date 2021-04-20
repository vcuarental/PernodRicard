({
    doInit : function(cmp, event, helper) {
        helper.handleInitActions(cmp, helper);
    },

    handleControlButtonClick : function (cmp, event, helper) {
        const
            validity = cmp.get('v.validity'),
            who = event.getSource().get('v.name');

        if (!cmp.get('v.isPerformingSaveAction')) {
            cmp.set('v.isPerformingSaveAction', (who == 'save') || cmp.get('v.isPerformingSaveAction'));
            helper.handleControlAction(cmp, helper, who, validity);
        }
    },

    getProductQuery : function (cmp) {
        var
            previewRecords = cmp.get('v.productPreviewRecords') || [],
            savedRecords = (cmp.get('v.model.productGroup.Product_in_Groups__r') || []).map(item => item['ProductID__r']),
            result = ($A.util.isEmpty(previewRecords) ? savedRecords : previewRecords) || [];

        cmp.get('v.commercialConditions')
            .setProductRecords({
                'records' : result
            });
    },

    handleBrandChange : function (cmp, event, helper) {
        event.preventDefault();
        helper.showBrandChangeDialog(cmp, event, helper);
    },

    handleAfterScriptsLoaded : function (cmp) {
        cmp.set('v.isScriptsLoaded', true);
    },

    handleApplyTemplate : function (cmp, event, helper) {
        cmp.find('productGroupCompound').clearSearch();
        helper.applyTemplate(cmp, event, helper);
    },

    handleAnimationChange : function (cmp, event, helper) {
        helper.validateAnimation(cmp, event, helper);
    },

    handleRecordDataChange : function (cmp, event, helper) {
        helper.mapRecordData(cmp, event, helper);
    },

    applyCommercialConditionsTemplate : function (cmp, event, helper) {
        helper.applyCommercialConditionsTemplate(cmp, helper);
    },

    setCommercialConditionsValidity : function (cmp, event) {
        if (cmp.get('v.validity')) {
            cmp.set('v.validity.commercialConditions.hasErrors', !$A.util.isEmpty(event.getParam('errors')));
        }
    },

    setPlvConditionsValidity : function (cmp, event) {
        var errors = event.getParam('errors') || [];
        cmp.set('v.validity.freeConditionsTemplate.hasErrors', !$A.util.isEmpty(errors) && !(errors.length == 1 && errors[0] == 'hasLineItems'));
    },

    handleValidityChange : function (cmp, event, helper) {
        helper.processComponentsValidity(cmp, event, helper);
    },

    handleAddDeliveryDate : function (cmp, event, helper) {
        helper.addDeliveryDate(cmp, event, helper);
    },

    setDeliveryDateToday : function (cmp, event, helper) {
        helper.setDeliveryDateToday(cmp, helper);
    },

    handleRemoveDeliveryDate : function (cmp, event, helper) {
        helper.removeDeliveryDate(cmp, event, helper);
    },

    handleDeliveryDateOptionSelect : function (cmp, event, helper) {
        helper.selectDeliveryDateOption(cmp, event, helper);
    },

    handleChangeDealStartDate : function (cmp, event, helper) {
        helper.selectDealStartDate(cmp, event, helper);
    },

    handleInputChange : function (cmp, event, helper) {
        var
            src = event.getSource(),
            who = src.get('v.name');

        switch (who) {
            case 'AvailableForAll__c' :
                cmp.set('v.animation.AvailableForAll__c', src.get('v.value'));
                break;
            case 'result-template-name' :
                //@edit PZ - 08.04.18 - Fixes for summer 18 release
                //cmp.set('v.resultTemplateHasErrors', !src.get('v.validity.valid'));
                cmp.set('v.resultTemplateHasErrors', !src.get('v.validity').valid);
                break;
            default : break;
        }
    },

    handleSelectChange : function (cmp, event, helper) {
        const
            src = event.getSource(),
            who = src.get('v.name'),
            val = src.get('v.value');

        switch(who) {
            case 'select-result-template':
                helper.selectResultTemplate(cmp, helper, val);
                break;
            default: break;
        }
    },

    handleResultTemplateChange : function (cmp, event, helper) {
        var value = event.getParam('value') || {};
        if (Object.keys(value).length > 1 || !value.name) {
            helper.setPlvConditionsTemplate(cmp, helper);
        }
    },

    onPreviewRecordClose : function (cmp, event, helper) {
        const
            source = event.getSource(),
            who = source.getLocalId() || '',
            id = source.get('v.record.Id'),
            compound = cmp.find(who.replace('-details-view', 'GroupCompound'));
        console.log('source => ', source);
        console.log('who => ', who);
        console.log('id => ', id);


        compound.closePreviewItem(id);
        // helper.clearPresenceOfCustomLogic(cmp, helper, id);
    },

    clearPresenceOfCustomLogic : function (cmp, event, helper) {
        if (event.getSource().getLocalId() == 'productGroupCompound') {
            helper.clearPresenceOfCustomLogic(cmp, helper);
        }
    },

    addSelectedToPreview : function (cmp, event, helper) {
        var
            who = event.getParam('arguments').who || event.getSource().getLocalId(),
            prevArgName = 'v.' + who.replace('Group', 'PreviewRecords'),
            items = cmp.get(prevArgName) || [],
            idSet = new Set(items.map((item) => item.Id) || []),
            newItems = event.getParam('arguments').records || [];

        for (let i = 0; i < newItems.length; i++) {
            if (!idSet.has(newItems[i].Id)) {
                items.push(newItems[i]);
            }
        }
        cmp.set(prevArgName, items);
    },

    changeGroup : function (cmp, event, helper) {
        var
            params = event.getParam('arguments'),
            compound = cmp.find(params.who + 'Compound'),
            group = (cmp.get('v.' + params.who) || compound.get('v.selector')[0].get('v.value'));

        if (!$A.util.isEmpty(params) && params.who && params.group) {
            compound.set('v.groupName', params.group.Name);
            compound.set('v.groupId', params.group.Id);
            compound.set('v.isDynamic', params.group.EUR_CRM_IsDynamic__c);
        } else if (!$A.util.isEmpty(group) && $A.util.isEmpty(params.group) && params.who !== 'plvGroup') {
            compound.reset();
        }
    },

    revealPresetRecords : function (cmp, event, helper) {
        const who = event.getSource().get('v.name');

        switch(who) {
            case 'reveal-account-records' :
                helper.revealRelatedAccounts(cmp, cmp.get('v.model.accountGroup'));
                break;
            case 'reveal-product-records' :
                helper.revealRelatedProducts(cmp, cmp.get('v.model.productGroup'));
                break;
            case 'reveal-plv-records' :
                helper.revealRelatedPlv(cmp, cmp.get('v.model.pbEntryGrouping'));
                break;
        }
    },

    onResultTemplateRemove : function (cmp, event, helper) {
        helper.removeResultTemplate(cmp);
    },

    clearSpaces : function (cmp, event) {
        event.getSource().set('v.value', event.getSource().get('v.value').replace(/\s/g, ''));
    },

    trimLeft : function (cmp, event) {
        event.getSource().set('v.value', event.getSource().get('v.value').trimLeft());
    },

    navigateToSection : function (cmp, event) {
        var section = cmp.find(event.getSource().get('v.value') + 'Section');
        if (section) {
            setTimeout($A.getCallback(() => {
                scrollTo(0, section.getElement().offsetTop + 50);
            }), 100);
        }
    },

    onDetailsCardMove : function (cmp, event, helper) {
        helper.moveDetailsCard(cmp, event.getParam('who'), event.getParam('direction'), event.getParam('position'));
    },

    onConfirm: function (component, event, helper) {
        console.log('onConfirm()');
        const accTarGroup = helper.getAnimationViewModel(component, helper);
        console.log('accTarGroup => ', accTarGroup);
        if(typeof(accTarGroup) !== 'string') {
            accTarGroup.accountsInGroup = component.get('v.accountPreviewRecords');
            // accTarGroup.criteria = component.get('v.accountQueryCriteria');
            accTarGroup.accountGroup.criteria = component.find('accountGroupCompound').get('v.filterResult');
        }
        return component.get('v.parent').setAccountTargetGroupMethod(accTarGroup);
    },
});