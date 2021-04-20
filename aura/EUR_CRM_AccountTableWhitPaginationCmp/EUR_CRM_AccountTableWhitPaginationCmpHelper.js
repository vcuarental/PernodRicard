({
    _constants: {
        events: {
            AccountsIsSelectedEvent: 'AccountsIsSelectedEvent',
            CallAddAllAccountHandler: 'CallAddAllAccountHandler'
        },
        attributes: {
            records: 'v.records',

            sortedBy: 'v.sortedBy',
            sortedDirection: 'v.sortedDirection',

            countRecordsOnPage: 'v.countRecordsOnPage',
            page: 'v.page',
        },
        auraId: 'mainTable'
    },

    doInit: function (component, event, helper) {
        let records = component.get("v.records");
        let countRecordsOnPage = component.get(this._constants.attributes.countRecordsOnPage);
        this.setTotalPages(component);
        component.set("v.recordsToPage", records.slice(0, countRecordsOnPage));

    },

    setTotalPages: function (component) {
        let records = component.get("v.records");
        let countRecordsOnPage = component.get(this._constants.attributes.countRecordsOnPage);
        if ((records.length % countRecordsOnPage) === 0) {
            component.set("v.totalPages", Math.floor(records.length / countRecordsOnPage));
        } else {
            component.set("v.totalPages", Math.floor(records.length / countRecordsOnPage) + 1);
        }
    },
    /* ========================================================= */
    /*     Handlers
    /* ========================================================= */
    handleOnClickAddToCart: function (component) {
        const accounts = this.getSelectedRows(component);
        if (!accounts.length) {
            return;
        }

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
    fireSendQuery: function (component,selectionMethod) {
        const call = component.getEvent(this._constants.events.CallAddAllAccountHandler);
        call.setParam("message", selectionMethod);
        call.fire();

    },

    sort: function (component, accounts, fieldName, sortDirection) {
        const ordering = sortDirection === 'asc' ? 1 : -1;

        return accounts.sort(function (a, b) {
            if (!a[fieldName] && b[fieldName]) {
                return ordering;
            } else if (!b[fieldName] && a[fieldName]) {
                return ordering * -1;
            } else if (!a[fieldName] && !b[fieldName]) {
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

    getAccounts: function (component, page, recordToDisply) {
        // create a server side action.
        var action = component.get("c.fetchAccount");
        // set the parameters to method
        action.setParams({
            "pageNumber": page,
            "recordToDisply": recordToDisply
        });
        // set a call back
        action.setCallback(this, function (a) {
            // store the response return value (wrapper class insatance)
            var result = a.getReturnValue();
            console.log('result ---->' + JSON.stringify(result));
            // set the component attributes value with wrapper class properties.

            component.set("v.Accounts", result.accounts);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total / recordToDisply));

        });
        // enqueue the action
        $A.enqueueAction(action);
    },

    navigate: function (component, event) {
        let records = component.get("v.records");
        let page = component.get(this._constants.attributes.page);
        let countRecordsOnPage = component.get(this._constants.attributes.countRecordsOnPage);
        let recordsToPage = component.get("v.recordsToPage");
        let direction = event.getSource().getLocalId();
        if (direction === "Next" && records != null) {
            component.set("v.page", page + 1);
            recordsToPage = records.slice(countRecordsOnPage * page, countRecordsOnPage * (page + 1));
            component.set("v.recordsToPage", recordsToPage);
            component.set("v.isPageInRange", page < (component.get("v.totalPages") - 1));
        } else {
            component.set("v.page", page - 1);
            component.set("v.recordsToPage", records.slice(countRecordsOnPage * (page - 2), countRecordsOnPage * (page - 1)));
            component.set("v.isPageInRange", true);
        }
    },

    addAll: function (component) {
        const selectionMethod = component.get('v.selectionMethod');
        const accounts = component.get("v.records");
        console.log('selection method =>' + selectionMethod);
        if (accounts.length>700) {
            console.log('list size more then 700 records =>' + accounts.length);
            this.fireSendQuery(component, selectionMethod);
            component.set('v.records', [])
        }
        else {
            this.fireAccountsIsSelectedEvent(component, accounts);
        }
    },


    isSelectRow: function (component) {
        let isSelect;
        isSelect = component.find("mainTable").getSelectedRows().length > 0;
        component.set("v.isSelectRow", isSelect);
    }
});