import { LightningElement, api, track } from 'lwc';

export default class ASI_CRM_DataTable_Comp extends LightningElement {

    @api mode            = "VIEW";
    @api recordList      = [];
    @api fieldConfigList = [];

    @api paginationConfigObj    = {
        'pageNo'    : 0,
        'pageSize'  : 0,
        'totalPage' : 0
    };
    @api componentConfigObj     = {
        'allowView'       : false,
        'allowSelect'     : false,
        'allowClone'      : false,
        'allowDelete'     : false,
        'allowPagination' : false,
        'allowResponsive' : false
    };
    @api componentStyleClassObj = {
        'tableStyleClass' : '',
        'theadStyleClass' : '',
        'tbodyStyleClass' : '',
        'tfootStyleClass' : '',
        'textStyleClass'  : ''
    };
    @api componentCallbackObj   = {
        'recordFieldUpdateCallback' : null,
        'viewRecordCallback'        : null,
        'selectRecordCallback'      : null,
        'cloneRecordCallback'       : null,
        'deleteRecordCallback'      : null,
        'pageChangeCallback'        : null
    };

    @track pageNo;
    @track fieldUpdateCallback = this.onFieldUpdateCallback.bind(this);

    get tableContainerClass() {
        return this.componentConfigObj.allowResponsive ? "dynamic-table-container" : "";
    }

    get tableClass() {
        return "slds-table slds-no-row-hover slds-table_bordered " + this.componentStyleClassObj.tableStyleClass;
    }

    get allowAction() {
        return this.componentConfigObj.allowView || 
            this.componentConfigObj.allowSelect || 
            this.componentConfigObj.allowClone || 
            this.componentConfigObj.allowDelete;
    }

    get disableBackPage() {
        return this.paginationConfigObj.pageNo <= 1;
    }

    get disableNextPage() {
        return this.paginationConfigObj.pageNo >= this.paginationConfigObj.totalPage;
    }

    onClickViewRecord(event) {
        if(this.componentCallbackObj.viewRecordCallback && 
            event.currentTarget.dataset)
            this.componentCallbackObj.viewRecordCallback(this.getRecordById(event.currentTarget.dataset.id));
    }

    onClickSelectRecord(event) {
        if(this.componentCallbackObj.selectRecordCallback && 
            event.currentTarget.dataset)
            this.componentCallbackObj.selectRecordCallback(this.getRecordById(event.currentTarget.dataset.id));
    }

    onClickCloneRecord(event) {
        if(this.componentCallbackObj.cloneRecordCallback && 
            event.currentTarget.dataset)
            this.componentCallbackObj.cloneRecordCallback(this.getRecordById(event.currentTarget.dataset.id));
    }

    onClickDeleteRecord(event) {
        if(this.componentCallbackObj.deleteRecordCallback && 
            event.currentTarget.dataset) {
            this.componentCallbackObj.deleteRecordCallback(this.getRecordById(event.currentTarget.dataset.id));
        }
    }

    onClickBackPage() {
        this.componentCallbackObj.pageChangeCallback(this.paginationConfigObj.pageNo - 1);
    }
    
    onClickNextPage() {
        this.componentCallbackObj.pageChangeCallback(this.paginationConfigObj.pageNo + 1);
    }

    onChangePageNo(event) {
        this.pageNo = Number(event.target.value);
    }

    onClickChangePage() {
        this.componentCallbackObj.pageChangeCallback(this.pageNo || this.paginationConfigObj.pageNo);
    }

    onFieldUpdateCallback(recordId, field, value) {
        if(this.componentCallbackObj.recordFieldUpdateCallback)
            this.componentCallbackObj.recordFieldUpdateCallback(recordId, field, value);
    }

    getRecordById(id) {
        var index;

        if(!id) 
            return null;
        
        index = this.recordList.findIndex(record => record.Id === id);

        if(index === -1)
            return null;

        return this.recordList[index];
    }

}