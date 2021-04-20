public class EUR_CRM_AccountListViewSelectorCtrller {

    @TestVisible transient List<EUR_CRM_Account__c> euAccounts;
    public EUR_CRM_ObjPromo__c objPromo { get; set; }
    Integer pSize = 20;
    public String filterId { get; set; }
    public String countryCode { get; set; }
    public String currentURL { get; set; }
    public String opAccountMappingRecordTypeName { get; set; }
    public String listViewFilterOption { get; set; }
    public Boolean LiteView { get; set; }

    @TestVisible Set<Id> selectedAccounts = new Set<Id>();
    @TestVisible Set<Id> deselectedAccounts = new Set<Id>();

    public Boolean sortAccount { get; set; }
    public String sortFieldName { get; set; }
    public String oldSortFieldName { get; set; }
    public String sortOrder { get; set; }

    // Determines whether all selected accounts can be saved or not
    public Boolean isPermissible { get; set; }

    public Boolean isAllSelected { get; set; }
    public ApexPages.StandardController standardController { get; set; }
    public ApexPages.StandardSetController con {
        get {

            if (con == null) {

                String query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                    ', EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c ' +
                    ', EUR_CRM_Key_Account_Manager__c, EUR_JB_Customer_Taxonomy__c, EUR_CRM_Epicenter__c, EUR_CRM_Model_Shop__c, EUR_CRM_Reason_for_deactivation__c ' +
                    ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c, EUR_CRM_Business_Type__c,EUR_CRM_Territory__c,EUR_CRM_Territory__r.Name ' +
                    'from EUR_CRM_Account__c where eur_crm_country_code__c = \'' + countryCode + '\' LIMIT 1';

                //System.debug(query);
                //System.debug(con);

                if (filterId != null) {
                    con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                    this.con.setPageSize(pSize);
                    con.setFilterId(filterId);
                    this.euAccounts = null;
                    this.selectedAccounts = new Set<Id>();
                } else {
                    con = new ApexPages.StandardSetController(new List<EUR_CRM_Account__c>());
                }
            }

            return con;
        }
        set;
    }

    public List<EUR_CRM_Account__c> retrieveAccounts() {
        if (euAccounts == null) {
            integer pageNumber = this.con.getPageNumber();
            this.con.first();

            //System.debug('Re-initializing euAccounts');
            euAccounts = new List<EUR_CRM_Account__c>();

            while (this.con.getHasNext()) {
                //System.debug(this.con.getRecords());
                euAccounts.addAll((List<EUR_CRM_Account__c>) this.con.getRecords());
                this.con.next();
            }

            // Add the last page to the list of accounts
            //System.debug(this.con.getRecords());
            euAccounts.addAll((List<EUR_CRM_Account__c>) this.con.getRecords());

            this.con.setPageNumber(pageNumber);
        }

        //System.debug(euAccounts.size());
        return euAccounts;
    }

    public List<euAccountsWrapper> getWrapAccounts() {
        List<euAccountsWrapper> wrapAccounts = new List<euAccountsWrapper>();

        for (EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>) con.getRecords()) {
            if (!deselectedAccounts.contains(acc.Id))
                this.selectedAccounts.add(acc.Id);
        }

        for (sObject r : this.con.getRecords()) {
            EUR_CRM_Account__c a = (EUR_CRM_Account__c) r;

            euAccountsWrapper wrapAccount = new euAccountsWrapper(a, false);
            if (this.selectedAccounts.contains(a.Id)) {
                wrapAccount.IsSelected = true;
            } else {
                wrapAccount.IsSelected = false;
            }
            wrapAccounts.add(wrapAccount);
        }

        //System.debug(wrapAccounts);
        return wrapAccounts;
    }

    public PageReference sort() {
        sortAccount = true;
        con = null;
        if (sortFieldName != oldSortFieldName) {
            sortOrder = null;
            oldSortFieldName = sortFieldName ;
        }
        sortOrder = sortOrder == null || sortOrder == 'DESC' ? 'ASC' : 'DESC';
        return null;
    }

    public void doNext() {
        if (this.con.getHasNext()) {
            this.con.next();
            //System.debug(this.con.getRecords());
        }

    }

    public void doPrevious() {
        if (this.con.getHasPrevious()) {
            this.con.previous();
            getWrapAccounts();
        }
    }
    public void first() {
        con.first();
        getWrapAccounts();
    }

    // returns the last page of records
    public void last() {
        con.last();
        getWrapAccounts();
    }

    public Boolean getHasPrevious() {
        return this.con.getHasPrevious();
    }

    /*
    *   return whether next page exists
    */
    public Boolean getHasNext() {
        return this.con.getHasNext();
    }

    public Integer getPageNumber() {
        return this.con.getPageNumber();
    }


    public Integer getTotalPages() {

        Decimal totalSize = this.con.getResultSize();
        Decimal pageSize = this.con.getPageSize();

        Decimal pages = totalSize / pageSize;

        return (Integer) pages.round(System.RoundingMode.CEILING);
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    public Integer getPageSize() {
        return con.getPageSize() != null ? con.getPageSize() : 0;
    }

    public Integer getRecordSize() {
        return con.getResultSize() != null ? con.getResultSize() : 0;
    }

    public String contextItem { get; set; }

    //Method to Select a Record
    public void doSelectItem() {
        this.selectedAccounts.add(this.contextItem);
        this.deselectedAccounts.remove(this.contextItem);    //Sid 2.1

        if (this.deselectedAccounts.size() == 0) {
            isAllSelected = true;
        }
    }

    public List<Id> getSelectedAccounts() {
        List<Id> returnedList = new List<Id>();
        returnedList.addAll(this.selectedAccounts);

        return returnedList;
    }

    //Method to De-Select a Record
    public void doDeselectItem() {

        this.selectedAccounts.remove(this.contextItem);
        this.deselectedAccounts.add(this.contextItem);    //Sid 2.1
        isAllSelected = false;    //Sid 2.1
    }

    public Boolean getHasSelectedAccounts() {
        return selectedAccounts.size() > 0;
    }

    //Method to Select All Record
    public void selectAll() {
        for (EUR_CRM_Account__c a : retrieveAccounts()) {
            selectedAccounts.add(a.id);
            this.deselectedAccounts.remove(a.id);    //Sid 2.1
        }
        isAllSelected = true;
    }

    //Method to De Select All Records
    public void deSelectAll() {

        for (EUR_CRM_Account__c a : retrieveAccounts()) {
            selectedAccounts.remove(a.id);
            this.deselectedAccounts.add(a.id);    //Sid 2.1
        }
        isAllSelected = false;
    }

    public Boolean getIsDeactivated() {
        return this.objPromo.EUR_CRM_Status__c == 'Deactivated';
    }

    public List<EUR_CRM_ObjPromo_Account_Mapping__c> removeDuplicateOPAccounts(Set<Id> existingOPAccountIds, List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts) {
        List<EUR_CRM_ObjPromo_Account_Mapping__c> uniqueOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();

        for (Integer i = 0; i < toInsertOPAccounts.size(); i++) {
            //System.debug(toInsertOPAccounts[i]);
            if (!existingOPAccountIds.contains(toInsertOPAccounts[i].EUR_CRM_Account__c)) {
                // If the account doesn't exist, add to uniqueOPAccounts list
                uniqueOPAccounts.add(toInsertOPAccounts[i]);
            }
        }

        return uniqueOPAccounts;
    }

    public PageReference quickSaveAccounts() {
        Savepoint sp = Database.setSavepoint();

        try {
            Id opAccountMappingRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c' + this.opAccountMappingRecordTypeName);

//            System.debug('opAccountMappingRecordTypeId:'+opAccountMappingRecordTypeId);
            //System.debug(this.opAccountMappingRecordTypeName);

            List<EUR_CRM_ObjPromo_Account_Mapping__c> toDeleteOPAccounts = [
                select id, EUR_CRM_Account__c
                from EUR_CRM_ObjPromo_Account_Mapping__c
                where EUR_CRM_ObjPromo__c = :objPromo.id
            ];

            List<EUR_CRM_ObjPromo_Target__c> toDeleteOPTargets = new List<EUR_CRM_ObjPromo_Target__c>();
            //Delete Everything If OP is BE
            if (countryCode == 'BE') {
                toDeleteOPTargets = [
                    SELECT id
                    FROM EUR_CRM_ObjPromo_Target__c
                    WHERE EUR_CRM_ObjPromo__c = :objPromo.Id
                ];
            } else {
                toDeleteOPTargets = [
                    SELECT id
                    FROM EUR_CRM_ObjPromo_Target__c
                    WHERE EUR_CRM_ObjPromo__c = :objPromo.Id
                        AND EUR_CRM_O_P_Target__c != null
                ];
            }

            //System.debug('>>>Delete OPAccMap / OPTarget');
            //System.debug(toDeleteOPAccounts);
            //System.debug(toDeleteOPTargets);
            if (toDeleteOPAccounts != null && toDeleteOPAccounts.size() > 0) {
                // Removes all inserted accounts regardless of duplication
                delete toDeleteOPAccounts;
            }
            if (this.objPromo.EUR_CRM_Status__c == 'Draft') {

                // Deletes all inserted accounts and targets if the O/P is still in draft mode


                if (toDeleteOPTargets != null && toDeleteOPTargets.size() > 0) {
                    delete toDeleteOPTargets;
                }
            }

            // Inserts OP Account Mapping
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
//            System.debug('euAccounts.size():'+euAccounts.size());
//            System.debug('selectedAccounts.size():'+selectedAccounts.size());
            for (EUR_CRM_Account__c euAcc : retrieveAccounts()) {
                if (selectedAccounts.contains(euAcc.id)) {
                    EUR_CRM_ObjPromo_Account_Mapping__c opAccount = new EUR_CRM_ObjPromo_Account_Mapping__c(
                        EUR_CRM_Account__c = euAcc.Id,
                        EUR_CRM_ObjPromo__c = objPromo.id,
                        EUR_CRM_Is_Active__c = false
                    );

                    if (opAccountMappingRecordTypeId != null) {
                        opAccount.recordtypeid = opAccountMappingRecordTypeId;
                    }
                    toInsertOPAccounts.add(opAccount);
                }
            }
//            System.debug('#1 toInsertOPAccounts.size():'+toInsertOPAccounts.size());

            // Remove OP Accounts that are duplicates, if the O/P is Active
            if (this.objPromo.EUR_CRM_Status__c == 'Active' &&
                toDeleteOPAccounts != null && toDeleteOPAccounts.size() > 0) {

                Set<Id> existingOPAccountIds = new Set<Id>();
                for (EUR_CRM_ObjPromo_Account_Mapping__c opMap : toDeleteOPAccounts) {
                    existingOPAccountIds.add(opMap.EUR_CRM_Account__c);
                }

                toInsertOPAccounts = removeDuplicateOPAccounts(existingOPAccountIds, toInsertOPAccounts);
            }

            //System.debug('=========== toInsertOPAccounts ' + toInsertOPAccounts.size());

            //System.debug('@@ selectedAccounts: ' + selectedAccounts );
            //System.debug(selectedAccounts.size());
            //System.debug('@@ toInsertOPAccounts: ' + toInsertOPAccounts);

//            System.debug('#2 toInsertOPAccounts.size():'+toInsertOPAccounts.size());

            if ((!Test.isRunningTest() && toInsertOPAccounts.size() < 10000) || (Test.isRunningTest() && toInsertOPAccounts.size()<200)) {
                insert toInsertOPAccounts;
            } else {
                Integer MAX_BATCHES = 5;
                Integer runningBatchJobs = [
                    select count()
                    from AsyncApexJob
                    where JobType = 'BatchApex'
                        and status in ('Queued', 'Processing', 'Preparing')
                ];

                if (runningBatchJobs >= MAX_BATCHES) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.WARNING, Label.EUR_CRM_No_Resources_Available
                    ));
                } else {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.INFO, Label.EUR_CRM_OP_Publish_Batch_Error
                    ));
                    //create the postDMLS
                    Database.executeBatch(new EUR_CRM_BatchDML_Utility(toInsertOPAccounts, 'EUR_CRM_ObjPromo_Account_Mapping__c', EUR_CRM_BatchDML_Utility.Operation.INSERT_RECORDS, true, null));
                }
            }

            PageReference pageRef = new PageReference('/' + currentURL);
            pageRef.setRedirect(true);
            return pageRef;

        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
            //System.debug('@@ ERROR : ' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
        }
    }

    public PageReference saveAccounts() {
        quickSaveAccounts();
        return cancel();
    }

    // TODO: Generalize where user can jump, for more flexibility
    public PageReference quickSaveContinue() {
        quickSaveAccounts();
        PageReference pageRef = new PageReference('/' + currentURL + '#tabs-2');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + objPromo.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public class euAccountsWrapper {
        public Boolean isSelected { get; set; }
        public EUR_CRM_Account__c euAccount { get; set; }

        public euAccountsWrapper(EUR_CRM_Account__c euAccount, Boolean isSelected) {
            this.euAccount = euAccount;
            this.isSelected = isSelected;
        }
    }

    public SelectOption[] getListViewOptions() {
        List<SelectOption> selOpList = new List<SelectOption>();
        selOpList.add(new SelectOption('', '--None--'));
        //selOpList.addAll(con.getListViewOptions());

        //Filter Select Option List
        //System.debug('controller:' + con);
        //System.debug('getListViewOptions:' + con.getListViewOptions());
        If (String.isNotEmpty(listViewFilterOption)) {
            List<SelectOption> TargetOptionList = new List<SelectOption>();

            for (SelectOption SOpt : (List<SelectOption>) con.getListViewOptions()) {
                If (SOpt.getLabel().contains(listViewFilterOption)) {
                    TargetOptionList.add(SOpt);
                }
            }
            selOpList.addAll(TargetOptionList);
        } else {
            selOpList.addAll(con.getListViewOptions());
        }
        return selOpList;
    }

    public PageReference resetFilter() {
        //System.debug('Changing filter to ' + filterId);
        this.con = null;
        this.con.setPageNumber(1);
        this.con.setFilterId(filterId);
        this.euAccounts = null;
        //this.wrapAccounts = null;
        this.selectedAccounts = new Set<Id>();

        this.deselectedAccounts = new Set<Id>();    //Sid 2.1

        this.isAllSelected = false;

        this.selectAll();    //Sid 2.2
        //System.debug('========================= this.selectedAccounts ' + this.selectedAccounts.size());
        //isPermissible = true;    //Sid 2.2

        return null;
    }

    public PageReference validateAccounts() {
        //List<String> permissibleRecordTypeNames = new List<String>();
        Map<Id, RecordType> permissibleAccountRecordTypes = new Map<Id, RecordType>();
        String recordTypeCountryCode = '%\\_' + countryCode + '\\_%';
        String recordTypeOnTradeName = '%\\_On\\_%';
        String recordTypeOffTradeName = '%\\_Off\\_%';
        String recordTypeDistributorName = '%Distributor%';
        String recordTypeDistributionName = '%Distribution%';
        String recordTypeWholesalerName = '%Wholesaler%';

        Map<Id, RecordType> objPromoRecType = new Map<Id, RecordType>([
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE sObjectType = 'EUR_CRM_ObjPromo__c'
                AND DeveloperName LIKE :recordTypeCountryCode
        ]);

        // On Trade Objective and Promotion

        if (objPromoRecType.get(objPromo.RecordTypeId).DeveloperName == 'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist') {
            //BE On Trade + Cavist
            permissibleAccountRecordTypes = new Map<Id, RecordType>([
                SELECT DeveloperName
                FROM RecordType
                WHERE sObjectType = 'EUR_CRM_Account__c'
                    AND DeveloperName = 'EUR_BE_Wholesaler'
            ]);
        } else if (countryCode == 'SE') {
            //Special Handling For SE Account
            permissibleAccountRecordTypes = new Map<Id, RecordType>([
                SELECT DeveloperName
                FROM RecordType
                WHERE sObjectType = 'EUR_CRM_Account__c'
                    AND DeveloperName LIKE :recordTypeCountryCode
            ]);
        } else if (objPromoRecType.get(objPromo.RecordTypeId).DeveloperName.containsIgnoreCase(countryCode + '_On_')) {
            permissibleAccountRecordTypes = new Map<Id, RecordType>([
                SELECT DeveloperName
                FROM RecordType
                WHERE sObjectType = 'EUR_CRM_Account__c'
                    AND DeveloperName LIKE :recordTypeCountryCode
                    AND DeveloperName LIKE :recordTypeOnTradeName
            ]);
        } else if (objPromoRecType.get(objPromo.RecordTypeId).DeveloperName.containsIgnoreCase(countryCode + '_Off_')) {
            // Off Trade Objective and Promotion
            permissibleAccountRecordTypes = new Map<Id, RecordType>([
                SELECT DeveloperName
                FROM RecordType
                WHERE sObjectType = 'EUR_CRM_Account__c'
                    AND DeveloperName LIKE :recordTypeCountryCode
                    AND (DeveloperName LIKE :recordTypeOffTradeName
                        OR DeveloperName LIKE :recordTypeDistributionName
                        OR DeveloperName LIKE :recordTypeDistributorName)
            ]);
        }

        //System.debug(selectedAccounts.size());
        List<EUR_CRM_Account__c> validatedAccounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> selectedAccountsList = New List<EUR_CRM_Account__c>();

        if (objPromoRecType.get(objPromo.RecordTypeId).DeveloperName == 'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist') {
            //BE On Trade + Cavist, Check Account Record Type and Channel
            selectedAccountsList = [
                select Id, recordTypeId
                from EUR_CRM_Account__c
                where Id IN:selectedAccounts
                    AND EUR_CRM_Channel__c = 'ON TRADE'
            ];
        } else {
            selectedAccountsList = [
                select Id, recordTypeId
                from EUR_CRM_Account__c
                where Id IN:selectedAccounts
            ];
        }


//, AND EUR_CRM_Channel__c = 'ON TRADE'
        //System.debug(selectedAccountsList.size());

        for (EUR_CRM_Account__c acc : selectedAccountsList) {
            if (permissibleAccountRecordTypes.containsKey(acc.recordTypeId)) {
                validatedAccounts.add(acc);
            }
        }

        //System.debug('validatedAccounts:' + validatedAccounts);

        if (validatedAccounts.size() != selectedAccounts.size()) {
            isPermissible = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.EUR_CRM_OP_Publish_Validation));
        } else {
            isPermissible = true;
        }

        return null;
    }
}