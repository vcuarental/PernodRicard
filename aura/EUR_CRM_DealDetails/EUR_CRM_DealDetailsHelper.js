/**
 * Created by V. Kamenskyi on 19.07.2018.
 */
({
    handleInitActions : function(cmp, helper) {
        this.CalloutService = cmp.find('calloutService');
        this.Notifications = cmp.find('notificationsLib');
        this.NavigationService = cmp.find('navigationService');
        this.DialogBuilder = cmp.find('dialogBuilder');
        this.handlePageReference(cmp, cmp.get("v.pageReference"));
        helper.dispatchAction(cmp);
        cmp.set('v.isReady', false);
        helper.setDefaults(cmp);
        helper.getModel(cmp, helper);
    },

    handlePageReference : function (cmp, ref) {
        if (!cmp.get('v.recordId') && ref && ref.state) {
            if (ref.state.recordId) {
                cmp.set('v.recordId', ref.state.recordId);
            } else if (ref.state.sourceId) {
                cmp.set('v.sourceId', ref.state.sourceId);
            }
            cmp.set('v.sObjectName', 'EUR_CRM_Deal__c');
        }
    },

    dispatchAction : function (cmp) {
        if (cmp.get('v.sObjectName') && cmp.get('v.recordId')) {
            cmp.set('v.isUpdate', true);
        } else if (cmp.get('v.sObjectName')) {
            cmp.set('v.isCreate', true);
        }
    },

    getModel : function(cmp, helper) {
        var recordId = cmp.get('v.recordId');
        var sourceId = cmp.get('v.sourceId');
        this.CalloutService
            .runApex('getModel', {
                'recordId' : recordId || sourceId
            })
            .then($A.getCallback(result => {
                if(window.ActualCmp === cmp){
                    if (!recordId && sourceId && result.deal) {
                        let deal = result.deal;
                        deal['sobjectType'] = 'EUR_CRM_Deal__c';
                        deal['Id'] = null;
                        cmp.set('v.record', deal);
                    }
                    cmp.set('v.isReady', true);
                    helper.processModel(cmp, helper, result);
                }
            }))
            .catch($A.getCallback(error => {
                console.error(error)
            }));
    },

    processModel : function(cmp, helper, model) {
        if (!$A.util.isEmpty(model)) {
            cmp.set('v.model', model);
            if (!cmp.get('v.sourceId')) {
                cmp.set('v.record', model.deal.Id ? model.deal : helper.getDefaultDeal(model));
            }
            if (!cmp.get('v.recordId') && !cmp.get('v.sourceId')) {
                this.showOrderTypeDialog(cmp);
                return;
            }
            helper.presetDealConditions(cmp, model);
        }
    },

    presetDealConditions : function(cmp, model) {
        // console.log('model.discountTypes ' , model.discountTypes);
        if (!$A.util.isEmpty(model.discountTypes)) {
            model.discountTypes.forEach(type => {
                switch (type.id) {
                    case this._DISCOUNT_TYPES.DISCOUNT : this.createDiscountConditions(cmp, model); break;
                    case this._DISCOUNT_TYPES.FREE_PRODUCT : this.createFreeProductConditions(cmp, model); break;
                    case this._DISCOUNT_TYPES.FREE_POSM : this.createPOSMConditions(cmp, model); break;
                    default: console.log('Wrong available sections settings: ', type.id);
                }
            })
        }

    },

    createDiscountConditions : function(cmp, model) {
        this.CalloutService.createComponent('c:EUR_CRM_DealDiscountConditions', {
            'discountType' : this._DISCOUNT_TYPES.DISCOUNT,
            'deal' : cmp.get('v.record'),
            'conditionItems' : model.productsInDeal || [],
            'productLevelLookup' : 'EUR_CRM_' + model.productLevelByOrderType[cmp.get('v.record.EUR_CRM_OrderType__c')] + '__c',
            'parent' : cmp
        }).then(result => {
            cmp.set('v.discountConditions', result);
            // console.log('result discountType', JSON.stringify(result.get('v.discountType')));
            // console.log('result deal', JSON.stringify(result.get('v.deal')));
            // console.log('result conditionItems', result.get('v.conditionItems'));
            // console.log('result productLevelLookup', JSON.stringify(result.get('v.productLevelLookup')));
            // console.log('result parent', result.get('v.parent').get('v.discountConditions'));
            // console.log('cmp discountConditions', cmp.get('v.discountConditions'));

            result.set('v.visited', true);
        }).catch(error => {
            console.log('error on create deal conditions:', error);
        });
    },

    createFreeProductConditions : function(cmp, model) {

        this.CalloutService.createComponent('c:EUR_CRM_DealFreeProductConditions', {
            'discountType' : this._DISCOUNT_TYPES.FREE_PRODUCT,
            'deal' : cmp.get('v.record'),
            'conditionItems' : model.freeProductGroupings || [],
            'productLevelLookup' : 'EUR_CRM_' + model.productLevelByOrderType[cmp.get('v.record.EUR_CRM_OrderType__c')] + '__c',
            'parent' : cmp
        }).then(result => {
            // console.log('... FREE CONDITIONS c:DealConditions: v.freeProductGroupings', result.get('v.freeProductGroupings'));
            cmp.set('v.freeConditions', result);
        }).catch(error => {
            console.log('error on create deal conditions:', error);
        });
    },

    createPOSMConditions : function(cmp, model) {
        this.CalloutService.createComponent('c:EUR_CRM_DealPOSMConditions', {
            'discountType' : this._DISCOUNT_TYPES.FREE_POSM,
            'deal' : cmp.get('v.record'),
            'conditionItems' : model.posmGroupings || [],
            'parent' : cmp
        }).then(result => {
            // console.log('... FREE POSM CONDITIONS c:DealConditions: v.posmGroupings', result.get('v.posmGroupings'));
            cmp.set('v.posmConditions', result);
        }).catch(error => {
            console.log('error on create deal conditions:', error);
        });
    },

    handleControlAction : function (cmp, helper, src, validity) {
        switch (src) {
            case 'save' :
                if (this.validateConditions(cmp)) {
                    helper.saveDeal(cmp);
                }
                break;
            case 'clone' :
                this.cloneDeal(cmp);
                break;
            case 'delete' :
                this.deleteDeal(cmp);
                break;
            case 'cancel' :
                this.navigateToListView();
                break;
            case 'edit' :
                this.NavigationService.navigate({
                    'type': 'standard__component',
                    'attributes': {
                        'name': 'c:EUR_CRM_DealDetails' },
                    'state': {
                        'c__layoutType': 'edit',
                        'c__recordId': cmp.get("v.recordId")
                    }
                });
                break;
            case 'back' :
                window.history.back();
                break;
            default :
                cmp.set('v.validity', validity);
                break;
        }
    },

    saveDeal : function (cmp) {
        cmp.set('v.isReady', false);
        var viewModel = this.getDealViewModel(cmp);
        // console.log('viewModel ' + JSON.stringify(viewModel));
        this.CalloutService.runApex('doUpsert', {
            'view' : JSON.stringify(viewModel)
        }).then(result => {
            // console.log('>>> result on save: ', result);
            this.Notifications.showToast({
                'title' : 'Success!',
                'message' : 'The record has been successfully saved.',
                'variant' : 'success'
            });
                // console.log('JSON.parse(result) : ' + JSON.stringify(result));

            window.location.replace('/lightning/r/EUR_CRM_Deal__c/'+JSON.parse(result).id + '/view');
            // this.navigateToRecordPage(JSON.parse(result).id);

        }).catch(error => {
            console.log('>>> error on save: ', error);
            this.Notifications.showToast({
                'title' : 'Warning!',
                // 'message' : 'Something went wrong during saving the record.',
                'message' : error.message,
                'variant' : 'error'
            });
        }).finally(() => {
            cmp.set('v.isReady', true);
            cmp.set('v.isPerformingSaveAction', false);
        })

    },

    cloneDeal : function (cmp) {
        this.NavigationService.navigate({
            'type': 'standard__component',
            'attributes': {
                'componentName': 'c__EUR_CRM_DealDetails' },
            'state': {
                'sourceId': cmp.get('v.recordId')
            }
        });
    },

    deleteDeal  :function (cmp) {
        cmp.set('v.isReady', false);
        let recordId = cmp.get('v.recordId');
        if (recordId) {
            this.CalloutService.runApex('doDelete', {
                'recordId':cmp.get('v.recordId')
            })
                .then(result => {
                    this.processDeleteResult(cmp, result);
                })
                .catch(error => {
                    console.log('... error on delete:', error);
                    cmp.set('v.isReady', true);
                    this.Notifications.showToast({
                        'type' : 'warning',
                        'title' : $A.get('$Label.c.EUR_CRM_Warning'),
                        'message' : $A.get('$Label.c.EUR_CRM_Fail_On_Delete').replace('{0}', cmp.get('v.record.Name'))
                    });
                });
        }
    },

    processDeleteResult : function (cmp, result) {
        if (result && JSON.parse(result).success) {
            cmp.set('v.isReady', true);
            this.Notifications.showToast({
                'title' : $A.get('$Label.c.EUR_CRM_Success'),
                'message' : $A.get('$Label.c.EUR_CRM_Success_On_Delete').replace('{0}', cmp.get('v.record.Name')),
                'variant' : 'success'
            });
            this.navigateToListView();
        }
    },

    validateConditions : function (cmp) {
        var conditions = []
            .concat(cmp.get('v.discountConditions') || [])
            .concat(cmp.get('v.freeConditions') || [])
            .concat(cmp.get('v.posmConditions') || []);
        if (conditions.some(item => !item.validate())
            || !this.validateInputFields(cmp, true)
            || $A.util.isEmpty(cmp.get('v.discountConditions').get('v.conditionItems'))) {

            this.Notifications.showToast({
                'title' : $A.get('$Label.c.EUR_CRM_Warning') + '!',
                'message' : $A.get('$Label.c.EUR_CRM_failOnValidityCheck'),
                'variant' : 'warning'
            });
            return false;
        }
        return true;
    },

    getDealViewModel : function(cmp) {
        return {
            'deal' : this.getDeal(cmp),
            'productsInDeal' : cmp.get('v.discountConditions') == null ? null : cmp.get('v.discountConditions').get('v.visited')
                ? this.getProductsInDeal(cmp)
                : cmp.get('v.sourceId')
                    ? (cmp.get('v.model.productsInDeal') || []).map(item => { item.Id = null; return item; })
                    : null,
            'freeProductGroupings' : cmp.get('v.freeConditions') == null ? null : cmp.get('v.freeConditions').get('v.visited')
                ? this.getFreeProductGroupings(cmp)
                : cmp.get('v.sourceId')
                    ? (cmp.get('v.model.freeProductGroupings') || []).map(item => { item.Id = null; return item; })
                    : null,
            'posmGroupings' : cmp.get('v.posmConditions') == null ? null : cmp.get('v.posmConditions').get('v.visited')
                ? this.getPOSMGroupings(cmp)
                : cmp.get('v.sourceId')
                    ? (cmp.get('v.model.posmGroupings') || []).map(item => { item.Id = null; return item; })
                    : null,
        };
    },

    getDeal : function(cmp) {
        var result = cmp.get('v.record');
        var inputs = cmp.find('dealInputFields');
        if (inputs) {
            inputs.forEach(item => {
                result[item.get('v.fieldName')] = item.get('v.value');
            });
        }
        return result;
    },

    getProductsInDeal : function (cmp) {
        var result = [];
        var orderType = cmp.get('v.record.EUR_CRM_OrderType__c');
        var discountConditions = cmp.get('v.discountConditions');
        if (discountConditions) {
            var products = [].concat(discountConditions.find('sku') || []);
            var modelProductLevelTyOrderType = cmp.get('v.model').productLevelByOrderType;
            // var productRef = cmp.get('v.record.EUR_CRM_OrderType__c') === 'EUR_Direct' ? 'EUR_CRM_SKU__c' : 'EUR_CRM_BQS__c';
            var productRef = modelProductLevelTyOrderType[orderType] === 'SKU' ? 'EUR_CRM_SKU__c' : 'EUR_CRM_BQS__c';
            // console.log('modelProductLevelTyOrderType ' , JSON.stringify(modelProductLevelTyOrderType));
            // console.log('cmo.get(v.model ' , JSON.stringify(cmp.get('v.model')));
            // console.log('v.record.EUR_CRM_OrderType__c ' , cmp.get('v.record.EUR_CRM_OrderType__c'));
            // console.log('productRef ' , JSON.stringify(productRef));
            // console.log('v.record' , JSON.stringify(cmp.get('v.record')));
            // console.log('v.record.RecordType ' , JSON.stringify(cmp.get('v.record.RecordType')));
            // console.log('v.record.RecordType.DeveloperName ' , JSON.stringify(cmp.get('v.record.RecordType.DeveloperName')));
            var qtyArr = [].concat(discountConditions.find('quantity') || []);
            if (cmp.get('v.record.RecordType.DeveloperName') === 'EUR_Discount') {
                var dscArr = [].concat(discountConditions.find('discount') || []);
            }
            var editFormArr = [].concat(cmp.get('v.discountConditions').find('editForm') || []);
            editFormArr.forEach((form, pos) => {
                result.push({
                    'sobjectType' : 'EUR_CRM_Product_In_Deal__c',
                    'Id' : cmp.get('v.recordId') ? (form.get('v.recordId') || null) : null,
                    'EUR_CRM_AnimationID__c' : cmp.get('v.recordId') || null,
                    [productRef] : products[pos].get('v.value') || null,
                    'EUR_CRM_Quantity__c' : qtyArr[pos].get('v.value') || null,
                    'EUR_CRM_Discount__c' : dscArr ? (dscArr[pos].get('v.value') || null) : null,
                });
            });
        }
        // console.log('RESULT ' , JSON.stringify(result));
        return result;
    },

    getFreeProductGroupings : function (cmp) {
        var result = [];
        var orderType = cmp.get('v.record.EUR_CRM_OrderType__c');
        var freeConditions = cmp.get('v.freeConditions');
        // console.log('freeConditions ' , JSON.stringify(freeConditions));
        if (freeConditions) {
            var products = [].concat(freeConditions.find('sku') || []);
            var modelProductLevelTyOrderType = cmp.get('v.model').productLevelByOrderType;
            // console.log('products ' , JSON.stringify(products));
            // var productRef = cmp.get('v.record.EUR_CRM_OrderType__c') === 'EUR_Direct' ? 'EUR_CRM_SKU__c' : 'EUR_CRM_BQS__c';
            var productRef = modelProductLevelTyOrderType[orderType] === 'SKU' ? 'EUR_CRM_SKU__c' : 'EUR_CRM_BQS__c';
            var qtyArr = [].concat(freeConditions.find('quantity') || []);
            var editFormArr = [].concat(freeConditions.find('editForm') || []);
            editFormArr.forEach((form, pos) => {
                result.push({
                    'sobjectType' : 'EUR_CRM_ProductCatalogItemGrouping__c',
                    'Id' : cmp.get('v.recordId') ? (form.get('v.recordId') || null) : null,
                    'EUR_CRM_AnimationID__c' : cmp.get('v.recordId') || null,
                    [productRef] : products[pos].get('v.value') || null,
                    'EUR_CRM_Quantity__c' : qtyArr[pos].get('v.value') || null,
                });
            });
        }
        return result;
    },

    getPOSMGroupings : function (cmp) {
        var result = [];
        var posmConditions = cmp.get('v.posmConditions');
        if (posmConditions) {
            var posmArr = [].concat(posmConditions.find('posm') || []);
            var qtyArr = [].concat(posmConditions.find('quantity') || []);
            var editFormArr = [].concat(posmConditions.find('editForm') || []);
            editFormArr.forEach((form, pos) => {
                result.push({
                    'sobjectType' : 'EUR_CRM_ProductCatalogItemGrouping__c',
                    'Id' : cmp.get('v.recordId') ? (form.get('v.recordId') || null) : null,
                    'EUR_CRM_AnimationID__c' : cmp.get('v.recordId') || null,
                    'EUR_CRM_POS_Material__c' : posmArr[pos].get('v.value') || null,
                    'EUR_CRM_Quantity__c' : qtyArr[pos].get('v.value') || null,
                });
            });
        }
        return result;
    },

    setDefaults : function(cmp) {
        this._DISCOUNT_TYPES = {
            DISCOUNT : 'Discount',
            FREE_POSM : 'Free POSM',
            FREE_PRODUCT : 'Free Product'
        };
        this._SOBJECT_NAME = cmp.get('v.sObjectName');
        if ($A.util.isEmpty(cmp.get('v.validity'))) {
            cmp.set('v.validity', this.getDefaultValidity(cmp));
        }
        cmp.set('v.customDomain', window.location.host.substring(0, window.location.host.lastIndexOf('.lightning.force')));
        // console.log('customDomain ' , cmp.get('v.customDomain'));
    },

    getDefaultValidity : function (cmp) {
        return $A.util.isEmpty(cmp.get('v.validity'))
            ? {
                'isUpdatable': false,
                'isClonable' : true,
                'isRemovable' : false,
            }
            : cmp.get('v.validity');
    },

    getDefaultDeal : function (model) {
        var recordTypeId = this.getUrlParam('recordTypeId');
        // console.log('getDefaultDeal .model ' , JSON.stringify(model));
        // console.log('getDefaultDeal .model.dealRecordTypesByIds ' , JSON.stringify(model.dealRecordTypesByIds));
        // console.log('getDefaultDeal .model.deal.RecordTypeId ' , JSON.stringify(model.deal.RecordTypeId));
        // console.log('getDefaultDeal .model.deal ' , JSON.stringify(model.deal));
        if (recordTypeId && recordTypeId.length === 18) {
            recordTypeId = Object.keys(model.dealRecordTypesByIds).find(k => k.startsWith(recordTypeId));
            // console.log('getDefaultDeal .recordTypeId IF ' , JSON.stringify(recordTypeId));
        } else if (model && model.deal && model.deal.RecordTypeId) {
            recordTypeId = model.deal.RecordTypeId;
        } else if (model.dealRecordTypesByIds){
            // console.log('model.dealRecordTypesByIds ' , JSON.stringify(model.dealRecordTypesByIds));
            recordTypeId = model.dealRecordTypesByIds[Object.keys(model.dealRecordTypesByIds)[0]].Id;
        }
        // console.log('recordTypeId ' , JSON.stringify(recordTypeId));
        // console.log('model.dealRecordTypesByIds[recordTypeId] ' , JSON.stringify(model.dealRecordTypesByIds[recordTypeId]));
        return {
            'sobjectType' : 'EUR_CRM_Deal__c'
            , 'Name' : ''
            , 'EUR_CRM_Country__c' : model.currentUser.EUR_CRM_Affiliate_Code_Picklist__c.split(';')[0]
            , 'EUR_CRM_Objectives_Promotions__c' : null
            , 'EUR_CRM_Deal_logic__c' : 'AND'
            , 'RecordTypeId' : recordTypeId
            , 'RecordType' : model.dealRecordTypesByIds[recordTypeId]
            , 'EUR_CRM_OrderType__c' : model.picklistEntries.orderTypes['EUR_Direct']
        }
    },

    validateInputField : function(cmp, src, suppressWarning) {
        // console.log('... validate, field', src.get('v.fieldName'));
        // console.log('... validate, value', src.get('v.value'));
        // console.log('required => ', new Set(cmp.get('v.requiredFields')));
        var result = true;
        var value = src.get('v.value');
        var fieldName = src.get('v.fieldName');
        var required = new Set(cmp.get('v.requiredFields'));
        // console.log('!value && required.has(fieldName) => ' , !value && required.has(fieldName));
        // console.log('suppressWarning => ' , suppressWarning);
        // console.log('===========');
        if (src) {
            if (!value && required.has(fieldName)) {
                if (!suppressWarning) {
                    this.Notifications.showToast({
                        'title' : $A.get('$Label.c.EUR_CRM_Warning') + '!',
                        'message' : $A.get('$Label.c.EUR_CRM_failOnValidityCheck'),
                        'variant' : 'warning'
                    });
                }
                src.set('v.class', 'slds-has-error');
                result = false;
            } else {
                src.set('v.class', '');
            }
        }
        return result;
    },

    validateInputFields : function(cmp, suppressWarning) {
        var inputs = [].concat(cmp.find('dealInputFields') || []);
        var isValid = true;
        for (let i = 0; i < inputs.length; i++) {
            isValid = this.validateInputField(cmp, inputs[i], suppressWarning);
            if (!isValid) break;
        }
        cmp.set('v.validity.isUpdatable', isValid);
        return isValid;
    },

    setConditionsTabVisited : function (cmp, tabId) {
        switch (tabId) {
            case 'Discount' :
                if (cmp.get('v.discountConditions')) {
                    // console.log('VISITED');
                    cmp.get('v.discountConditions').set('v.visited', true);
                }
                break;
            case 'Free Product' :
                if (cmp.get('v.freeConditions')) {
                    cmp.get('v.freeConditions').set('v.visited', true);
                }
                break;
            case 'Free POSM' :
                if (cmp.get('v.posmConditions')) {
                    cmp.get('v.posmConditions').set('v.visited', true);
                }
                break;
        }
    },

    showOrderTypeDialog : function (cmp) {
        this.CalloutService.createComponent('lightning:combobox', {
            'name' : 'EUR_CRM_OrderType__c',
            'label' : cmp.get('v.model.labels.entities.EUR_CRM_Deal__c.fields.EUR_CRM_OrderType__c'),
            'type' : 'List',
            'placeholder' : $A.get('$Label.c.EUR_CRM_Select_Order_Type'),
            'options' : cmp.get('v.model.picklistEntries.orderTypes'),
            'onchange' : cmp.getReference('c.onOrderTypeSelect'),
            'required' : true,
            'class' : 'slds-p-bottom_xx-large slds-m-bottom_xx-large',
        }).then(result => {
            this.DialogBuilder.getInstance()
                .submitAction('Submit', () => {this.presetDealConditions(cmp, cmp.get('v.model'))}, {'disabled' : cmp.getReference('v.isOrderTypeEmpty')})
                .rejectAction('Cancel', () => {this.handleControlAction(cmp, this, 'cancel');})
                .header($A.get('$Label.c.EUR_CRM_Action_Required'))
                .body(result)
                .build().showModal();
        });

    },

    /**
     * Utility methods
     */

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

    getUrlParams : function () {
        return new Map(decodeURIComponent(location.search.substring(1)).split('&').map(param => param.split('=')))
            || new Map();
    },

    getUrlParam : function (key) {
        return this.getUrlParams().get(key);
    },

    /**
     *
     * @param filterName || 'Recent' by default
     * @param sObjectName || current sObjectName by default
     */
    navigateToListView : function (cmp, filterName, sObjectName) {
        this.NavigationService.navigate({
            'type': 'standard__objectPage',
            'attributes': {
                'objectApiName': sObjectName || this._SOBJECT_NAME,
                'actionName': 'list'
            },
            'state': {
                'filterName': filterName || 'Recent'
            }
        });
        cmp = null;
    },

    /**
     *
     * @param recordId
     * @param sObjectName || current sObjectName by default
     */
    navigateToRecordPage : function (recordId, sObjectName) {

        this.NavigationService.navigate({
            'type' : 'standard__recordPage',
            'attributes' : {
                'recordId' : recordId,
                'objectApiName' : sObjectName || this._SOBJECT_NAME,
                'actionName' : 'view'
            }
        });

    },

    /**
     * Constants
     */

    _DISCOUNT_TYPES : {},

    _SOBJECT_NAME : 'EUR_CRM_Deal__c'
})