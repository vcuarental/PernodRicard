({
    component: null,
    _constants: {
        serverSideActions: {
            getAccountsOfListView: 'c.getAccountsOfListView',
            getAccountsOfCustomerTaxonomy: 'c.getAccountsOfCustomerTaxonomy',
            getAccountsOfPros: 'c.getAccountsOfPros',
            getAccountsOfProfs: 'c.getAccountsOfProfs',
            getAssignedAccounts: 'c.getAssignedAccounts',
            assignToAccounts: 'c.assignToAccounts',
            deleteAccountAssignments: 'c.deleteAccountAssignments',
        },
        attributes: {
            recordId: 'v.recordId',
            accounts: 'v.accounts',
            accountColumnsSortable: 'v.accountColumnsSortable',
            accountColumns: 'v.accountColumns',
            assignedAccounts: 'v.assignedAccounts',
            selectedAccounts: 'v.selectedAccounts',
            isShownTargetedAccountsModalWindow: 'v.isShownTargetedAccountsModalWindow',
            isShownSpinner: 'v.isShownSpinner',
            simpleRecord: 'v.simpleRecord',
            isShownDeletionCheckboxes: 'v.isShownDeletionCheckboxes',

        },
        events: {
            SelectionMethodIsChangedEvent: {
                name: 'SelectionMethodIsChangedEvent',
                attributes: {
                    selectionMethod: 'selectionMethod',
                    data: 'data'
                }
            },
            ShowHideComponentEvent: {
                name: 'ShowHideComponentEvent',
                attributes: {
                    componentName: 'componentName',
                    display: 'display',
                }
            },
            AccountsIsSelectedEvent: {
                name: 'AccountsIsSelectedEvent',
                attributes: {
                    type: 'type',
                    records: 'records'
                }
            },
            CallAddAllAccountHandler: {
                message: 'message'
            }
        },
        selectionMethods: {
            listView: 'Account list views',
            customerTaxonomy: 'Customer taxonomy',
            pros: 'PROS',
            profs: 'PROFS',
        },
        accountColumnsSortable: [
            {label: 'Name', fieldName: 'Name', type: 'text', sortable: true},
            {label: 'Status', fieldName: 'Status', type: 'text', sortable: true},
            {label: 'Channel', fieldName: 'Channel', type: 'text', sortable: true},
            {label: 'Region', fieldName: 'Region', type: 'text', sortable: true},
            {label: 'Territory', fieldName: 'TerritoryName', type: 'text', sortable: true},
            {label: 'Record Type', fieldName: 'RecordTypeName', type: 'text', sortable: true},
            {label: 'Owner', fieldName: 'OwnerName', type: 'text', sortable: true},
        ],
        accountColumns: [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Status', fieldName: 'Status', type: 'text'},
            {label: 'Channel', fieldName: 'Channel', type: 'text'},
            {label: 'Region', fieldName: 'Region', type: 'text'},
            {label: 'Territory', fieldName: 'TerritoryName', type: 'text'},
            {label: 'Record Type', fieldName: 'RecordTypeName', type: 'text'},
            {label: 'Owner', fieldName: 'OwnerName', type: 'text'},
        ],
        none: '--None--',
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    handleOnInit: function (component) {
        this.component = component;

        this._setAccountColumnsSortable(this._constants.accountColumnsSortable);
        this._setAccountColumns(this._constants.accountColumns);

        this.downloadAssignedAccounts();
    },

    handleOnRecordLoaded: function () {
        const simpleRecord = this._getCurrentQuizRecord();
        let isShownDeletionCheckboxes = false;
        let startDate = simpleRecord.EUR_CRM_StartDate__c;
        if (startDate !=null) {

            const year = Number(startDate.split('-')[0]);
            const month = Number(startDate.split('-')[1]);
            const date = Number(startDate.split('-')[2]);

            const currentYear = new Date().getFullYear();
            const currentMonth = new Date().getMonth() + 1;
            const currentDate = new Date().getDate();

            if (currentYear < year) {
                isShownDeletionCheckboxes = true;
            } else if (currentYear === year) {
                if (currentMonth < month) {
                    isShownDeletionCheckboxes = true;
                } else if (currentMonth === month) {
                    if (currentDate < date) {
                        isShownDeletionCheckboxes = true;
                    }
                }
            }
        }else{isShownDeletionCheckboxes = false;}
        this._setIsShownDeletionCheckboxes(isShownDeletionCheckboxes);
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    handleOnSelectionMethodIsChangedEvent: function (component, event) {
        const selectionMethod = event.getParam(this._constants.events.SelectionMethodIsChangedEvent.attributes.selectionMethod);
        const data = event.getParam(this._constants.events.SelectionMethodIsChangedEvent.attributes.data);
        if (selectionMethod === this._constants.none) {
            this.resetAccounts();
            return;
        }

        if (selectionMethod === this._constants.selectionMethods.listView) {
            this.downloadAccountsOfListView(data[0]);
        } else if (selectionMethod === this._constants.selectionMethods.customerTaxonomy) {
            this.downloadAccountsOfCustomerTaxonomy(data[0]);
        } else if (selectionMethod === this._constants.selectionMethods.pros) {
            this.downloadAccountsOfPros(data);
        } else if (selectionMethod === this._constants.selectionMethods.profs) {
            this.downloadAccountsOfProfs(data);
        }
        component.set('v.selectionMethod',selectionMethod);
        console.log('data =>' + JSON.stringify(data));
        console.log('selectionMethod =>' + JSON.stringify(selectionMethod));
        const recordId = component.get(this._constants.attributes.recordId);
        const childCmp = component.find('EUR_CRM_TargetedAccountsModalCmpId');
        childCmp.setFilterData(data, recordId);
    },

    handleOnAccountsIsSelectedEvent: function (event) {
        const type = event.getParam(this._constants.events.AccountsIsSelectedEvent.attributes.type);
        if (type === 'MainTable') {
            this.handleOnAccountsIsSelectedEventOnMainTable(event);
        } else if (type === 'CartTable') {
            this.handleOnAccountsIsSelectedEventOnCartTable(event);
        } else if (type === 'TargetedAccountsTable') {
            this.handleOnAccountsIsSelectedEventOnTargetAccountsTable(event);
        }
    },

    handleOnShowHideComponentEvent: function (event) {
        const componentName = event.getParam(this._constants.events.ShowHideComponentEvent.attributes.componentName);
        const display = event.getParam(this._constants.events.ShowHideComponentEvent.attributes.display);

        if (componentName === 'Targeted Accounts') {
            this._setIsShownTargetedAccountsModalWindow(display);
        } else if (componentName === 'Spinner') {
            this._setIsShownSpinner(display);
        }
    },
    addAllAcc: function (component, event) {
    const filter = event.getParam('message');
        var childCmp = component.find('EUR_CRM_TargetedAccountsModalCmpId');
        childCmp.getAllAccounts(filter);
        //this.showSpinner();
    },

    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    handleOnAccountsIsSelectedEventOnMainTable: function (event) {
        const selectedAccounts = event.getParam(this._constants.events.AccountsIsSelectedEvent.attributes.records);

        const accounts = this._getAccounts();
        const allSelectedAccounts = this._getSelectedAccounts();
        selectedAccounts.forEach(account => allSelectedAccounts.find(acc => acc.Id === account.Id) ? undefined : allSelectedAccounts.push(account));
        this._setSelectedAccounts(allSelectedAccounts);

        const nonSelectedAccounts = [];
        accounts.forEach(account => selectedAccounts.find(acc => acc.Id === account.Id) ? undefined : nonSelectedAccounts.push(account));
        this._setAccounts(nonSelectedAccounts);
    },

    handleOnAccountsIsSelectedEventOnCartTable: function (event) {
        const selectedAccountsIds = event.getParam(this._constants.events.AccountsIsSelectedEvent.attributes.records);
        console.log('selectedAccountsIds => '+ selectedAccountsIds)
        this.createRelationshipForAccounts(selectedAccountsIds);
    },

    handleOnAccountsIsSelectedEventOnTargetAccountsTable: function (event) {
        const selectedAccounts = event.getParam(this._constants.events.AccountsIsSelectedEvent.attributes.records);
        this.deleteRelationshipForAccounts(selectedAccounts.map(acc => acc.Id));
    },


    /* ========================================================= */
    /*     Server-Side Actions
    /* ========================================================= */
    downloadAssignedAccounts: function () {
        this.component.lax.enqueue(this._constants.serverSideActions.getAssignedAccounts, {recordId: this._getRecordId()}).then(assignedAccounts => {
            this._setAssignedAccounts(assignedAccounts);
        });
    },

    downloadAccountsOfListView: function (listView) {
        const params = {
            filterId: listView,
            recordId: this._getRecordId(),
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getAccountsOfListView, params).then(accounts => {
            this._setAccounts(this.filterBySelectedAccounts(accounts));
            this.hideSpinner();
        });
    },

    downloadAccountsOfCustomerTaxonomy: function (customerTaxonomy) {
        const params = {
            customerTaxonomy: customerTaxonomy,
            recordId: this._getRecordId(),
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getAccountsOfCustomerTaxonomy, params).then(accounts => {
            this._setAccounts(this.filterBySelectedAccounts(accounts));
            this.hideSpinner();
        });
    },
    downloadAccountsOfPros: function (pros) {
        const params = {
            prosWrappersJSON: JSON.stringify(pros),
            recordId: this._getRecordId(),
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getAccountsOfPros, params).then(accounts => {
            this._setAccounts(this.filterBySelectedAccounts(accounts));
            this.hideSpinner();
        });
    },

    downloadAccountsOfProfs: function (profs) {
        const params = {
            profsWrappersJSON: JSON.stringify(profs),
            recordId: this._getRecordId(),
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getAccountsOfProfs, params).then(accounts => {
            this._setAccounts(this.filterBySelectedAccounts(accounts));
            this.hideSpinner();
        });
    },

    createRelationshipForAccounts: function (accountIds) {
        const params = {
            accountIdsJSON: JSON.stringify(accountIds),
            recordId: this._getRecordId()
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.assignToAccounts, params).then(status => {
            this.hideTargetedAccountsModalWindow();
            this.refreshComponent(accountIds);
            this.hideSpinner();
        });
    },

    deleteRelationshipForAccounts: function (accountIds) {
        const params = {
            accountIdsJSON: JSON.stringify(accountIds),
            recordId: this._getRecordId()
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.deleteAccountAssignments, params).then(status => {
            this.hideTargetedAccountsModalWindow();
            this.refreshComponent(accountIds);
            this.hideSpinner();
        });
    },


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    resetAccounts: function () {
        this._setAccounts([]);
    },

    filterBySelectedAccounts: function (accounts) {
        const selectedAccounts = this._getSelectedAccounts();
        const resultAccounts = [];
        accounts.forEach(account => selectedAccounts.find(acc => acc.Id === account.Id) ? undefined : resultAccounts.push(account));
        return resultAccounts;
    },

    showTargetedAccountsModalWindow: function () {
        this._setIsShownTargetedAccountsModalWindow(true);
    },

    hideTargetedAccountsModalWindow: function () {
        this._setIsShownTargetedAccountsModalWindow(false);
    },

    showSpinner: function () {
        this._setIsShownSpinner(true);
    },

    hideSpinner: function () {
        this._setIsShownSpinner(false);
    },

    refreshComponent: function (accountIds) {
        this.downloadAssignedAccounts();

        const selectedAccounts = this._getSelectedAccounts();
        const accounts = [];
        selectedAccounts.forEach(acc => accountIds.indexOf(acc.Id) === -1 ? accounts.push(acc) : undefined);
        this._setSelectedAccounts(accounts);
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    _getCurrentQuizRecord: function () {
        return this.component.get(this._constants.attributes.simpleRecord);
    },

    _getRecordId: function () {
        return this.component.get(this._constants.attributes.recordId);
    },

    _getSelectedAccounts: function () {
        return this.component.get(this._constants.attributes.selectedAccounts);
    },

    _getAccounts: function () {
        return this.component.get(this._constants.attributes.accounts);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setAssignedAccounts: function (data) {
        this.component.set(this._constants.attributes.assignedAccounts, data);
    },

    _setAccounts: function (data) {
        this.component.set(this._constants.attributes.accounts, data);
    },

    _setAccountColumnsSortable: function (data) {
        this.component.set(this._constants.attributes.accountColumnsSortable, data);
    },

    _setAccountColumns: function (data) {
        this.component.set(this._constants.attributes.accountColumns, data);
    },

    _setSelectedAccounts: function (data) {
        this.component.set(this._constants.attributes.selectedAccounts, data);
    },

    _setIsShownTargetedAccountsModalWindow: function (data) {
        this.component.set(this._constants.attributes.isShownTargetedAccountsModalWindow, data);
    },

    _setIsShownSpinner: function (data) {
        this.component.set(this._constants.attributes.isShownSpinner, data)
    },

    _setIsShownDeletionCheckboxes: function (data) {
        this.component.set(this._constants.attributes.isShownDeletionCheckboxes, data)
    },

});