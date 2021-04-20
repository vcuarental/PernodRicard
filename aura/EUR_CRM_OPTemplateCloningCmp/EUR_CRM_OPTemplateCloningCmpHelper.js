({
    component: null,
    parentComponent: null,
    _constants: {
        serverSideActions: {
            getRecordToClone: 'c.getRecordToClone',
            cloneRecordWithRelatedLists: 'c.cloneRecordWithRelatedLists',
        },
        attributes: {
            recordId: 'v.recordId',
            record: 'v.record',
            isShownSpinner: 'v.isShownSpinner',
        },
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    onInitHandler: function (component) {
        this.component = component;
        this.parentComponent = this.component.get('v.parent');

        if ( ! this._getRecordId()) { return; }
        this.downloadRecordToClone();
    },


    /* ========================================================= */
    /*     Interactions
    /* ========================================================= */
    onClickCancelModalWindowHandler: function () {
        this.parentComponent.closeCloneWindowMethod();
    },

    onClickCloneHandler: function () {
        this.cloneRecord();
    },


    /* ========================================================= */
    /*     Server-Side Actions
    /* ========================================================= */
    downloadRecordToClone: function () {
        this.showSpinner();
        const params = { recordId: this._getRecordId() };
        this.component.lax.enqueue(this._constants.serverSideActions.getRecordToClone, params)
            .then(record => {
                this._setRecord(record);
                this.hideSpinner();
            });
    },

    cloneRecord: function () {
        this.showSpinner();
        const params = { record: this._getRecord() };
        this.component.lax.enqueue(this._constants.serverSideActions.cloneRecordWithRelatedLists, params)
            .then(clonedRecordId => {
                this.hideSpinner();
                this.redirectToRecord(clonedRecordId);
            });
    },


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    showSpinner: function () {
        this._setIsShownSpinner(true);
    },

    hideSpinner: function () {
        this._setIsShownSpinner(false);
    },

    redirectToRecord: function (recordId) {
        const eUrl= $A.get('e.force:navigateToURL');
        eUrl.setParams({'url': '/' + recordId});
        eUrl.fire();
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    _getRecordId: function () {
        return this.component.get(this._constants.attributes.recordId);
    },

    _getRecord: function () {
        return this.component.get(this._constants.attributes.record);
    },


    /* ========================================================= */
    /*     Setters
    /* ========================================================= */
    _setRecord: function (data) {
        this.component.set(this._constants.attributes.record, data);
    },

    _setIsShownSpinner: function (data) {
        this.component.set(this._constants.attributes.isShownSpinner, data)
    },

});