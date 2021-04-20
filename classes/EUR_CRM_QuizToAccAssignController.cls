public with sharing class EUR_CRM_QuizToAccAssignController {

    public List<PROSWrapper> oldProsWrappers { get; set; }
    public List<PROSWrapper> prosWrappers { get; set; }

    public String selectionMethod { get; set; }
    public static final String ACCOUNT_LIST_VIEWS = 'Account list views';
    public static final String CUSTOMER_TAXONOMY = 'Customer taxonomy';
    public static final String PROS = 'PROS';

    public String filterId { get; set; }

    public EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType { get; set; }
    public EUR_CRM_PRS_Seg_Aspect__c segAspect { get; set; }
    public String customerTaxonomyChain { get; set; }

    public ApexPages.StandardSetController con { get; set; }

    private Id quizId;
    private AccountWrapperContainer wrapperContainer;

    private static final String NONE = '--None--';
    private final Integer PAGE_SIZE = 25;

    public List<ImageLevelWrapper> oldImageLevelWrappers { get; set; }
    public List<ImageLevelWrapper> imageLevelWrappers { get; set; }

    public EUR_CRM_QuizToAccAssignController() {
        this.oldImageLevelWrappers = new List<ImageLevelWrapper> { new ImageLevelWrapper() };
        this.imageLevelWrappers = new List<ImageLevelWrapper> { new ImageLevelWrapper() };

        this.selectionMethod = PROS;

        this.initProsWrappers();
        this.groupOutletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        this.segAspect = new EUR_CRM_PRS_Seg_Aspect__c();

        this.quizId = ApexPages.currentPage().getParameters().get('quizId');
        this.wrapperContainer = new AccountWrapperContainer(this.quizId);
        this.showAccounts();
    }


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public PageReference showFilters() {
        this.filterId = null;
        this.customerTaxonomyChain = null;
        this.groupOutletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
        this.segAspect = new EUR_CRM_PRS_Seg_Aspect__c();
        this.showAccounts();
        return null;
    }

    public PageReference showAccounts() {
        System.debug('\n\n PageReference showAccounts([]) \n');

        String query = '' +
            'SELECT Id' +
            ',  Name ' +
            ',  EUR_CRM_Status__c ' +
            ',  EUR_CRM_Channel__c ' +
            ',  EUR_CRM_Region__c ' +
            ',  EUR_CRM_Territory__c ' +
            ',  RecordType.Name ' +
            ',  OwnerId ' +
            ',  Owner.Name ' +
            'FROM EUR_CRM_Account__c ';

        query += this.configureCriteria();
        query += 'ORDER BY Name';

        System.debug('\n\n query => ' + JSON.serializePretty(query) + '\n');
        this.con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        this.con.setPageSize(PAGE_SIZE);
        if ( ! String.isBlank(this.filterId)) {
            this.con.setFilterId(filterId);
        }
        return null;
    }

    public PageReference assignToAccounts() {
        List<EUR_CRM_QuizPartaker__c> quizPartakers = new List<EUR_CRM_QuizPartaker__c>();

        for (Id accId : this.wrapperContainer.getSelectedAccountIds()) {
            quizPartakers.add(new EUR_CRM_QuizPartaker__c(
                EUR_CRM_AccountId__c = accId
            ,   EUR_CRM_QuizId__c = this.quizId
            ));
        }
        insert quizPartakers;

        return new PageReference('/' + this.quizId);
    }

    public PageReference onClickImageLevelCheckbox() {
        if (this.imageLevelWrappers[0].selectAllIconic == true && this.oldImageLevelWrappers[0].selectAllIconic == false) {
            for (PROSWrapper wrapper : this.prosWrappers) {
                wrapper.imageLevelCheckboxWrappers[0].isChecked = this.imageLevelWrappers[0].selectAllIconic;
            }
        }


        return null;
    }

    public PageReference onClickCheckbox() {
        System.debug('\n\n this.oldProsWrappers => ' + JSON.serializePretty(this.oldProsWrappers) + '\n');
        System.debug('\n\n this.prosWrappers => ' + JSON.serializePretty(this.prosWrappers) + '\n');

        for (Integer i = 0; i < this.prosWrappers.size(); i++) {
            if (this.prosWrappers[i].selectAll != this.oldProsWrappers[i].selectAll) {
                for (CheckboxWrapper wrapper : this.prosWrappers[i].imageLevelCheckboxWrappers) {
                    wrapper.isChecked = this.prosWrappers[i].selectAll;
                }

                for (CheckboxWrapper wrapper : this.oldProsWrappers[i].imageLevelCheckboxWrappers) {
                    wrapper.isChecked = this.prosWrappers[i].selectAll;
                }

                this.oldProsWrappers[i].selectAll = this.prosWrappers[i].selectAll;
            }
        }

        System.debug('\n\n this.oldProsWrappers => ' + JSON.serializePretty(this.oldProsWrappers) + '\n');

        return null;
    }


    /* ========================================================= */
    /*     Getters
    /* ========================================================= */
    public List<SelectOption> getSelectionMethods() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ACCOUNT_LIST_VIEWS, ACCOUNT_LIST_VIEWS));
        options.add(new SelectOption(CUSTOMER_TAXONOMY, CUSTOMER_TAXONOMY));
        options.add(new SelectOption(PROS, PROS));
        return options;
    }

    public List<SelectOption> getAccountListViews() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', NONE));
        options.addAll(this.con.getListViewOptions());
        return options;
    }

    public List<SelectOption> getCustomerTaxonomyChains() {
        List<AggregateResult> aggregateResults = this.selectCustomerTaxonomyAggregateResult();

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(NONE, NONE));
        for (AggregateResult result : aggregateResults) {
            String chain = String.valueOf(result.get('Chain'));
            options.add(new SelectOption(chain, chain));
        }
        return options;
    }

    public List<AccountWrapper> getAccountWrappers() {
        System.debug('\n\n List<EUR_CRM_PT_ObjPromoManageController.AccountWrapper> getAccountWrappers([]) \n');

        this.wrapperContainer.setAccountsForNewPage((List<EUR_CRM_Account__c>)this.con.getRecords());
        return this.wrapperContainer.accountWrappers;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void initProsWrappers() {
        this.oldProsWrappers = new List<PROSWrapper>();
        this.prosWrappers = new List<PROSWrapper>();

        Schema.DescribeFieldResult fieldResult = EUR_CRM_PRS_Group_Outlet_Type__c.EUR_CRM_Group_Outlet_Type_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            this.oldProsWrappers.add(new PROSWrapper(f.getValue()));
            this.prosWrappers.add(new PROSWrapper(f.getValue()));
        }

        System.debug('\n\n this.prosWrappers => ' + JSON.serializePretty(this.prosWrappers) + '\n');
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private String configureCriteria() {
        System.debug('\n\n groupOutletType.EUR_CRM_Group_Outlet_Type_Name__c => ' + JSON.serializePretty(groupOutletType.EUR_CRM_Group_Outlet_Type_Name__c) + '\n');
        System.debug('\n\n segAspect.EUR_CRM_Segmentation_IL_Aspect_Name__c => ' + JSON.serializePretty(segAspect.EUR_CRM_Segmentation_IL_Aspect_Name__c) + '\n');
//        System.debug('\n\n segAspect.EUR_CRM_Segmentation_VP_Aspect_Name__c => ' + JSON.serializePretty(segAspect.EUR_CRM_Segmentation_VP_Aspect_Name__c) + '\n');
//        System.debug('\n\n segAspect.EUR_CRM_Segmentation_BP_Aspect_Name__c => ' + JSON.serializePretty(segAspect.EUR_CRM_Segmentation_BP_Aspect_Name__c) + '\n');
//        System.debug('\n\n segAspect.EUR_CRM_Segmentation_BBP_Aspect_Name__c => ' + JSON.serializePretty(segAspect.EUR_CRM_Segmentation_BBP_Aspect_Name__c) + '\n');
        System.debug('\n\n customerTaxonomyChain => ' + JSON.serializePretty(customerTaxonomyChain) + '\n');

        String criteria = '';

        System.debug('\n\n this.isCriteriaExists() => ' + JSON.serializePretty(this.isCriteriaExists()) + '\n');

        if ( ! this.isCriteriaExists()) {
            return criteria;
        }

        criteria += 'WHERE ';
        if (this.isCriteriaExists(this.groupOutletType.EUR_CRM_Group_Outlet_Type_Name__c)) {
            criteria += 'EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Type_Name__c = \'' + this.groupOutletType.EUR_CRM_Group_Outlet_Type_Name__c + '\' ';
        }

        if (this.isCriteriaExists(this.segAspect.EUR_CRM_Segmentation_IL_Aspect_Name__c)) {
            if ( ! criteria.endsWithIgnoreCase('WHERE ')) { criteria += 'AND '; }
            criteria += 'EUR_CRM_PRS_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c = \'' + this.segAspect.EUR_CRM_Segmentation_IL_Aspect_Name__c + '\' ';
        }

//        if (this.isCriteriaExists(this.segAspect.EUR_CRM_Segmentation_VP_Aspect_Name__c)) {
//            if ( ! criteria.endsWithIgnoreCase('WHERE ')) { criteria += 'AND '; }
//            criteria += 'EUR_CRM_PRS_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c = \'' + this.segAspect.EUR_CRM_Segmentation_VP_Aspect_Name__c + '\' ';
//        }
//
//        if (this.isCriteriaExists(this.segAspect.EUR_CRM_Segmentation_BP_Aspect_Name__c)) {
//            if ( ! criteria.endsWithIgnoreCase('WHERE ')) { criteria += 'AND '; }
//            criteria += 'EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c = \'' + this.segAspect.EUR_CRM_Segmentation_BP_Aspect_Name__c + '\' ';
//        }
//
//        if (this.isCriteriaExists(this.segAspect.EUR_CRM_Segmentation_BBP_Aspect_Name__c)) {
//            if ( ! criteria.endsWithIgnoreCase('WHERE ')) { criteria += 'AND '; }
//            criteria += 'EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c = \'' + this.segAspect.EUR_CRM_Segmentation_BBP_Aspect_Name__c + '\' ';
//        }

        if (this.isCriteriaExists(this.customerTaxonomyChain)) {
            if ( ! criteria.endsWithIgnoreCase('WHERE ')) { criteria += 'AND '; }
            criteria += 'EUR_CRM_Customer_Taxonomy_Chain__c = \'' + this.customerTaxonomyChain + '\' ';
        }

        return criteria;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isCriteriaExists() {
        return this.isCriteriaExists(groupOutletType.EUR_CRM_Group_Outlet_Type_Name__c)
            || this.isCriteriaExists(segAspect.EUR_CRM_Segmentation_IL_Aspect_Name__c)
            || this.isCriteriaExists(segAspect.EUR_CRM_Segmentation_VP_Aspect_Name__c)
            || this.isCriteriaExists(segAspect.EUR_CRM_Segmentation_BP_Aspect_Name__c)
            || this.isCriteriaExists(segAspect.EUR_CRM_Segmentation_BBP_Aspect_Name__c)
            || this.isCriteriaExists(customerTaxonomyChain)
        ;
    }

    private Boolean isCriteriaExists(String criteria) {
        return ! String.isEmpty(criteria)
            && ! criteria.equalsIgnoreCase(NONE)
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<AggregateResult> selectCustomerTaxonomyAggregateResult() {
        return [
            SELECT EUR_CRM_Chain__c Chain, COUNT(Id)
            FROM EUR_CRM_Customer_Taxonomy__c
            WHERE EUR_CRM_Chain__c != null
            GROUP BY EUR_CRM_Chain__c
        ];
    }


    /* ========================================================= */
    /*     Wrappers
    /* ========================================================= */
    public class AccountWrapperContainer {

        public List<AccountWrapper> accountWrappers { get; set; }

        private List<AccountWrapper> accountWrappersInitial;
        private Set<Id> selectedAccountIds;
        private Id quizId;

        public AccountWrapperContainer(Id quizId) {
            this.selectedAccountIds = new Set<Id>();
            this.quizId = quizId;
        }

        public void setAccountsForNewPage(List<EUR_CRM_Account__c> accounts) {
            this.saveCheckedAccountIds();

            Map<Id, EUR_CRM_QuizPartaker__c> quizPartakerByAccountId = this.getQuizPartakerByAccountId(accounts);
//            System.debug('\n\n quizPartakerByAccountId => ' + JSON.serializePretty(quizPartakerByAccountId) + '\n');

            this.accountWrappers = new List<AccountWrapper>();
            this.accountWrappersInitial = new List<AccountWrapper>();

            for (EUR_CRM_Account__c account : accounts) {
                Boolean isCheckedByUser = this.selectedAccountIds.contains(account.Id);
                Boolean existsInSystem = quizPartakerByAccountId.containsKey(account.Id);
                this.accountWrappers.add(new AccountWrapper(account, isCheckedByUser, existsInSystem));
                this.accountWrappersInitial.add(new AccountWrapper(account, isCheckedByUser, existsInSystem));
            }
        }

        public Set<Id> getSelectedAccountIds() {
            this.saveCheckedAccountIds();
            return this.selectedAccountIds;
        }


        /* ========================================================= */
        /*     Helpers
        /* ========================================================= */
        private void saveCheckedAccountIds() {
            if (this.accountWrappers == null) { return ; }

            for (Integer i = 0; i < this.accountWrappers.size(); i++) {
                if (this.accountWrappers[i].isChecked == true && this.accountWrappersInitial[i].isChecked == false) {
                    this.selectedAccountIds.add(this.accountWrappers[i].account.Id);
                } else if (this.accountWrappers[i].isChecked == false && this.accountWrappersInitial[i].isChecked == true) {
                    this.selectedAccountIds.remove(this.accountWrappers[i].account.Id);
                }
            }
        }

        private  Map<Id, EUR_CRM_QuizPartaker__c> getQuizPartakerByAccountId(List<EUR_CRM_Account__c> accounts) {
            List<EUR_CRM_QuizPartaker__c> quizPartakers = this.selectQuizPartakers(new Map<Id, EUR_CRM_Account__c>(accounts).keySet());
//            System.debug('\n\n quizPartakers => ' + JSON.serializePretty(quizPartakers) + '\n');

            Map<Id, EUR_CRM_QuizPartaker__c> quizPartakerByAccountId = new Map<Id, EUR_CRM_QuizPartaker__c>();
            for (EUR_CRM_QuizPartaker__c quizPartaker : quizPartakers) {
                quizPartakerByAccountId.put(quizPartaker.EUR_CRM_AccountId__c, quizPartaker);
            }
            return quizPartakerByAccountId;
        }


        /* ========================================================= */
        /*     SOQL Selectors
        /* ========================================================= */
        private List<EUR_CRM_QuizPartaker__c> selectQuizPartakers(Set<Id> accIds) {
            return [
                SELECT Id
                ,   EUR_CRM_AccountId__c
                FROM EUR_CRM_QuizPartaker__c
                WHERE EUR_CRM_AccountId__c IN :accIds
                    AND EUR_CRM_QuizId__c = :this.quizId
            ];
        }
    }

    public class AccountWrapper {
        public EUR_CRM_Account__c account { get; set; }
        public Boolean isChecked { get; set; }
        public Boolean disabled { get; set; }

        public AccountWrapper(EUR_CRM_Account__c acc, Boolean checked, Boolean existsInSystem) {
            this.account = acc;
            this.isChecked = checked || existsInSystem;
            this.disabled = existsInSystem;
        }
    }

    public class ImageLevelWrapper {
        public String iconicName { get; set; }
        public Boolean selectAllIconic { get; set; }

        public String leadingName { get; set; }
        public Boolean selectAllLeading { get; set; }

        public String premiumName { get; set; }
        public Boolean selectAllPremium { get; set; }

        public String mainstreamName { get; set; }
        public Boolean selectAllMainstream { get; set; }

        public ImageLevelWrapper() {
            this.iconicName = 'Iconic';
            this.selectAllIconic = false;
            this.leadingName = 'Leading';
            this.selectAllLeading = false;
            this.premiumName = 'Premium';
            this.selectAllPremium = false;
            this.mainstreamName = 'Mainstream';
            this.selectAllMainstream = false;
        }
    }

    public class PROSWrapper {
        public String groupOutletType { get; set; }
        public Boolean selectAll { get; set; }
        public List<CheckboxWrapper> imageLevelCheckboxWrappers { get; set; }

        public PROSWrapper(String got) {
            this.groupOutletType = got;
            this.selectAll = false;

            this.imageLevelCheckboxWrappers = new List<CheckboxWrapper>();
            Schema.DescribeFieldResult fr = EUR_CRM_PRS_Seg_Aspect__c.EUR_CRM_Segmentation_IL_Aspect_Name__c.getDescribe();
            List<Schema.PicklistEntry> p = fr.getPicklistValues();
            for (PicklistEntry entry : p) {
                this.imageLevelCheckboxWrappers.add(new CheckboxWrapper(entry.getValue()));
            }
        }
    }

    public class CheckboxWrapper {
        public String imageLevelName { get; set; }
        public Boolean isChecked { get; set; }

        public CheckboxWrapper(String ilName) {
            this.imageLevelName = ilName;
            this.isChecked = false;
        }
    }


}