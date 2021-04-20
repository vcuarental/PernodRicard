({
    component: null,


    /* ========================================================= */
    /*     Wrapper of Parent Modal Window Component
    /* ========================================================= */
    parentModalWindowCmp: null,
    parentModalWindowCmpInitialization: function (_helper) {
        const helper = _helper;
        const constants = {
            events: {
                showHideComponentEvent: 'ShowHideComponentEvent',
            },
            attributes: {
                showModal: 'v.showModal',
                showSaveConfirmation: 'v.showSaveConfirmation',
            },
        };

        const handleOnChangeShowModalWindow = function handleOnChangeShowModalWindow() {
            if (getShowModal()) {
                helper.assignedAccountsCmp.setAccounts();
                helper.assignedAccountsCmp.setFirstAccounts();
                helper.targetAccountsCmp.setAccounts();
                helper.targetAccountsCmp.setAccountsInTable();
            }
        };

        const handleOnClickCancelModalWindow = function handleOnClickCancelModalWindow() {
            const showHideComponentEvent = helper.component.getEvent(constants.events.showHideComponentEvent);
            showHideComponentEvent.setParams({
                componentName: 'Targeted Accounts',
                display: false,
            });
            showHideComponentEvent.fire();
        };

        const handleOnClickSaveModalWindow = function handleOnClickSaveModalWindow() {
            helper.targetAccountsCmp.handleOnClickSavingTargetAccounts();
        };

        const handleOnClickSaveAllTargetAccounts = function handleOnClickSaveAllTargetAccounts() {
            helper.targetAccountsCmp.handleOnClickSavingAllTargetAccounts();
        };

        /* ========================================================= */
        /*     Getters
        /* ========================================================= */
        const getShowModal = function getShowModal() {
            return helper.component.get(constants.attributes.showModal);
        };

        return {
            handleOnChangeShowModalWindow: handleOnChangeShowModalWindow,
            handleOnClickCancelModalWindow: handleOnClickCancelModalWindow,
            handleOnClickSaveModalWindow: handleOnClickSaveModalWindow,
            handleOnClickSaveAllTargetAccounts: handleOnClickSaveAllTargetAccounts,
        };
    },


    /* ========================================================= */
    /*     Wrapper of Assigned Accounts Component
    /* ========================================================= */
    assignedAccountsCmp: null,
    assignedAccountsCmpInitialization: function (_helper) {
        const helper = _helper;
        const constants = {
            events: {
                AccountsIsSelectedEvent: 'AccountsIsSelectedEvent',
            },
            attributes: {
                selectedRows: 'v.selectedRows',
                data: 'v.data',
                hideCheckboxColumn: 'v.hideCheckboxColumn',
                isShownDeletionCheckboxes: 'v.isShownDeletionCheckboxes',
                enableInfiniteLoading: 'v.enableAssignedTableInfiniteLoading',

                assignedAccounts: 'v.assignedAccounts',
                assignedAccountsToDelete: 'v.assignedAccountsToDelete',
                // hideAssignedAccountsCheckboxes: 'v.hideAssignedAccountsCheckboxes',
                assignedAccountsInTable: 'v.assignedAccountsInTable'
            },
            auraId: 'assignedTable',
        };

        const handleOnAssignedAccountsRowSelection = function handleOnAssignedAccountsRowSelection() {
            setAssignedAccountsToDelete(this.getSelectedRows());
        };

        const handleOnClickDeleteAssignedAccounts = function handleOnClickDeleteAssignedAccounts() {
            // setHideAssignedAccountsCheckboxes(true);

            const accounts = getSelectedRows();

            const AccountsIsSelectedEvent = helper.component.getEvent(constants.events.AccountsIsSelectedEvent);
            AccountsIsSelectedEvent.setParams({
                type: 'TargetedAccountsTable',
                records: accounts
            });
            AccountsIsSelectedEvent.fire();
        };

        const setAccounts = function setAccounts() {
            if (getIsShownDeletionButton()) {
                setAssignedRows([]);

            } else {
                const accounts = this.getAssignedAccounts();
                setAssignedRows(accounts.map(acc => acc.Id));
            }
        };
        const setAccountsInTable = function setAccounts() {
            var accounts = this.getAssignedAccounts();
            var startSetOfAccounts = accounts.slice(0, 15);

            setFirstStartAcc(startSetOfAccounts);
        };

        /* ========================================================= */
        /*     Getters
        /* ========================================================= */
        const getAssignedAccounts = function getAssignedAccounts() {
            return helper.component.get(constants.attributes.assignedAccounts);
        };

        const getSelectedRows = function getSelectedRows() {
            return helper.component.find(constants.auraId).getSelectedRows();
        };

        const getIsShownDeletionButton = function getIsShownDeletionButton() {
            return helper.component.get(constants.attributes.isShownDeletionCheckboxes);
        };

        /* ========================================================= */
        /*     Setters
        /* ========================================================= */
        const setAssignedAccountsToDelete = function setAssignedAccountsToDelete(data) {
            helper.component.set(constants.attributes.assignedAccountsToDelete, data);
        };

        const setAssignedRows = function setAssignedRows(data) {
            helper.component.find(constants.auraId).set(constants.attributes.selectedRows, data);
        };
        const setInfiniteLoading = function setAssignedRows(data) {
            helper.component.set(constants.attributes.enableInfiniteLoading, data);
        };
        const setFirstStartAcc = function setAssignedRows(data) {
            helper.component.find(constants.auraId).set(constants.attributes.data, data);
            console.log('data.length => ' + data.length);
            if (data.length >= 15) {
                setInfiniteLoading(true);
            }

        };

        return {
            handleOnAssignedAccountsRowSelection: handleOnAssignedAccountsRowSelection,
            handleOnClickDeleteAssignedAccounts: handleOnClickDeleteAssignedAccounts,

            setAccounts: setAccounts,
            setFirstAccounts: setAccountsInTable,

            getAssignedAccounts: getAssignedAccounts,
            getSelectedRows: getSelectedRows,
        }
    },


    /* ========================================================= */
    /*     Wrapper of Target Accounts Component
    /* ========================================================= */
    targetAccountsCmp: null,
    targetAccountsCmpInitialization: function (_helper) {
        const helper = _helper;
        const constants = {
            events: {
                AccountsIsSelectedEvent: 'AccountsIsSelectedEvent',
            },
            attributes: {
                selectedRows: 'v.selectedRows',
                data: 'v.data',
                hideCheckboxColumn: 'v.hideCheckboxColumn',

                targetAccounts: 'v.targetAccounts',
                targetAccountIds: 'v.targetAccountIds',

                enableInfiniteLoading: 'v.enableCartTableInfiniteLoading',
                assignedAccountsInTable: 'v.assignedAccountsInTable'
            },
            auraId: 'cartTable',
        };

        const state = {
            accountIds: [],
            targetAccountIds: [],

            shouldBeRefreshed: false,
            refreshedAccountIds: [],
            refreshedSelectedAccountIds: []
        };

        const handleOnTargetAccountsRowSelection = function handleOnTargetAccountsRowSelection() {
            const selectedRows = getSelectedRows();

            let accountIds = [];
            if (selectedRows) {
                selectedRows.forEach(row => accountIds.push(row.Id));
            } else if (state.targetAccountIds.length) {
                accountIds = state.targetAccountIds;
            }

            state.targetAccountIds = accountIds;
            setSelectedAccountIds(state.targetAccountIds);
        };

        const handleOnChangeTargetAccounts = function handleOnChangeTargetAccounts() {
            const targetAccounts = getSelectedAccounts();

            if (state.shouldBeRefreshed) {
                state.accountIds = state.refreshedAccountIds;
                state.targetAccountIds = state.refreshedSelectedAccountIds;

                state.refreshedAccountIds = [];
                state.refreshedSelectedAccountIds = [];
                state.shouldBeRefreshed = false;
            }
            let accountIds = targetAccounts.map(acc => acc.Id);

            if (!state.accountIds.length) {
                state.targetAccountIds = accountIds;
                state.accountIds = accountIds;
            } else {
                accountIds.forEach(id => state.accountIds.indexOf(id) === -1 ? state.targetAccountIds.push(id) : undefined);
                accountIds.forEach(id => state.accountIds.indexOf(id) === -1 ? state.accountIds.push(id) : undefined);
            }

        };

        const updateStateAfterSaving = function updateStateAfterSaving(accounts) {
            state.shouldBeRefreshed = true;

            let accountIds = [];
            state.accountIds.forEach(id => accounts.find(row => row.Id === id) ? undefined : accountIds.push(id));

            state.refreshedAccountIds = accountIds;
            state.refreshedSelectedAccountIds = [];
        };

        const updateStateAfterSavingAccIds = function updateStateAfterSavingAccIds(targetAccountIds) {
            state.shouldBeRefreshed = true;

            let accountIds = [];
            state.accountIds.forEach(id => targetAccountIds.find(row => row.Id === id) ? undefined : accountIds.push(id));

            state.refreshedAccountIds = accountIds;
            state.refreshedSelectedAccountIds = [];
        };

        const setAccounts = function setAccounts() {
            setSelectedAccountIds(state.targetAccountIds);
            setSelectedRows(state.targetAccountIds);
        };

        const handleOnClickSavingTargetAccounts = function handleOnClickSavingTargetAccounts() {
            const accounts = getSelectedRows();
            const accId = accounts.map(accounts => accounts.Id);

            const AccountsIsSelectedEvent = helper.component.getEvent(constants.events.AccountsIsSelectedEvent);
            AccountsIsSelectedEvent.setParams({
                type: 'CartTable',
                records: accId
            });
            AccountsIsSelectedEvent.fire();

            updateStateAfterSaving(accounts);
        };

        const handleOnClickSavingAllTargetAccounts = function handleOnClickSavingAllTargetAccounts() {
            const accounts = getTargetAccounts();
            const accId = accounts.map(accounts => accounts.Id);

            const AccountsIsSelectedEvent = helper.component.getEvent(constants.events.AccountsIsSelectedEvent);
            AccountsIsSelectedEvent.setParams({
                type: 'CartTable',
                records: accId
            });
            AccountsIsSelectedEvent.fire();

            updateStateAfterSavingAccIds(accId);
        };
        const setAccountsInTable = function setAccounts() {
            var accounts = getSelectedAccounts();
            var startSetOfAccounts = accounts.slice(0, 15);

            initAccountToAssign(startSetOfAccounts);
        };
        const initAccountToAssign = function setAssignedRows(data) {
            helper.component.find(constants.auraId).set(constants.attributes.data, data);

            if (getSelectedAccounts().length >= 15) {
                setInfiniteLoading(true);
            }

        };

        /* ========================================================= */
        /*     Getters
        /* ========================================================= */
        const getSelectedAccounts = function getSelectedAccounts() {
            return helper.component.get(constants.attributes.targetAccounts);
        };

        const getTargetAccounts = function getTargetAccounts() {
            return helper.component.get(constants.attributes.targetAccounts);
        };

        const getSelectedRows = function getSelectedRows() {
            return helper.component.find(constants.auraId).getSelectedRows();
        };

        /* ========================================================= */
        /*     Setters
        /* ========================================================= */
        const setSelectedAccountIds = function setSelectedAccountIds(data) {
            helper.component.set(constants.attributes.targetAccountIds, data);
        };

        const setSelectedRows = function setSelectedRows(data) {
            helper.component.find(constants.auraId).set(constants.attributes.selectedRows, data);
        };
        const setInfiniteLoading = function setAssignedRows(data) {
            helper.component.set(constants.attributes.enableInfiniteLoading, data);
        };

        return {
            handleOnTargetAccountsRowSelection: handleOnTargetAccountsRowSelection,
            handleOnChangeTargetAccounts: handleOnChangeTargetAccounts,

            getSelectedRows: getSelectedRows,
            setAccountsInTable: setAccountsInTable,

            setAccounts: setAccounts,
            handleOnClickSavingTargetAccounts: handleOnClickSavingTargetAccounts,
            handleOnClickSavingAllTargetAccounts: handleOnClickSavingAllTargetAccounts,
        }
    },
    setFilterData: function (component, event) {
        var filterSettingEvent = event.getParam('arguments');
        component.set('v.filterSetting', filterSettingEvent.data);
        component.set('v.recordId', filterSettingEvent.recordId);

    },

    getAllAccounts: function (component, event) {
        const filterSetting = component.get('v.filterSetting');
        const recordId = component.get('v.recordId');
        const arg = event.getParam('arguments');
        const selectedFilter = arg.selectedFilter;
        console.log('selectedMethod =>' + JSON.stringify(event.getParam('arguments')));
        console.log('selectedFilter =>' + JSON.stringify(selectedFilter));
        console.log('filterSetting =>' + filterSetting);

        if (selectedFilter==='PROS'){
            this.downloadAccountsOfPros(component, filterSetting, recordId);
        }else if(selectedFilter==='PROFS'){
            this.downloadAccountsOfProfs(component, filterSetting, recordId);
        }else if(selectedFilter==='Customer taxonomy'){
            this.downloadAccountsOfCustomerTaxonomy(component,String(filterSetting), recordId);
        }else if(selectedFilter==='Account list views'){
            this.downloadAccountsOfAccountListViews(component,String(filterSetting), recordId);
        }
    },
    downloadAccountsOfPros: function (component, pros, recordId) {
        const params = {
            prosWrappersJSON: JSON.stringify(pros),
            recordId: recordId,
        };
        console.log('params =>' + JSON.stringify(params));
        this.component.lax.enqueue('c.getAccountsOfPros', params).then(accounts => {
            component.set('v.targetAccounts',
                this.filterBySelectedAccounts(accounts));
        });

    },
    downloadAccountsOfProfs: function (component, profs, recordId) {
        const params = {
            profsWrappersJSON: JSON.stringify(profs),
            recordId: recordId,
        };
        console.log('params =>' + JSON.stringify(params));
        this.component.lax.enqueue('c.getAccountsOfProfs', params).then(accounts => {
            component.set('v.targetAccounts',
                this.filterBySelectedAccounts(accounts));

        });
    },
    downloadAccountsOfCustomerTaxonomy: function (component,customerTaxonomy,recordId) {
        const params = {
            customerTaxonomy: customerTaxonomy,
            recordId: recordId
        };
        this.component.lax.enqueue('c.getAccountsOfCustomerTaxonomy', params).then(accounts => {
            component.set('v.targetAccounts',
                this.filterBySelectedAccounts(accounts));

        });

    },
    downloadAccountsOfAccountListViews: function (component,listView,recordId) {
        const params = {
            filterId: listView,
            recordId: recordId
        };
        this.component.lax.enqueue('c.getAccountsOfListView', params).then(accounts => {
            component.set('v.targetAccounts',
                this.filterBySelectedAccounts(accounts));

        });

    },
    filterBySelectedAccounts: function (accounts) {
        const selectedAccounts = this.component.get('v.targetAccounts');
        const resultAccounts = [];
        accounts.forEach(account => selectedAccounts.find(acc => acc.Id === account.Id) ? undefined : resultAccounts.push(account));
        return resultAccounts;
    },

    loadMoreAssignedAccounts: function (component, event, helper) {
        this.fetchAssignedAccounts(component, event);
    },

    fetchAssignedAccounts: function (component, event) {
        var assignedAccounts = component.get('v.assignedAccounts');
        var accInTable = component.get('v.assignedAccountsInTable');
        var length = accInTable.length;
        if (event === undefined) {
            console.log('init')
        } else {
            event.getSource().set("v.isLoading", true);
        }
        component.set('v.loadMoreStatus', 'Loading');
        component.set('v.assignedAccountsInTable', accInTable.concat(assignedAccounts.slice(length, length + 10)));

        if (assignedAccounts.length === accInTable.length) {
            component.set('v.enableAssignedTableInfiniteLoading', false);
        }
        event.getSource().set('v.isLoading', false);
    },

    loadMoreAccountToAssign: function (component, event) {
        this.fetchAccountToAssign(component, event);
    },

    fetchAccountToAssign: function (component, event) {
        var targetAccounts = component.get('v.targetAccounts');
        var accInTable = component.get('v.accountsToAssignInTable');
        var length = accInTable.length;
        if (event === undefined) {
            console.log('init')
        } else {
            event.getSource().set("v.isLoading", true);
        }

        component.set('v.loadMoreStatus', 'Loading');
        component.set('v.accountsToAssignInTable', accInTable.concat(targetAccounts.slice(length, length + 10)));

        if (targetAccounts.length === accInTable.length) {
            component.set('v.enableCartTableInfiniteLoading', false);
        }
        event.getSource().set('v.isLoading', false);
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    handleOnInit: function (component) {
        this.component = component;

        this.parentModalWindowCmp = this.parentModalWindowCmpInitialization(this);
        this.assignedAccountsCmp = this.assignedAccountsCmpInitialization(this);
        this.targetAccountsCmp = this.targetAccountsCmpInitialization(this);

    },

});