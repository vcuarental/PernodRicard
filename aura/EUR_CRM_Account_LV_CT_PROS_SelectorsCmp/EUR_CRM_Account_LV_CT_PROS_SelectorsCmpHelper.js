({
    component : null,
    _constants: {
        events: {
            SelectionMethodIsChangedEvent: 'SelectionMethodIsChangedEvent',
            ShowHideComponentEvent: 'ShowHideComponentEvent',
            SendQuery: 'SendQuery'
        },
        serverSideActions: {
            getSelectionMethods: 'c.getSelectionMethodOptions',
            getAccountListViews: 'c.getAccountListViewOptions',
            getCustomerTaxonomies: 'c.getCustomerTaxonomyOptions',
            getPROSTable : 'c.getPROSTable',
            getPROFS : 'c.getPROFS',
        },
        attributes: {
            selectionMethods: 'v.selectionMethods',
            selectionMethod: 'v.selectionMethod',
            listViews: 'v.listViews',
            listView: 'v.listView',
            customerTaxonomies: 'v.customerTaxonomies',
            customerTaxonomy: 'v.customerTaxonomy',
            pros: 'v.pros',
            profs: 'v.profs',
            profsColumns: 'v.profsColumns',
            prosTableWidth: 'v.prosTableWidth',
        },
        selectionMethods: {
            listView: 'Account list views',
            customerTaxonomy: 'Customer taxonomy',
            pros: 'PROS',
            profs: 'PROFS',
        },
        none: '--None--',
        tabContainerId: 'tabContainerId',
        auraIds: {
            imageLevelCheckboxes: 'imageLevelCheckboxes',
            customerTaxonomy: 'customerTaxonomy',
            listView: 'listView',
        },
        profsColumns: [
            { label: 'Name', fieldName: 'Name', type: 'text'},
        ],
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    handleOnInit: function (component) {
        this.component = component;

        this.downloadSelectionMethods();
        this._setProfsColumns(this._constants.profsColumns);
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    handleOnRecordsAreSelectedEvent: function (event) {
        const typeOfRecords = event.getParam('typeOfRecords');
        const records = event.getParam('records');

        if (typeOfRecords === this._constants.selectionMethods.profs) {
            this.fireEventToDownloadAccountsOfProfs(records);
        }
    },


    /* ========================================================= */
    /*     Interaction
    /* ========================================================= */
    handleOnChangedSelectionMethod: function () {
        let selectionMethod = this._getSelectionMethod();

        this.resetAccounts();

        if (selectionMethod === this._constants.none) {
            this.resetFilters();
        } else if (selectionMethod === this._constants.selectionMethods.listView) {
            this._setCustomerTaxonomy(this._constants.none);

            if (this.isEmptyListViews()) {
                this.downloadAccountListViews();
            }
        } else if (selectionMethod === this._constants.selectionMethods.customerTaxonomy) {
            this._setListView(this._constants.none);

            if (this.isEmptyCustomerTaxonomies()) {
                this.downloadCustomerTaxonomies();
            }
        } else if (selectionMethod === this._constants.selectionMethods.pros) {
            this.resetFilters();

            if (this.isEmptyPros()) {
                this.downloadPros();
            }
        } else if (selectionMethod === this._constants.selectionMethods.profs) {
            this.resetFilters();

            if (this.isEmptyProfs()) {
                this.downloadProfs();
            }
        }
    },

    handleOnChangedListView: function () {
        let listView = this._getListView();
        if (listView === this._constants.none) {
            this.resetAccounts();
            return ;
        }

        this.fireEventToDownloadAccountsOfListView(listView);
    },

    handleOnChangedCustomerTaxonomy: function () {
        let customerTaxonomy = this._getCustomerTaxonomy();

        if (customerTaxonomy === this._constants.none) {
            this.resetAccounts();
            return ;
        }

        this.fireEventToDownloadAccountsOfCustomerTaxonomy(customerTaxonomy);
    },

    handleOnChangedImageLevel: function (component,event) {
        let target = event.getSource();
        let imageLevel = target.get('v.text');
        let value = target.get('v.value');

        let pros = this._getPros();
        pros.forEach(p => p.imageLevelCheckboxWrappers.find(il => il.imageLevelName === imageLevel).isChecked = value);
        this._setPros(pros);
        this.isProsFilterCheck(component);
    },

    handleOnChangedGOT: function (component,event) {
        let target = event.getSource();
        let got = target.get('v.text');
        let value = target.get('v.value');

        let pros = this._getPros();
        pros.find(p => p.groupOutletType === got).imageLevelCheckboxWrappers.forEach(il => il.isChecked = value);
        this._setPros(pros);
        this.isProsFilterCheck(component);
    },

    handleOnChangedInnerPros: function (component,event) {
        let target = event.getSource();
        let position = target.get('v.text');

        let got = position.split('_')[0];
        let imageLevel = position.split('_')[1];

        let pros = this._getPros();
        // select/unselect Group Outlet Type checkboxes
        pros.find(row => row.groupOutletType === got).selectAll = pros.find(row => row.groupOutletType === got).imageLevelCheckboxWrappers.every(il => il.isChecked);
        this._setPros(pros);
        // select/unselect Image Level checkboxes
        let checkboxes = this._getImageLevelCheckboxes();
        checkboxes.find(checkbox => checkbox.get('v.text') === imageLevel).set('v.value', pros.every(row => row.imageLevelCheckboxWrappers.find(il => il.imageLevelName === imageLevel).isChecked));
        this.isProsFilterCheck(component);
    },

    handleOnClickApplyPros: function () {
        const selectionMethod = this._getSelectionMethod();
        if (selectionMethod === this._constants.selectionMethods.pros) {
            let pros = this._getPros();
            this.fireEventToDownloadAccountsOfPros(pros);
        } else {
            let profs = this._getProfs();
            this.fireEventToDownloadAccountsOfProfs(profs);
        }

    },


    /* ========================================================= */
    /*     Server-Side actions
    /* ========================================================= */
    downloadSelectionMethods: function () {
        this.component.lax.enqueue(this._constants.serverSideActions.getSelectionMethods).then(selectionMethods => {
            this._setSelectionMethods(selectionMethods);
        });
    },

    downloadAccountListViews: function () {
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getAccountListViews).then(listViews => {
            this.hideSpinner();
            this._setListViews(listViews);
        });
    },

    downloadCustomerTaxonomies: function () {
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getCustomerTaxonomies).then(customerTaxonomies => {
            this.hideSpinner();
            this._setCustomerTaxonomies(customerTaxonomies);
        });
    },

    downloadPros: function () {
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getPROSTable).then(pros => {
            this.hideSpinner();
            this._setPros(pros);
        });
    },

    downloadProfs: function () {
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getPROFS).then(profs => {
            this.hideSpinner();
            this._setProfs(profs);
        });
    },


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    fireEventToDownloadAccountsOfListView: function (listView) {
        this.fireSelectionMethodIsChangedEvent(this._constants.selectionMethods.listView, [ listView ]);
    },

    fireEventToDownloadAccountsOfCustomerTaxonomy: function (customerTaxonomy) {
        this.fireSelectionMethodIsChangedEvent(this._constants.selectionMethods.customerTaxonomy, [ customerTaxonomy ]);
    },

    fireEventToDownloadAccountsOfPros: function (pros) {
        this.fireSelectionMethodIsChangedEvent(this._constants.selectionMethods.pros, pros);
    },

    fireEventToDownloadAccountsOfProfs: function (profs) {
        this.fireSelectionMethodIsChangedEvent(this._constants.selectionMethods.profs, profs);
    },


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    fireSelectionMethodIsChangedEvent: function (selectionMethod, data) {
        let SelectionMethodIsChangedEvent = this.component.getEvent(this._constants.events.SelectionMethodIsChangedEvent);
        SelectionMethodIsChangedEvent.setParams({
            'selectionMethod': selectionMethod,
            'data': data
        });
        SelectionMethodIsChangedEvent.fire();

    },

    resetFilters: function () {
        this._setListView(this._constants.none);
        this._setCustomerTaxonomy(this._constants.none);
    },

    resetAccounts: function () {
        this.fireSelectionMethodIsChangedEvent(this._constants.none, []);
    },

    showSpinner: function () {
        this.fireShowHideComponentEventForSpinner(true);
    },

    hideSpinner: function () {
        this.fireShowHideComponentEventForSpinner(false);
    },

    fireShowHideComponentEventForSpinner: function (display) {
        const ShowHideComponentEvent = this.component.getEvent(this._constants.events.ShowHideComponentEvent);
        ShowHideComponentEvent.setParams({
            'componentName': 'Spinner',
            'display': display
        });
        ShowHideComponentEvent.fire();
    },

    setTableWidth: function () {
        this._setProsTableWidth(this.component.find(this._constants.tabContainerId).getElement().clientWidth);
    },

    isProsFilterCheck:function(component){
      let pros = JSON.stringify(this._getPros());
      let isSelectCheckbox= pros.includes("isChecked\":true");
      console.log("isSelectCheckbox+ >"+isSelectCheckbox);
      component.set("v.isSelectCheckbox",isSelectCheckbox);
    },


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    isEmptyListViews: function () {
        return this._getListViews().length === 0;
    },

    isEmptyCustomerTaxonomies: function () {
        return this._getCustomerTaxonomies().length === 0;
    },

    isEmptyPros: function () {
        return this._getPros().length === 0;
    },

    isEmptyProfs: function () {
        return this._getProfs().length === 0;
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    _getSelectionMethod: function () {
        return this.component.get(this._constants.attributes.selectionMethod);
    },

    _getListView: function () {
        return this.component.get(this._constants.attributes.listView);
    },

    _getListViews: function () {
        return this.component.get(this._constants.attributes.listViews);
    },

    _getCustomerTaxonomy: function () {
        return this.component.get(this._constants.attributes.customerTaxonomy);
    },

    _getCustomerTaxonomies: function () {
        return this.component.get(this._constants.attributes.customerTaxonomies);
    },

    _getPros: function () {
        return this.component.get(this._constants.attributes.pros);
    },

    _getProfs: function () {
        return this.component.get(this._constants.attributes.profs);
    },

    _getImageLevelCheckboxes: function () {
        return this.component.find(this._constants.auraIds.imageLevelCheckboxes);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setSelectionMethods: function (data) {
        this.component.set(this._constants.attributes.selectionMethods, data);
    },

    _setSelectionMethod: function (data) {
        this.component.set(this._constants.attributes.selectionMethod, data);
    },

    _setListViews: function (data) {
        this.component.set(this._constants.attributes.listViews, data);
    },

    _setListView: function (data) {
        this.component.find(this._constants.auraIds.listView).set('v.value', data);
    },

    _setCustomerTaxonomies: function (data) {
        this.component.set(this._constants.attributes.customerTaxonomies, data);
    },

    _setCustomerTaxonomy: function (data) {
        this.component.find(this._constants.auraIds.customerTaxonomy).set('v.value', data);
    },

    _setPros: function (data) {
        this.component.set(this._constants.attributes.pros, data);
    },

    _setProfs: function (data) {
        this.component.set(this._constants.attributes.profs, data);
    },

    _setProfsColumns: function (data) {
        this.component.set(this._constants.attributes.profsColumns, data);
    },

    _setProsTableWidth: function (data) {
        this.component.set(this._constants.attributes.prosTableWidth, data);
    },

});