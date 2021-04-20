({
    component: null,
    parentComponent: null,

    _constants: {
        serverSideActions: {
            getSectionsToDisplay : 'c.getSectionsToDisplay',
            deletePromoTargets : 'c.deletePromoTargets',
            deleteTargetManagers : 'c.deleteTargetManagers',
            deleteTargetReps : 'c.deleteTargetReps',
            updateFormulaFields : 'c.updateFormulaFields',
        },
        attributes: {
            tabWidth: 'v.tabWidth',
            showGeneralLevel: 'v.showGeneralLevel',
            showManagerLevel: 'v.showManagerLevel',
            showSalesRepLevel: 'v.showSalesRepLevel',
            recordId: 'v.recordId',
            isEditable: 'v.isEditable',
            products: 'v.products',
            currentTopLevelTab: 'v.currentTopLevelTab',
            objectiveLevelIsValid: 'v.objectiveLevelIsValid',
            managerLevelIsValid: 'v.managerLevelIsValid',
            salesRepLevelIsValid: 'v.salesRepLevelIsValid',
        },
        sectionLevels: {
            generalLevel: 'General Level',
            managerLevel: 'Manager Level',
            salesRepLevel: 'Sales Representative Level'
        },
        sectionLabels: {
            generalTarget: 'General Target',
            managerTarget: 'Manager Target',
            salesRepTarget: 'Sales Rep. Target',
        },

        tabContainerId: 'tabContainerId',
    },

    state: {
        isConfirmed: false,
        areProductsInitialized: false
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    handleOnInit: function (component) {
        this.component = component;
        this.parentComponent = this.component.get('v.parent');

        const isEditable = this._getIsEditable();

        this._setObjectiveLevelIsValid( ! isEditable);
        this._setManagerLevelIsValid( ! isEditable);
        this._setSalesRepLevelIsValid( ! isEditable);

        this.downloadSectionsToDisplay();
    },

    downloadSectionsToDisplay: function () {
        const params = { recordId: this._getRecordId() };
        this.component.lax.enqueue(this._constants.serverSideActions.getSectionsToDisplay, params)
            .then(sectionsToDisplay => {
                this.setDisplayingLevels(sectionsToDisplay);
            });
    },

    setDisplayingLevels: function (sections) {
        const showGeneralLevel = this.isContains(sections, this._constants.sectionLevels.generalLevel);
        const showManagerLevel = this.isContains(sections, this._constants.sectionLevels.managerLevel);
        const showSalesRepLevel = this.isContains(sections, this._constants.sectionLevels.salesRepLevel);

        this._setShowGeneralLevel(showGeneralLevel);
        this._setShowManagerLevel(showManagerLevel);
        this._setShowSalesRepLevel(showSalesRepLevel);

        this.setInitialCurrentTopLevelTabDependingOnDisplaySection();
    },

    setInitialCurrentTopLevelTabDependingOnDisplaySection: function () {
        const showGeneralLevel = this._getShowGeneralLevel();
        const showManagerLevel = this._getShowManagerLevel();

        this._setCurrentTopLevelTab(
            showGeneralLevel ? this._constants.sectionLabels.generalTarget :
                showManagerLevel ? this._constants.sectionLabels.managerTarget :
                    this._constants.sectionLabels.salesRepTarget
        );
    },

    setTabWidth: function () {
        this._setTabWidth(this.component.find(this._constants.tabContainerId).getElement().clientWidth);
    },


    /* ========================================================= */
    /*     User's 'Manual' Event Handlers
    /* ========================================================= */
    handleOnClickTopLevelTab: function (component, event) {
        this.component = component;
        event.preventDefault();
        this._setCurrentTopLevelTab(event.target.name);
    },

    handleOnChangeFieldOnGeneralLevel: function (component, event) {
        this.component = component;

        const value = this.extractValue(event);
        const productId = event.target.name.split('.')[0];
        const fieldApiName = event.target.name.split('.')[1];

        let products = this._getProducts();

        products.find(product => product.productId === productId)
            .columnWrappers.find(cw => cw.fieldName === fieldApiName)
            .data = value;

        this._setProducts(products);
    },

    handleOnChangeFieldOnManagerLevel: function (component, event) {
        this.component = component;

        let value = this.extractValue(event);
        const productId = event.target.name.split('.')[0];
        const managerId = event.target.name.split('.')[1];
        const fieldApiName = event.target.name.split('.')[2];

        const products = this._getProducts();

        if (this._getShowGeneralLevel()) {
            value = this.validateValueOnManagerDependingOnGeneralData(products, value, productId, managerId, fieldApiName);
        }

        products.find(product => product.productId === productId)
            .managers.find(man => man.Id === managerId)
                .columnWrappers.find(cw => cw.fieldName === fieldApiName)
                .data = value;

        this._setProducts(products);
    },

    handleOnChangeFieldOnSalesRepLevel: function (component, event) {
        this.component = component;

        let value = this.extractValue(event);
        const productId = event.target.name.split('.')[0];
        const managerId = event.target.name.split('.')[1];
        const salesRepId = event.target.name.split('.')[2];
        const fieldApiName = event.target.name.split('.')[3];

        const products = this._getProducts();

        if (this._getShowGeneralLevel() || this._getShowManagerLevel()) {
            value = this.validateValueOnSalesRepDependingOnParentData(products, value, productId, managerId, salesRepId, fieldApiName);
        }

        products.find(product => product.productId === productId)
            .managers.find(man => man.Id === managerId)
            .salesReps.find(sr => sr.Id === salesRepId)
            .columnWrappers.find(cw => cw.fieldName === fieldApiName)
            .data = value;

        this._setProducts(products);
    },

    handleOnDeletePromoTarget: function (component, event) {
        event.preventDefault();

        const productId = event.target.name;

        let products = this._getProducts();
        const productToDelete = products.find(product => product.productId === productId);

        if (productToDelete.promoTarget.Id) {
            if(confirm('An OP Promo Target record will be deleted with all related OP Target Manger and OP Target REP records. Are you sure?')) {
                this.deleteOPPromoTarget(productToDelete.promoTarget.Id);
                this.refreshProductAndChildren(products.find(product => product.productId === productId));
                this._setProducts(products);
            }
        } else {
            if(confirm('Are you sure?')) {
                products = this.deleteProductFromList(products, productId);
                this._setProducts(products);
            }
        }
    },

    handleOnDeleteTargetManager: function (component, event) {
        event.preventDefault();

        const productId = event.target.name.split('.')[0];
        const targetManagerId = event.target.name.split('.')[1];

        if(confirm('An OP Target Manager record will be deleted with all related OP Target REP records. Are you sure?')) {
            this.deleteOPTargetManager(targetManagerId);

            const products = this._getProducts();
            this.refreshManagerAndSalesReps(
                products.find(product => product.productId === productId)
                    .managers.find(man => man.targetManager.Id === targetManagerId)
            );
            this.refreshProductIfNeed(products, productId);
            this._setProducts(products);
        }
    },

    handleOnDeleteTargetRep: function (component, event) {
        event.preventDefault();

        const productId = event.target.name.split('.')[0];
        const targetManagerId = event.target.name.split('.')[1];
        const targetRepId = event.target.name.split('.')[2];

        if(confirm('An OP Target Rep record will be deleted. Are you sure?')) {
            this.deleteOPTargetRep(targetRepId);

            const products = this._getProducts();
            this.refreshSalesRep(
                products.find(product => product.productId === productId)
                    .managers.find(man => man.targetManager.Id === targetManagerId)
                    .salesReps.find(sr => sr.targetSalesRep.Id === targetRepId)
            );
            this.refreshManagerIfNeed(products, productId, targetManagerId);
            this._setProducts(products);
        }
    },

    handleOnClickUpdateFormulas: function (component) {
        this.component = component;

        const params = { productWrapperAsJSON: JSON.stringify(this._getProducts()) };

        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.updateFormulaFields, params)
            .then(products => {
                if (this.isAllDataValid() && this.state.isConfirmed || this.state.areProductsInitialized) {
                    this.setConfirmedProducts(this.extractProductsForConfirmationPage(JSON.parse(JSON.stringify(products))));
                }
                this._setProducts(products);
                this.hideSpinner();
            });
    },

    handleOnClickConfirm: function (component) {
        this.component = component;

        if (this.isAllDataValid()) {
            const products = this._getProducts();
            this.setConfirmedProducts(this.extractProductsForConfirmationPage(JSON.parse(JSON.stringify(products))));
            this.state.isConfirmed = true;
        }
    },


    /* ========================================================= */
    /*     System's 'Automatic' Event Handlers
    /* ========================================================= */
    handleOnChangeProducts: function (component) {
        this.component = component;

        const showGeneralLevel = this._getShowGeneralLevel();
        const showManagerLevel = this._getShowManagerLevel();
        const showSalesRepLevel = this._getShowSalesRepLevel();

        const products = this._getProducts();
        this.calculateCountOfManagersWithSalesReps(products);
        this.calculateCountOfSalesReps(products);

        if (showGeneralLevel && showManagerLevel && showSalesRepLevel) {
            this.doValidationWhenAllTabsAreDisplaying(products);
        } else if (showGeneralLevel && showSalesRepLevel) {
            this.doValidationWhenGeneralAndSalesRepTabsAreDisplaying(products);
        } else if (showManagerLevel && showSalesRepLevel) {
            this.doValidationWhenManagerAndSalesRepTabsAreDisplaying(products);
        } else if (showSalesRepLevel) {
            this.doValidationWhenOnlySalesRepTabIsDisplaying(products);
        }

        this._setObjectiveLevelIsValid( ! showGeneralLevel || products.every(product => product.isValid));
        this._setManagerLevelIsValid( ! showManagerLevel || products.every(product => product.isValidOnManagerLevel));
        this._setSalesRepLevelIsValid( ! showSalesRepLevel || products.every(product => product.managers.every(man => man.isValidOnSalesRepLevel)));

        if ( ! this.state.areProductsInitialized) {
            this.state.areProductsInitialized = true;
            this.setConfirmedProducts(this.extractProductsForConfirmationPage(JSON.parse(JSON.stringify(products))));

        }
    },

    onChangeShowComponentBodyHandler: function (component, event) {
        this.component = component;
        this.setInitialCurrentTopLevelTabDependingOnDisplaySection();
    },


    /* ========================================================= */
    /*     Server Side Actions
    /* ========================================================= */
    deleteOPPromoTarget: function (opPromoTargetId) {
        const params = {
            promoTargetId: opPromoTargetId,
            recordId: this._getRecordId()
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.deletePromoTargets, params)
            .then(status => {
                this.hideSpinner();
            });
    },

    deleteOPTargetManager: function (targetManagerId) {
        const params = {
            targetManagerId: targetManagerId,
            recordId: this._getRecordId()
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.deleteTargetManagers, params)
            .then(status => {
                this.hideSpinner();
            });
    },

    deleteOPTargetRep: function (targetRepId) {
        const params = {
            targetRepId: targetRepId,
            recordId: this._getRecordId()
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.deleteTargetReps, params)
            .then(status => {
                this.hideSpinner();
            });
    },


    /* ========================================================= */
    /*     Validation Block (Sales Rep block is always displaying)
    /* ========================================================= */
    /* ========================================================= */
    /*    | General | Manager | Sales Rep |
    /* ========================================================= */
    doValidationWhenAllTabsAreDisplaying: function (products) {
        this.validateSalesRepFieldsDependingOnManagerData(products);
        this.validateSalesRepsDependingOnFields(products);

        this.validateManagerFieldsDependingOnGeneralData(products);
        this.validateManagersDependingOnFields(products);
        this.validateSalesRepsForEachManager(products);

        this.validateGeneralFieldsDependingOnGeneralData(products);
        this.validateProductsDependingOnFields(products);
        this.validateManagersForEachProduct(products);
    },

    /* ========================================================= */
    /*    | General | Sales Rep |
    /* ========================================================= */
    doValidationWhenGeneralAndSalesRepTabsAreDisplaying: function (products) {
        this.validateSalesRepFieldsDependingOnGeneralData(products);
        this.validateSalesRepsDependingOnFields(products);

        this.ignoreManagerFieldsValidation(products);
        this.validateManagersDependingOnFields(products);
        this.validateSalesRepsForEachManager(products);

        this.validateGeneralFieldsDependingOnGeneralData(products);
        this.validateProductsDependingOnFields(products);
        this.validateManagersForEachProduct(products);
    },

    /* ========================================================= */
    /*    | Manager | Sales Rep |
    /* ========================================================= */
    doValidationWhenManagerAndSalesRepTabsAreDisplaying: function (products) {
        this.validateSalesRepFieldsDependingOnManagerData(products);
        this.validateSalesRepsDependingOnFields(products);

        this.validateManagerFieldsDependingOnManagerData(products);
        this.validateManagersDependingOnFields(products);
        this.validateSalesRepsForEachManager(products);

        this.ignoreGeneralFieldsValidation(products);
        this.validateProductsDependingOnFields(products);
        this.validateManagersForEachProduct(products);
    },

    /* ========================================================= */
    /*    | Sales Rep |
    /* ========================================================= */
    doValidationWhenOnlySalesRepTabIsDisplaying: function (products) {
        this.validateSalesRepFieldsDependingOnSalesRepData(products);
        this.validateSalesRepsDependingOnFields(products);

        this.ignoreManagerFieldsValidation(products);
        this.validateManagersDependingOnFields(products);
        this.validateSalesRepsForEachManager(products);

        this.ignoreGeneralFieldsValidation(products);
        this.validateProductsDependingOnFields(products);
        this.validateManagersForEachProduct(products);
    },

    /* ========================================================= */
    /*     Field Validation Helpers
    /* ========================================================= */
    validateSalesRepFieldsDependingOnManagerData: function (products) {
        // column is valid only if the field sum on all SRs is equal to field's data on Manager Level.
        products.forEach(product => product
            .managers.forEach(manager => manager
                .salesReps.forEach(salesRep => salesRep
                    .columnWrappers.filter(cw => cw.editable).forEach(wrapper => wrapper.isValid =
                        Number.parseInt(manager.columnWrappers.find(cw => cw.fieldName === wrapper.fieldName).data) ===
                        manager.salesReps.reduce(
                            (sum, sr) => sum += Number.parseInt(sr.columnWrappers.find(cw => cw.fieldName === wrapper.fieldName).data)
                            , 0
                        )
                    )
                )
            )
        );
    },

    validateSalesRepFieldsDependingOnGeneralData: function (products) {
        // column is valid only if the field sum on all SRs is equal to field's data on General Level.
        products.forEach(product => product
            .managers.forEach(manager => manager
                .salesReps.forEach(salesRep => salesRep
                    .columnWrappers.filter(cw => cw.editable).forEach(wrapper => wrapper.isValid =
                        Number.parseInt(product.columnWrappers.find(cw => cw.fieldName === wrapper.fieldName).data) ===
                        product.managers.reduce(
                            (sumManager, man) => sumManager += man
                                .salesReps.reduce(
                                    (srSum, sr) => srSum += Number.parseInt(sr.columnWrappers.find(cw => cw.fieldName === wrapper.fieldName).data)
                                    , 0
                                )
                            , 0
                        )
                    )
                )
            )
        );
    },

    validateSalesRepFieldsDependingOnSalesRepData: function (products) {
        // column is valid only if the field's data is > 0 on at least one SR.
        products.forEach(product => product
            .managers.forEach(man => man
                .salesReps.forEach(sr => sr
                    .columnWrappers.filter(cw => cw.editable).forEach(cw => cw.isValid = Number.parseInt(cw.data) > 0)
                )
            )
        );

        // do the validation field by field:
        // field is valid only if at least one of the rows has a valid field in certain column.
        products.forEach(product => product
            .managers.forEach(man => man
                .salesReps.forEach(sr => sr
                    .columnWrappers.filter(wrapper => wrapper.editable).forEach(wrapper => wrapper.isValid =
                        products.some(product => product
                            .managers.some(man => man
                                .salesReps.some(sr => sr.columnWrappers.find(cw => cw.fieldName === wrapper.fieldName).isValid)
                            )
                        )
                    )
                )
            )
        );
    },

    validateManagerFieldsDependingOnGeneralData: function (products) {
        // column is valid only if the field sum on all Managers is equal to field's data on General Level
        products.forEach(product => product
            .managers.forEach(manager => manager
                .columnWrappers.filter(cw => cw.editable).forEach(wrapper => wrapper.isValid =
                    Number.parseInt(product.columnWrappers.find(cw => cw.fieldName === wrapper.fieldName).data) ===
                    product.managers.reduce(
                        (sum, man) => sum += Number.parseInt(man.columnWrappers.find(cw => cw.fieldName === wrapper.fieldName).data)
                        , 0
                    )
                )
            )
        );
    },

    validateManagerFieldsDependingOnManagerData: function (products) {
        // column is valid only if the field's data is > 0
        products.forEach(product => product
            .managers.forEach(manager => manager
                .columnWrappers.filter(cw => cw.editable).forEach(wrapper => wrapper.isValid = Number.parseInt(wrapper.data) > 0)
            )
        );

        // do the validation field by field:
        // field is valid only if at least one of the rows has a valid field in certain column.
        products.forEach(product => product
            .managers.forEach(man => man
                .columnWrappers.filter(wrapper => wrapper.editable).forEach(wrapper => wrapper.isValid =
                    products.some(product => product
                        .managers.some(man => man.columnWrappers.find(cw => cw.fieldName === wrapper.fieldName).isValid)
                    )
                )
            )
        );
    },

    ignoreManagerFieldsValidation: function (products) {
        // column is always valid
        products.forEach(product => product
            .managers.forEach(manager => manager
                .columnWrappers.filter(cw => cw.editable).forEach(wrapper => wrapper.isValid = true)
            )
        );
    },

    validateGeneralFieldsDependingOnGeneralData: function (products) {
        // column is valid only if the field's data is > 0
        products.forEach(product => product
            .columnWrappers.filter(cw => cw.editable).forEach(wrapper => wrapper.isValid = Number.parseInt(wrapper.data) > 0)
        );
    },

    ignoreGeneralFieldsValidation: function (products) {
        // column is always valid
        products.forEach(product => product
            .columnWrappers.filter(cw => cw.editable).forEach(wrapper => wrapper.isValid = true)
        );
    },

    /* ========================================================= */
    /*     Row Validation Helpers
    /* ========================================================= */
    validateSalesRepsDependingOnFields: function (products) {
        // do validation on each Sales Rep: SR is valid only if all Column Wrappers are valid
        products.forEach(product => product
            .managers.forEach(manager => manager
                .salesReps.forEach(salesRep => salesRep.isValid =
                    salesRep.columnWrappers.filter(cw => cw.editable).every(cw => cw.isValid)
                )
            )
        );
    },

    validateManagersDependingOnFields: function (products) {
        // do validation on each Manager: Manager is valid only if all Column Wrappers are valid
        products.forEach(product => product
            .managers.forEach(manager => manager.isValid =
                manager.columnWrappers.filter(cw => cw.editable).every(cw => cw.isValid)
            )
        );
    },

    validateSalesRepsForEachManager: function (products) {
        // do validation on each Manager about SRs' validation: all SRs should be valid
        products.forEach(product => product
            .managers.forEach(manager => manager.isValidOnSalesRepLevel =
                manager.salesReps.every(sr => sr.isValid)
            )
        );
    },

    validateProductsDependingOnFields: function (products) {
        // do validation on each Product: all fields should be valid
        products.forEach(product => product.isValid = product.columnWrappers.filter(cw => cw.editable).every(cw => cw.isValid));
    },

    validateManagersForEachProduct: function (products) {
        // do validation on each Product about Manager's validation: all Managers should be valid
        products.forEach(product => product.isValidOnManagerLevel = product.managers.every(man => man.isValid));
    },
    /* ========================================================= */
    /*     End Validation Block
    /* ========================================================= */


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    validateValueOnManagerDependingOnGeneralData: function (products, value, productId, managerId, fieldApiName) {
        // generalMax - the data on General Level for certain field.
        const generalMax = Number.parseInt(products.find(product => product.productId === productId)
            .columnWrappers.find(cw => cw.fieldName === fieldApiName).data);

        // managersSum - the sum of certain fields of all Managers (of certain column)
        const managersSum = products.find(product => product.productId === productId)
            .managers.filter(man => man.Id !== managerId)
            .reduce((sum, man) => sum += Number.parseInt(man.columnWrappers.find(cw => cw.fieldName === fieldApiName).data), 0);

        // possibleMax - the maximum value of data that can be input by user
        const possibleMax = generalMax - managersSum;

        // if current value > possibleMax - return possibleMax, otherwise return the current value
        return value > possibleMax ? possibleMax : value;
    },

    validateValueOnSalesRepDependingOnParentData: function (products, value, productId, managerId, salesRepId, fieldApiName) {
        // generalMax - the data on General Level for certain field.
        const generalMax = Number.parseInt(products.find(product => product.productId === productId)
            .columnWrappers.find(cw => cw.fieldName === fieldApiName).data);

        // managersSum - the sum of certain fields of all Managers (of certain column)
        const managerMax = Number.parseInt(products.find(product => product.productId === productId)
            .managers.find(man => man.Id === managerId)
            .columnWrappers.find(cw => cw.fieldName === fieldApiName).data);

        // if the Manager Target section if shown - set parentMap as managerMax, otherwise - generalMax
        const parentMax = this._getShowManagerLevel() ? managerMax : generalMax;

        // salesRepsSum - the sum of certain fields of all Sales Reps (of certain column)
        let salesRepsSum = 0;
        if (this._getShowManagerLevel()) {
            // collect data from Sales Reps under specified Manager
            salesRepsSum = products.find(product => product.productId === productId)
                .managers.find(man => man.Id === managerId).salesReps.filter(sr => sr.Id !== salesRepId)
                    .reduce((srSum, sr) => srSum += Number.parseInt(sr.columnWrappers.find(cw => cw.fieldName === fieldApiName).data), 0);
        } else {
            // collect data from Sales Reps under the whole Product (under all Managers)
            salesRepsSum = products.find(product => product.productId === productId)
                .managers.reduce(
                (managerSum, man) => managerSum += man.salesReps.filter(sr => sr.Id !== salesRepId)
                    .reduce((srSum, sr) => srSum += Number.parseInt(sr.columnWrappers.find(cw => cw.fieldName === fieldApiName).data), 0)
                , 0
            );
        }

        // possibleMax - the maximum value of data that can be input by user
        const possibleMax = parentMax - salesRepsSum;

        // if current value > possibleMax - return possibleMax, otherwise return the current value
        return value > possibleMax ? possibleMax : value;
    },

    extractProductsForConfirmationPage: function (products) {
        this.filterNonEmptySalesReps(products);

        if (this._getShowManagerLevel()) {
            this.filterNonEmptyManagers(products);
        } else {
            this.filterNonEmptyManagersOrWithNonEmptySalesReps(products);
        }

        this.calculateCountOfManagersWithSalesReps(products);
        this.calculateCountOfSalesReps(products);
        return products;
    },

    filterNonEmptySalesReps: function (products) {
        // do filtering of Sales Reps:
        // 1. has targetSalesRep.Id
        // OR
        // 2. has a non empty column's value
        products.forEach(product => product
            .managers.forEach(man => man.salesReps = man
                .salesReps.filter(sr => sr.targetSalesRep && sr.targetSalesRep.Id
                    || sr.columnWrappers.filter(cw => cw.editable).some(cw => Number.parseInt(cw.data))
                )
            )
        );
    },

    filterNonEmptyManagers: function (products) {
        // do filtering of Managers:
        // 1. has targetManager.Id
        // OR
        // 2. has a non empty column's value
        products.forEach(product => product.managers = product
            .managers.filter(man => man.targetManager && man.targetManager.Id
                || man.columnWrappers.filter(cw => cw.editable).some(cw => Number.parseInt(cw.data)))
        );
    },

    filterNonEmptyManagersOrWithNonEmptySalesReps: function (products) {
        // do filtering of Managers:
        // 1. has targetManager.Id
        // OR
        // 2. has Sales Reps that:
        //      1. has targetSalesRep.Id
        //      OR
        //      2. has a non empty column's value
        products.forEach(product => product.managers = product
            .managers.filter(man => man.targetManager && man.targetManager.Id
                || man.salesReps.some(sr => sr.targetSalesRep && sr.targetSalesRep.Id
                    || sr.columnWrappers.filter(cw => cw.editable).some(cw => Number.parseInt(cw.data)))
            )
        );
    },


    /* ========================================================= */
    /*     Start Refresh Block
    /* ========================================================= */
    refreshManagerIfNeed: function (products, productId, targetManagerId) {
        const hasValidSalesReps = products.find(product => product.productId === productId)
            .managers.find(man => man.targetManager.Id === targetManagerId)
            .salesReps.some(sr => sr
                .columnWrappers.filter(cw => cw.editable).some(cw => Number.parseInt(cw.data)));

        if ( ! hasValidSalesReps) {
            this.refreshManager(
                products.find(product => product.productId === productId)
                    .managers.find(man => man.targetManager.Id === targetManagerId)
            );

            this.refreshProductIfNeed(products, productId);
        }
    },

    refreshProductIfNeed: function (products, productId) {
        const hasValidManagers = products.find(product => product.productId === productId)
            .managers.some(man => man
                .columnWrappers.filter(cw => cw.editable).some(cw => Number.parseInt(cw.data)));

        if ( ! hasValidManagers) {
            this.refreshProduct(products.find(product => product.productId === productId));
            if (this._getShowGeneralLevel()) {
                this._setCurrentTopLevelTab(this._constants.sectionLabels.generalTarget);
            }
        } else {
            this._setCurrentTopLevelTab(this._constants.sectionLabels.managerTarget);
        }
    },

    refreshProductAndChildren: function (product) {
        this.refreshProduct(product);

        product.managers.forEach(man => this.refreshManagerAndSalesReps(man));
    },

    deleteProductFromList: function (products, productId) {
        products = products.filter(product => product.productId !== productId);
        return products;
    },

    refreshManagerAndSalesReps: function (man) {
        this.refreshManager(man);

        man.salesReps.forEach(sr => this.refreshSalesRep(sr));
    },

    refreshProduct: function (product) {
        product.isValid = false;
        product.isValidOnManagerLevel = false;
        delete product.product.Id;
        product.promoTarget = {};
        product.targetSalesRep = {};
        this.refreshColumnWrappers(product.columnWrappers);
    },

    refreshManager: function (man) {
        man.isValid = false;
        man.isValidOnSalesRepLevel = false;
        man.targetManager = {};
        man.targetSalesRep = {};

        this.refreshColumnWrappers(man.columnWrappers);
    },

    refreshSalesRep: function (sr) {
        sr.isValid = false;
        sr.targetSalesRep = {};

        this.refreshColumnWrappers(sr.columnWrappers);
    },

    refreshColumnWrappers: function (columnWrappers) {
        columnWrappers.forEach(cw => this.refreshColumnWrapper(cw));
    },

    refreshColumnWrapper: function (cw) {
        cw.data = 0;
        cw.isValid = 0;
    },
    /* ========================================================= */
    /*     End Refresh Block
    /* ========================================================= */


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    isContains: function (string, subString) {
        return string.indexOf(subString) !== -1;
    },

    extractValue: function (event) {
        let value = Number.parseInt(event.target.value);
        value = value > 0 ? value : 0;
        return value;
    },

    calculateCountOfManagersWithSalesReps: function (products) {
        products.forEach(product => product.countOfManagersWithSalesReps = product.managers.reduce((sum, manager) => sum + (manager.salesReps.length ? 1 : 0), 0));
    },

    calculateCountOfSalesReps: function (products) {
        products.forEach(product => product.countOfSalesReps = product.managers.reduce((sum, manager) => sum + manager.salesReps.length, 0));
    },

    showSpinner: function () {
        this.parentComponent.showSpinnerMethod();
    },

    hideSpinner: function () {
        this.parentComponent.hideSpinnerMethod();
    },

    isAllDataValid: function () {
        return this._getObjectiveLevelIsValid()
            && this._getManagerLevelIsValid()
            && this._getSalesRepLevelIsValid()
        ;
    },


    /* ========================================================= */
    /*     Component Communication
    /* ========================================================= */
    setConfirmedProducts: function (records) {
        this.parentComponent.setConfirmedProductsMethod(records);
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    _getRecordId: function () {
        return this.component.get(this._constants.attributes.recordId);
    },

    _getIsEditable: function () {
        return this.component.get(this._constants.attributes.isEditable);
    },

    _getProducts: function () {
        return this.component.get(this._constants.attributes.products);
    },

    _getShowGeneralLevel: function () {
        return this.component.get(this._constants.attributes.showGeneralLevel);
    },

    _getShowManagerLevel: function () {
        return this.component.get(this._constants.attributes.showManagerLevel);
    },

    _getShowSalesRepLevel: function () {
        return this.component.get(this._constants.attributes.showSalesRepLevel);
    },

    _getObjectiveLevelIsValid: function () {
        return this.component.get(this._constants.attributes.objectiveLevelIsValid);
    },

    _getManagerLevelIsValid: function () {
        return this.component.get(this._constants.attributes.managerLevelIsValid);
    },

    _getSalesRepLevelIsValid: function () {
        return this.component.get(this._constants.attributes.salesRepLevelIsValid);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setTabWidth: function (data) {
        this.component.set(this._constants.attributes.tabWidth, data);
    },

    _setProducts: function (data) {
        this.component.set(this._constants.attributes.products, data);
    },

    _setCurrentTopLevelTab: function (data) {
        this.component.set(this._constants.attributes.currentTopLevelTab, data);
    },

    _setShowGeneralLevel: function (data) {
        this.component.set(this._constants.attributes.showGeneralLevel, data);
    },

    _setShowManagerLevel: function (data) {
        this.component.set(this._constants.attributes.showManagerLevel, data);
    },

    _setShowSalesRepLevel: function (data) {
        this.component.set(this._constants.attributes.showSalesRepLevel, data);
    },

    _setObjectiveLevelIsValid: function (data) {
        this.component.set(this._constants.attributes.objectiveLevelIsValid, data);
    },

    _setManagerLevelIsValid: function (data) {
        this.component.set(this._constants.attributes.managerLevelIsValid, data);
    },

    _setSalesRepLevelIsValid: function (data) {
        this.component.set(this._constants.attributes.salesRepLevelIsValid, data);
    },

});