({
    handleInitActions : function(cmp, helper) {
        this.CalloutService = cmp.find('calloutService');
        this.Notifications = cmp.find('notificationsLib');
        this.MessageService = cmp.find('messageService');
        helper.dispatchAction(cmp);
        cmp.set('v.isReady', false);
        // helper.setDefaults(cmp);
        // helper.obtainLabels(cmp, helper);
        helper.getModel(cmp, helper);
        // helper.obtainResultTemplates(cmp, helper);
        // cmp.set('v.prodListViewExtraFields', ['EAN__c']);
    },

    obtainLabels : function (cmp) {
        this.CalloutService.runApex('getLabelsForEntities',
            {
                'entities' : [
                    'Animation__c'
                    , 'CommercialConditions__c'
                    , 'Commercial__c'
                    , 'PriceBookEntryGrouping__c'
                    , 'PriceBookEntryGroupingItem__c'
                ]
            }).then(result => {
            cmp.set('v.labels', result);
        }).catch(error => console.error(error));
    },

    dispatchAction : function (cmp) {
        if (cmp.get('v.sObjectName') && cmp.get('v.recordId')) {
            cmp.set('v.isUpdate', true);
        } else if (cmp.get('v.sObjectName')) {
            cmp.set('v.isCreate', true);
        }
    },

    getModel : function(cmp, helper) {
        this.CalloutService.runApex('getModel', {
            'promoId' : cmp.get('v.recordId')
        }).then($A.getCallback(result => {
            cmp.set('v.isReady', true);
            helper._model = result;
            helper.processModel(cmp);
        })).catch($A.getCallback(error => {
            console.error(error)
        }));
        // var hasCloneSourceId = window.location.hash.match(/(?:&cs=)[\w]{18}/);
        // var recordId = !$A.util.isEmpty(hasCloneSourceId) && hasCloneSourceId[0] && hasCloneSourceId[0].substring(4).length == 18
        //     ? hasCloneSourceId[0].substring(4) : cmp.get('v.recordId') || null;
        // this.CalloutService
        //     .runApex('getModel', { 'animationId' : recordId })
        //     .then($A.getCallback(result => {
        //         if (!cmp.get('v.recordId') && recordId && result.animation) {
        //             let a = result.animation;
        //             a['sobjectType'] = 'Animation__c';
        //             a['Id'] = null;
        //             a['Status__c'] = 'Draft';
        //             a['Code__c'] = '';
        //             cmp.set('v.animation', a);
        //             helper.changeBrand(cmp, null, helper);
        //             helper.presetCloneSharing(cmp, helper, recordId);
        //         }
        //         helper.presetDeliveryDates(cmp, helper);
        //         cmp.set('v.isReady', true);
        //         helper.processModel(cmp, helper, result);
        //     }))
        //     .catch($A.getCallback(error => {
        //         console.error(error)
        //     }));
    },

    presetDeliveryDates : function (cmp, helper) {
        var a = cmp.get('v.animation');
        var minFixOptions = a.MinFixed__c ? a.MinFixed__c.split(';') : [];
        cmp.set('v.hasToday', (a && a.DeliveryDates__c && a.DeliveryDates__c.includes('TODAY')));
        var deliveryDates = a.DeliveryDates__c
            ? (a.DeliveryDates__c.split(';') || []).map(function(date, inx) {
                return {
                    'val' : date,
                    'label' : helper.formatDate(date),
                    'option' : helper.mapMinFixOption(minFixOptions[inx])
                }
            })
            : [{'val':'TODAY','label':'TODAY','option':''}];
        cmp.set('v.deliveryDates', deliveryDates);
    },

    processModel : function(cmp) {
        if (!$A.util.isEmpty(this._model)) {
            cmp.set('v.promo', this._model.promo);
            this.presetAccountGroupRecords(cmp);
            this.initRelatedGroups(cmp, this._model);
        }
    },
    // processModel : function(cmp, helper, model) {
    //     if (!$A.util.isEmpty(model)) {
    //         cmp.set('v.model', model);
    //         cmp.set('v.animation', model.animation.Id ? model.animation : helper.getDefaultAnimation());
    //         cmp.set('v.simpleRecord', this.clone(model.animation));
    //         cmp.set('v.brandLabel', model.brands[model.animation.Brand__c]);
    //         cmp.set('v.countryLabel', model.countries[model.animation.Country__c]);
    //         window.setTimeout($A.getCallback(() => helper.presetCommercialConditions(cmp, helper, model)), 1);
    //         helper.presetDiscountConditions(cmp);
    //         helper.presetAccountGroupRecords(cmp, helper, model);
    //         helper.presetProductGroupRecords(cmp, helper, model);
    //         helper.presetFreeProductGrouping(cmp, helper, model);
    //         helper.initRelatedGroups(cmp, model);
    //     }
    // },

    initRelatedGroups : function (cmp, model) {
        if (model.accountGroup && model.accountGroup.Id) {
            // model.accountGroup._size = model.accountGroup['Account_in_Target_Groups__r'].length || 0;
            model.accountGroup._size = model.accountsInTargetGroup.length || 0;
            cmp.find('accountGroupCompound').set('v.relatedGroup', model.accountGroup);
            // this.revealRelatedAccounts(cmp, model.accountGroup);
            console.log('model.accountsInTargetGroup.size => ', model.accountsInTargetGroup.length);
            console.log('model.accountsInTargetGroup => ', model.accountsInTargetGroup);
            this.revealRelatedAccounts(cmp, model.accountsInTargetGroup);
        }
        // if (model.productGroup && model.productGroup.Id) {
        //     model.productGroup._size = model.productGroup['Product_in_Groups__r'].length || 0;
        //     cmp.find('productGroupCompound').set('v.relatedGroup', model.productGroup);
        //     this.revealRelatedProducts(cmp, model.productGroup);
        // }
        // if (!$A.util.isEmpty(model.pbEntryGrouping)) {
        //     this.revealRelatedPlv(cmp, model.pbEntryGrouping);
        // }
    },

    createGroupComponent : function (cmp, params) {
        // let disabled = cmp.get('v.layoutType') == 'view'
        //     || cmp.get('v.animation.Status__c') == 'Closed'
        //     || cmp.get('v.animation.Status__c') == 'Canceled'
        //     || !cmp.get('v.animation.Brand__c');

        this.CalloutService.getComponentsBuilder()
            .append('c:EUR_CRM_GenericGroup', {
                'aura:id' : params.localId,
                'localId' : params.localId,
                'groupApiName' : params.groupApiName,
                'recordApiName' : params.recordApiName,
                'animationLookupApiName' : params.animationLookupApiName,
                'recordLookupApiName' : params.recordLookupApiName,
                'recordInGroupApiName' : params.recordInGroupApiName,
                // 'groupInAnimationApiName' : params.groupInAnimationApiName,
                'criteria' : params.criteria,
                'mapping' : params.mapping || {},
                'sortExclusion' : params.sortExclusion || [],
                'storageAction' : params.storageAction,
                // 'disabled' : disabled,
                'parent': cmp.getReference('this')
            })
            .append('c:EUR_CRM_GroupHeader', {
                'L_EntityName' : params.L_EntityName,
                'L_EntityPluralName' : params.L_EntityPluralName,
                'entityIcon' : params.entityIcon,
                'group' : params.group || {},
                'searchFields' : params.searchFields,
                'searchField' : {'name':'Name','label':'Name'},
                // 'disabled' : disabled
            })
            .build()
            .then(result => {
                result[0].set('v.header', result[1]);
                result[0].set('v.limit', 2000);
                result[1].set('v.parent', result[0].getReference('this'));
                result[0].find('dataTable').set('v.columns', params.columns);
                cmp.set(params.groupAttribute, result[0]);
                return result[0];
            })
            .catch(error => {
                console.error(error);
            });
    },

    presetAccountGroupRecords : function (cmp) {
        this.createGroupComponent(cmp, {
            'localId' : 'accountGroup',
            'group' : this._model.accountGroup,
            'groupApiName' : 'EUR_CRM_Account_Target_Group__c',
            'recordApiName' : 'EUR_CRM_Account__c',
            'animationLookupApiName' : 'EUR_CRM_Objectives_Promotions__c',
            'recordLookupApiName' : 'EUR_CRM_Account__c',
            'recordInGroupApiName' : 'EUR_CRM_Account_in_Target_Group__c',
            // 'groupInAnimationApiName' : 'EUR_CRM_Objectives_Promo_Account_mapping__c',
            'criteria' : cmp.get('v.accountQueryCriteria') || [],
            'L_EntityName' : 'Customer',
            'L_EntityPluralName' : 'Customers',
            'entityIcon' : 'standard:account',
            'groupAttribute' : 'v.accountGroup',
            'searchFields' : [
                {'name':'Name','label':'Name'},
                // {'name':'AccountSAP100code__c','label':'SAP code'},
            ],
            'columns' : [
                {
                    'label' : 'Name',
                    'fieldName' : 'Name',
                    'type' : 'text',
                    'sortable' : true,
                    'initialWidth' : 300
                },
                {
                    'label' : 'Account Code',
                    'fieldName' : 'EUR_CRM_Account_Code__c',
                    'type' : 'text',
                    'sortable' : true,
                    'initialWidth' : 300
                },
                {
                    'label' : 'Channel',
                    'fieldName' : 'EUR_CRM_Channel__c',
                    'type' : 'text',
                    'sortable' : true,
                    'initialWidth' : 300
                },
                {
                    'label' : 'Street',
                    'fieldName' : 'EUR_CRM_Street__c',
                    'type' : 'text',
                    'sortable' : true,
                    'initialWidth' : 300
                },
                {
                    'label' : 'City',
                    'fieldName' : 'EUR_CRM_City__c',
                    'type' : 'text',
                    'sortable' : true,
                    'initialWidth' : 300
                },
                {
                    'label' : 'Address',
                    'fieldName' : 'EUR_CRM_Address__c',
                    'type' : 'text',
                    'sortable' : true,
                    'initialWidth' : 300
                },
                {
                    'label' : 'Owner',
                    'fieldName' : 'OwnerName',
                    'type' : 'text',
                    'sortable' : true,
                    'initialWidth' : 300
                }
            ]
        });
    },

    presetProductGroupRecords : function (cmp, helper, model) {
        helper.createGroupComponent(cmp, {
            'localId' : 'productGroup',
            'group' : model.productGroup,
            'groupApiName' : 'ProductGroup__c',
            'recordApiName' : 'CTCPG__Product__c',
            'animationLookupApiName' : 'AnimationID__c',
            'recordLookupApiName' : 'ProductID__c',
            'recordInGroupApiName' : 'ProductInGroup__c',
            'groupInAnimationApiName' : 'ProductsinAnimation__c',
            'criteria' : cmp.get('v.productQueryCriteria'),
            'L_EntityName' : 'Product',
            'L_EntityPluralName' : 'Products',
            'entityIcon' : 'standard:product',
            'groupAttribute' : 'v.productGroup',
            'mapping' : model.productsMapping,
            'sortExclusion' : ['ExcludeFromDiscounts'],
            'searchFields' : [
                {'name':'Name','label':'Name'},
                {'name':'EAN__c','label':'EAN code'},
                {'name':'ProductSAPcode__c','label':'SAP code'},
                {'name':'ACL__c','label':'National code'},
            ],
            'columns' : [

                {
                    'label' : 'Exclude From Discounts',
                    'fieldName' : 'ExcludeFromDiscounts',
                    'type' : 'text',
                    'sortable' : false,
                },
                {
                    'label' : 'Name',
                    'fieldName' : 'Name',
                    'type' : 'text',
                    'sortable' : true,
                },
                {
                    'label' : 'Brand',
                    'fieldName' : 'Brandgl__c',
                    'type' : 'text',
                    'sortable' : true,
                },
                {
                    'label' : 'EAN code',
                    'fieldName' : 'EAN__c',
                    'type' : 'text',
                    'sortable' : true,
                },
                {
                    'label' : 'SAP code',
                    'fieldName' : 'ProductSAPcode__c',
                    'type' : 'text',
                    'sortable' : true,
                },
                {
                    'label' : 'National code',
                    'fieldName' : 'ACL__c',
                    'type' : 'text',
                    'sortable' : true,
                }
            ]
        });
    },

    presetFreeProductGrouping : function (cmp, helper, model) {
        helper.createGroupComponent(cmp, {
            'localId' : 'plvGroup',
            'group' : model.freeProductGroup,
            'groupApiName' : 'ProductGroup__c',
            'recordApiName' : 'CTCPG__Product__c',
            'animationLookupApiName' : 'AnimationID__c',
            'recordLookupApiName' : 'ProductID__c',
            'recordInGroupApiName' : 'ProductInGroup__c',
            'groupInAnimationApiName' : 'ProductsinAnimation__c',
            'criteria' : cmp.get('v.freeItemsCriteria'),
            'L_EntityName' : 'Product',
            'L_EntityPluralName' : 'Products',
            'entityIcon' : 'standard:thanks',
            'groupAttribute' : 'v.plvGroup',
            'searchFields' : [
                {'name':'Name','label':'Name'},
                {'name':'EAN__c','label':'EAN code'},
                {'name':'ProductSAPcode__c','label':'SAP code'},
                {'name':'ACL__c','label':'National code'},
            ],
            'columns' : [
                {
                    'label' : 'Name',
                    'fieldName' : 'Name',
                    'type' : 'text',
                    'sortable' : true
                },
                {
                    'label' : 'Brand',
                    'fieldName' : 'Brandgl__c',
                    'type' : 'text',
                    'sortable' : true,
                },
                {
                    'label' : 'EAN code',
                    'fieldName' : 'EAN__c',
                    'type' : 'text',
                    'sortable' : true,
                },
                {
                    'label' : 'SAP code',
                    'fieldName' : 'ProductSAPcode__c',
                    'type' : 'text',
                    'sortable' : true,
                },
                {
                    'label' : 'National code',
                    'fieldName' : 'ACL__c',
                    'type' : 'text',
                    'sortable' : true,
                }
            ]
        });
    },

    presetCommercialConditions : function (cmp, helper, model) {
        var cc = model.commercialConditions || {};
        cc.sobjectType = 'CommercialConditions__c';
        let ccLineItems = cc['Commercial_Condition_Line_Items__r'] || [];
        ccLineItems = ccLineItems.map(val => {
            val.sobjectType = 'Commercial__c';
            return val;
        });
        cmp.set('v.isCalcTypeSet', cc.CalculationType__c);
        this.CalloutService.createComponent('c:AnimationConditionsConstructor', {
            'aura:id' : 'comCondTemplate',
            'parent' : cmp.getReference('this'),
            'getProductQuery' : cmp.getReference('c.getProductQuery'),
            'validFrom' : cmp.get('v.animation.ValidFrom__c'),
            'initialDate' : cmp.get('v.initialDate'),
            'labels' : cmp.get('v.labels'),
            'onsuccess' : cmp.getReference('c.applyCommercialConditionsTemplate'),
            'onerror' : cmp.getReference('c.setCommercialConditionsValidity'),
            'disabled' : cmp.get('v.validity.commercialConditions.disabled') || cmp.get('v.layoutType') == 'view' || model.animation.Status__c == 'Canceled' || model.animation.Status__c == 'Closed',
            'template' : cc,
            'lineItems' : ccLineItems,
            'paymentTerms' : model.paymentTerms,
            'hasLineItems' : cmp.getReference('v.comCondHasLineItems'),
            'hasBeenChanged' : cmp.getReference('v.ccHasBeenChanged'),
            'isCalcTypeSet' : cmp.getReference('v.isCalcTypeSet')
        }).then($A.getCallback(result => {
            result.wrapLineItems();
            cmp.set('v.commercialConditions', result);
            helper.presetAdditionalConditions(cmp, helper);
            cmp.set('v.isCommercialConditionsLoaded', true);
            cmp.set('v._ccRuntimeHistory', {
                'template' : result.get('v.template'),
                'lineItems' : result.get('v.lineItems')
            });
        })).catch($A.getCallback(error => {
            console.error(error);
            cmp.set('v.isCommercialConditionsLoaded', true);
        }));
    },

    presetDiscountConditions : function (cmp) {
        cmp.find('calloutService').createComponent('c:FreeItemsConditionsConstructor', {
            'aura:id' : 'freeCondTemplate',
            'parent' : cmp.getReference('this'),
            'template' : cmp.get('v.freeProdCondTemplate'),
            'lineItems' : cmp.get('v.freeLineItems'),
            'isCalcTypeSet' : cmp.get('v.isFreeCalcTypeSet'),
            'hasBeenChanged' : cmp.get('v.resultTemplateHasBeenChanged'),
            'onerror' : cmp.getReference('c.setPlvConditionsValidity'),
            'disabled' : cmp.get('v.layoutType') == 'view' || cmp.get('v.validity.freeConditionsTemplate.disabled')
        }).then($A.getCallback(result => {
            cmp.set('v.discountConditions', result);
        })).catch($A.getCallback(error => {
            console.error(error);
        }));
    },

    presetCloneSharing : function (cmp, helper, parentId) {
        this.CalloutService.runApex('getCloneSharing', {
            'parentId':parentId
        }).then(result => {
            if (!$A.util.isEmpty(result)) {
                for (let i = 0; i < result.length; i++) {
                    result[i].Id = null;
                    result[i].ParentId = null;
                }
                cmp.find('sharing').setRecords(result);
            }
        }).catch(error => Error(error));
    },

    presetAdditionalConditions : function (cmp, helper) {
        var ccCmp = cmp.get('v.commercialConditions');
        var addCond = helper.parseAdditionalConditions(cmp, cmp.get('v.animation').AdditionalConditions__c);
        if (!$A.util.isEmpty(ccCmp)) {
            ccCmp.wrapLineItems();
            ccCmp.set('v.presenceOf', addCond.presenceOf);
            ccCmp.set('v.numberOfDistRef', addCond.numberOfDistRef);
            ccCmp.set('v.customLogic', addCond.customLogic);
        }
    },

    revealRelatedAccounts : function (cmp, accountsInTargetGroup) {
        if (accountsInTargetGroup && !$A.util.isEmpty(accountsInTargetGroup)) {
            let accounts = accountsInTargetGroup.map(item => {
                return item.EUR_CRM_Account__r;
            });
            cmp.set('v.accountPreviewRecords', accounts);
        }
    },

    // revealRelatedAccounts : function (cmp, group) {
    //     if (group && !$A.util.isEmpty(group.Account_in_Target_Groups__r)) {
    //         let accounts = group.Account_in_Target_Groups__r.map(item => {
    //             return item.EUR_CRM_Account__r;
    //         })
    //         cmp.set('v.accountPreviewRecords', accounts);
    //     }
    // },

    revealRelatedProducts : function (cmp, group) {
        if (group && !$A.util.isEmpty(group.Product_in_Groups__r)) {
            let products = group.Product_in_Groups__r.map(item => {
                return item.ProductID__r;
            })
            cmp.set('v.productPreviewRecords', products);
        }
    },

    revealRelatedPlv : function (cmp, pbEntryGrouping) {
        if (!$A.util.isEmpty(pbEntryGrouping)) {
            let conditions = pbEntryGrouping.map(item => {
                return {
                    'Id' : item['FreeID__r']['ProductID__c'],
                    'Name' : item['FreeID__r']['ProductID__r']['Name'],
                    'ProductSAPcode__c' : item['FreeID__r']['ProductID__r']['ProductSAPcode__c'],
                    'Price_Book_Items__r' : [].concat(item['FreeID__r']),
                    'pbEntryGrouping' : item,
                    'pbEntryGroupingItems' : item['Price_Book_Entry_Grouping_Items__r']
                }
            })
            cmp.set('v.plvPreviewRecords', conditions || []);
        }
    },

    parseAdditionalConditions : function (cmp, val) {
        var result = { 'presenceOf': [], 'numberOfDistRef': 0, 'customLogic': '' };
        if (!$A.util.isEmpty(val)) {
            let customLogic = this.reduceToCustomLogicExp(val);
            result.customLogic = customLogic.logic;
            let eanCodes = [];
            for (let key in customLogic.mapping) {
                if (key === 'N') {
                    result.numberOfDistRef = customLogic.mapping[key];
                } else {
                    eanCodes.push(customLogic.mapping[key]);
                    result.presenceOf.push(customLogic.mapping[key]);
                }
            }
            if (!$A.util.isEmpty(eanCodes)) {
                this.getProductsByEAN(cmp, eanCodes);
            }
        }
        return result;
    },

    reduceToCustomLogicExp : function (exp) {
        var i = 1;
        var m = {};
        var reduced = exp.replace(/\([PN]([^)^(]+)\)/g, function(p){
            var value = p.substring(2, p.length - 1);
            if (p.indexOf('P') === 1) {
                let pos = Object.values(m).findIndex(v => v === value);
                if (pos > -1) {
                    return Object.keys(m)[pos];
                } else {
                    let n = i++;
                    m['P' + n] = value;
                    return ('P' + n);
                }
            } else {
                m['N'] = value;
                return ('N');
            }
        }).replace(/(AND)|(OR)/g, ' $& ');

        return {
            'mapping' : m,
            'logic' : reduced,
            'addCond' : exp
        }
    },


    getProductsByEAN : function (cmp, eanCodes) {
        var action = cmp.get('c.getProductsByEAN');
        action.setParams({
            'eanCodes' : [].concat(eanCodes)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var ccCmp = cmp.get('v.commercialConditions');
                if (!$A.util.isEmpty(result) && !$A.util.isEmpty(ccCmp)) {
                    ccCmp.set('v.presenceOf', eanCodes.map(code => result.find(record => record.EAN__c === code)));
                }
            } else if (cmp.isValid() && state === 'INCOMPLETE') {
                console.log("Call of getProductsByEAN(eanCodes) INCOMPLETE");
            } else if (cmp.isValid() && state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error('Error message: ' +
                            errors[0].message);
                    }
                } else {
                    console.log('Unknown error');
                }
            }
        });
        $A.enqueueAction(action);

    },


    mapRecordData : function (cmp, event, helper) {
        var val = event.getParam('value');
        var a = cmp.get('v.animation') || {};
        if (!$A.util.isEmpty(val)) {
            for (let key in val) {
                if (a.hasOwnProperty(key)) {
                    if (key.endsWith('__r')) {
                        a[key].Name = val[key];
                    } else {
                        a[key] = val[key];
                    }
                }
            }
        }
        cmp.set('v.animation', a);
        helper.changeBrand(cmp, event, helper);
        helper.presetDeliveryDates(cmp, helper);
        cmp.set('v.isReady', true);
    },


    handleControlAction : function (cmp, helper, src, validity) {
        switch (src) {
            case 'save' :
                cmp.set('v.isReady', false);
                helper.saveAnimation(cmp, helper);
                break;
            case 'clone' :
                cmp.set('v.isReady', false);
                helper.duplicate(cmp, helper, function (response, error) {
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result) && result.Id) {
                        let evt = $A.get('e.force:navigateToURL');
                        evt.setParams({
                            'url' : location.protocol + '//' + location.host + '/one/one.app#/sObject/Animation__c/new?recordTypeId=' + cmp.get('v.simpleRecord')['RecordTypeId'] + '&cs=' + cmp.get('v.recordId')
                        });
                        evt.fire();
                    } else if (error) {
                        result = error.substring(error.lastIndexOf('getMessage=') + 11, error.lastIndexOf(';getStatusCode='));
                        let evt = $A.get('e.force:showToast');
                        evt.setParams({
                            'title' : 'Something went wrong',
                            'message' : 'Details: ' + result,
                            'type' : 'warning'
                        });
                        evt.fire();
                    }
                    cmp.set('v.validity', validity);
                });
                break;
            case 'delete' :
                cmp.set('v.isReady', false);
                let recordId = cmp.get('v.recordId');
                if (recordId) {
                    this.CalloutService.runApex('doDelete', {
                        'recordId':cmp.get('v.recordId')
                    })
                        .then(result => {
                            cmp.set('v.isReady', true);
                            this.Notifications.showToast({
                                'type' : 'success',
                                'title' : 'Success!',
                                'message' : '{0} has been successfully deleted'.replace('{0}', cmp.get('v.animation.Name'))
                            });
                            var evt = $A.get('e.force:navigateToURL');
                            evt.setParams({
                                'url' : location.protocol + '//' + location.host + '/one/one.app#/sObject/Animation__c/list?filterName=Recent'
                            });
                            evt.fire();
                        })
                        .catch(error => {
                            cmp.set('v.isReady', true);
                            this.Notifications.showToast({
                                'type' : 'warning',
                                'title' : 'Warning!',
                                'message' : 'Error occurred during {0} delete'.replace('{0}', cmp.get('v.animation.Name'))
                            });
                        });
                }
                break;
            case 'sharing' :
                $A.util.toggleClass(cmp.find('sharingContainer'), 'slds-hide');
                cmp.set('v.sharingBtnState', !cmp.get('v.sharingBtnState'));
                break;
            case 'cancel' :
                let evt = $A.get('e.force:navigateToURL');
                evt.setParams({
                    'url' : window.location.protocol + '//' + window.location.host + '/one/one.app#/sObject/Animation__c/list?filterName=Recent'
                });
                evt.fire();
                break;
            case 'edit' :
                let navEvt = $A.get("e.force:navigateToComponent");
                navEvt.setParams({
                    'componentDef' : 'c:AnimationGenerator',
                    'componentAttributes' : {
                        'recordId' : cmp.get("v.recordId")
                    }
                });
                navEvt.fire();
                break;
            case 'back' :
                window.history.back();
                break;
            default :
                cmp.set('v.validity', validity);
                break;
        }
    },


    saveAnimation : function (cmp, helper) {
        if (!helper.validateAnimation(cmp, {'getParams' : () => {return {'index':'Status__c','value':cmp.get('v.animation.Status__c')}}}, helper)) {
            let msg = cmp.get('v.message.animation');
            let labels = cmp.get('v.labels.Animation__c');
            msg = Object.keys(msg).filter((k) => msg[k]).map((k) => { if (msg[k]) return {[labels[k]]:msg[k]}; });
            msg = JSON.stringify(msg, (k, v) => {if (v) return v;}, ' ').replace(new RegExp('[{}"\\[\\]]', 'g'),'');
            this.Notifications.showToast({
                'variant' : 'warning',
                'title' : 'Please, review errors and correct your data',
                'message' : msg
            });
            cmp.set('v.isReady', true);
            cmp.set('v.isPerformingSaveAction', false);
            return;
        }
        var viewModel = helper.getAnimationViewModel(cmp, helper);
        if (typeof(viewModel) === 'string') {
            this.Notifications.showToast({
                'variant' : 'warning',
                'title' : 'Warning!',
                'message' : viewModel
            });
            cmp.set('v.isReady', true);
            cmp.set('v.isPerformingSaveAction', false);
            return;
        }
        cmp.set('v.viewModel', viewModel);

        if (viewModel.record.Status__c !== 'Draft' && ($A.util.isEmpty(viewModel.conditions) || $A.util.isEmpty(viewModel.levels))) {
            cmp.set('v.isReady', true);
            this.MessageService
                .initSaveDialog({
                    'onSubmit' : function () {
                        helper.proceedSaveAction(cmp, helper, viewModel);
                    },
                    'onReject' : function () {
                        cmp.set('v.isPerformingSaveAction', false);
                        if (!viewModel.conditions) {
                            helper.blinkDomElement(cmp, 'levelsSection', 600);
                        } else {
                            helper.blinkDomElement(cmp, 'freeProductSection', 600);
                        }
                    }
                });
        } else {
            this.proceedSaveAction(cmp, helper, viewModel);
        }

    },

    proceedSaveAction : function (cmp, helper, viewModel) {
        cmp.set('v.isReady', false);
        helper.CalloutService.runApex('doUpsert', {
            'viewModel' : JSON.stringify(viewModel)
        }).then(result => {
            var record = cmp.get('v.simpleRecord');
            var animation = cmp.get('v.animation');
            if (result && result.length === 18) {
                if (!$A.util.isEmpty(record) && !$A.util.isEmpty(animation)
                    && record.Status__c !== animation.Status__c) {
                    window.location.replace('/' + result);
                } else {
                    helper.Notifications.showToast({
                        'variant' : 'success',
                        'title' : 'Success!',
                        'message' : '{0} has been successfully created'.replace('{0}', 'OP')
                    });
                    let evt = $A.get('e.force:navigateToSObject');
                    evt.setParams({ 'recordId' : result });
                    evt.fire();
                }
            }
            cmp.set('v.isReady', true);
            window.setTimeout($A.getCallback(() => {
                cmp.set('v.isPerformingSaveAction', false);
            }), 2000);
        }).catch(errors => {
            if (errors) {
                cmp.set('v.isPerformingSaveAction', false);
                if (errors[0] && errors[0].message) {
                    console.log('Error message: ', errors[0].message);
                    let msg = errors[0].message;
                    helper.Notifications.showToast({
                        'variant' : 'warning',
                        'title' : 'Warning!',
                        'message' : msg
                    });
                    switch(msg) {
                        case 'You have to select customers' : helper.blinkDomElement(cmp, 'accountSection', 600);
                            break;
                        case 'You have to select products' : helper.blinkDomElement(cmp, 'productSection', 600);
                            break;
                        case 'You have to add commercial conditions for Promotion' : helper.blinkDomElement(cmp, 'levelsSection', 600);
                            break;
                        case 'You have to select discount products' : helper.blinkDomElement(cmp, 'freeProductSection', 600);
                            break;
                    }
                }
            } else {
                console.log('Unknown error');
                helper.Notifications.showToast({
                    'variant' : 'warning',
                    'title' : 'Warning!'
                });
            }
            cmp.set('v.isReady', true);
        });
    },


    duplicate : function (cmp, helper, callback) {
        var a = cmp.get('v.animation');
        for (let key in a) {
            if (key.endsWith('__r')) {
                delete a[key];
            }
        }
        a.Id = cmp.get('v.recordId');
        var action = cmp.get('c.duplicate');
        action.setParams({
            'record' : a
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set('v.isReady', true);
            if (cmp.isValid() && state === 'SUCCESS') {
                callback(response);
            } else if (cmp.isValid() && state === 'INCOMPLETE') {
                console.log("Call of doUpsert() INCOMPLETE");
            } else if (cmp.isValid() && state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        callback(response, errors[0].message);
                        console.error('Error message: ' +
                            errors[0].message);
                        this.Notifications.showToast({
                            'variant' : 'warning',
                            'title' : 'Warning!',
                            'message' : errors[0].message
                        });
                    }
                } else {
                    console.log('Unknown error');
                }
            }
        });
        $A.enqueueAction(action);
    },


    getAnimationViewModel : function (cmp, helper) {
        // var a = cmp.get('v.animation');
        // a.Id = cmp.get('v.recordId');
        // for (let key in a) {
        //     if (key.endsWith('__r')) {
        //         delete a[key];
        //     }
        // }

        var accountGroupCompound = cmp.find('accountGroupCompound');
        var agName = (accountGroupCompound.find('group-name').get('v.value') || '').trim();
        if ((!agName || !accountGroupCompound.get('v.storageAction'))) {
            // helper.blinkDomElement(cmp, 'accountSection', 600);

            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": 'warning',
                "title": 'Group Name',
                "message": 'Please complete the Group Name field.'
            });
            resultsToast.fire();

            return 'Customers group name or storage action can not be empty';
        }

        function getProperGroupOnAction(entity, action) {
            switch (action) {
                case 'update' : return { Id: cmp.get('v.parent').get('v.simpleRecord').EUR_CRM_Account_Target_Group__c, Name: cmp.get('v.accountGroup').Name };
                case 'assign' : return cmp.get('v.accountGroup').get('v.header').get('v.group');
                case 'create' : return { IsDynamic__c: false, Id: null};
                case 'createDynamic' : return { IsDynamic__c: true, Id: null};
            }
        }

        // function getCommercialConditions() {
        //     if (cmp.get('v.ccHasBeenChanged')) {
        //         return cmp.get('v._ccRuntimeHistory.template') || null;
        //     }
        //     if (!$A.util.isEmpty(cmp.get('v.commercialConditions').get('v.template.CalculationType__c'))) {
        //         return helper.setEanAndMultiplicationFactor(cmp);
        //     }
        //     return null;
        // }
        //
        // function getCommercialConditionsLineItems() {
        //     if (cmp.get('v.ccHasBeenChanged')) {
        //         return cmp.get('v._ccRuntimeHistory.lineItems') || [];
        //     }
        //     if (!$A.util.isEmpty(cmp.get('v.commercialConditions').get('v.template.CalculationType__c'))) {
        //         return cmp.get('v.commercialConditions').get('v.lineItems');
        //     }
        //     return [];
        // }

        var accGroup = getProperGroupOnAction('account', accountGroupCompound.get('v.storageAction'));

        if (accGroup.IsDynamic__c === undefined) {
            accGroup.IsDynamic__c = accountGroupCompound.get('v.isDynamic')
        }

        // var prodGroup = getProperGroupOnAction('product', productGroupCompound.get('v.storageAction'));
        const storeAction = accountGroupCompound.get('v.storageAction');
        var viewModel = {
            // 'entityType' : 'Animation__c',
            // 'record' : a,
            'accountGroup' : {
                'action' : storeAction,
                'sobjectType' : 'EUR_CRM_Account_Target_Group__c',
                'Name' : agName,
                'IsDynamic' : storeAction.indexOf('create') > -1 ? accGroup.IsDynamic__c : undefined,
                'Id' : (accGroup && accGroup.Id) ? accGroup.Id : null
            },
            'accountsInGroup' : helper.getRecordsInGroup(cmp, 'account'),
            // 'accountsInTargetGroup' : [],
        };

        if (viewModel.accountGroup && viewModel.accountGroup.IsDynamic__c) {
            let filterResult = accountGroupCompound.get('v.filterResult');
            console.log('filterResult => ', filterResult);
            if (!$A.util.isEmpty(filterResult)) {
                filterResult.objectName = 'EUR_CRM_Account__c';
                viewModel.accountGroup.Criteria__c = filterResult && !$A.util.isEmpty(filterResult.items) ? JSON.stringify(filterResult) : null;
            }
        }
        return viewModel;
    },

    getRecordsInGroup : function (cmp, type) {

        function getAccountGroupMembers() {
            return selected.map(account => {
                return {
                    'recordInGroup' : {
                        'sobjectType' : 'AccountInGroup__c',
                        'Account__c' : account.Id
                    }
                }
            });
        }

        function getProductGroupMembers() {
            return selected.map(product => {
                return {
                    'recordInGroup' : {
                        'sobjectType' : 'ProductInGroup__c',
                        'ProductID__c' : product.Id
                    }
                }
            });
        }

        function getPlvGrouping() {
            return selected.map(val => {
                if (!$A.util.isEmpty(previewRecords)) {
                    let grouping = {
                        'recordInGroup' : null,
                        'pbEntryGrouping' : val.pbEntryGrouping || null,
                        'pbegItems' : val.pbEntryGroupingItems || null,
                    }
                    if (grouping.pbEntryGrouping && !grouping.pbEntryGrouping['FreeID__c']) {
                        grouping.pbEntryGrouping['FreeID__c'] = val['Price_Book_Items__r'] && val['Price_Book_Items__r'].length === 1
                            ? val['Price_Book_Items__r'][0]['Id']
                            : grouping.pbEntryGrouping['FreeID__c'];
                    }
                    return grouping;
                }
                return {
                    'recordInGroup' : null,
                    'pbEntryGrouping' : val || null,
                    'pbegItems' : val['Price_Book_Entry_Grouping_Items__r'] || null,
                };
            });
        }

        var
            previewRecords = cmp.get('v.' + type + 'PreviewRecords') || []
            , savedRecords = type == 'plv'
            ? cmp.get('v.model.pbEntryGrouping')
            : type == 'product'
                ? (cmp.get('v.model.productGroup.Product_in_Groups__r') || []).map(item => item['ProductID__r'])
                : (cmp.get('v.model.accountGroup.Account_in_Groups__r') || []).map(item => item['Account__r'])
            , selected = ($A.util.isEmpty(previewRecords) ? savedRecords : previewRecords) || []
            , records;

        switch (type) {
            case 'account':
                records = getAccountGroupMembers();
                break;
            case 'product':
                records = getProductGroupMembers();
                break;
            case 'plv':
                records = getPlvGrouping();
                break;
            default: console.log('--- Unknown group type: ', type);
        }
        return records;
    },

    setDefaults : function(cmp) {
        cmp.set('v.accountData', {'recordSource' : 'acc-selected'});
        cmp.set('v.productData', {'recordSource' : 'prod-selected'});
        cmp.set('v.freeProductData', {'recordSource' : 'free-selected', 'conditions' : {}});
        cmp.set('v.initialDate', new Date().toJSON().split('T')[0]);
        if ($A.util.isEmpty(cmp.get('v.validity'))) {
            cmp.set('v.validity', this.getDefaultValidity(cmp));
        }
        cmp.set('v.message', {'animation':{'ValidFrom__c':'','ValidTo':''}});
        cmp.set('v.customDomain', window.location.host.substring(0, window.location.host.lastIndexOf('.lightning.force')));
        cmp.set('v.accountQueryCriteria', [
            {
                'f' : 'RecordType.DeveloperName',
                's' : '!=',
                'v' : '\'Account_Brand\''
            }
        ]);
        var brandCriteria = {
            'f' : 'Brandgl__c',
            's' : '=',
            'v' : "'" + cmp.get('v.animation.Brand__c') + "'"
        };
        cmp.set('v.productQueryCriteria', [
            {
                'f' : 'Id',
                's' : 'IN',
                'v' : '(SELECT ProductID__c ' +
                'FROM PriceBookItem__c ' +
                'WHERE PriceBookID__r.IsStandard__c = true ' +
                'AND ProductID__r.RecordType.DeveloperName = \'CompanyProduct\'' +
                'AND RecordType.DeveloperName != \'Free\' ' +
                'AND ProductID__r.CTCPG__IsActive__c = TRUE)'
            },
            brandCriteria
        ]);
        cmp.set('v.freeItemsCriteria', [
            {
                'f' : 'Id',
                's' : 'IN',
                'v' : '(SELECT ProductID__c ' +
                'FROM PriceBookItem__c ' +
                'WHERE PriceBookID__r.IsStandard__c = true ' +
                'AND RecordType.DeveloperName = \'Free\' ' +
                'AND ProductID__r.CTCPG__IsActive__c = TRUE)'
            },
            brandCriteria
        ]);
        cmp.set('v._ccRuntimeHistory', {
            'template' : {'sobjectType' : 'CommercialConditions__c'},
            'lineItems' : []
        });
    },

    getDefaultValidity : function (cmp) {
        return $A.util.isEmpty(cmp.get('v.validity'))
            ? {
                'isUpdatable': true,
                'isClonable' : true,
                'isRemovable' : false,
                'accountGroup' : { 'disabled' : false },
                'productGroup' : { 'disabled' : false },
                'commercialConditions' : { 'disabled' : false },
                'freeConditionsTemplate' : { 'disabled' : false },
                'freeProductGroup' : { 'disabled' : false }
            }
            : cmp.get('v.validity');
    },

    getDefaultAnimation : function () {
        const TODAY = new Date().toISOString().split('T')[0];
        return {
            'sobjectType' : 'Animation__c'
            , 'Name' : ''
            , 'Status__c' : 'Draft'
            , 'Application__c' : ''
            , 'Brand__c' : ''
            , 'Code__c' : ''
            , 'ValidFrom__c' : TODAY
            , 'ValidTo__c' : TODAY
            , 'IsDealOpening__c' : false
            , 'Withbonus__c' : true
            , 'NewProductLaunch__c' : false
            , 'Priority__c' : 0
            , 'AdditionalConditions__c' : ''
            , 'UnlimitedOccurrence__c' : true
            , 'DiscountCalculationMethod__c' : ''
            , 'DeliveryDates__c' : 'TODAY'
            , 'MinFixed__c' : 'S'
            , 'Country__c' : ''
            , 'DealStartDate__c' : 'TODAY'
            , 'DealEndDate__c' : ''
            , 'GenerateSeparatedDocType__c' : false
            , 'AvailableForAll__c' : true
        }
    },

    showBrandChangeDialog : function (cmp, event, helper) {
        let products = cmp.get('v.productPreviewRecords') || cmp.get('v.productData.listViewRecords') || [];
        let plv = cmp.get('v.plvPreviewRecords') || cmp.get('v.model.pbEntryGrouping') || [];
        if (!$A.util.isEmpty(products) || !$A.util.isEmpty(plv)) {
            this.MessageService
                .initChangeBrandDialog({
                    'onSubmit' : function () {
                        helper.submitBrandChangeDialog(cmp, helper);
                    },
                    'onReject' : function () {
                        cmp.set('v.animation.Brand__c', cmp.get('v.brandOldValue'));
                    }
                });
        } else {
            helper.changeBrand(cmp, event, helper);
        }
    },

    submitBrandChangeDialog : function (cmp, helper) {
        cmp.set('v.model.accountGroup', null);
        cmp.set('v.model.productGroup', null);
        cmp.set('v.model.pbEntryGrouping', []);
        helper.clearPresenceOfCustomLogic(cmp, helper);
        helper.changeBrand(cmp, null, helper);
    },

    changeBrand : function (cmp, event, helper) {
        var a = cmp.get('v.animation') || {};
        var val = !event ? a['Brand__c'] : event.getSource().get('v.value') || (event.getParam('value') ? event.getParam('value').Brand__c : '') || a.Brand__c;
        var accCmp = cmp.find('accountGroupCompound');
        var prodCmp = cmp.find('productGroupCompound');
        var plvCmp = cmp.find('plvGroupCompound');
        var accountGroup = cmp.get('v.accountGroup') || accCmp.get('v.selector')[0].get('v.value');
        var productGroup = cmp.get('v.productGroup') || prodCmp.get('v.selector')[0].get('v.value');
        var plvGroup = cmp.get('v.plvGroup') || plvCmp.get('v.selector')[0].get('v.value');

        accCmp.reset();
        prodCmp.reset();
        plvCmp.reset();

        cmp.set('v.brandOldValue', val);
        var prodCriteria = $A.util.isEmpty(val)
            ? []
            : [{ 'f' : 'Brandgl__c', 's' : '=', 'v' : "'" + val + "'" }];

        mergeCriteria('productQueryCriteria', prodCriteria);
        mergeCriteria('freeItemsCriteria', prodCriteria);
        if (accountGroup) {
            accountGroup.initGroupList(cmp.get('v.accountQueryCriteria'));
            accountGroup.setGroupLocked(!val);
        }
        if (productGroup) {
            productGroup.initGroupList(cmp.get('v.productQueryCriteria'));
            productGroup.setGroupLocked(!val);
        }
        if (plvGroup) {
            plvGroup.initGroupList(cmp.get('v.freeItemsCriteria'));
            plvGroup.setGroupLocked(!val);
        }
        cmp.set('v.accountData.listViewRecords', []);
        cmp.set('v.productData.listViewRecords', []);
        cmp.set('v.freeProductData.listViewRecords', []);

        function mergeCriteria(attrName, criteria) {
            var oldCriteria = cmp.get('v.' + attrName);
            var mergeResult = oldCriteria;
            if (!$A.util.isEmpty(criteria) && !$A.util.isEmpty(oldCriteria)) {
                mergeResult.forEach(item => {
                    if (item.f === 'Brandgl__c') {
                        item.s = criteria[0].s;
                        item.v = criteria[0].v;
                    }
                });
            } else if (!$A.util.isEmpty(criteria)) {
                mergeResult = criteria;
            }
            cmp.set('v.' + attrName, mergeResult);
            return mergeResult;
        }
    },

    applyTemplate : function (cmp, event, helper) {
        if (event && event.getSource().get('v.name') === 'applyFreeProdCondTemplate') {
            helper.applyAnimationResultTemplate(cmp, helper);
        } else {
            let ccComp = cmp.get('v.commercialConditions');
            ccComp.validateCustomLogic();
            let logic = ccComp.get('v.addCond');
            let a  = cmp.get('v.animation');
            a.AdditionalConditions__c = logic;
            cmp.set('v.animation', a);
            let cc = helper.setEanAndMultiplicationFactor(cmp);
            cmp.set('v.comCondTemplate', cc);
            cmp.set('v.ccHasBeenChanged', false);
            cmp.set('v._ccRuntimeHistory', {
                'template' : this.clone(cc),
                'lineItems' : this.clone(ccComp.get('v.lineItems')),
            });
        }
    },

    setEanAndMultiplicationFactor : function (cmp) {
        let cc = cmp.get('v.commercialConditions').get('v.template');
        let ccEans = (cc['AnimationProductsEAN__c'] || '').split(';');
        let ccMF = (cc['AnimationProductsMultiplier__c'] || '').split(';');
        ccEans = ccEans.length === 1 && !ccEans[0] ? [] : ccEans;
        ccMF = ccMF.length === 1 && !ccMF[0] ? [] : ccMF;
        let products = [].concat(cmp.find('product-details-view') || []);
        let records = [].concat(cmp.get('v.productPreviewRecords') || []);
        let modelEans = (cmp.get('v.model.productGroup.Product_in_Groups__r') || []).map(item => {
            if (item['ProductID__r'] && item['ProductID__r']['EAN__c']) {
                return item['ProductID__r']['EAN__c'];
            }
        });
        if ($A.util.isEmpty(products) && cmp.get('v.model.productGroup') && !$A.util.isEmpty(modelEans)) {
            if (!cc['AnimationProductsEAN__c']) {
                cc['AnimationProductsEAN__c'] = modelEans.join(';');
                cc['AnimationProductsMultiplier__c'] = Array(modelEans.length).fill('1').join(';');
                cc['ExcludedProductsEAN__c'] = null;
            }
            return cc;
        }
        let eanCodes = [];
        let multiplierValues = [];
        let excludedEans = [];
        let allEanSet = new Set();
        for (let i = 0; i < products.length; i++) {
            let ean = products[i].get('v.record.EAN__c');
            if (ean) {
                eanCodes.push(ean);
                multiplierValues.push(products[i].get('v.multiplicationFactor') || '1');
                if (products[i].get('v.excludeFromDiscounts')) {
                    excludedEans.push(ean);
                }
                allEanSet.add(ean);
            }
        }
        if (records.length > products.length) {
            let modelProductGroup = cmp.get('v.model.productGroup');
            let prodComp = cmp.find('productGroupCompound');
            let productGroup = prodComp.get('v.storageAction') !== 'update'
                ? prodComp.get('v.selector')[0].get('v.value') || {}
                : modelProductGroup;
            let mapping = modelProductGroup && modelProductGroup.Id === productGroup.Id
                ? cmp.get('v.model.productsMapping') || {}
                : {};
            for (let i = 0; i < records.length; i++) {
                if (records[i] && records[i]['EAN__c'] && !allEanSet.has(records[i]['EAN__c'])) {
                    let pos = ccEans.findIndex(item => item === records[i]['EAN__c']);
                    if (!$A.util.isEmpty(mapping) && (pos > -1 || mapping[records[i]['EAN__c']])) {
                        eanCodes.push(records[i]['EAN__c']);
                        multiplierValues.push(ccMF[pos] || '1');
                        if (mapping[records[i]['EAN__c']] && mapping[records[i]['EAN__c']]['ExcludeFromDiscounts']) {
                            excludedEans.push(records[i]['EAN__c']);
                        }
                    } else {
                        eanCodes.push(records[i]['EAN__c']);
                        if (records[i]['EAN__c']['ExcludeFromDiscounts']) {
                            excludedEans.push(records[i]['EAN__c']);
                        }
                    }
                }
            }
        }
        cc['AnimationProductsEAN__c'] = !$A.util.isEmpty(eanCodes) && !$A.util.isEmpty(products)
            ? eanCodes.join(';')
            : '';
        cc['AnimationProductsMultiplier__c'] = !$A.util.isEmpty(eanCodes) && !$A.util.isEmpty(products)
            ? multiplierValues.join(';')
            : '';
        cc['ExcludedProductsEAN__c'] = !$A.util.isEmpty(excludedEans) && !$A.util.isEmpty(products)
            ? excludedEans.join(';')
            : '';
        return cc;
    },

    applyCommercialConditionsTemplate : function (cmp, helper) {
        var ccComp = cmp.get('v.commercialConditions');
        var persist = ccComp.saveAsTemplate() || {};
        cmp.set('v.comCondTemplate', persist.template);
        cmp.set('v.comCondLineItems', persist.lineItems);
        var logic = ccComp.get('v.addCond');
        var parseLogicResult = helper.parseAdditionalConditions(cmp, logic);
        var presenceOf = ccComp.get('v.presenceOf');
        if (presenceOf.length > parseLogicResult.presenceOf.length) {
            this.Notifications.showToast({
                'type' : 'info',
                'title' : 'Warning!',
                'message' : '\'Presence of\' contains more products than \'Custom logic\'. \'Presence Of\' sequence will be shrunk according to the logic.'
            });
        }
        if (logic && parseLogicResult) {
            let a  = cmp.get('v.animation');
            a.AdditionalConditions__c = logic;
            cmp.set('v.animation', a);
        } else {
            helper.showToast(cmp, { 'type':'warning', 'title':'Warning!', 'message':'' });
        }
    },

    applyAnimationResultTemplate : function (cmp, helper) {
        var persist = cmp.get('v.discountConditions').saveAsTemplate();
        var template = {
            'id' : cmp.get('v.resultTemplate.id') || null,
            'name' : cmp.get('v.resultTemplateName')
        };
        var pbegTempl = persist.template || {};
        var pbegItems = persist.lineItems || [];
        var templates = cmp.get('v.resultTemplates');
        template.calc_type = pbegTempl.Type__c;
        template.multi = pbegTempl.IsMultipling__c || false;
        template.plv_type = pbegTempl.PLVTypes__c;
        template.levels = [].concat(pbegItems).map((item) => {
            return {
                'order_qty' : item.Minquantitytoorder__c,
                'free_qty' : item.Freequantity__c
            }
        });
        template.id = template.id || new Date().toISOString();
        if (!templates.some((t, inx) => {
            if (t && t.id === template.id) {
                templates[inx] = template;
            }
            return t.id === template.id;
        })) {
            templates.push(template);
        }
        cmp.set('v.resultTemplate', template);
        cmp.set('v.resultTemplateHasBeenChanged', false);
        cmp.set('v.resultTemplates', templates);
        cmp.find('select-result-template').set('v.value', template.id);
        if (!cmp.get('v.resultTemplatesLoaded')) {
            helper.obtainResultTemplates(cmp, helper);
        }
    },

    selectResultTemplate : function (cmp, helper, val) {
        if (val == 'new') {
            let origin = cmp.get('v.resultTemplate') || {};
            if (!$A.util.isEmpty(origin)) {
                let tmp = {
                    'id' : null,
                    'name' : origin.name,
                    'calc_type' : origin.calc_type,
                    'multi' : origin.multi,
                    'plv_type' : origin.plv_type,
                    'levels' : (origin.levels || []).slice(0)
                };
                cmp.set('v.resultTemplate', tmp);
            }
            cmp.set('v.resultTemplateHasBeenChanged', true);
        } else {
            let name = '';
            cmp.set('v.resultTemplate', (cmp.get('v.resultTemplates') || []).find((item) => {
                name = item.name;
                return item.id === val;
            }) || {});
            cmp.set('v.resultTemplateName', name);
            cmp.set('v.resultTemplateHasBeenChanged', false);
        }
    },

    setPlvConditionsTemplate : function (cmp, helper) {
        var tmp = cmp.get('v.resultTemplate');
        var pbegTmp = cmp.get('v.freeProdCondTemplate');
        if (!$A.util.isEmpty(tmp)) {
            pbegTmp.Type__c = tmp.calc_type;
            pbegTmp.IsMultipling__c = typeof(tmp.multi) == 'boolean' ? tmp.multi : tmp.multi == 'true';
            pbegTmp.PLVTypes__c = tmp.plv_type;
            let pbegItems = (tmp.levels || []).map((item) => {
                return {
                    'sobjectType' : 'PriceBookEntryGroupingItem__c',
                    'Minquantitytoorder__c' : parseInt(item.order_qty),
                    'Freequantity__c' : parseInt(item.free_qty)
                };
            });
            cmp.set('v.freeProdCondTemplate', pbegTmp);
            cmp.set('v.freeLineItems', pbegItems);
            cmp.set('v.isFreeCalcTypeSet', !!pbegTmp.Type__c);
            let uiTmp = cmp.get('v.discountConditions');
            uiTmp.set('v.template', pbegTmp);
            uiTmp.set('v.lineItems', pbegItems);
            if (uiTmp) {
                uiTmp.wrapLineItems();
                uiTmp.set('v.isFreeCalcTypeSet', !!pbegTmp.Type__c);
            }
        }
    },

    validateAnimation : function (cmp, event, helper) {

        function checkIsRequired(fieldSet) {
            if ($A.util.isEmpty(fieldSet) && params.index) {
                message.animation[params.index] = a['Status__c'] !== 'Draft' && ($A.util.isEmpty(a[params.index]) || $A.util.isEmpty(a[params.index].toString().trim()))
                    ? 'Field is required'
                    : '';
            } else if (!$A.util.isEmpty(fieldSet)) {
                fieldSet.forEach(f => {
                    message.animation[f] = a['Status__c'] !== 'Draft' && ($A.util.isEmpty(a[f]) || $A.util.isEmpty(a[f].toString().trim())) ? 'Field is required' : '';
                });
            }
            return message;
        }

        function checkValidFrom(val) {
            var d = new Date(val);
            if (!isNaN(val) || Object.prototype.toString.call(d) !== "[object Date]" || isNaN(d.getTime())) {
                a.ValidFrom__c = '';
                message.animation.ValidFrom__c = 'Must be a date';
            } else if (a.ValidTo__c && val > a.ValidTo__c) {
                a.ValidFrom__c = '';
                message.animation.ValidFrom__c = 'Cannot be great than Valid To value: ' + new Date(a.ValidTo__c).toDateString();
            } else if (val < TODAY && ((record && record['Status__c'] !== 'Draft' && record['ValidFrom__c'] >= TODAY)
                || (($A.util.isEmpty(record) && a.Status__c !== 'Draft') || record['Status__c'] === 'Draft'))) {
                message.animation.ValidFrom__c = 'Cannot be set in past';
            } else {
                message.animation.ValidFrom__c = '';
                checkIsDealOpening(a.IsDealOpening__c);
                checkDeliveryDates();
            }
        }

        function checkValidTo(val) {
            var d = new Date(val);
            if (!isNaN(val) || Object.prototype.toString.call(d) !== "[object Date]" || isNaN(d.getTime())) {
                a.ValidTo__c = '';
                message.animation.ValidTo__c = 'Must be a date';
            } else if (a.ValidFrom__c && val < a.ValidFrom__c) {
                a.ValidTo__c = '';
                message.animation.ValidTo__c = 'Cannot be less than Valid From value: ' + new Date(a.ValidFrom__c).toDateString();
            } else if (val < TODAY) {
                a.ValidTo__c = '';
                message.animation.ValidTo__c = 'Cannot be set in past';
            } else {
                message.animation.ValidTo__c = '';
                checkIsDealOpening(a.IsDealOpening__c);
            }
        }

        function checkDeliveryDates() {
            helper.checkDeliveryDates(cmp);
        }

        function checkIsDealOpening(val) {
            if (val) {
                checkDealStartDate(a.DealStartDate__c);
                checkDealEndDate(a.DealEndDate__c);
            } else {
                message.animation.DealStartDate__c = message.animation.DealEndDate__c = '';
            }
        }

        function checkDealStartDate(val) {
            var d = new Date(val);
            if (val && isNaN(val) && Object.prototype.toString.call(d) === "[object Date]" && !isNaN(d.getTime())) {
                if (a.ValidFrom__c && val < a.ValidFrom__c) {
                    a.DealStartDate__c = '';
                    message.animation.DealStartDate__c = 'Cannot be less than Valid From value: ' + new Date(a.ValidFrom__c).toDateString();
                } else if (a.DealEndDate__c && val > a.DealEndDate__c) {
                    a.DealStartDate__c = '';
                    message.animation.DealStartDate__c = 'Cannot be great than Deal End Date: ' + new Date(a.DealEndDate__c).toDateString();
                } else if (d < TODAY && ((record && record['Status__c'] !== 'Draft' && record['DealStartDate__c'] >= TODAY) || (!record || record['Status__c'] === 'Draft' || record['Status__c'] === 'Active'))) {
                    message.animation.DealStartDate__c = 'Cannot be set in past';
                } else {
                    message.animation.DealStartDate__c = '';
                }
            } else {
                a.DealStartDate__c = 'TODAY';
                message.animation.DealStartDate__c = '';
            }
        }

        function checkDealEndDate(val) {
            var d = new Date(val);
            if (val && isNaN(val) && Object.prototype.toString.call(d) === "[object Date]" && !isNaN(d.getTime())) {
                if (a.DealStartDate__c && a.DealStartDate__c === 'TODAY' && a.ValidFrom__c && val < a.ValidFrom__c) {
                    a.DealEndDate__c = '';
                    message.animation.DealEndDate__c = 'Cannot be less than Valid From value: ' + new Date(a.ValidFrom__c).toDateString();
                } else if (a.DealStartDate__c && a.DealStartDate__c !== 'TODAY' && val < a.DealStartDate__c) {
                    a.DealEndDate__c = '';
                    message.animation.DealEndDate__c = 'Cannot be less than Deal Start Date: ' + new Date(a.DealStartDate__c).toDateString();
                } else if (d < TODAY && ((record && record['Status__c'] !== 'Draft' && record['DealEndDate__c'] >= TODAY) || (!record || record['Status__c'] === 'Draft' || record['Status__c'] === 'Active'))) {
                    a.DealEndDate__c = '';
                    message.animation.DealEndDate__c = 'Cannot be set in past';
                } else {
                    message.animation.DealEndDate__c = '';
                }
            } else {
                message.animation.DealEndDate__c = 'Must be a date';
            }
        }

        function checkCode(val) {
            if (val && val.length != 3) {
                message.animation.Code__c = 'Length of the code must equal 3 characters';
                return;
            }
            helper.CalloutService.runApex('hasFieldUniqueValue', {
                'recordId' : cmp.get('v.recordId') || null,
                'fieldApiName' : 'Code__c',
                'value' : val
            }).then(result => {
                let msg = checkIsRequired(['Code__c']);
                if (!msg.animation.Code__c) {
                    msg.animation.Code__c = result ? '' : 'Must be unique';
                }
                cmp.set('v.message', msg);
                setValidity(cmp.get('v.message.animation'));
            }).catch(error => console.error(error));
        }

        function setValidity(obj) {
            var validity = cmp.get('v.validity') || helper.getDefaultValidity(cmp);
            validity.isUpdatable = true;
            validity.isClonable = record.Id && record.Status__c !== 'Canceled';
            for (let key in obj) {
                if (message.animation[key]) {
                    validity.isUpdatable = false;
                    break;
                }
            }
            cmp.set('v.validity', validity);
        }

        function checkStatus(val) {
            /* @edit PZ - 23.01.18
            *  Switched string validation messages
            *  to custom labels
            *
            *  @edit PZ - 29.01.18
            *  $A.util.isEmpty(record) check didn't work
            *  for new record create, as record was never empty
            *  so messages weren't shown
            *
            *
            */

            message.animation.Status__c = record['Status__c'] === 'Active' && val === 'Draft'
                ? 'You can only close or cancel an active Promotion'
                : ($A.util.isEmpty(cmp.get('v.recordId')) || record['Status__c'] === 'Draft') && (val === 'Closed' || val === 'Canceled')
                    ? 'You can close or cancel only an active Promotion' : '';


            checkIsRequired(['Name', 'Code__c', 'Brand__c', 'OrderType__c', 'Priority__c', 'DiscountCalculationMethod__c', 'Country__c']);
            checkValidFrom(a['ValidFrom__c']);
            checkValidTo(a['ValidTo__c']);
            checkIsDealOpening(a.IsDealOpening__c);
            checkCode(a['Code__c']);
        }

        var a = cmp.get('v.animation');
        var record = cmp.get('v.simpleRecord') || {};
        var params = event.getParams() || {};
        var now = new Date().toISOString();
        const TODAY = now.substring(0, now.indexOf('T'));
        var message = cmp.get('v.message') || {'animation':{}};

        if (!$A.util.isEmpty(params)) {
            switch (params.index) {
                case 'Status__c' :
                    checkStatus(params.value);
                    break;
                case 'ValidFrom__c' :
                    checkValidFrom(params.value);
                    break;
                case 'ValidTo__c' :
                    checkValidTo(params.value);
                    break;
                case 'DealStartDate__c' :
                    checkDealStartDate(params.value);
                    break;
                case 'DealEndDate__c' :
                    checkDealEndDate(params.value);
                    break;
                case 'Code__c' :
                    checkCode(params.value);
                    break;
                case 'IsDealOpening__c':
                    checkIsDealOpening(params.value);
                    break;
                case 'DeliveryDates__c' :
                case 'MinFixed__c' :
                case 'UnlimitedOccurrence__c':
                case 'Withbonus__c':
                case 'NewProductLaunch__c':
                case 'GenerateSeparatedDocType__c':
                case 'Application__c':
                case 'sobjectType':
                case 'AvailableForAll__c':
                    break;
                default : checkIsRequired();
                    break;
            }
        }
        setValidity(message.animation);
        cmp.set('v.message', message);
        return cmp.get('v.validity.isUpdatable');
    },

    checkDeliveryDates : function (cmp) {
        var deliveryDates = cmp.get('v.deliveryDates');
        var ddInputs = cmp.find('deliveryDate');
        var validFrom = cmp.get('v.animation.ValidFrom__c');
        var hasToday = false;
        if (!$A.util.isEmpty(deliveryDates) && !$A.util.isEmpty(ddInputs)) {
            deliveryDates.forEach((item) => {
                hasToday = item.val === 'TODAY' || hasToday;
                if (item.val != 'TODAY' && item.val < validFrom) {
                    this.Notifications.showNotice({
                        'variant' : 'error',
                        'header' : 'Attention',
                        'message' : 'Be careful! The promotion has at least one delivery date that less than Valid From date. This delivery date will not be used unless you set appropriate Valid From date.'
                    });
                }
            });
        }
        cmp.set('v.hasToday', hasToday);
    },

    processComponentsValidity : function (cmp, event, helper) {
        var validity = cmp.get('v.validity');
        if (validity) {
            for (let key in validity) {
                if (validity[key] && validity[key].hasErrors) {
                    cmp.set('v.validity.isUpdatable', false);
                    return;
                }
            }
            let message = cmp.get('v.message');
            if (message && message.animation) {
                for (let key in message.animation) {
                    if (message.animation[key]) {
                        cmp.set('v.validity.isUpdatable', false);
                        return;
                    }
                }
            }
            let a = (cmp.get('v.recordId') ? cmp.get('v.simpleRecord') : cmp.get('v.animation')) || {};
            cmp.set('v.validity.isUpdatable', a.Status__c === 'Draft' || a.Status__c === 'Active');
        }
    },

    addDeliveryDate : function (cmp, event, helper) {
        var val = event.getSource().get('v.value');
        var d = new Date(val);
        const TODAY = new Date().toISOString().split('T')[0];
        var a = cmp.get('v.animation');
        var deliveryDates = cmp.get('v.deliveryDates');
        if (isNaN(val) && Object.prototype.toString.call(d) === "[object Date]" && !isNaN(d.getTime()) ) {
            if (!deliveryDates.some(item => item.val == val || (item.val === 'TODAY' && val === TODAY)) && val >= TODAY) {
                if (!$A.util.isEmpty(deliveryDates)) {
                    deliveryDates.push({'val' : val, 'label' : helper.formatDate(val), 'option' : deliveryDates.some((dd) => dd.option === 'Minimum') ? 'Fixed' : ''});
                } else {
                    deliveryDates.push({'val' : val, 'label' : helper.formatDate(val), 'option' : ''});
                }
                a.DeliveryDates__c = [].concat(deliveryDates).reduce(function(prev, curr){return [...prev, curr.val]}, []).join(';');
                a.MinFixed__c = [].concat(deliveryDates).reduce(function(prev, curr){return [...prev, helper.mapMinFixOption(curr.option)]}, []).join(';');
                cmp.set('v.animation', a);
                cmp.set('v.deliveryDates', deliveryDates);
            }
        }
        helper.checkDeliveryDates(cmp);
    },

    setDeliveryDateToday : function (cmp, helper) {
        var dd = cmp.get('v.deliveryDates') || [];
        if ($A.util.isEmpty(dd) || (dd.length < 3 && dd.every((date) => date.val !== 'TODAY'))) {
            dd.push({'val' : 'TODAY', 'label' : 'TODAY', 'option' : ''});
            cmp.set('v.hasToday', true);
            cmp.set('v.deliveryDates', dd);
            let a = cmp.get('v.animation');
            a.DeliveryDates__c = [].concat(dd).reduce(function(prev, curr){return [...prev, curr.val]}, []).join(';');
            a.MinFixed__c = [].concat(dd).reduce(function(prev, curr){return [...prev, helper.mapMinFixOption(curr.option)]}, []).join(';');
            cmp.set('v.animation', a);
        }
    },

    removeDeliveryDate : function (cmp, event, helper) {
        var deliveryDates = cmp.get('v.deliveryDates');
        var a = cmp.get('v.animation');
        var index = event.getParam('data').id;
        deliveryDates.splice(index, 1);
        a.DeliveryDates__c = [].concat(deliveryDates).reduce(function(prev, curr){return [...prev, curr.val]}, []).join(';');
        a.MinFixed__c = [].concat(deliveryDates).reduce(function(prev, curr){return [...prev, helper.mapMinFixOption(curr.option)]}, []).join(';');
        cmp.set('v.animation', a);
        cmp.set('v.deliveryDates', deliveryDates);
        cmp.set('v.hasToday', a.DeliveryDates__c.includes('TODAY'));
    },

    selectDeliveryDateOption : function (cmp, event, helper) {
        var val = event.getSource().get('v.value');
        var pos = event.getSource().get('v.name');
        var deliveryDates = cmp.get('v.deliveryDates');
        var a = cmp.get('v.animation');
        deliveryDates[pos].option = val === 'Minimum' && deliveryDates.filter(d => d.option === val).length > 1 ? '' : val;
        a.MinFixed__c = [].concat(deliveryDates).reduce(function(prev, curr){return [...prev, helper.mapMinFixOption(curr.option)]}, []).join(';');
        cmp.set('v.animation', a);
        cmp.set('v.deliveryDates', deliveryDates);
    },

    selectDealStartDate : function (cmp, event, helper) {
        var val = event.getSource().get('v.value');
        var d = new Date(val);
        if (Object.prototype.toString.call(d) !== "[object Date]" || isNaN(d.getTime())) {
            val = 'TODAY';
            event.getSource().set('v.value', val);
        } else {
            val = d.toISOString().split('T')[0]
        }
        cmp.set('v.animation.DealStartDate__c', val);
    },

    clearPresenceOfCustomLogic : function (cmp, helper, id) {
        var ccCmp = cmp.get('v.commercialConditions');
        ccCmp.set('v.customLogic', '');
        ccCmp.set('v.numberOfDistRef', id && !$A.util.isEmpty(ccCmp.get('v.presenceOf')) ? ccCmp.get('v.numberOfDistRef') : 0);
        ccCmp.set('v.presenceOf', id ? (ccCmp.get('v.presenceOf') || []).filter(item => item.Id != id) : []);
        if (ccCmp && ccCmp.isValid()) {
            helper.applyTemplate(cmp, null, helper);
        }
    },

    obtainResultTemplates : function (cmp, helper) {
        var hasCloneSourceId = window.location.hash.match(/(?:&cs=)[\w]{18}/);
        var recordId = !$A.util.isEmpty(hasCloneSourceId) && hasCloneSourceId[0] && hasCloneSourceId[0].substring(4).length == 18
            ? hasCloneSourceId[0].substring(4) : cmp.get('v.recordId') || null;
        var templates = [].concat(cmp.get('v.resultTemplates'));
        this.CalloutService.runApex('getResultTemplates', {
            'recordId':recordId
        }).then(result => {
            cmp.set('v.resultTemplates', templates.concat(result || []));
            if (cmp.get('v.resultTemplate')) {
                cmp.find('select-result-template').set('v.value', cmp.get('v.resultTemplate.id'));
            }
            cmp.set('v.resultTemplatesLoaded', true);
        }).catch(error => console.error(error));
    },

    removeResultTemplate : function (cmp) {
        var tmp = cmp.get('v.resultTemplate');
        var templates = cmp.get('v.resultTemplates');
        if (!$A.util.isEmpty(tmp) && !$A.util.isEmpty(templates)) {
            cmp.set('v.resultTemplates', templates.filter(item => item.id !== tmp.id));
            cmp.set('v.resultTemplate.id', null);
        }
    },

    moveDetailsCard : function (cmp, who, direction, position) {
        var key = 'v.' + who + 'PreviewRecords'
            , records = cmp.get(key)
            , movingRecord = records[position]
            , newPosition = direction === 'up' ? position - 1 : position + 1;
        if (movingRecord && records[newPosition]) {
            records[position] = records[newPosition];
            records[newPosition] = movingRecord;
        }
        cmp.set(key, records);
    },

    /**
     * Utility methods
     */

    mapMinFixOption : function (o) {
        switch(o) {
            case 'M': return 'Minimum';
            case 'S': return '';
            case 'F': return 'Fixed';
            case 'Minimum': return 'M';
            case '': return 'S';
            case 'Fixed': return 'F';
        }
    },

    formatDate : function (d, f, l) {
        if (d === 'TODAY') return d;
        return $A.localizationService.formatDateTime(d, f || $A.get("$Locale.dateFormat"), l || $A.get("$Locale.langLocale"));
    },

    showToast : function (params) {
        var toast = $A.get('e.force:showToast');
        toast.setParams(params);
        toast.fire();
    },

    blinkDomElement : function (cmp, localId, timeout) {
        setTimeout($A.getCallback(function () {
            var section = cmp.find(localId);
            section.getElement().scrollIntoView();
            $A.util.addClass(section, 'section-blink');
            setTimeout($A.getCallback(function () {
                $A.util.removeClass(section, 'section-blink');
            }), 200);
        }), timeout);
    },

    clone : function (o) {
        var result;
        if ($A.util.isEmpty(o)) return o;
        if ($A.util.isObject(o)) {
            result = {};
            for (let key in o) {
                if (o.hasOwnProperty(key)) {
                    result[key] = $A.util.isObject(o[key]) || $A.util.isArray(o[key]) ? this.clone(o[key]) : o[key];
                }
            }
        } else if ($A.util.isArray(o)) {
            result = [];
            for (let i = 0; i < o.length; i++) {
                result[i] = $A.util.isObject(o[i]) || $A.util.isArray(o[i]) ? this.clone(o[i]) : o[i];
            }
        } else {
            result = o;
        }
        return result;
    },

    log : function (o) {
        if (o && o.hasOwnProperty() && !Array.isArray(o)) {
            Object.keys(o).forEach(k => {
                console.log('>>> ', k, ' : ', o[k]);
                this.log(o[k]);
            });
        }
    },
});