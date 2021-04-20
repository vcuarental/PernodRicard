import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import eur_doc_headerstyle from '@salesforce/resourceUrl/eur_doc_headerstyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import initModulesPicklist from '@salesforce/apex/EUR_DOC_DocServerController.initModulesPicklist';
import checkIfUserIsRussian from '@salesforce/apex/EUR_DOC_DocServerController.checkIfUserIsRussian';
import checkIfUserIsFinland from '@salesforce/apex/EUR_DOC_DocServerController.checkIfUserIsFinland';
import initBSbqPicklist from '@salesforce/apex/EUR_DOC_DocServerController.initBSbqPicklist';
import getTaxonomyChainConfigOK from '@salesforce/apex/EUR_DOC_DocServerController.getTaxonomyChainConfigOK';
import { fireEvent } from 'c/eur_doc_pubsub';
import apexSearchAccounts from '@salesforce/apex/EUR_DOC_SampleLookupController.searchAccounts';
import apexSearchUsers from '@salesforce/apex/EUR_DOC_SampleLookupController.searchUsers';
import apexSearchTaxonomy from '@salesforce/apex/EUR_DOC_SampleLookupController.searchTaxonomy';
import apexSearchTerritory from '@salesforce/apex/EUR_DOC_SampleLookupController.searchTerritory';
import apexSearchRegion from '@salesforce/apex/EUR_DOC_SampleLookupController.searchRegion';
import apexSearchObjectivePromotion from '@salesforce/apex/EUR_DOC_SampleLookupController.searchObjectivePromotion';
import apexSearchPOSM from '@salesforce/apex/EUR_DOC_SampleLookupController.searchPOSM';
import apexSearchB from '@salesforce/apex/EUR_DOC_SampleLookupController.searchB';
import apexSearchBQ from '@salesforce/apex/EUR_DOC_SampleLookupController.searchBQ';
import apexSearchBQS from '@salesforce/apex/EUR_DOC_SampleLookupController.searchBQS';
import apexSearchToolkit from '@salesforce/apex/EUR_DOC_SampleLookupController.searchToolkit';
import apexSearchSKU from '@salesforce/apex/EUR_DOC_SampleLookupController.searchSKU';
//const DELAY = 350;

export default class Eur_doc_filters extends LightningElement {
    date = null;
    @track earlierDate = null;
    @track laterDate = null;
    @track module = null;
    @track moduleList = null;
    @track loading = false;
    @track bsbqOptions = null;
    @track isOnTrade = true;
    @track isOffTrade = false;
    @track isDistributor = false;
    @track isOther = false;
    @track isTaxonomyChainConfigOK = true;
    @track hasAccountSelected = false;
    @track hasTaxonomySelected = false;
    @track hasTerritorySelected = false;
    @track hasRegionSelected = false;
    @track hasBSelected = false;
    @track hasBQSelected = false;
    @track hasBQSSelected = false;
    @track hasSKUSelected = false;
    @track hasPOSMSelected = false;
    @track hasToolkitSelected = false;
    @track isRussianUser;
    @track isFinlandUser;
    @track onTradeButtonStyle = "brand";
    @track offTradeButtonStyle = "Neutral";
    @track distributorButtonStyle = "Neutral";
    @track othersButtonStyle = "Neutral";
    @track debug = '';


    @track filters = {
        timestamp: null,
        earlierDate: null,
        laterDate: null,
        account: '',
        user: '',
        taxonomy: '',
        taxonomychain: '',
        territory: '',
        region: '',
        epicenter: false,
        module: 'ALL',
        posm: '',
        opcode: '',
        op: '',
        isOnTrade: '',
        isOffTrade: '',
        isDistributor: '',
        isOther: '',
        b: '',
        bq: '',
        bqs: '',
        sku: '',
        toolkit: '',
        bsbq: ''
    };

    connectedCallback() {
        Promise.all([
            loadStyle(this, eur_doc_headerstyle)
        ]).then(() => {
            this.loading = true;
            this.date = new Date();
            this.laterDate = this.date.toISOString().slice(0, 10);
            this.filters.laterDate = this.laterDate;
            this.date.setDate(this.date.getDate() - 7);
            this.earlierDate = this.date.toISOString().slice(0, 10);
            this.filters.earlierDate = this.earlierDate;
            this.module = 'ALL';
            this.filters.isOnTrade = true;
            this.filters.isOffTrade = false;
            this.filters.isDistributor = false;
            this.filters.isOther = false;
            initModulesPicklist().then(result => {
                this.moduleList = result;
                initBSbqPicklist().then(result => {
                    this.bsbqOptions = result;
                    this.loading = false;
                });
            });
            checkIfUserIsRussian().then(result => {
                this.isRussianUser = result;
            });
            checkIfUserIsFinland().then(result => {
                this.isFinlandUser = result;
            });
            getTaxonomyChainConfigOK().then(result => {
                this.isTaxonomyChainConfigOK = result;
            });
        })
    }

