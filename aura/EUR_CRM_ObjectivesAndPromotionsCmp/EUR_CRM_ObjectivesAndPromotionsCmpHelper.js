({
    component: null,

    _constants: {
        serverSideActions: {
            getInitialTargets : 'c.getInitialTargets',
            getProductsWithManagersAndSalesReps : 'c.getProductsWithManagersAndSalesReps',
            saveData : 'c.saveData',
        },
        attributes: {
            recordId: 'v.recordId',
            simpleRecord: 'v.simpleRecord',
            isShownSpinner: 'v.isShownSpinner',
            currentTopLevelTab: 'v.currentTopLevelTab',
            productsWithUserHierarchy: 'v.productsWithUserHierarchy',
            simpleTemplate: 'v.simpleTemplate',
        },
        tabs: {
            AccountSelection: 'AccountSelection',
            ProductSelection: 'ProductSelection',
            TargetManagement: 'TargetManagement',
            Confirmation: 'Confirmation',
        },
        childComponents: {
            ObjAndPromoConfirmationCmp: {
                auraId: 'EUR_CRM_ObjAndPromoConfirmationCmp',
                params: {
                    products: 'v.products',
                    accountTargetGroup: 'v.accountTargetGroup',
                }
            },
            ObjAndPromoSelectProductCmp: {
                auraId: 'EUR_CRM_ObjAndPromoSelectProductCmp'
            },
            ObjAndPromoTargetManagementCmp: {
                auraId: 'EUR_CRM_ObjAndPromoTargetManagementCmp'
            }
        }
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    handleOnInit: function (component) {
        this.component = component;
    },

    onRecordLoadedHandler: function (component) {
        const simpleRecord = this._getSimpleRecord();

        component.find('templateLoader').reloadRecord();

        const redirectTo = simpleRecord.EUR_CRM_Status__c === 'Draft' ? null : this._constants.tabs.Confirmation;

        this.getInitialProductsWithManagersAndSalesRepsHandler(redirectTo);
    },

    getInitialProductsWithManagersAndSalesRepsHandler: function (redirectTo) {
        const params = { recordId: this._getRecordId() };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getInitialTargets, params)
            .then(products => {
                this._setProductsWithUserHierarchy(products);
                redirectTo ? this._setCurrentTopLevelTab(redirectTo) : undefined;
                this.hideSpinner();
            });
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    handleOnClickTopLevelTab: function (event) {
        event.preventDefault();
        this._setCurrentTopLevelTab(event.target.name);
    },


    /* ========================================================= */
    /*     Server-Side Actions
    /* ========================================================= */
    saveData: function (data) {
        const params = {
            data: JSON.stringify(data),
            recordId: this._getRecordId()
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.saveData, params)
            .then(status => {
                this.getInitialProductsWithManagersAndSalesRepsHandler();
                this.component.find(this._constants.childComponents.ObjAndPromoSelectProductCmp.auraId).refreshProductListMethod();
            })
            .catch(errors => {
                console.error(errors);

                const messages = this.extractFieldErrorMessages(errors.entries[0].fieldErrors);
                console.log('messages => ', messages);

                this.hideSpinner();
                this.component.showToastMethod('error', 'Error: Saving process.', messages);
            });;
    },

    getProductsWithManagersAndSalesReps: function (component, event) {
        this.component = component;

        const productIds = event.getParam('arguments').productIds;
        if ( ! productIds || ! productIds.length) {
            this.component.showToastMethod('error', 'Error: Products.', 'Products are not specified!');
            return;
        }

        const accountTargetGroup = this.component.find(this._constants.childComponents.ObjAndPromoConfirmationCmp.auraId)
            .get(this._constants.childComponents.ObjAndPromoConfirmationCmp.params.accountTargetGroup);
        if ( ! accountTargetGroup) {
            this.component.showToastMethod('error', 'Error: Account Target Group.', 'Account Target Group is not specified!');
            return;
        }

        const accountsInGroup = accountTargetGroup.accountsInGroup;
        if ( ! accountsInGroup || ! accountsInGroup.length) {
            this.component.showToastMethod('error', 'Error: Accounts in the Account Target Group.', 'There are no Accounts in the specified Account Target Group!');
            return;
        }

        const products = this._getProductsWithUserHierarchy();
        const productIdsFinal = productIds.filter(id => ! products.find(product => product.productId === id));

        const params = {
            productWrapperAsJSON: JSON.stringify(products),
            productIdsJSON: JSON.stringify(productIdsFinal),
            recordId: this._getRecordId(),
            accountIdsAsJSON: JSON.stringify(accountsInGroup.map(accInGroup => accInGroup.Id))
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getProductsWithManagersAndSalesReps, params)
            .then(products => {
                let template = component.get(this._constants.attributes.simpleTemplate);
                if (!template.EUR_CRM_Has_Target__c) {
                    this.component.find(this._constants.childComponents.ObjAndPromoTargetManagementCmp.auraId).confirmationWithoutTargetMethod(products);
                }

                this._setProductsWithUserHierarchy(products);
                this.hideSpinner();
            });
    },


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    hideSpinner: function () {
        this._setIsShownSpinner(false);
    },

    showSpinner: function () {
        this._setIsShownSpinner(true);
    },

    extractFieldErrorMessages: function (fieldErrors) {
        let message = '';
        for(let key in fieldErrors) {
            // message += key + ' (' + fieldErrors[key][0].statusCode + '): ' + fieldErrors[key][0].message;
            message += fieldErrors[key][0].message;
        }
        return message;
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    _getRecordId: function () {
        return this.component.get(this._constants.attributes.recordId);
    },

    _getSimpleRecord: function () {
        return this.component.get(this._constants.attributes.simpleRecord);
    },

    _getProductsWithUserHierarchy: function () {
        return this.component.get(this._constants.attributes.productsWithUserHierarchy);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setIsShownSpinner: function (data) {
        this.component.set(this._constants.attributes.isShownSpinner, data)
    },

    _setCurrentTopLevelTab: function (data) {
        this.component.set(this._constants.attributes.currentTopLevelTab, data);
    },

    _setProductsWithUserHierarchy: function (data) {
        this.component.set(this._constants.attributes.productsWithUserHierarchy, data);
    },

});