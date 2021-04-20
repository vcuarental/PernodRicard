({

    component: null,
    _constants: {
        serverSideActions: {
            getSelectionMethods: 'c.getSelectionMethodOptions',
            getPROSTable: 'c.getPROSTable',
            getPROFS: 'c.getPROFS',
        },
        attributes: {
            sObjectName: 'v.sObjectName',
            selectionMethods: 'v.selectionMethods',
            selectionMethod: 'v.selectionMethod',
            pros: 'v.pros',
            profs: 'v.profs',
            selectedRows: 'v.selectedRows',
            profsColumns: 'v.profsColumns',
            text: 'v.text',
            value: 'v.value',
        },
        events: {
            filtersValidationEvent: 'filtersValidationEvent'
        },
        selectionMethods: {
            pros: 'PROS',
            profs: 'PROFS',
        },
        auraIds: {
            profsTable: 'profsTable',
            imageLevelCheckboxes: 'imageLevelCheckboxes'
        },
        profsColumns: [
            { label: 'Name', fieldName: 'Name', type: 'text'},
        ],
        fieldApiNames: {
            gotRTDevName: 'EUR_CRM_PRS_Group_Outlet_Type__r.RecordType.DeveloperName',
            ilRTDevName: 'EUR_CRM_Image_Level__r.RecordType.DeveloperName',
            gotName: 'EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_PRS_Group_Outlet_Name__c',
            ilAspectName: 'EUR_CRM_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c',
        },
        fieldConstants: {
            gotRTOn: '_PRS_On_Trade_Group_Outlet_Type',
            gotRTMaskOn: '\'%_PRS_On_Trade_Group_Outlet_Type\'',
            gotRTOff: '_PRS_Off_Trade_Group_Outlet_Type',
            gotRTMaskOff: '\'%_PRS_Off_Trade_Group_Outlet_Type\'',
            ilRT: '_PRS_Segmentation_Aspect_Image_Level',
            ilRTMask: '\'%_PRS_Segmentation_Aspect_Image_Level\'',
        },
        none: '--None--',
        arguments: 'arguments',
    },

    state: {
        criteria: {
            items: null,
        }
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
    /*     Method Handlers
    /* ========================================================= */
    handleOnSetInitialItems: function (event) {
        const params = event.getParam(this._constants.arguments);
        if ( ! this.isConditionItemsExist(params)) { return; }

        this.state.criteria.items = params.conditionItems;
        console.log('this.state.criteria.items => ', this.state.criteria.items);

        if (this.isEmptyPros()) { this.downloadPros(); }
        if (this.isEmptyProfs()) { this.downloadProfs(); }
    },

    handleOnValidate: function () {
        try {
            this.buildQueryAndSendResult();
        } catch(e) {
            this.sendResult(JSON.parse(e.message));
        }
    },


    /* ========================================================= */
    /*     Interactions
    /* ========================================================= */
    handleOnChangedSelectionMethod: function () {
        const selectionMethod = this._getSelectionMethod();

        if (selectionMethod === this._constants.selectionMethods.pros) {
            if (this.isEmptyPros()) {
                this.downloadPros();
            }
        } else if (selectionMethod === this._constants.selectionMethods.profs) {
            if (this.isEmptyProfs()) {
                this.downloadProfs();
            }
        }
    },

    handleOnChangedImageLevel: function (event) {
        let target = event.getSource();
        let imageLevel = target.get(this._constants.attributes.text);
        let value = target.get(this._constants.attributes.value);

        let pros = this._getPros();
        pros.forEach(p => p.imageLevelCheckboxWrappers.find(il => il.imageLevelName === imageLevel).isChecked = value);
        this._setPros(pros);
    },

    handleOnChangedGOT: function (event) {
        let target = event.getSource();
        let got = target.get(this._constants.attributes.text);
        let value = target.get(this._constants.attributes.value);

        let pros = this._getPros();
        pros.find(p => p.groupOutletType === got).imageLevelCheckboxWrappers.forEach(il => il.isChecked = value);
        this._setPros(pros);
    },

    handleOnChangedInnerPros: function (event) {
        let target = event.getSource();
        let position = target.get(this._constants.attributes.text);

        let got = position.split('_')[0];
        let imageLevel = position.split('_')[1];

        let pros = this._getPros();
        // select/unselect Group Outlet Type checkboxes
        pros.find(row => row.groupOutletType === got).selectAll = pros.find(row => row.groupOutletType === got).imageLevelCheckboxWrappers.every(il => il.isChecked);
        this._setPros(pros);

        // select/unselect Image Level checkboxes
        let checkboxes = this._getImageLevelCheckboxes();
        checkboxes.find(checkbox => checkbox.get(this._constants.attributes.text) === imageLevel)
            .set(this._constants.attributes.value, pros.every(row => row.imageLevelCheckboxWrappers.find(il => il.imageLevelName === imageLevel).isChecked));
    },


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    buildQueryAndSendResult: function() {
        const condition = this.configureConditionSubQuery();
        console.log('condition => ', condition);

        if ( ! condition) {
            this.sendResult({
                success: true,
                message: 'OK',
                filter: {
                    testQuery: '',
                    objectName: this._getSObjectName(),
                    items: [],
                    filterLogic: ''
                }
            });
            return;
        }

        const items = this.makeItems();
        console.log('items => ', items);

        const filterLogic = this.configureFilterLogic();
        console.log('filterLogic => ', filterLogic);

        const response = {
            success: true,
            message: 'OK',
            filter: {
                testQuery: 'SELECT Id FROM ' + this._getSObjectName() + ' ' + condition,
                objectName: this._getSObjectName(),
                items: items,
                filterLogic: filterLogic,
                parentRelationType: 'contains',
            }
        };
        console.log('response => ', response);
        this.sendResult(response);
    },


    /* ========================================================= */
    /*     Server-Side Actions
    /* ========================================================= */
    downloadSelectionMethods: function () {
        this.component.lax.enqueue(this._constants.serverSideActions.getSelectionMethods).then(selectionMethods => {
            this._setSelectionMethods(this.filterSelectOptions(selectionMethods));
        });
    },

    downloadPros: function () {
        this.component.lax.enqueue(this._constants.serverSideActions.getPROSTable).then(pros => {
            this._setPros(this.setSelectedPROS(pros));
        });
    },

    downloadProfs: function () {
        this.component.lax.enqueue(this._constants.serverSideActions.getPROFS).then(profs => {
            this._setProfs(profs);
            this.setSelectedPROFS();
        });
    },


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    setSelectedPROS: function (pros) {
        const items = this.state.criteria.items;
        if ( ! items || items[0].field !== this._constants.fieldApiNames.gotRTDevName
            || items[1].field !== this._constants.fieldApiNames.ilRTDevName) {
            return pros;
        }

        for (let i = 2; i < items.length; i++) {
            let got = items[i].value;
            let il = items[++i].value;
            if (got === this._constants.fieldConstants.ilRT || il === this._constants.fieldConstants.ilRT) {
                break;
            }
            console.log(JSON.stringify(pros.find(row => row.groupOutletType === got)));
            try {
                pros.find(row => row.groupOutletType === got).imageLevelCheckboxWrappers.find(column => column.imageLevelName === il).isChecked = true;
            } catch (e) {
                console.log(e);
            }
        }
        return pros;
    },

    setSelectedPROFS: function () {
        const items = this.state.criteria.items;

        let profsItemIndex = this.getPROFSRTItemIndex(items);
        if (profsItemIndex === undefined) { return; }
        profsItemIndex = Number.parseInt(profsItemIndex);

        this._setSelectedProfs(this.extractSelectedProfsFromItems(items, profsItemIndex));
    },

    configureConditionSubQuery: function () {
        if (this.isEmptySelectedPros() && this.isEmptySelectedProfs()) { return ''; }

        const prosPairs = this.getListOfSelectedPROSPairs();
        const profsOptions = this.getListOfSelectedPROFS();

        const groupOfOutletFieldAPI = this._constants.fieldApiNames.gotName;
        const imageLevelFieldAPI = this._constants.fieldApiNames.ilAspectName;

        const prosCondition = this.createPROSCondition(prosPairs, groupOfOutletFieldAPI, imageLevelFieldAPI);
        console.log('prosCondition => ', prosCondition);

        const profsCondition = this.cretePROFSCondition(profsOptions, groupOfOutletFieldAPI);
        console.log('profsCondition => ', profsCondition);

        return 'WHERE '
            + (prosCondition ? '(' + prosCondition + ')' : '')
            + (profsCondition ? (prosCondition ? ' OR (' + profsCondition + ')' : '(' + profsCondition + ')') : '')
        ;
    },

    makeItems: function () {
        const prosItems = this.getPROSItems();
        const profsItems = this.getPROFSItems();

        return [].concat(prosItems).concat(profsItems);
    },

    configureFilterLogic: function () {
        if (this.isEmptySelectedPros() && this.isEmptySelectedProfs()) { return ''; }

        const prosFilterLogic = this.getPROSFilterLogic();

        const lastNumber = this.getLastNumber(prosFilterLogic);
        const profsFilterLogic = this.getPROFSFilterLogic(lastNumber + 1);

        return prosFilterLogic + ' ' + profsFilterLogic;
    },


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    filterSelectOptions: function (selectOptions) {
        return selectOptions.reduce((accumulator, option) => {
            this.isMatchedSelectedOption(option) ? accumulator.push(option) : undefined;
            return accumulator;
        }, []);
    },

    getPROFSRTItemIndex: function (items) {
        let result = undefined;
        if ( ! items) { return result; }

        items.forEach((item, index) => {
            item.field === this._constants.fieldApiNames.gotRTDevName &&
            item.value === this._constants.fieldConstants.gotRTOff ? result = index : undefined;
        });
        return result;
    },

    extractSelectedProfsFromItems: function (items, profsItemIndex) {
        const selectedProfs = [];
        for (let i = ++profsItemIndex; i < items.length; i++) {
            if (items[i].field !== this._constants.fieldApiNames.gotName) { break; }
            selectedProfs.push(items[i].value);
        }
        return selectedProfs;
    },

    getListOfSelectedPROSPairs: function () {
        const pros = this._getPros();
        const prosPairs = [];
        pros.forEach(row =>
            row.imageLevelCheckboxWrappers.forEach(
                column => column.isChecked ? prosPairs.push(row.groupOutletType + '_' + column.imageLevelName) : undefined
            )
        );
        return prosPairs;
    },

    getListOfSelectedPROFS: function () {
        const profs = this._getSelectedProfs();

        const profsOptions = [];
        profs.forEach(row => profsOptions.push(row.Name));
        return profsOptions;
    },

    createPROSCondition: function (prosPairs, groupOfOutletFieldAPI, imageLevelFieldAPI) {
        if (this.isEmptySelectedPros()) { return ''; }

        let condition = this._constants.fieldApiNames.gotRTDevName + ' LIKE ' + this._constants.fieldConstants.gotRTMaskOn + ' ';
        condition += 'AND ' + this._constants.fieldApiNames.ilRTDevName + ' LIKE ' + this._constants.fieldConstants.ilRTMask + ' AND (';

        prosPairs.forEach(pair => {
            const got = pair.split('_')[0];
            const il = pair.split('_')[1];
            condition += '(' + groupOfOutletFieldAPI + '=\'' + got + '\' AND ' + imageLevelFieldAPI + '=\'' + il + '\')';
        });
        condition = condition.replace(new RegExp(/\)\(/, 'g'), ') OR (');
        condition += ')';
        return condition;
    },

    cretePROFSCondition: function (profsOptions, groupOfOutletFieldAPI) {
        if (this.isEmptySelectedProfs()) { return ''; }

        let condition = this._constants.fieldApiNames.gotRTDevName + ' LIKE ' + this._constants.fieldConstants.gotRTMaskOff + ' AND (';

        profsOptions.forEach(option => condition += groupOfOutletFieldAPI + '=\'' + option + '\'');
        condition = condition.replace(new RegExp('\'' + groupOfOutletFieldAPI, 'g'), '\'' + ' OR ' + groupOfOutletFieldAPI);
        condition += ')';
        return condition;
    },

    getPROSItems: function () {
        if (this.isEmptySelectedPros()) { return []; }

        const prosItems = [];
        prosItems.push(this.makeItem(this._constants.fieldApiNames.gotRTDevName, 'ends with', this._constants.fieldConstants.gotRTOn));
        prosItems.push(this.makeItem(this._constants.fieldApiNames.ilRTDevName, 'ends with', this._constants.fieldConstants.ilRT));

        const groupOfOutletFieldAPI = this._constants.fieldApiNames.gotName;
        const imageLevelFieldAPI = this._constants.fieldApiNames.ilAspectName;

        const prosPairs = this.getListOfSelectedPROSPairs();
        prosPairs.forEach(pair => {
            prosItems.push(this.makeItem(groupOfOutletFieldAPI, 'equals', pair.split('_')[0]));
            prosItems.push(this.makeItem(imageLevelFieldAPI, 'equals', pair.split('_')[1]));
        });
        return prosItems;
    },

    getPROFSItems: function () {
        if (this.isEmptySelectedProfs()) { return []; }

        const profsItems = [];
        profsItems.push(this.makeItem(this._constants.fieldApiNames.gotRTDevName, 'ends with', this._constants.fieldConstants.gotRTOff));

        const gotFieldAPI = this._constants.fieldApiNames.gotName;

        const profsOptions = this.getListOfSelectedPROFS();
        profsOptions.forEach(option => {
            profsItems.push(this.makeItem(gotFieldAPI, 'equals', option));
        });
        return profsItems;
    },

    getPROSFilterLogic: function () {
        if (this.isEmptySelectedPros()) { return ''; }

        let filterLogic = '(1 AND 2 AND (';

        let currentNumber = 3;
        const prosPairs = this.getListOfSelectedPROSPairs();
        prosPairs.forEach(pair => filterLogic += ('(' + currentNumber++ + ' AND ' + currentNumber++ + ')'));
        filterLogic = filterLogic.replace(new RegExp(/\)\(/, 'g'), ') OR (');
        filterLogic += '))';
        return filterLogic;
    },

    getLastNumber: function (prosFilterLogic) {
        if (prosFilterLogic.lastIndexOf(')))') > -1) {
            return Number.parseInt(prosFilterLogic.substr(prosFilterLogic.lastIndexOf(')))') - 2, 2).trim());
        } else if (prosFilterLogic.lastIndexOf('))') > -1) {
            return Number.parseInt(prosFilterLogic.substr(prosFilterLogic.lastIndexOf('))') - 2, 2).trim());
        } else if (prosFilterLogic.lastIndexOf(')') > -1) {
            return Number.parseInt(prosFilterLogic.substr(prosFilterLogic.lastIndexOf(')') - 1, 2).trim());
        } else if (prosFilterLogic) {
            return Number.parseInt(prosFilterLogic);
        }

        return 0;
    },

    getPROFSFilterLogic: function (lastNumber) {
        if (this.isEmptySelectedProfs()) { return ''; }

        const profsOptions = this.getListOfSelectedPROFS();
        let filterLogic = '';
        if (lastNumber > 2) {
            filterLogic += 'OR ';
        }

        filterLogic += '(' + lastNumber++ + ' AND (';
        profsOptions.forEach(option => filterLogic += lastNumber++ + ' OR ');
        filterLogic = filterLogic.substr(0, filterLogic.lastIndexOf(' OR '));
        filterLogic += '))';
        return filterLogic;
    },


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    isMatchedSelectedOption: function (option) {
        return option.label === this._constants.none
            || option.label === this._constants.selectionMethods.pros
            || option.label === this._constants.selectionMethods.profs
        ;
    },

    isConditionItemsExist: function (params) {
        return params.conditionItems && params.conditionItems.length;
    },

    isEmptyPros: function () {
        return this._getPros().length === 0;
    },

    isEmptyProfs: function () {
        return this._getProfs().length === 0;
    },

    isEmptySelectedPros: function () {
        return ! this.getListOfSelectedPROSPairs().length;
    },

    isEmptySelectedProfs: function () {
        return ! this.getListOfSelectedPROFS().length;
    },

    makeItem: function (field, operator, value) {
        return {
            field,
            operator,
            value
        };
    },


    /* ========================================================= */
    /*     Event Firing methods
    /* ========================================================= */
    sendResult: function(result) {
        const filtersValidationEvent = this.component.getEvent(this._constants.events.filtersValidationEvent);
        filtersValidationEvent.setParams({
            result: result
        });
        filtersValidationEvent.fire();
    },


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    _getSelectionMethod: function () {
        return this.component.get(this._constants.attributes.selectionMethod);
    },

    _getPros: function () {
        return this.component.get(this._constants.attributes.pros);
    },

    _getProfs: function () {
        return this.component.get(this._constants.attributes.profs);
    },

    _getSelectedProfs: function () {
        try {
            return this.component.find(this._constants.auraIds.profsTable).getSelectedRows();
        } catch (e) {
            return [];
        }
    },

    _getSObjectName: function () {
        return this.component.get(this._constants.attributes.sObjectName);
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

    _setProfsColumns: function (data) {
        this.component.set(this._constants.attributes.profsColumns, data);
    },

    _setPros: function (data) {
        this.component.set(this._constants.attributes.pros, data);
    },

    _setProfs: function (data) {
        this.component.set(this._constants.attributes.profs, data);
    },

    _setSelectedProfs: function (data) {
        setTimeout($A.getCallback(() => {
            this.component.find(this._constants.auraIds.profsTable).set(this._constants.attributes.selectedRows, data);
        }), 0);
    },

});