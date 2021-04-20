({
    component: null,
    _constants: {
        serverSideActions: {
            getAssignedUserRoles: 'c.getAssignedUserRoles',
            getCountryCodeOptions: 'c.getCountryCodeOptions',
            getUserRolesForCountry: 'c.getUserRolesForCountry',
            addRoles: 'c.addRoles',
            removeRoles: 'c.removeRoles',
        },
        attributes: {
            recordId: 'v.recordId',
            countryCodeOptions: 'v.countryCodeOptions',
            countryCodeOption: 'v.countryCodeOption',
            userRoles: 'v.userRoles',
            userRoleColumns: 'v.userRoleColumns',
            isShownSpinner: 'v.isShownSpinner',
            isShownModal: 'v.isShownModal',

            assignedUserRoles: 'v.assignedUserRoles',
            assignedUserRolesToDelete: 'v.assignedUserRolesToDelete',
            selectedUserRoles: 'v.selectedUserRoles',
        },
        events: {
            RecordsAreSelectedEvent: {
                name: 'RecordsAreSelectedEvent',
                attributes: {
                    typeOfRecords: 'typeOfRecords',
                    records: 'records',
                    action: 'action'
                }
            },
            AccountsIsSelectedEvent: {
                name: 'AccountsIsSelectedEvent',
                attributes: {
                    type: 'type',
                    records: 'records'
                }
            },
            ShowHideComponentEvent: {
                name: 'ShowHideComponentEvent',
                attributes: {
                    componentName: 'componentName',
                    display: 'display',
                }
            },
        },
        userRoleColumns: [
            { label: 'Name', fieldName: 'Name', type: 'text' },
        ],
        none: '--None--'
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    handleOnInit: function (component) {
        this.component = component;

        this._setUserRoleColumns(this._constants.userRoleColumns);
        this.downloadAssignedUserRoles();
        this.downloadCountryCodeOptions();
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    handleOnRecordsAreSelectedEvent: function (event) {
        const typeOfRecords = event.getParam(this._constants.events.RecordsAreSelectedEvent.attributes.typeOfRecords);
        const records = event.getParam(this._constants.events.RecordsAreSelectedEvent.attributes.records);
        const action = event.getParam(this._constants.events.RecordsAreSelectedEvent.attributes.action);

        if (typeOfRecords === 'UserRole') {
            if (action === 'addToCart') {
                this.handleAddSelectedRecordsToCart(records);
            }
        }
    },

    handleOnShowHideComponentEvent: function (event) {
        const componentName = event.getParam(this._constants.events.ShowHideComponentEvent.attributes.componentName);
        const display = event.getParam(this._constants.events.ShowHideComponentEvent.attributes.display);

        if (componentName === 'Targeted Records') {
            this._setIsShownModal(display);
        }
    },

    handleOnAccountsIsSelectedEvent: function (event) {
        const type = event.getParam(this._constants.events.AccountsIsSelectedEvent.attributes.type);
        if (type === 'CartTable') {
            this.handleOnAccountsIsSelectedEventOnCartTable(event);
        } else if (type === 'TargetedRecordsTable') {
            this.handleOnAccountsIsSelectedEventOnTargetedRecordsTable(event);
        }
    },
    

    handleOnClickTargetUserRole: function () {
        this.showModal();
    },

    handleOnChangeCountryCodeOption: function () {
        console.log('handleOnChangeCountryCodeOption()');
        const countryCode = this._getCountryCodeOption();
        console.log('countryCode => ', countryCode);
        if ( ! countryCode || countryCode === this._constants.none) {
            this._setUserRoles([]);
            return;
        }

        this.downloadRolesForCountry(countryCode);
    },


    /* ========================================================= */
    /*     Server Side Actions
    /* ========================================================= */
    downloadAssignedUserRoles: function (event) {
        const params = {
            recordId: this._getRecordId()
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getAssignedUserRoles, params).then(assignedUserRoles => {
            this._setAssignedUserRoles(assignedUserRoles);
            this.hideSpinner();
        });
    },

    downloadCountryCodeOptions: function () {
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getCountryCodeOptions).then(countryCodeOptions => {
            this._setCountryCodeOptions(countryCodeOptions);
            if (countryCodeOptions.length === 1) {
                this.downloadRolesForCountry(countryCodeOptions[0].value);
            } else {
                this.hideSpinner();
            }
        });
    },

    downloadRolesForCountry: function (countryCode) {
        console.log('downloadRolesForCountry()');

        if ( ! countryCode || countryCode === this._constants.none) { return ; }

        const params = {
            recordId: this._getRecordId(),
            countryCode: countryCode
        };
        console.log('params => ', params);
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.getUserRolesForCountry, params).then(userRoles => {
            console.log('userRoles => ', userRoles);
            this._setUserRoles(this.filterBySelectedUserRoles(userRoles));
            this.hideSpinner();
        });
    },

    createRelationshipForAccounts: function (userRoleDevNames) {
        const params = {
            recordId: this._getRecordId(),
            userRoleDevNamesJSON: JSON.stringify(userRoleDevNames),
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.addRoles, params).then(status => {
            this.downloadAssignedUserRoles();

            this._setCountryCodeOption(this._getCountryCodeOptions()[0].value);
            this._setSelectedUserRoles([]);

            this.hideModal();
            this.hideSpinner();
        });
    },

    removeRelationshipForAccounts: function (userRoleDevNames) {
        const params = {
            recordId: this._getRecordId(),
            userRoleDevNamesJSON: JSON.stringify(userRoleDevNames),
        };
        this.showSpinner();
        this.component.lax.enqueue(this._constants.serverSideActions.removeRoles, params).then(status => {
            this.downloadAssignedUserRoles();

            const countryCode = this._getCountryCodeOptions()[0].value;
            this._setCountryCodeOption(countryCode);
            this.downloadRolesForCountry(countryCode);

            this.hideModal();
            if (countryCode === this._constants.none) {
                this.hideSpinner();
            }
        });
    },


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    handleAddSelectedRecordsToCart: function (selectedUserRoles) {
        const userRoles = this._getUserRoles();
        const allSelectedUserRoles = this._getSelectedUserRoles();
        selectedUserRoles.forEach(userRole => allSelectedUserRoles.find(role => role.Id === userRole.Id) ? undefined : allSelectedUserRoles.push(userRole));
        this._setSelectedUserRoles(allSelectedUserRoles);

        const nonSelectedUserRoles = [];
        userRoles.forEach(userRole => selectedUserRoles.find(role => role.Id === userRole.Id) ? undefined : nonSelectedUserRoles.push(userRole));
        this._setUserRoles(nonSelectedUserRoles);
    },

    handleOnAccountsIsSelectedEventOnCartTable: function (event) {
        const selectedAccounts = event.getParam(this._constants.events.AccountsIsSelectedEvent.attributes.records);
        this.createRelationshipForAccounts(selectedAccounts.map(acc => acc.DeveloperName));
    },

    handleOnAccountsIsSelectedEventOnTargetedRecordsTable: function (event) {
        const selectedAccounts = event.getParam(this._constants.events.AccountsIsSelectedEvent.attributes.records);
        this.removeRelationshipForAccounts(selectedAccounts.map(acc => acc.DeveloperName));
    },


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    showSpinner: function () {
        this._setIsShownSpinner(true);
    },

    hideSpinner: function () {
        this._setIsShownSpinner(false);
    },

    showModal: function () {
        this._setIsShownModal(true);
    },

    hideModal: function () {
        this._setIsShownModal(false);
    },

    filterBySelectedUserRoles: function (userRoles) {
        const selectedUserRoles = this._getSelectedUserRoles();
        const resultUserRoles = [];
        userRoles.forEach(userRole => selectedUserRoles.find(role => role.Id === userRole.Id) ? undefined : resultUserRoles.push(userRole));
        return resultUserRoles;
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    _getCountryCodeOptions: function (data) {
        return this.component.get(this._constants.attributes.countryCodeOptions, data);
    },

    _getCountryCodeOption: function () {
        return this.component.get(this._constants.attributes.countryCodeOption);
    },

    _getUserRoles: function () {
        return this.component.get(this._constants.attributes.userRoles);
    },

    _getSelectedUserRoles: function () {
        return this.component.get(this._constants.attributes.selectedUserRoles);
    },

    _getRecordId: function () {
        return this.component.get(this._constants.attributes.recordId);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setAssignedUserRoles: function (data) {
        this.component.set(this._constants.attributes.assignedUserRoles, data);
    },

    _setCountryCodeOptions: function (data) {
        this.component.set(this._constants.attributes.countryCodeOptions, data);
    },

    _setIsShownSpinner: function (data) {
        this.component.set(this._constants.attributes.isShownSpinner, data);
    },

    _setIsShownModal: function (data) {
        this.component.set(this._constants.attributes.isShownModal, data);
    },

    _setUserRoleColumns: function (data) {
        this.component.set(this._constants.attributes.userRoleColumns, data);
    },

    _setUserRoles: function (data) {
        this.component.set(this._constants.attributes.userRoles, data);
    },

    _setSelectedUserRoles: function (data) {
        this.component.set(this._constants.attributes.selectedUserRoles, data);
    },

    _setCountryCodeOption: function (data) {
        console.log('_setCountryCodeOption() => ', data);
        this.component.set(this._constants.attributes.countryCodeOption, data);
    },

});