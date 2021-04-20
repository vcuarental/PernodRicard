({
    component: null,
    _constants: {
        events: {
            RecordsAreSelectedEvent: 'RecordsAreSelectedEvent'
        },
        attributes: {
            records: 'v.records',
            typeOfRecords: 'v.typeOfRecords',

            sortedBy: 'v.sortedBy',
            sortedDirection: 'v.sortedDirection',
        },
        auraId: 'mainTable'
    },

    handleOnInit: function (component) {
        this.component = component;
    },


    /* ========================================================= */
    /*     Handlers
    /* ========================================================= */
    handleResort: function (event) {
        const fieldName = event.getParam('fieldName');
        const sortDirection = event.getParam('sortDirection');

        this.component.find(this._constants.auraId).set(this._constants.attributes.sortedBy, fieldName);
        this.component.find(this._constants.auraId).set(this._constants.attributes.sortedDirection, sortDirection);

        const records = this._getRecords();
        this._setRecords(this.sort(records, fieldName, sortDirection));
    },

    handleOnClickAddToCart: function () {
        const records = this._getSelectedRows();
        if ( ! records.length) { return ; }

        this.fireRecordsAreSelectedEvent(records);
    },


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    fireRecordsAreSelectedEvent: function (records) {
        const RecordsAreSelectedEvent = this.component.getEvent(this._constants.events.RecordsAreSelectedEvent);
        RecordsAreSelectedEvent.setParams({
            typeOfRecords: this._getTypeOfRecords(),
            records: records,
            action: 'addToCart'
        });
        RecordsAreSelectedEvent.fire();
    },

    sort: function (records, fieldName, sortDirection) {
        const ordering = sortDirection === 'asc' ? 1 : -1;

        return records.sort(function (a, b) {
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
    _getSelectedRows: function () {
        return this.component.find(this._constants.auraId).getSelectedRows();
    },

    _getRecords: function () {
        return this.component.get(this._constants.attributes.records);
    },

    _getTypeOfRecords: function () {
        return this.component.get(this._constants.attributes.typeOfRecords);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setRecords: function (data) {
        this.component.set(this._constants.attributes.records, data);
    },

});