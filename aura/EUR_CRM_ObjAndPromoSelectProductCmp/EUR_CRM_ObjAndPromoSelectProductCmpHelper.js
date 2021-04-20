({
    parentComponent: null,
    component: null,
    _constants: {
        serverSideActions: {
            getSelectedProductType : 'c.getSelectedProductType',
            getProductsOfBrand : 'c.getProductsOfBrand',
            getProductsOfBrandQuality : 'c.getProductsOfBrandQuality',
            getProductsOfBrandQualitySize : 'c.getProductsOfBrandQualitySize',
            getProductsOfSKU : 'c.getProductsOfSKU',
            getProductsOfPOSMaterials : 'c.getProductsOfPOSMaterials',
            getProductsOfProductToolkit : 'c.getProductsOfProductToolkit',
        },
        attributes: {
            recordId: 'v.recordId',
            selectedProductType: 'v.selectedProductType',
            products: 'v.products',
            selectedProductIds: 'v.selectedProductIds',
            savedProductIds: 'v.savedProductIds',
            isConfirmationButtonAvailable: 'v.isConfirmationButtonAvailable',
        },
        selectionProductTypes: {
            Brand: 'Brand',
            BrandQuality: 'Brand-Quality',
            BrandQualitySize: 'Brand-Quality-Size',
            SKU: 'SKU',
            POSMaterial: 'POS Material',
            ProductToolkit: 'Product Toolkit',
        },
        none: '--None--',
    },

    state: {},


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    onInitHandler: function (component) {
        this.component = component;
        this.parentComponent = this.component.get('v.parent');
    },


    /* ========================================================= */
    /*     Interactions
    /* ========================================================= */
    onChangeSelectedProductTypeHandler: function (component) {
        this.component = component;
        const selectedProductType = this._getSelectedProductType();

        if (selectedProductType === this._constants.none) {
            this._setProducts([]);
            return ;
        }

        if (selectedProductType === this._constants.selectionProductTypes.Brand) {
            this.downloadProductsOfBrand();
        } else if (selectedProductType === this._constants.selectionProductTypes.BrandQuality) {
            this.downloadProductsOfBrandQuality();
        } else if (selectedProductType === this._constants.selectionProductTypes.BrandQualitySize) {
            this.downloadProductsOfBrandQualitySize();
        } else if (selectedProductType === this._constants.selectionProductTypes.SKU) {
            this.downloadProductsOfSKU();
        }  else if (selectedProductType === this._constants.selectionProductTypes.POSMaterial) {
            this.downloadProductsOfPOSMaterials();
        } else if (selectedProductType === this._constants.selectionProductTypes.ProductToolkit) {
            this.downloadProductsOfProductToolkit();
        }
    },

    onChangeUserInputHandler: function (component, event) {
        this.component = component;
        const source = event.getSource();
        const inputValue = source.get('v.value');

        if ( ! inputValue) { this._setProducts(this.state.initialProducts); }

        const filteredProducts = this.state.initialProducts.filter(product => product.label.toLowerCase().indexOf(inputValue.toLowerCase()) > -1);
        const additionalProducts = this.state.initialProducts.filter(product => this._getSelectedProductIds().find(id => id === product.value));
        filteredProducts.push(...additionalProducts);

        if (this.state.initialProducts.find(product => product.label.toLowerCase().indexOf(inputValue.toLowerCase()) > -1)) {
            this._setProducts(filteredProducts);
        }
    },

    onChangeProductDualListBoxComponentHandler: function (component, event) {
        this.component = component;
        const selectedProductIds = event.getParam('value');
        const addedProductIds = selectedProductIds.filter(selectedId => !this._getSavedProductIds().includes(selectedId));
        this._setIsConfirmationButtonAvailable(addedProductIds.length > 0);
    },

    onClickRefreshHandler: function (component, event) {
        this.component = component;
        const selectedProductType = this._getSelectedProductType();
        this._setSelectedProductType(this._constants.none);
        this._setSelectedProductType(selectedProductType);
    },

    onClickConfirmHandler: function (component) {
        this.component = component;
        const selectedProductIds = this.component.find('productDualListBoxComponent').get('v.value');
        const addedProductIds = selectedProductIds.filter(selectedId => !this._getSavedProductIds().includes(selectedId));
        this.parentComponent.populateProductsWithManagersAndSalesRepsMethod(addedProductIds);
        this._setIsConfirmationButtonAvailable(false);
    },


    /* ========================================================= */
    /*     Server-Side Actions
    /* ========================================================= */
    downloadSelectedProductType: function () {
        const params = {
            recordId: this._getRecordId()
        };
        this.component.lax.enqueue(this._constants.serverSideActions.getSelectedProductType, params).then(productType => {
            this._setSelectedProductType(productType);
        });
    },

    downloadProductsOfBrand: function () {
        console.log('downloadProductsOfBrand()');
        this.parentComponent.showSpinnerMethod();
        this.component.lax.enqueue(this._constants.serverSideActions.getProductsOfBrand, { recordId: this._getRecordId() })
            .then(products => {
                console.log('products => ', products);
                this.setProducts(products);
                this.parentComponent.hideSpinnerMethod();
            });
    },

    downloadProductsOfBrandQuality: function () {
        this.parentComponent.showSpinnerMethod();
        this.component.lax.enqueue(this._constants.serverSideActions.getProductsOfBrandQuality, { recordId: this._getRecordId() })
            .then(products => {
                this.setProducts(products);
                this.parentComponent.hideSpinnerMethod();
            });
    },

    downloadProductsOfBrandQualitySize: function () {
        this.parentComponent.showSpinnerMethod();
        this.component.lax.enqueue(this._constants.serverSideActions.getProductsOfBrandQualitySize, { recordId: this._getRecordId() })
            .then(products => {
                this.setProducts(products);
                this.parentComponent.hideSpinnerMethod();
            });
    },

    downloadProductsOfSKU: function () {
        this.parentComponent.showSpinnerMethod();
        this.component.lax.enqueue(this._constants.serverSideActions.getProductsOfSKU, { recordId: this._getRecordId() })
            .then(products => {
                this.setProducts(products);
                this.parentComponent.hideSpinnerMethod();
            });
    },

    downloadProductsOfPOSMaterials: function () {
        this.parentComponent.showSpinnerMethod();
        this.component.lax.enqueue(this._constants.serverSideActions.getProductsOfPOSMaterials, { recordId: this._getRecordId() })
            .then(products => {
                this.setProducts(products);
                this.parentComponent.hideSpinnerMethod();
            });
    },

    downloadProductsOfProductToolkit: function () {
        this.parentComponent.showSpinnerMethod();
        this.component.lax.enqueue(this._constants.serverSideActions.getProductsOfProductToolkit, { recordId: this._getRecordId() })
            .then(products => {
                this.setProducts(products);
                this.parentComponent.hideSpinnerMethod();
            });
    },


    /* ========================================================= */
    /*     Server-Side Delegate Methods
    /* ========================================================= */
    setProducts: function (products) {
        console.log('setProducts()');
        this._setProducts(products);

        const selectedProductIds = products.filter(product => product.isSelected)
            .reduce((selectedProducts, product) => { selectedProducts.push(product.value); return selectedProducts; }, []);
        console.log('selectedProductIds => ', selectedProductIds);
        this._setSelectedProductIds(selectedProductIds);

        const savedProductIds = products.filter(product => product.hasTargetReps)
            .reduce((savedProducts, product) => { savedProducts.push(product.value); return savedProducts; }, []);
        console.log('savedProductIds => ', savedProductIds);
        this._setSavedProductIds(savedProductIds);

        this.state.initialProducts = products;

        const productsToConfirm = selectedProductIds.filter(el => ! savedProductIds.includes(el));
        console.log('productsToConfirm => ', productsToConfirm);
        this._setIsConfirmationButtonAvailable(productsToConfirm.length > 0);
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

    _getSelectedProductType: function () {
        return this.component.get(this._constants.attributes.selectedProductType);
    },

    _getSelectedProductIds: function () {
        return this.component.get(this._constants.attributes.selectedProductIds);
    },

    _getSavedProductIds: function (data) {
        return this.component.get(this._constants.attributes.savedProductIds, data);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setSelectedProductType: function (data) {
        this.component.set(this._constants.attributes.selectedProductType, data);
    },

    _setProducts: function (data) {
        this.component.set(this._constants.attributes.products, data);
    },

    _setSelectedProductIds: function (data) {
        this.component.set(this._constants.attributes.selectedProductIds, data);
    },

    _setSavedProductIds: function (data) {
        this.component.set(this._constants.attributes.savedProductIds, data);
    },

    _setIsConfirmationButtonAvailable: function (data) {
        this.component.set(this._constants.attributes.isConfirmationButtonAvailable, data);
    },

});