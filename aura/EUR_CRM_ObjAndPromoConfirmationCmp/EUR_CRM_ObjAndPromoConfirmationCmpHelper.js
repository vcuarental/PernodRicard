({
    parentComponent: null,
    component: null,

    _constants: {
        serverSideActions: {
            getOPTemplateWithOPActions: 'c.getOPTemplateWithOPActions',
            getAccountTargetGroupWithRelatedAccounts: 'c.getAccountTargetGroupWithRelatedAccounts',
            deleteProductWithRelated: 'c.deleteProductWithRelated'
        },
        attributes: {
            parent: 'v.parent',
            recordId: 'v.recordId',
            opTemplateWithOPActions: 'v.opTemplateWithOPActions',
            opActionColumns: 'v.opActionColumns',
            accountTargetGroup: 'v.accountTargetGroup',
            accountTargetGroupAccountColumns: 'v.accountTargetGroupAccountColumns',
            products: 'v.products',
            productColumns: 'v.productColumns',
            isSaveButtonAvailable: 'v.isSaveButtonAvailable',
        },
        opActionColumns: [
            { label: 'Name', fieldName: 'Name', type: 'text' },
            { label: 'Stage', fieldName: 'EUR_CRM_Stage__c', type: 'text' },
            { label: 'Step Order', fieldName: 'EUR_CRM_Step_Order__c', type: 'number' },
            { label: 'Reoccuring Type', fieldName: 'EUR_CRM_Reoccuring_Type__c', type: 'text' },
        ],
        accountTargetGroupAccountColumns: [
            { label: 'Name', fieldName: 'Name', type: 'text' },
        ],
        productColumns: [
            { label: 'Name', fieldName: 'productName', type: 'text' },
        ],
    },

    state: {
        areProductsInitialized: false,
        isGroupInitialized: false
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    handleOnInit: function (component) {
        this.Notifications = component.find('notificationsLib');
        this.component = component;
        this.parentComponent = this.component.get('v.parent');

        this._setOpActionColumns();
        this._setAccountTargetGroupAccountColumns();
        this._setProductColumns();

        this.downloadOPTemplateWithOPActionsHandler();
        this.downloadAccountTargetGroupWithRelatedAccounts();
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    handleOnClickSave: function (event) {
        const products = this._getProducts();
        const accountTargetGroup = this._getAccountTargetGroup();

        this.parentComponent.confirmationSaveMethod({
            accountTargetGroup: accountTargetGroup,
            products: products
        });

        this._setIsSaveButtonAvailable(false);
    },

    onChangeProductsHandler: function () {
        if ( ! this.state.areProductsInitialized) {
            this.state.areProductsInitialized = true;
        } else {
            this._setIsSaveButtonAvailable(true);
        }
    },

    onChangeAccountTargetGroupHandler: function () {
        if ( ! this.state.isGroupInitialized) {
            this.state.isGroupInitialized = true;
        } else {
            this._setIsSaveButtonAvailable(true);
        }
    },

    handleOnDeleteProduct : function(conponent, event) {
        const productId = event.target.name;
        if(confirm('An OP Promo Target record will be deleted with all related OP Target, OP Target Manger and OP Target REP records. Are you sure?')) {
            this.deleteProduct(productId);
        }
    },


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    showSpinner: function () {
        this.parentComponent.showSpinnerMethod();
    },

    hideSpinner: function () {
        this.parentComponent.hideSpinnerMethod();
    },
    
    
    /* ========================================================= */
    /*     Server-Side Actions
    /* ========================================================= */
    downloadOPTemplateWithOPActionsHandler: function () {
        const params = { recordId: this._getRecordId() };
        this.component.lax.enqueue(this._constants.serverSideActions.getOPTemplateWithOPActions, params)
            .then(opTemplateWithOPActions => {
                if ($A.util.isEmpty(opTemplateWithOPActions)) {
                    this.Notifications.showToast({
                        'variant': 'warning',
                        'mode': 'sticky',
                        'title' : $A.get('$Label.c.EUR_CRM_Warning'),
                        'message' : $A.get('$Label.c.EUR_CRM_Select_OP_Template')
                    });
                }

                this._setOpTemplateWithOPActions(opTemplateWithOPActions);
            });
    },

    downloadAccountTargetGroupWithRelatedAccounts: function () {
        const params = { recordId: this._getRecordId() };
        this.component.lax.enqueue(this._constants.serverSideActions.getAccountTargetGroupWithRelatedAccounts, params)
            .then(accountTargetGroupWithRelatedAccounts => {
                this._setAccountTargetGroup(accountTargetGroupWithRelatedAccounts);
            });
    },

    deleteProduct: function (productId) {
        const params = {
            productId: productId
            , opId: this._getRecordId()
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.deleteProductWithRelated, params)
            .then(status => {
                this.hideSpinner();
            });
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    _getRecordId: function () {
        return this.component.get(this._constants.attributes.recordId);
    },

    _getProducts: function () {
        return this.component.get(this._constants.attributes.products);
    },

    _getAccountTargetGroup: function () {
        return this.component.get(this._constants.attributes.accountTargetGroup);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setOpActionColumns: function () {
        this.component.set(this._constants.attributes.opActionColumns, this._constants.opActionColumns);
    },

    _setAccountTargetGroupAccountColumns: function () {
        this.component.set(this._constants.attributes.accountTargetGroupAccountColumns, this._constants.accountTargetGroupAccountColumns);
    },

    _setAccountTargetGroup: function (data) {
        this.component.set(this._constants.attributes.accountTargetGroup, data);
    },

    _setProductColumns: function () {
        this.component.set(this._constants.attributes.productColumns, this._constants.productColumns);
    },

    _setOpTemplateWithOPActions: function (data) {
        this.component.set(this._constants.attributes.opTemplateWithOPActions, data);
    },

    _setIsSaveButtonAvailable: function (data) {
        this.component.set(this._constants.attributes.isSaveButtonAvailable, data);
    },

});