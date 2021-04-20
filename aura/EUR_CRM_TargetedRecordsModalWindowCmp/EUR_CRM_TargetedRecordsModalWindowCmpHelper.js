({
    component : null,


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
                helper.assignedRecordsCmp.setRecords();
                helper.targetRecordsCmp.setRecords();
            }
        };

        const handleOnClickCancelModalWindow = function handleOnClickCancelModalWindow() {
            const showHideComponentEvent = helper.component.getEvent(constants.events.showHideComponentEvent);
            showHideComponentEvent.setParams({
                componentName: 'Targeted Records',
                display: false,
            });
            showHideComponentEvent.fire();
        };

        const handleOnClickSaveModalWindow = function handleOnClickSaveModalWindow() {
            helper.targetRecordsCmp.handleOnClickSavingTargetRecords();
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
        };
    },


    /* ========================================================= */
    /*     Wrapper of Assigned Records Component
    /* ========================================================= */
    assignedRecordsCmp: null,
    assignedRecordsCmpInitialization: function (_helper) {
        const helper = _helper;
        const constants = {
            events: {
                RecordsIsSelectedEvent: 'AccountsIsSelectedEvent',
            },
            attributes: {
                selectedRows: 'v.selectedRows',
                data: 'v.data',
                hideCheckboxColumn: 'v.hideCheckboxColumn',
                isShownDeletionCheckboxes: 'v.isShownDeletionCheckboxes',

                assignedRecords: 'v.assignedRecords',
                assignedRecordsToDelete: 'v.assignedRecordsToDelete',
                // hideAssignedRecordsCheckboxes: 'v.hideAssignedRecordsCheckboxes',
            },
            auraId: 'assignedTable',
        };

        const handleOnAssignedRecordsRowSelection = function handleOnAssignedRecordsRowSelection() {
            setAssignedRecordsToDelete(this.getSelectedRows());
        };

        const handleOnClickDeleteAssignedRecords = function handleOnClickDeleteAssignedRecords() {
            // setHideAssignedRecordsCheckboxes(true);

            const records = getSelectedRows();

            const RecordsIsSelectedEvent = helper.component.getEvent(constants.events.RecordsIsSelectedEvent);
            RecordsIsSelectedEvent.setParams({
                type: 'TargetedRecordsTable',
                records: records
            });
            RecordsIsSelectedEvent.fire();
        };

        const setRecords = function setRecords() {
            if (getIsShownDeletionButton()) {
                setAssignedRows([]);
            } else {
                const records = this.getAssignedRecords();
                setAssignedRows(records.map(acc => acc.Id));
            }
        };

        /* ========================================================= */
        /*     Getters
        /* ========================================================= */
        const getAssignedRecords = function getAssignedRecords() {
            return helper.component.get(constants.attributes.assignedRecords);
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
        const setAssignedRecordsToDelete = function setAssignedRecordsToDelete(data) {
            helper.component.set(constants.attributes.assignedRecordsToDelete, data);
        };

        const setAssignedRows = function setAssignedRows(data) {
            helper.component.find(constants.auraId).set(constants.attributes.selectedRows, data);
        };

        return {
            handleOnAssignedRecordsRowSelection: handleOnAssignedRecordsRowSelection,
            handleOnClickDeleteAssignedRecords: handleOnClickDeleteAssignedRecords,

            setRecords: setRecords,

            getAssignedRecords: getAssignedRecords,
            getSelectedRows: getSelectedRows,
        }
    },


    /* ========================================================= */
    /*     Wrapper of Target Records Component
    /* ========================================================= */
    targetRecordsCmp: null,
    targetRecordsCmpInitialization: function (_helper) {
        const helper = _helper;
        const constants = {
            events: {
                RecordsIsSelectedEvent: 'AccountsIsSelectedEvent',
            },
            attributes: {
                selectedRows: 'v.selectedRows',
                data: 'v.data',
                hideCheckboxColumn: 'v.hideCheckboxColumn',

                targetRecords: 'v.targetRecords',
                targetRecordIds: 'v.targetRecordIds',
            },
            auraId: 'cartTable',
        };

        const state = {
            recordIds: [],
            targetRecordIds: [],

            shouldBeRefreshed: false,
            refreshedRecordIds: [],
            refreshedSelectedRecordIds: []
        };

        const handleOnTargetRecordsRowSelection = function handleOnTargetRecordsRowSelection() {
            const selectedRows = getSelectedRows();

            let recordIds = [];
            if (selectedRows) {
                selectedRows.forEach(row => recordIds.push(row.Id));
            } else if (state.targetRecordIds.length) {
                recordIds = state.targetRecordIds;
            }

            state.targetRecordIds = recordIds;
            setSelectedRecordIds(state.targetRecordIds);
        };

        const handleOnChangeTargetRecords = function handleOnChangeTargetRecords() {
            const targetRecords = getSelectedRecords();

            if (state.shouldBeRefreshed) {
                state.recordIds = state.refreshedRecordIds;
                state.targetRecordIds = state.refreshedSelectedRecordIds;

                state.refreshedRecordIds = [];
                state.refreshedSelectedRecordIds = [];
                state.shouldBeRefreshed = false;
            }
            let recordIds = targetRecords.map(acc => acc.Id);

            if ( ! state.recordIds.length) {
                state.targetRecordIds = recordIds;
                state.recordIds = recordIds;
            } else {
                recordIds.forEach(id => state.recordIds.indexOf(id) === -1 ? state.targetRecordIds.push(id) : undefined);
                recordIds.forEach(id => state.recordIds.indexOf(id) === -1 ? state.recordIds.push(id) : undefined);
            }
        };

        const updateStateAfterSaving = function updateStateAfterSaving(records) {
            state.shouldBeRefreshed = true;

            let recordIds = [];
            state.recordIds.forEach(id => records.find(row => row.Id === id) ? undefined : recordIds.push(id));

            state.refreshedRecordIds = recordIds;
            state.refreshedSelectedRecordIds = [];
        };

        const setRecords = function setRecords() {
            setSelectedRecordIds(state.targetRecordIds);
            setSelectedRows(state.targetRecordIds);
        };

        const handleOnClickSavingTargetRecords = function handleOnClickSavingTargetRecords() {
            const records = getSelectedRows();

            const RecordsIsSelectedEvent = helper.component.getEvent(constants.events.RecordsIsSelectedEvent);
            RecordsIsSelectedEvent.setParams({
                type: 'CartTable',
                records: records
            });
            RecordsIsSelectedEvent.fire();

            updateStateAfterSaving(records);
        };

        /* ========================================================= */
        /*     Getters
        /* ========================================================= */
        const getSelectedRecords = function getSelectedRecords() {
            return helper.component.get(constants.attributes.targetRecords);
        };

        const getSelectedRows = function getSelectedRows() {
            return helper.component.find(constants.auraId).getSelectedRows();
        };

        /* ========================================================= */
        /*     Setters
        /* ========================================================= */
        const setSelectedRecordIds = function setSelectedRecordIds(data) {
            helper.component.set(constants.attributes.targetRecordIds, data);
        };

        const setSelectedRows = function setSelectedRows(data) {
            helper.component.find(constants.auraId).set(constants.attributes.selectedRows, data);
        };

        return {
            handleOnTargetRecordsRowSelection: handleOnTargetRecordsRowSelection,
            handleOnChangeTargetRecords: handleOnChangeTargetRecords,

            getSelectedRows: getSelectedRows,

            setRecords: setRecords,
            handleOnClickSavingTargetRecords: handleOnClickSavingTargetRecords,
        }
    },


    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    handleOnInit: function (component) {
        this.component = component;

        this.parentModalWindowCmp = this.parentModalWindowCmpInitialization(this);
        this.assignedRecordsCmp = this.assignedRecordsCmpInitialization(this);
        this.targetRecordsCmp = this.targetRecordsCmpInitialization(this);
    },

});