    @wire(CurrentPageReference) pageRef;

    handleEarlyDateChange(event) {
        this.filters.earlierDate = event.target.value;
    }

    handleLateDateChange(event) {
        this.filters.laterDate = event.target.value;
    }

    handleModuleChange(event) {
        this.filters.module = event.target.value;
        this.module = event.target.value;
        this.clearSpecificfilters();

        if (!this.isbFilterAvailable) {
            this.filters.b = '';
            this.hasBSelected = false;
        }

        if (!this.isbqFilterAvailable) {
            this.filters.bq = '';
            this.hasBQSelected = false;
        }

        if (!this.isbqFilterAvailable) {
            this.filters.bqs = '';
            this.hasBQSSelected = false;
        }

        if (!this.isSKUFilterAvailable) {
            this.filters.sku = '';
            this.hasSKUSelected = false;
        }

        if (!this.isToolkitFilterAvailable) {
            this.filters.toolkit = '';
            this.hasToolkitSelected = false;
        }
        if (!this.isPOSMFilterAvailable) {
            this.filters.posm = '';
            this.hasPOSMSelected = false;
        }

        //this.debug = JSON.stringify(this.filters);
    }

    clearSpecificfilters() {
        this.filters.posm = '';
        this.filters.opcode = '';
        this.filters.op = '';
        this.filters.bsbq = '';
        this.filters.toolkit = '';
    }

    handleTaxChainChange(event) {
        this.filters.taxonomychain = event.target.value;
    }

    onTradeSelected() {
        if (this.hasAccountSelected) {
            this.isOnTrade = true;
            this.filters.isOnTrade = true;
            this.onTradeButtonStyle = "brand";
            this.isOffTrade = false;
            this.filters.isOffTrade = false;
            this.offTradeButtonStyle = "Neutral";
            this.isDistributor = false;
            this.filters.isDistributor = false;
            this.distributorButtonStyle = "Neutral";
            this.isOther = false;
            this.filters.isOther = false;
            this.othersButtonStyle = "Neutral";
        } else if (!this.isOnTrade) {
            this.isOnTrade = true;
            this.filters.isOnTrade = true;
            this.onTradeButtonStyle = "brand";
        } else if (this.isOffTrade || this.isDistributor || this.isOther) {
            this.isOnTrade = false;
            this.filters.isOnTrade = false;
            this.onTradeButtonStyle = "Neutral";
        }
    }

    offTradeSelected() {
        if (this.hasAccountSelected) {
            this.isOffTrade = true;
            this.filters.isOffTrade = true;
            this.offTradeButtonStyle = "brand";
            this.isOnTrade = false;
            this.filters.isOnTrade = false;
            this.onTradeButtonStyle = "Neutral";
            this.isDistributor = false;
            this.filters.isDistributor = false;
            this.distributorButtonStyle = "Neutral";
            this.isOther = false;
            this.filters.isOther = false;
            this.othersButtonStyle = "Neutral";
        }
        if (!this.isOffTrade) {
            this.isOffTrade = true;
            this.filters.isOffTrade = true;
            this.offTradeButtonStyle = "brand";
        } else if (this.isOnTrade || this.isDistributor || this.isOther) {
            this.isOffTrade = false;
            this.filters.isOffTrade = false;
            this.offTradeButtonStyle = "Neutral";
        }
    }

    distributorSelected() {
        if (this.hasAccountSelected) {
            this.isOffTrade = false;
            this.filters.isOffTrade = false;
            this.offTradeButtonStyle = "Neutral";
            this.isOnTrade = false;
            this.filters.isOnTrade = false;
            this.onTradeButtonStyle = "Neutral";
            this.isDistributor = true;
            this.filters.isDistributor = true;
            this.distributorButtonStyle = "brand";
            this.isOther = false;
            this.filters.isOther = false;
            this.othersButtonStyle = "Neutral";
        }
        if (!this.isDistributor) {
            this.isDistributor = true;
            this.filters.isDistributor = true;
            this.distributorButtonStyle = "brand";
        } else if (this.isOnTrade || this.isOffTrade || this.isOther) {
            this.isDistributor = false;
            this.filters.isDistributor = false;
            this.distributorButtonStyle = "Neutral";
        }
    }

