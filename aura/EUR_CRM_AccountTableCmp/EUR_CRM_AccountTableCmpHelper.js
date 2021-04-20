({
    _constants: {
        events: {
            AccountsIsSelectedEvent: 'AccountsIsSelectedEvent'
        },
        attributes: {
            records: 'v.records',

            sortedBy: 'v.sortedBy',
            sortedDirection: 'v.sortedDirection',
        },
        auraId: 'mainTable'
    },


    /* ========================================================= */
    /*     Handlers
    /* ========================================================= */
    handleOnClickAddToCart: function (component) {
        const accounts = this.getSelectedRows(component);
        if ( ! accounts.length) { return ; }

        this.fireAccountsIsSelectedEvent(component, accounts);
    },

    handleResort: function (component, event) {
        const fieldName = event.getParam('fieldName');
        const sortDirection = event.getParam('sortDirection');

        component.find(this._constants.auraId).set(this._constants.attributes.sortedBy, fieldName);
        component.find(this._constants.auraId).set(this._constants.attributes.sortedDirection, sortDirection);

        const accounts = this.getRecords(component);
        this.setRecords(component, this.sort(component, accounts, fieldName, sortDirection));
    },


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    fireAccountsIsSelectedEvent: function (component, accounts) {
        const AccountsIsSelectedEvent = component.getEvent(this._constants.events.AccountsIsSelectedEvent);
        AccountsIsSelectedEvent.setParams({
            type: 'MainTable',
            records: accounts
        });
        AccountsIsSelectedEvent.fire();
    },

    sort: function (component, accounts, fieldName, sortDirection) {
        const ordering = sortDirection === 'asc' ? 1 : -1;

        return accounts.sort(function (a, b) {
            if ( ! a[fieldName] && b[fieldName]) {
                return ordering;
            } else if ( ! b[fieldName] && a[fieldName]) {
                return ordering * -1;
            } else if ( ! a[fieldName] && ! b[fieldName]) {
                return 0;
            }

            return ordering * a[fieldName].localeCompare(b[fieldName]);
        });
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    getSelectedRows: function (component) {
        return component.find(this._constants.auraId).getSelectedRows();
    },

    getRecords: function (component) {
        return component.get(this._constants.attributes.records);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    setRecords: function (component, data) {
        component.set(this._constants.attributes.records, data);
    },

});