({
    component: null,
    _constants: {
        serverSideActions: {
            getRecordToClone: 'c.getRecordToClone',
            cloneRecordWithRelatedLists: 'c.cloneRecordWithRelatedLists',
        },
        attributes: {
            recordId: 'v.recordId',
            isShownSpinner: 'v.isShownSpinner',
            record: 'v.record',
        },
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    onInitHandler: function (component) {
        this.component = component;
        this.downloadRecordToClone();
    },


    /* ========================================================= */
    /*     Interactions
    /* ========================================================= */
    onClickCloneHandler: function () {
        this.cloneRecord();
    },


    /* ========================================================= */
    /*     Server-Side Actions
    /* ========================================================= */
    downloadRecordToClone: function () {
        this.showSpinner();
        const params = {
            recordId: this._getRecordId(),
        };
        this.component.lax.enqueue(this._constants.serverSideActions.getRecordToClone, params).then(record => {
            this._setRecord(record);
            this.hideSpinner();
        });
    },

    cloneRecord: function () {
        this.showSpinner();
        const params = {
            record: this._getRecord(),
        };
        this.component.lax.enqueue(this._constants.serverSideActions.cloneRecordWithRelatedLists, params)
            .then(clonedRecordId => {
                this.hideSpinner();
                this.redirectToRecord(clonedRecordId);
            }).catch(errors => {
                console.error(errors);

                const messages = this.extractFieldErrorMessages(errors.entries[0].fieldErrors);
                console.log('messages => ', messages);

                this.showToast('error', 'Cloning error!', messages)
                this.hideSpinner();
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

    extractFieldErrorMessages: function (fieldErrors) {
        let message = '';
        for(let key in fieldErrors) {
            // message += key + ' (' + fieldErrors[key][0].statusCode + '): ' + fieldErrors[key][0].message;
            message += fieldErrors[key][0].message;
        }
        return message;
    },

    showToast: function(type, title, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'type': type,
            'title': title,
            'message': message
        });
        toastEvent.fire();
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