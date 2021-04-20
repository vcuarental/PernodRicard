({
    handleInitActions : function (cmp) {
        this.presetFilterWarning(cmp);
        this.setDefaults(cmp);
    },

    presetFilters : function (cmp) {
        var builder = cmp.find('filterBuilder');
        try {
            var group = cmp.get('v.selector')[0].get('v.value').get('v.header').get('v.group');
            var filter = JSON.parse(group.EUR_CRM_Criteria__c);
            var items = filter ? filter.items || null : null;
            var logic = filter ? filter.filterLogic || null : null;
            var childItems = filter ? filter.childItems || null : null;
        } catch(e) {
            Error(e);
        }
        if (filter) {
            builder.setInitialItems(items, logic);
        }
        cmp.set('v.hasChildItemsFilter', !$A.util.isEmpty(childItems));
    },

    setDefaults : function (cmp) {
        cmp.set('v.relatedGroup', cmp.get('v.relatedGroup') || {});
        cmp.set('v.fileData', {
            'matched' : 0,
            'selected' : 0,
            'total' : 0
        });
    },

    searchInPreview : function (cmp, searchPhrase) {
        const isSearch = !!cmp.get('v.isSearch');
        cmp.set('v.isSearch', !!searchPhrase);
        if ((isSearch && !searchPhrase) || searchPhrase) {
            var items = cmp.get('v.previewRecords') || [];
            let searchFields = cmp.get('v.sObjectName') === 'Account'
                ? ['Name','AccountSAP100code__c']
                : ['Name', 'ProductSAPcode__c','EAN__c','ACL__c'];
            cmp.set(
                'v.previewSearchRecords', items.filter(item =>
                    searchFields.some(field =>
                        (item[field] || '').toLocaleLowerCase().includes(searchPhrase.toLocaleLowerCase())
                    )
                )
            );
            cmp.set('v.previewItems', []);
            this.setPreviewItems(cmp, cmp.get('v.previewSearchRecords'));
        }
    },

    processFiltersValidity : function (cmp, validity) {
        if (validity && validity.result && !validity.result.success) {
            cmp.get('v.parent').find('notificationsLib').showToast({
                'type' : 'warning',
                'title' : 'Please, review errors and correct your data',
                'message' : validity.result.message
            });
        } else if (validity.result.filter && validity.result.filter.testQuery) {
            this.processFiltersQuery(cmp, validity.result.filter.testQuery);
            cmp.set('v.filterResult', validity.result.filter);
        }
    },

    processFiltersQuery : function (cmp, query) {
        if (query && query.indexOf('WHERE ') > -1) {
            let whereConditions = query.substring(query.indexOf('WHERE ') + 'WHERE '.length);
            cmp.get('v.selector')[0].get('v.value').executeQuery(whereConditions);
            console.log('-- v.filterResult:', cmp.get('v.filterResult'));
            console.log('-- Criteria__c:', cmp.get('v.selector')[0].get('v.value').get('v.header').get('v.group.EUR_CRM_Criteria__c'));
            // cmp.get('v.parent')
            //     .find('messageService')
            //     .showToastOnEditReUsedGroup(cmp.get('v.selector')[0].get('v.value'), 'filters');
        } else {
            cmp.get('v.parent').find('notificationsLib').showToast({
                'type' : 'warning',
                'title' : 'Please, review errors and correct your data',
                'message' : 'No Filter is assigned!'
            });
        }
    },

    processCodes : function (cmp, helper) {
        var method;
        switch(cmp.getLocalId().replace('GroupCompound','')) {
            case 'account' : method = 'getAccountsByCodes'; break;
            case 'product' : method = 'getProductsByCodes'; break;
            case 'plv' : method = 'getPlvByCodes'; break;
            default: console.log('invalid method for import by codes'); return;
        }
        var codes = cmp.get('v.dirtyCodes').split('\n').map(code => code.trim());
        codes = codes.filter(code => code);
        if ($A.util.isEmpty(codes)) {
            cmp.set('v.codes', []);
            return;
        }
        var calloutService = cmp.get('v.parent').find('calloutService');
        var messageService = cmp.get('v.parent').find('notificationsLib');
        cmp.set('v.isReady', false);
        calloutService.runApex(method, {
            'codes' : codes,
            'brand' : cmp.get('v.parent').get('v.animation.Brand__c'),
            'country' : cmp.get('v.parent').get('v.animation.Country__c')
        }).then(result => {
            if (!$A.util.isEmpty(result)) {
                helper.testRecordsSelectedByCodes(cmp, helper, codes, result);
                cmp.set('v.codes', codes);
                cmp.set('v.sapCodeRecordsByIds', result);
            } else {
                cmp.find('notificationsLib').showToast({
                    'variant' : 'warning',
                    'title' : $A.get('$Label.c.EUR_CRM_NoRelatedObjects'),
                    'message' : $A.get('$Label.c.EUR_CRM_EmptyCSV')
                });
                cmp.set('v.codes', []);
            }
            cmp.set('v.isReady', true);
        }).catch(error => {
            console.error(error);
            cmp.set('v.isReady', true);
        });
    },

    testRecordsSelectedByCodes : function (cmp, helper, codes, recordsByIds) {
        const
            entity = cmp.getLocalId().replace('GroupCompound', '')
            , SAP_CODE_FIELD = entity === 'account' ? 'AccountSAP100code__c' : 'ProductSAPcode__c'
            , EAN_CODE_FIELD = entity === 'account' ? 'CIPCode__c' : 'EAN__c'
            , ACL_CODE_FIELD = entity === 'account' ? '' : 'ACL__c';
        var messageService = cmp.get('v.parent').find('notificationsLib');
        let wrongCodes = new Set(codes);
        let foundCodesByIds = new Map();
        let codeFieldName;
        let codeFields = [SAP_CODE_FIELD, EAN_CODE_FIELD, ACL_CODE_FIELD];
        for (let id in recordsByIds) {
            codeFieldName = getCodeFieldName(id);
            if (codeFieldName) {
                codeFields.forEach(field => {
                    if (recordsByIds[id][field]) {
                        wrongCodes.delete(recordsByIds[id][field]);
                    }
                });
                foundCodesByIds.set(id, recordsByIds[id][codeFieldName]);
            } else {
                delete recordsByIds[id];
            }
        }
        if (foundCodesByIds.size === 0) {
            messageService.showToast({
                'type' : 'warning',
                'title' : 'This activity has {0} status, objects related to it should not be edited',
                'message' : 'No records where found for provided SAP codes. Please check the correctness of the data.',
                'mode' : 'sticky'
            });
            cmp.set('v.codes', []);
        } else if (wrongCodes.size > 0) {
            messageService.showToast({
                'type' : 'warning',
                'title' : 'This activity has {0} status, objects related to it should not be edited',
                'message' : '{count} of entered SAP codes not found. Please, check the following codes:'.replace('{count}', wrongCodes.size).concat('"' + Array.from(wrongCodes).join('", "') + '"'),
                'mode' : 'sticky'
            });
            cmp.set('v.codes', codes.filter(code => wrongCodes.has(code)));
        }

        function getCodeFieldName(id) {
            return wrongCodes.has(recordsByIds[id][SAP_CODE_FIELD]) || (entity === 'account' && codes.some((code, index) => {
                let hasCodeSuffix = recordsByIds[id][SAP_CODE_FIELD]
                    && recordsByIds[id][SAP_CODE_FIELD].endsWith(code)
                    && /^[0]+$/.test(recordsByIds[id][SAP_CODE_FIELD].replace(code, ''));
                if (hasCodeSuffix) {
                    wrongCodes.delete(code);
                    codes[index] = recordsByIds[id][SAP_CODE_FIELD];
                }
                return hasCodeSuffix;
            }))
                ? SAP_CODE_FIELD
                : EAN_CODE_FIELD && wrongCodes.has(recordsByIds[id][EAN_CODE_FIELD])
                    ? EAN_CODE_FIELD
                    : ACL_CODE_FIELD && wrongCodes.has(recordsByIds[id][ACL_CODE_FIELD])
                        ? ACL_CODE_FIELD
                        : '';
        }
    },

    processRecordsSelectedByCodes : function (cmp) {
        const
            recordsByIds = cmp.get('v.sapCodeRecordsByIds'),
            records = Object.values(recordsByIds),
            sapCodeFieldName = cmp.getLocalId() === 'accountGroupCompound'
                ? 'AccountSAP100code__c'
                : 'ProductSAPcode__c',
            eanCodeFieldName = cmp.getLocalId() !== 'accountGroupCompound' ? 'EAN__c' : 'CIPCode__c',
            aclCodeFieldName = cmp.getLocalId() !== 'accountGroupCompound' ? 'ACL__c' : '';

        if (!$A.util.isEmpty(recordsByIds)) {
            let groupLocalId = cmp.get('v.selector')[0].get('v.value').getLocalId();
            let orderedCodes = cmp.get('v.codes');
            let orderedRecords = new Map();
            for (let i = 0; i < orderedCodes.length; i++) {
                let foundPos = records.findIndex(record => record[sapCodeFieldName] === orderedCodes[i]
                    || (eanCodeFieldName && record[eanCodeFieldName] === orderedCodes[i])
                    || (aclCodeFieldName && record[aclCodeFieldName] === orderedCodes[i]));
                if (foundPos > -1) {
                    orderedRecords.set(records[foundPos].Id, records[foundPos]);
                }
            }
            cmp.get('v.parent').addSelectedToPreview(Array.from(orderedRecords.values()), groupLocalId);
        }
    },

    resetComponent : function (cmp) {
        cmp.get('v.preview')[0].set('v.items', []);
        cmp.set('v.previewItems', []);
        cmp.set('v.previewRecords', []);
        cmp.set('v.relatedGroup', []);
        cmp.set('v.storageAction', 'assign');
        cmp.set('v.group', null);
        cmp.set('v.groupName', null);
        cmp.set('v.groupId', null);
        cmp.set('v.codes', []);
        cmp.set('v.sapCodeRecordsByIds', {});
        cmp.set('v.fileData', {});
        if (cmp.find('group-name')) cmp.find('group-name').set('v.value', '');
        this.clearSearch(cmp);
    },

    applyPlvTemplate : function (cmp) {
        var items = cmp.get('v.isSearch')
            ? cmp.get('v.previewSearchRecords')
            : cmp.get('v.previewRecords');
        var tmp = cmp.get('v.resultTemplates').find(item => item.id == cmp.get('v.resultTemplateId'));
        if (!$A.util.isEmpty(tmp) && !$A.util.isEmpty(items)) {
            let pbEntryGrouping = {
                'sobjectType' : 'PriceBookEntryGrouping__c',
                'Type__c' : tmp.calc_type,
                'IsMultipling__c' : typeof(tmp.multi) == 'boolean' ? tmp.multi : tmp.multi == 'true',
                'PLVTypes__c' : tmp.plv_type
            };
            let pbEntryGroupingItems = (tmp.levels || []).map((item) => {
                return {
                    'sobjectType' : 'PriceBookEntryGroupingItem__c',
                    'Minquantitytoorder__c' : parseInt(item.order_qty),
                    'Freequantity__c' : parseInt(item.free_qty)
                };
            });
            items.forEach(item => {
                let _pbeg = JSON.parse(JSON.stringify(pbEntryGrouping));
                let _items = JSON.parse(JSON.stringify(pbEntryGroupingItems));
                _pbeg['FreeID__c'] = item['Price_Book_Items__r'] && item['Price_Book_Items__r'].length === 1 ? item['Price_Book_Items__r'][0]['Id'] : null;
                item.pbEntryGrouping = _pbeg;
                item.pbEntryGroupingItems = _items;
            });
            this.setPreviewItems(cmp, items);
        }
    },

    showFilterWarning : function (cmp) {
        this.CalloutService = cmp.get('v.parent').find('calloutService');
        this.OverlayService = cmp.get('v.parent').find('overlayLib');
        var content = '&lt;p class=&quot;slds-text-title_caps&quot;&gt;Please note! &lt;p&gt;The group has already had some default filters. {0} All your customizations will be added to these defaults and could cause the interference effect.'
            .replace('{0}', cmp.get('v.L_GroupDefaultFilters'));
        this.CalloutService
            .createComponent('aura:unescapedHtml', {'value' : content})
            .then(result => {
                this.OverlayService.showCustomPopover({
                    'body' : result,
                    'referenceSelector' : '.' + cmp.get('v.popoverSelector'),
                    'cssClass' : 'filter-warning-popover,cAnimationGroupCompound'
                }).then(overlay => {
                    cmp.set('v.popoverOverlay', overlay);
                }).catch(overlayError => {
                    Error(overlayError);
                    cmp.set('v.popoverIsShown', false);
                })
            })
            .catch(error => {
                Error(error);
                cmp.set('v.popoverIsShown', false);
            });
    },

    presetFilterWarning : function (cmp) {
        switch (cmp.getLocalId()) {
            case 'accountGroupCompound' :
                setDefaultFiltersMessageContent(['Account record type is any except of "Account Brand"']);
                break;
            case 'productGroupCompound' :
                // 'Brand is the same as Animation Brand',
                setDefaultFiltersMessageContent(['Has single Price Book Item in standard Product Catalog', 'Related Price Book Item\'s record type is any except of "FREE"']);
                break;
            case 'plvGroupCompound' :
                // 'Brand is the same as Animation Brand',
                setDefaultFiltersMessageContent(['Has single Price Book Item in standard Product Catalog', 'Related Price Book Item\'s record type is "FREE"']);
                break;
        }

        function setDefaultFiltersMessageContent(defaultFilters) {
            var list = '';
            defaultFilters.forEach(item => {
                list += '<li>' + item + '</li>';
            })
            cmp.set('v.L_GroupDefaultFilters', '<div class="slds-box slds-box_x-small slds-m-vertical_small"><ul>'+ list +'</ul></div><div></div>');
        }
    },

    changeFiles : function(cmp, source) {
        var data = cmp.get('v.fileData');
        var files = source.get('v.files');
        if (!$A.util.isEmpty(files)) {
            data.file = files[0];
            cmp.set('v.fileData', data);
            let l = source.get('v.label');
            l = l.lastIndexOf(':') < 0 ? l : l.substring(0, l.lastIndexOf(':'));

            if (data && data.file) {
                source.set('v.label', (l  + ': ' + data.file.name));
            }
        }
        this.parseCsv(cmp, data.file);
    },

    parseCsv : function (cmp, file) {
        var reader = new FileReader();
        reader.onload = (e) => {
            let csvObj = $.csv.toObjects(reader.result);

            if (Array.isArray(csvObj)) {
                let data = cmp.get('v.fileData');

                data.csvRows = csvObj;
                cmp.set('v.fileData', data);
                this.setCsvRecordsCount(cmp, 0, 0, csvObj.length);
            }
        }

        reader.onerror = function (e) {
            console.error(e);
        }
        try {
            if (file) {
                reader.readAsText(file);
            }
        } catch (e) {
            console.error(e);
        }
    },

    setCsvRecordsCount : function (cmp, matched, selected, total) {
        var input = cmp.find('csv-input');
        if (input) {
            let fileData = cmp.get('v.fileData');
            fileData.matched = matched;
            fileData.selected = selected;
            fileData.total = total;
            cmp.set('v.fileData', fileData);
        }
    },

    processCsvRecordsSelection : function (cmp) {
        const SOURCE = cmp.getLocalId().replace('GroupCompound', '');
        const APEX_METHOD = SOURCE == 'account' ? 'getAccountsByIds' : SOURCE == 'product' ? 'getProductsByIds' : 'getPlvByIds';
        var calloutService = cmp.get('v.parent').find('calloutService');
        var messageService = cmp.get('v.parent').find('notificationsLib');
        var csvRecords = cmp.get('v.fileData.csvRows') || [];


        var idSet = new Set();
        for (let i = 0; i < csvRecords.length; i++) {
            let id  = csvRecords[i]['Id'] || csvRecords[i]['ID'] || csvRecords[i]['id'] || csvRecords[i]['Account (EU): ID'];
            if (id && (id.length === 15 || id.length === 18)) {
                idSet.add(id);
            }
        }

        if (idSet.size !== 0) {
            cmp.set('v.isReady', false);
            calloutService.runApex(APEX_METHOD, {
                'idSet' : Array.from(idSet)
            }).then($A.getCallback(result => {
                if (!$A.util.isEmpty(result)) {
                    cmp.get('v.parent').addSelectedToPreview(result, cmp.get('v.selector')[0].get('v.value').getLocalId());
                    this.setCsvRecordsCount(cmp, result.length, idSet.size, csvRecords.length);
                } else {
                    messageService.showToast({
                        'type' : 'warning',
                        'title' : $A.get('$Label.c.EUR_CRM_NoRelatedObjects'),
                        'message' : $A.get('$Label.c.EUR_CRM_EmptyCSV')
                    });

                }
                cmp.set('v.isReady', true);
            })).catch(error => {
                console.error(error);
                cmp.set('v.isReady', true)
            });
        }

    },

    changeGroupName : function (cmp, val) {
        var action = cmp.get('v.storageAction');
        switch (action) {
            case 'update' :
            case 'create' :
            case 'createDynamic' :
                cmp.set('v.groupName', val || cmp.get('v.groupName') || ''); break;
            case 'assign' : cmp.set('v.group.Name', val || cmp.get('v.group.Name') || ''); break;
        }
    },

    clearSearch : function (cmp) {
        cmp.find('search-in-preview').set('v.value', '');
        this.searchInPreview(cmp, '');
        cmp.set('v.isSearch', false);
    },

    clearPreview : function (cmp) {
        var previewStatusAttr;
        switch(cmp.getLocalId().replace('GroupCompound', '')) {
            case 'account' :
                previewStatusAttr = 'v.isAccountPreviewReady';
                break;
            case 'product' :
                previewStatusAttr = 'v.isProductPreviewReady';
                break;
            case 'plv' :
                previewStatusAttr = 'v.isPlvPreviewReady';
                break;
        }
        cmp.get('v.parent').set(previewStatusAttr, false);
        setTimeout($A.getCallback(() => {
            cmp.get('v.preview')[0].set('v.items', []);
            cmp.set('v.previewItems', []);
            cmp.set('v.previewRecords', []);
            cmp.get('v.parent').set(previewStatusAttr, true);
        }),1);
        // cmp.get('v.parent').clearPresenceOfCustomLogic();
        this.clearSearch(cmp);
    },

    setPreviewItems : function (cmp, records, isReading) {
        const
            scope = cmp.get('v.previewScope') || 5
            , itemsSize = cmp.get('v.previewItems.length') || 0
            , groupCmp = cmp.get('v.selector')[0].get('v.value');
        let previewItems = records.slice(0, records.length > scope && itemsSize < records.length
            ? (itemsSize && itemsSize >= scope ? itemsSize + 1 : scope)
            : records.length);
        cmp.set('v.previewItems', previewItems);
        cmp.get('v.preview')[0].set('v.items', previewItems);
        if (!isReading) {
            // cmp.get('v.parent').find('messageService').showToastOnEditReUsedGroup(groupCmp);
        }
    },
})