    othersSelected() {
        if (this.hasAccountSelected) {
            this.isOffTrade = false;
            this.filters.isOffTrade = false;
            this.offTradeButtonStyle = "Neutral";
            this.isOnTrade = false;
            this.filters.isOnTrade = false;
            this.onTradeButtonStyle = "Neutral";
            this.isDistributor = false;
            this.filters.isDistributor = false;
            this.distributorButtonStyle = "Neutral";
            this.isOther = true;
            this.filters.isOther = true;
            this.othersButtonStyle = "brand";
        }
        if (!this.isOther) {
            this.isOther = true;
            this.filters.isOther = true;
            this.othersButtonStyle = "brand";
        } else if (this.isOnTrade || this.isOffTrade || this.isDistributor) {
            this.isOther = false;
            this.filters.isOther = false;
            this.othersButtonStyle = "Neutral";
        }
    }

    toggleEpicenter(event) {
        this.filters.epicenter = event.target.checked;
    }

    triggerSearch() {
        this.debug = this.filters.region + ' ' + this.filters.territory;
        if (this.filters.earlierDate == null || this.filters.laterDate == null) {
            this.notifyUser("Empty Date", "Please fill in Date filter, in order to retrieve results.", "error");
        } else {
            this.filters.timestamp = new Date();
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            fireEvent(this.pageRef, 'triggerSearch', this.filters);
        }
    }

    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
    }



    get isPOModuleSelected() {
        return this.module === "PO" ? true : false;
    }

    get isPOSMModuleSelected() {
        return this.module === "POSM" || this.module === "SA" ? true : false;
    }

    get isOPModuleSelected() {
        return this.module === "OP" ? true : false;
    }

    get isCPTModuleSelected() {
        return this.module === "CPT" ? true : false;
    }

    get isBSModuleSelected() {
        return this.module === "BS" ? true : false;
    }

    get isSOModuleSelected() {
        return this.module === "SO" ? true : false;
    }

    get isVAModuleSelected() {
        return this.module === "VA" ? true : false;
    }

    get isMENUModuleSelected() {
        return this.module === "MENU" ? true : false;
    }

    isProductFilterAvailable(productLevel) {
        let matrix = [
            { module: 'OP', filtersAllowed: ['b', 'bq', 'bqs'] },
            { module: 'BSI', filtersAllowed: [] },
            { module: 'CPT', filtersAllowed: ['bq', 'bqs'] },
            { module: 'POSM', filtersAllowed: ['b', 'posm'] },
            { module: 'PO', filtersAllowed: ['bq'] },
            { module: 'MENU', filtersAllowed: ['b', 'bq'] },
            { module: 'VA', filtersAllowed: ['b', 'bq', 'bqs', 'sku', 'toolkit'] },
            { module: 'ALL', filtersAllowed: ['b', 'bq', 'bqs', 'sku', 'toolkit', 'posm'] }
        ];

        let isOtherFilterSelected = false;
        if (this.hasBSelected && productLevel !== 'b') {
            isOtherFilterSelected = true;
        } else if (this.hasBQSelected && productLevel !== 'bq') {
            isOtherFilterSelected = true;
        } else if (this.hasBQSSelected && productLevel !== 'bqs') {
            isOtherFilterSelected = true;
        } else if (this.hasSKUSelected && productLevel !== 'sku') {
            isOtherFilterSelected = true;
        } else if (this.hasPOSMSelected && productLevel !== 'posm') {
            isOtherFilterSelected = true;
        } else if (this.hasToolkitSelected && productLevel !== 'toolkit') {
            isOtherFilterSelected = true;
        }

        if (isOtherFilterSelected == false) {
            for (let i = 0; i < matrix.length; i++) {
                if (this.module === matrix[i].module) {
                    return matrix[i].filtersAllowed.includes(productLevel)
                }
            }
        }

        return false;

    }

    //Is Brand
    get isbFilterAvailable() {
        return this.isProductFilterAvailable('b');
    }

    //Is BRand Quality
    get isbqFilterAvailable() {
        return this.isProductFilterAvailable('bq');
    }


    //Is Brand Quality Size
    get isbqsFilterAvailable() {
        return this.isProductFilterAvailable('bqs');
    }

    //Is SKU
    get isSKUFilterAvailable() {
        return this.isProductFilterAvailable('sku');
    }

    //Is Product Toolkit
    get isToolkitFilterAvailable() {
        return this.isFinlandUser && this.isProductFilterAvailable('toolkit');
    }

    //Is Product Toolkit
    get isPOSMFilterAvailable() {
        return this.isFinlandUser && this.isProductFilterAvailable('posm');
    }



    get getOPCodeLabel() {
        return this.isRussianUser ? 'Maf Id' : 'OP Code';
    }

    get isOPSelected() {
        return this.filters.op !== '' ? true : false;
    }

    get getChainDisabled() {
        return this.isTaxonomyChainConfigOK ? false : true;
    }

    get getChainPlaceHolder() {
        return this.isTaxonomyChainConfigOK ? '' : 'The metadata is not configured. Contact an admin.';
    }




    @track initialSelection = [];
    @track errors = [];
    @track isMultiEntry = false;
    @track debug = '';
    indice = 0;
    @track lkp_user = 'lkp_user';
    @track lkp_acc = 'lkp_acc';
    @track lkp_taxo = 'lkp_taxo';
    @track lkp_terr = 'lkp_terr';
    @track lkp_reg = 'lkp_reg';
    @track lkp_posm = 'lkp_posm';
    @track lkp_op = 'lkp_op';
    @track lkp_b = 'lkp_b';
    @track lkp_bq = 'lkp_bq';
    @track lkp_bqs = 'lkp_bqs';
    @track lkp_sku = 'lkp_sku';
    @track lkp_toolkit = 'lkp_toolkit';

    handleUsersSearch(event) {
        apexSearchUsers(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_user');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleUsersSelectionChange() {
        this.errors = [];
        let el = this.getRightLookup('lkp_user');
        const selection = el.getSelection();
        if (selection.length > 0) {
            this.filters.user = selection[0].id;
        } else {
            this.filters.user = '';
        }
    }

    /*
     * BEGIN ACCOUNT
     */
    handleAccountsSearch(event) {
        apexSearchAccounts(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_acc');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleAccountsSelectionChange() {
        this.errors = [];
        let el = this.getRightLookup('lkp_acc');
        const selection = el.getSelection();
        if (selection.length > 0) {
            this.filters.account = selection[0].id;
            this.clearAccountfilters();
            this.hasAccountSelected = true;
            if (selection[0].other === "ON") {
                this.onTradeSelected();
            } else if (selection[0].other === "OFF") {
                this.offTradeSelected();
            } else if (selection[0].other === "Distributor") {
                this.distributorSelected();
            } else if (selection[0].other === "Others") {
                this.othersSelected();
            }
        } else {
            this.filters.account = '';
            this.onTradeSelected();
            this.hasAccountSelected = false;
        }
    }

    clearAccountfilters() {
            this.filters.taxonomychain = '';
            this.filters.taxonomy = '';
            this.filters.territory = '';
            this.filters.region = '';
            this.filters.epicenter = false;
            this.hasTerritorySelected = false;
            this.hasRegionSelected = false;
        }
        /*
         * END ACCOUNT
         */


    /*
     *   BEGIN TAXONOMY
     */
    handleTaxonomySearch(event) {
        apexSearchTaxonomy(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_taxo');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleTaxonomySelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_taxo');
            const selection = el.getSelection();
            if (selection.length > 0) {
                this.filters.taxonomy = selection[0].id;
                this.hasTaxonomySelected = true;
                this.filters.taxonomychain = '';
            } else {
                this.filters.taxonomy = '';
                this.hasTaxonomySelected = false;
            }
        }
        /*
         *   END TAXONOMY
         */




    /*
     *   BEGIN TERRITORY
     */
    handleTerritorySearch(event) {
        apexSearchTerritory(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_terr');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleTerritorySelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_terr');
            const selection = el.getSelection();
            if (selection.length > 0) {
                this.filters.territory = selection[0].id;
                this.hasTerritorySelected = true;
            } else {
                this.filters.territory = '';
                this.hasTerritorySelected = false;
            }
        }
        /*
         *   END TERRITORY
         */



    /*
     * BEGIN REGION
     */
    handleRegionSearch(event) {
        apexSearchRegion(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_reg');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleRegionSelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_reg');
            const selection = el.getSelection();
            if (selection.length > 0) {
                this.filters.region = selection[0].id;
                this.hasRegionSelected = true;
            } else {
                this.filters.region = '';
                this.hasRegionSelected = false;
            }
        }
        /*
         * END REGION
         */


    /*
     * BEGIN OBJECTIVE / PROMOTION 
     */
    handleOPSearch(event) {
        apexSearchObjectivePromotion(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_op');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field : ' + JSON.stringify(error), 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleOPSelectionChange() {
        this.errors = [];
        let el = this.getRightLookup('lkp_op');
        const selection = el.getSelection();
        this.debug = JSON.stringify(selection);
        if (selection.length > 0) {
            this.filters.op = selection[0].id;
            this.filters.opcode = '';
        } else {
            this.filters.op = '';
        }
    }

    handleOPCodeChange(event) {
        this.filters.opcode = event.target.value;
    }

    /*
     * END OBJECTIVE / PROMOTION 
     */

    /*
     * BEGIN POSM
     */
    handlePOSMSearch(event) {

        apexSearchPOSM(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_posm');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handlePOSMSelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_posm');
            const selection = el.getSelection();
            this.debug = JSON.stringify(selection);
            if (selection.length > 0) {
                this.filters.posm = selection[0].id;
                this.hasPOSMSelected = true;
            } else {
                this.filters.posm = '';
                this.hasPOSMSelected = false;
            }
        }
        /*
         * END POSM
         */

    /*
     * BEGIN Brand
     */
    handleBSearch(event) {
        apexSearchB(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_b');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleBSelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_b');
            const selection = el.getSelection();
            this.debug = JSON.stringify(selection);
            if (selection.length > 0) {
                this.filters.b = selection[0].id;
                this.hasBSelected = true;
            } else {
                this.filters.b = '';
                this.hasBSelected = false;
            }
        }
        /*
         * END Brand
         */

    /*
     * BEGIN Brand Quality
     */
    handleBQSearch(event) {
        apexSearchBQ(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_bq');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleBQSelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_bq');
            const selection = el.getSelection();
            this.debug = JSON.stringify(selection);
            if (selection.length > 0) {
                this.filters.bq = selection[0].id;
                this.hasBQSelected = true;
            } else {
                this.filters.bq = '';
                this.hasBQSelected = false;
            }
        }
        /*
         * END Brand Quality
         */


    /*
     * BEGIN Brand Quality Size
     */
    handleBQSSearch(event) {
        apexSearchBQS(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_bqs');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleBQSSelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_bqs');
            const selection = el.getSelection();
            this.debug = JSON.stringify(selection);
            if (selection.length > 0) {
                this.filters.bqs = selection[0].id;
                this.hasBQSSelected = true;
            } else {
                this.filters.bqs = '';
                this.hasBQSSelected = false;
            }
        }
        /*
         * END Brand Quality Size
         */
        /*
         * BEGIN Toolkit
         */
    handleToolkitSearch(event) {
        apexSearchToolkit(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_toolkit');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleToolkitSelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_toolkit');
            const selection = el.getSelection();
            this.debug = JSON.stringify(selection);
            if (selection.length > 0) {
                this.filters.toolkit = selection[0].id;
                this.hasToolkitSelected = true;
            } else {
                this.filters.toolkit = '';
                this.hasToolkitSelected = false;
            }
        }
        /*
         * END Toolkit
         */
        /*
         * BEGIN SKU
         */
    handleSKUSearch(event) {
        apexSearchSKU(event.detail)
            .then(results => {
                let el = this.getRightLookup('lkp_sku');
                el.setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleSKUSelectionChange() {
            this.errors = [];
            let el = this.getRightLookup('lkp_sku');
            const selection = el.getSelection();
            this.debug = JSON.stringify(selection);
            if (selection.length > 0) {
                this.filters.sku = selection[0].id;
                this.hasSKUSelected = true;
            } else {
                this.filters.sku = '';
                this.hasSKUSelected = false;
            }
        }
        /*
         * END SKU
         */

    getRightLookup(customKey) {
        let lkp = null;
        let lookups = this.template.querySelectorAll('c-eur_doc_lookup');

        let i = 0;
        while (i < lookups.length && lkp === null) {
            if (lookups[i].getkey() === customKey) {
                lkp = lookups[i];
            }
            i++;
        }

        if (lkp === null) {
            this.notifyUser("Lookup Key not found", "Lookup Key not found", "error");
        }
        return lkp;
    }

    /*Brand Security Brand Quality selection Handler begin*/

    handleBSbqChange(event) {
        this.filters.bsbq = event.target.value;
    }

    /*Brand Security Brand Quality selection Handler end*/

} //end of class