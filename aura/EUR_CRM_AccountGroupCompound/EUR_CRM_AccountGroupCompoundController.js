({
    onInit : function (cmp, event, helper) {
        helper.handleInitActions(cmp);
    },

    presetFilters : function (cmp, event, helper) {
        helper.presetFilters(cmp);
    },

    onExternalSourceSelect : function (cmp, event, helper) {
        var who = event.getParam('name');
        switch (who) {
            case 'clipboard' :
                cmp.set('v.importMenuIndex', 0);
                break;
            case 'file' :
                cmp.set('v.importMenuIndex', 1);
                break;
        }
    },

    searchInPreview : function (cmp, event, helper) {
        helper.searchInPreview(cmp, event.getSource().get('v.value'));
    },

    onStorageActionMenuSelect : function (cmp, event, helper) {
        const
            val = event.getParam('value')
            , groupCmp = cmp.get('v.selector')[0].get('v.value')
            , messageService = cmp.get('v.parent').find('messageService');

        cmp.set('v.storageAction', val);
        switch(val) {
            case 'create' :
                cmp.set('v.menuIconName', 'utility:new');
                cmp.set('v.groupName', '');
                cmp.find('group-name').set('v.value', '');
                break;
            case 'createDynamic' :
                cmp.set('v.menuIconName', 'utility:filterList');
                cmp.set('v.groupName', '');
                cmp.set('v.hasChildItemsFilter', false);
                cmp.set('v.previewItems', []);
                cmp.set('v.previewRecords', []);
                cmp.find('group-name').set('v.value', '');
                cmp.switchToFilters();
                break;
            case 'update' :
                cmp.set('v.menuIconName', 'utility:edit');
                // let relatedGroup = cmp.get('v.parent').get('v.model')[cmp.getLocalId().replace('Compound','') == 'accountGroup'
                //     ? 'accountGroup'
                //     : 'productGroup'] || {'Name' : ''};
                // cmp.set('v.relatedGroup', relatedGroup.Name);
                // cmp.find('group-name').set('v.value', relatedGroup.Name);
                // messageService.showToastOnEditReUsedGroup(groupCmp, 'filters');
                cmp.find('group-name').set('v.value', cmp.get('v.relatedGroup.Name'));
                break;
            case 'assign' :
                cmp.set('v.menuIconName', 'utility:refresh');
                let selectorName = cmp.get('v.selector')[0].get('v.value').get('v.header').get('v.group.Name');
                cmp.set('v.groupName', selectorName);
                cmp.find('group-name').set('v.value', selectorName);
                // messageService.showToastOnEditReUsedGroup(groupCmp, 'filters');
                break;
            default :
                cmp.set('v.menuIconName', 'utility:database');
                cmp.set('v.groupName', '');
                break;
        }

    },

    handleFilterValidationResult : function (cmp, event, helper) {
        cmp.set('v.isReady', true);
        helper.processFiltersValidity(cmp, event.getParams());
    },

    validateFilters : function (cmp, event, helper) {
        cmp.set('v.isReady', false);
        cmp.find('filterBuilder').validate();
    },

    switchToFilters : function (cmp, event, helper) {
        if (cmp.find('filtersTab')) {
            cmp.find('tabset').set('v.selectedTabId', 'builder');
        } else {
            window.open('/' + cmp.get('v.relatedGroup.Id'), '_blank');
        }
    },

    checkCodes : function (cmp, event, helper) {
        helper.processCodes(cmp, helper);
    },

    onCodeRecordsSubmit : function (cmp, event, helper) {
        helper.processRecordsSelectedByCodes(cmp);
    },

    onCsvRecordsSubmit : function (cmp, event, helper) {
        helper.processCsvRecordsSelection(cmp);
    },

    handleFilesChange : function(cmp, event, helper) {
        helper.changeFiles(cmp, event.getSource());
    },

    clearPreview : function (cmp, event, helper) {
        helper.clearPreview(cmp);
    },

    reset : function (cmp, event, helper) {
        helper.resetComponent(cmp);
    },

    applyPlvTemplate : function (cmp, event, helper) {
        helper.applyPlvTemplate(cmp);
    },

    showFilterWarning : function (cmp, event, helper) {
        if (!cmp.get('v.popoverIsShown')) {
            cmp.set('v.popoverIsShown', true);
            helper.showFilterWarning(cmp);
        }
    },

    hideFilterWarning : function (cmp, event, helper) {
        if (cmp.get('v.popoverIsShown') && cmp.get('v.popoverOverlay')) {
            setTimeout($A.getCallback(() => {
                helper.OverlayService.notifyClose()
                    .then(result => {
                        cmp.get('v.popoverOverlay')[0].close();
                    }).catch(error => {
                    console.log('... close popup error ...', error);
                }).finally(() => {
                    cmp.set('v.popoverOverlay', null);
                    cmp.set('v.popoverIsShown', false);
                });
            }), 600);
        }
    },
    handleTabSelect : function (cmp, event, helper) {
        if (cmp.get('v.disabled')) {
            event.getSource().set('v.selectedTabId', 'selector');
        }
        if (cmp.get('v.storageAction') == 'createDynamic') {
            event.getSource().set('v.selectedTabId', 'builder');
        }
    },

    handleGroupNameChange : function (cmp, event, helper) {
        var inp = cmp.find('group-name');
        if(inp && ($A.util.isEmpty(event.getSource().get('v.value')) || $A.util.isEmpty(event.getSource().get('v.value').trim()))){
            // trim whitespace for validation
            inp.set('v.value','');
            inp.showHelpMessageIfInvalid();
        }
        helper.changeGroupName(cmp, event.getSource().get('v.value'));
    },

    onRelatedGroupChange : function (cmp, event, helper) {
        var val = cmp.get('v.relatedGroup.Name');
        if (val) {
            cmp.find('group-name').set('v.value', val);
            cmp.set('v.storageAction', 'update');
            cmp.find('preview-storage-actions-menu').set('v.iconName', 'utility:edit');
        } else if (!val) {
            cmp.set('v.storageAction', 'assign');
            cmp.set('v.menuIconName', 'utility:refresh');
            if (cmp.find('group-name')) cmp.find('group-name').set('v.value', cmp.get('v.groupName'));
        }
    },

    onGroupSelect : function (cmp, event, helper) {
        var groupName = cmp.get('v.groupName');
        if (groupName && cmp.get('v.storageAction') === 'assign') {
            cmp.find('group-name').set('v.value', groupName);
        }
    },

    onPreviewRecordsChange : function (cmp, event, helper) {
        if (!$A.util.isEmpty(event.getParam('value'))) {
            helper.clearSearch(cmp);
            helper.setPreviewItems(cmp, cmp.get('v.previewRecords') || []);
        }
    },

    EUR_CRM_RemoveRelatedPlv : function (cmp, event, helper) {
        cmp.get('v.parent').set('v.model.pbEntryGrouping', []);
        cmp.set('v.previewRecords', []);
    },

    onPreviewScroll : function (cmp, event, helper) {
        const
            isSearch = cmp.get('v.isSearch'),
            recordsSize = (isSearch
                ? cmp.get('v.previewSearchRecords.length')
                : cmp.get('v.previewRecords.length')) || 0,
            itemsSize = cmp.get('v.previewItems.length') || 0,
            IS_READING = true;

        if (recordsSize && recordsSize > itemsSize) {
            cmp.set('v._previewScrollTop', event.target.scrollHeight);
            helper.setPreviewItems(cmp, isSearch ? cmp.get('v.previewSearchRecords') : cmp.get('v.previewRecords'), IS_READING);
        }
    },

    closePreviewItem : function (cmp, event, helper) {
        const
            newItems = cmp.get('v.previewItems').filter(item => item.Id !== event.getParam('arguments').id) || []
            , newRecords = cmp.get('v.previewRecords').filter(item => item.Id !== event.getParam('arguments').id) || [];
        if ($A.util.isEmpty(newRecords)) {
            helper.clearPreview(cmp);
        } else {
            cmp.set('v.previewItems', newItems);
            cmp.set('v.previewRecords', newRecords);
        }

    },

    clearSearch : function (cmp, event, helper) {
        helper.clearSearch(cmp);
    },

    onCodesTextareaChange : function (cmp, event, helper) {
        cmp.set('v.codes', []);
    }
})