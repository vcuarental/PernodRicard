/*
Provide Account Selection and Servey Creation on Servey Header Config Page.
1.Assign Survery Header to the component
2.Base on the Record type of the survery header, show different account select method
1.User Select Account Selection Method
2.Pick Account From Filtered List View
3.Click Publish To Create Survey

*/

public with sharing class EUR_CRM_SurveyAccountSelectorCtrl {
    //Contoller
    transient List<EUR_CRM_Account__c> euAccounts;
    public Boolean initialized { get; set; }
    public EUR_CRM_Survey_Header__c surveyHeader {
        get;
        set {
            surveyHeader = value;
            if (!initialized) {
                system.debug('Init?' + initialized);
                initializing();
                initialized = true;
            }
        }
    }
    public EUR_CRM_Survey_Header__c surveyHeaderlocal { get; set; }
    Integer pSize = 20;
    private final String ALL = 'All *';
    public ApexPages.StandardController standardController { get; set; }

    //Component Attribute
    public String surveyRtName { get; set; }    //RecordType Of The Survey that going to create
    public String filterOption { get; set; }    //AccList / CTax / PROS / PRSOn / PRSOff
    public String countryCode { get; set; }
    public String currentURL { get; set; }
    public String accountFilter { get; set; }
    public String addFilterCTax { get; set; }
    public String addFilterPROS { get; set; }
    public String addFilterPRS { get; set; }
    public String cTaxQuery { get; set; }


    //VF Page Direct Referenct Variable
    public Boolean selectorDisabled { get; set; }

    public Boolean isPermissible { get; set; }    //Selected Account Is Valid For Create Survey Or Not
    public Boolean enableAccLIstView { get; set; }
    public Boolean enableCTax { get; set; }
    public Boolean enablePROS { get; set; }

    public Boolean isAccListView { get {system.debug(filterOption); return filterOption == 'AccList' ? true : false;} set; }
    public Boolean isCTax { get {system.debug(filterOption); return filterOption == 'CTax' ? true : false;} set; }
    public Boolean isPROS { get {system.debug(filterOption); return filterOption == 'PROS' ? true : false;} set; }

    //In Class Gobal Variable
    //Control Account Selection Method For Different Survey Header,[0] AccList [1] CTax [2] PROS
    public Map<String, List<Boolean>> surveyHeaderRtToSelectionMethod = New Map<String, List<Boolean>>{
            'EUR_DE_OFF_Trade_Survey_Header' => New List<Boolean>{
                    True, True, False
            },
            'EUR_DE_ON_Trade_Survey_Header' => New List<Boolean>{
                    True, False, True
            },
            'EUR_DE_WS_Survey_Header' => New List<Boolean>{
                    True, True, False
            }
    };
    public String accountRtFilterQuery = '';
    public Map<Id, EUR_CRM_Account__c> publishedAccountSet = New Map<Id, EUR_CRM_Account__c>();

    //Control Account Record Type For Different Survey Header
    public static Map<string, String> SurveyAccountRtMapping = New Map<String, String>{
            'EUR_DE_OFF_Trade_Survey_Header' => '\'EUR_DE_OFF_STD\'',
            'EUR_DE_ON_Trade_Survey_Header' => '\'EUR_DE_ON_Consumers\',\'EUR_DE_ON_Enquiry_Acquisition\',\'EUR_DE_ON_Gastronomy\',\'EUR_DE_ON_Service_agency\'',
            'EUR_DE_WS_Survey_Header' => '\'EUR_DE_ON_Wholesaler\''
    };

    //Control Customer Taxonomy For different Survey Header
    public static Map<String, String> SurveyHeaderCustTax_FilterMap = New Map <String, String>{
            'EUR_DE_OFF_Trade_Survey_Header' => '(\'EUR_DE_Customer_Taxonomy\')',
            'EUR_DE_WS_Survey_Header' => '(\'EUR_DE_WS_Customer_Taxonomy\')'
    };

    //Control the pagenation of selection account for account list display
    public ApexPages.StandardSetController con {
        get {
            String query;
            if (con == null) {
                //Default record
                query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                        ', EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c ' +
                        ', EUR_CRM_Key_Account_Manager__c, EUR_JB_Customer_Taxonomy__c, EUR_CRM_Epicenter__c, EUR_CRM_Model_Shop__c, EUR_CRM_Reason_for_deactivation__c ' +
                        ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c ' +
                        'from EUR_CRM_Account__c where ' + accountRtFilterQuery + ' Limit 1';


                if (filterOption == 'CTax') {
                    if (cTaxQuery == null || String.isEmpty(cTaxQuery)) {
                        query = cTaxQuery;
                    }
                    System.Debug('>>>CTax Query:[' + customerTaxonomyList.size() + ']' + customerTaxonomyList);
                } else if (filterOption == 'PROS') {
                    if (whereClauseString != null && String.isNotEmpty(whereClauseString)) {
                        query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                                ', EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c ' +
                                ', EUR_CRM_Key_Account_Manager__c, EUR_JB_Customer_Taxonomy__c, EUR_CRM_Epicenter__c, EUR_CRM_Model_Shop__c, EUR_CRM_Reason_for_deactivation__c ' +
                                ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c ' +
                                'from EUR_CRM_Account__c where ' + accountRtFilterQuery + ' AND (' + whereClauseString + ') LIMIT 10000';
                    }
                    System.Debug('>>>PROS Query:' + whereClauseString);
                }


                /*String query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                    ', EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c ' +
                    ', EUR_CRM_Key_Account_Manager__c, EUR_JB_Customer_Taxonomy__c, EUR_CRM_Epicenter__c, EUR_CRM_Model_Shop__c, EUR_CRM_Reason_for_deactivation__c ' +
                    ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c '  + 
                    'from EUR_CRM_Account__c where eur_crm_country_code__c = \'' + countryCode + '\' ' + accountRtFilterQuery;*/

                System.debug('>>>Controller Query:' + query);
                con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                this.con.setPageSize(pSize);
                if (filterOption == 'AccList') {
                    con.setFilterId(filterId);
                }
                this.euAccounts = null;
                this.selectedAccounts = new Set<Id>();


                System.debug(con);

                /*if(filterId != null) {
                    con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                    this.con.setPageSize(pSize);
                    con.setFilterId(filterId);
                    this.euAccounts = null;
                    this.selectedAccounts = new Set<Id>();
                } else {
                    con = new ApexPages.StandardSetController(new List<EUR_CRM_Account__c>());
                }*/
            }

            return con;
        }
        set;
    }
    public String recordTypeCTax { get; set; }
    public List<String> recordTypePROS { get; set; }
    public List<String> recordTypeAcco { get; set; }


    //======Account Pick List Var
    @TestVisible Set<Id> selectedAccounts = new Set<Id>();
    @TestVisible Set<Id> deselectedAccounts = new Set<Id>();
    public Boolean sortAccount { get; set; }
    public String sortFieldName { get; set; }
    public String oldSortFieldName { get; set; }
    public String sortOrder { get; set; }
    public Boolean isAllSelected { get; set; }


    //======Account List View Var
    public String filterId { get; set; }    //Account List View Id


    //======CTax Var
    public ApexPages.StandardSetController conCTax {
        get {
            if (conCTax == null) {
                retrieveExistingCustomerTaxonomy();
                conCTax = new ApexPages.StandardSetController(retrieveExistingCustomerTaxonomy());
                conCTax.setPageSize(20);
            }
            return conCTax;
        }
        set;
    }
    public List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList { get; set; }

    public Boolean isRegional { get; set; }
    public String chainValue { get; set; }
    public String level1Value { get; set; }
    public String level2Value { get; set; }
    public String level3Value { get; set; }
    public String level4Value { get; set; }
    public String level5Value { get; set; }
    public String level6Value { get; set; }
    public String level7Value { get; set; }
    public String level8Value { get; set; }

    public String resetLevel { get; set; }

    private Boolean initLevel1 = false;
    private Boolean initLevel2 = false;
    private Boolean initLevel3 = false;
    private Boolean initLevel4 = false;
    private Boolean initLevel5 = false;
    private Boolean initLevel6 = false;
    private Boolean initLevel7 = false;
    private Boolean initLevel8 = false;
    private Boolean initMgmtType = false;


    //======PROS Var
    public List<ObjectPromWrapper> opWrapList { get; set; }
    public String whereClauseString { get; set; }
    public List<String> outletImages { get; set; }
    public List<String> outletTypes { get; set; }
    public List<String> selectedOutletImages { get; set; }
    public List<String> selectedOutletTypes { get; set; }
    public String opAccountMappingRecordTypeName { get; set; }

    //Method
    public EUR_CRM_SurveyAccountSelectorCtrl() {
        System.Debug('>>>Constructor');
        initialized = false;
        recordTypeCTax = '(\'\')';
        recordTypePROS = New List<String>{
        };
        recordTypeAcco = New List<String>{
        };

        enableAccLIstView = true;
        enableCTax = false;
        enablePROS = false;
    }
    public void determineSelectionMethod() {
        System.Debug('>>>determineSelectionMethod:' + surveyHeaderlocal.recordtype.DeveloperName);
        List<Boolean> SelectionEnabler = surveyHeaderRtToSelectionMethod.get(surveyHeaderlocal.recordtype.DeveloperName);
        if (SelectionEnabler != null) {
            enableAccLIstView = SelectionEnabler[0];
            enableCTax = SelectionEnabler[1];
            enablePROS = SelectionEnabler[2];
        } else {
            enableAccLIstView = true;
        }
    }

    public void initCheckedAccount() {
        //publishedAccountSet = [SELECT EUR_CRM_Account__c FROM EUR_CRM_Survey__c WHERE EUR_CRM_Survey_Header__c = : surveyHeaderlocal.Id];
        publishedAccountSet = new Map<Id, EUR_CRM_Account__c>([
                SELECT Id
                FROM EUR_CRM_Account__c
                WHERE Id in (
                        SELECT EUR_CRM_Account__c
                        FROM EUR_CRM_Survey__c
                        WHERE EUR_CRM_Survey_Header__r.Id = :surveyHeaderlocal.Id
                )
        ]);

    }

    public void initializing() {
        System.Debug('$$$initializing:' + surveyHeader);
        System.Debug('$$$initializing:' + surveyHeaderlocal);
        customerTaxonomyList = New List<EUR_CRM_Customer_Taxonomy__c>();
        If (surveyHeader != null) {
            surveyHeaderlocal = [
                    select id, EUR_CRM_Active__c,
                            EUR_CRM_Account_Filter_ID__c,
                            EUR_CRM_Account_Filter_PROS__c,
                            EUR_CRM_Account_Filter_PRS_On__c,
                            EUR_CRM_Account_Filter_CustTax_Chain__c, EUR_CRM_Account_Filter_CustTax_Level_1__c,
                            EUR_CRM_Account_Filter_CustTax_Level_2__c, EUR_CRM_Account_Filter_CustTax_Level_3__c,
                            EUR_CRM_Account_Filter_CustTax_Level_4__c, EUR_CRM_Account_Filter_CustTax_Level_5__c,
                            EUR_CRM_Account_Filter_CustTax_Level_6__c, EUR_CRM_Account_Filter_CustTax_Level_7__c,
                            EUR_CRM_Account_Filter_CustTax_Level_8__c, recordtypeId,
                            recordtype.developername
                    from EUR_CRM_Survey_Header__c
                    where id = :surveyHeader.Id
            ];

            System.Debug('>>>servey header:' + surveyHeaderlocal);

            accountRtFilterQuery = ' recordtype.developerName in (' + SurveyAccountRtMapping.get(surveyHeaderlocal.RecordType.DeveloperName) + ') ';

            if (surveyHeaderlocal.EUR_CRM_Active__c == True) {
                selectorDisabled = false; //Disable Account Selection if Survey is active
                initCheckedAccount();
            }

            determineSelectionMethod();

            filterOption = 'AccList';

            If (surveyHeaderlocal.EUR_CRM_Account_Filter_ID__c != null) {
                initAccountListView();
                filterOption = 'AccList';
            }

            If (surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Chain__c != null) {

                initCustomerTaxonomy();
                filterOption = 'CTax';
            }

            If (surveyHeaderlocal.EUR_CRM_Account_Filter_PROS__c != null) {
                initPROS();
                filterOption = 'PROS';
            }

            If (surveyHeaderlocal.EUR_CRM_Account_Filter_PRS_On__c != null) {

            }
        }

    }


/*Customer Taxonomy Section*/
    public Boolean initCustomerTaxonomy() {
        System.Debug('$$$initCustomerTaxonomy');
        if (surveyHeaderlocal != null) {
            /*if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Chain__c !=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Chain__c != '')
                chainValue = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Chain__c;

            if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_1__c!=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_1__c!= '')
                level1Value = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_1__c;
            if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_2__c!=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_2__c!= '')
                level2Value = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_2__c;
            if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_3__c!=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_3__c!= '')
                level3Value = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_3__c;
            if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_4__c!=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_4__c!= '')
                level4Value = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_4__c;
            if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_5__c!=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_5__c!= '')
                level5Value = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_5__c;
            if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_6__c!=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_6__c!= '')
                level6Value = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_6__c;
            if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_7__c!=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_7__c!= '')
                level7Value = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_7__c;
            if(surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_8__c!=null && surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_8__c!= '')
                level8Value = surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_8__c;*/
        }

        /*If(chainValue != null){
            filterCTax();
        }*/
        return true;
    }
    public List<EUR_CRM_Customer_Taxonomy__c> retrieveExistingCustomerTaxonomy() {
        System.Debug('$$$retrieveExistingCustomerTaxonomy');
        //List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyListTemp = new  List<EUR_CRM_Customer_Taxonomy__c>();
        //initCustomerTaxonomy();

        if (customerTaxonomyList == null) {
            customerTaxonomyList = New List<EUR_CRM_Customer_Taxonomy__c>();
            System.Debug('customerTaxonomyList Reset:');
        }
        return customerTaxonomyList ;
    }

    public void resetValue() {
        Boolean flag = false;
        System.Debug('resetValue:' + resetLevel);
        if (resetLevel == 'EUR_CRM_Chain__c' || flag) {
            level1Value = null;
            flag = true;
        }
        if (resetLevel == 'EUR_CRM_Level_1__c' || flag) {
            level2Value = null;
            flag = true;
        }
        if (resetLevel == 'EUR_CRM_Level_2__c' || flag) {
            level3Value = null;
            flag = true;
        }
        if (resetLevel == 'EUR_CRM_Level_3__c' || flag) {
            level4Value = null;
            flag = true;
        }
        if (resetLevel == 'EUR_CRM_Level_4__c' || flag) {
            level5Value = null;
            flag = true;
        }
        if (resetLevel == 'EUR_CRM_Level_5__c' || flag) {
            level6Value = null;
            flag = true;
        }
        if (resetLevel == 'EUR_CRM_Level_6__c' || flag) {
            level7Value = null;
            flag = true;
        }
        if (resetLevel == 'EUR_CRM_Level_7__c' || flag) {
            level8Value = null;
        }
    }

    public List<SelectOption> getChainOptions() {

        return retrieveCTaxListValues(null, 'EUR_CRM_Chain__c', '');
    }
    public List<SelectOption> getLevel1Options() {
        /*if(!initLevel1)
            initLevel1 = true;
        else
            level1Value = null;*/

        /*if(chainValue == null || chainValue  == ALL){
           level1Value = null;
            return null;
        }*/
        return retrieveCTaxListValues('EUR_CRM_Chain__c', 'EUR_CRM_Level_1__c', chainValue);
    }
    public List<SelectOption> getLevel2Options() {
        /*if(!initLevel2)
            initLevel2 = true;
        else
            level2Value = null;*/
        /*if(level1Value== null || level1Value == ALL){
            level2Value = null;
            return null;
        }*/
        return retrieveCTaxListValues('EUR_CRM_Level_1__c', 'EUR_CRM_Level_2__c', level1Value);
    }
    public List<SelectOption> getLevel3Options() {
        /*if(!initLevel3)
            initLevel3 = true;
        else
            level3Value = null;*/
        /*if(level2Value== null || level2Value == ALL){
            level3Value = null;        
            return null;
        }*/
        return retrieveCTaxListValues('EUR_CRM_Level_2__c', 'EUR_CRM_Level_3__c', level2Value);
    }
    public List<SelectOption> getLevel4Options() {
        /*if(!initLevel4)
            initLevel4 = true;
        else
            level4Value = null;*/
        /*if(level3Value== null || level3Value == ALL){
            level4Value = null;            
            return null;
        }*/
        return retrieveCTaxListValues('EUR_CRM_Level_3__c', 'EUR_CRM_Level_4__c', level3Value);
    }
    public List<SelectOption> getLevel5Options() {

        /*if(!initLevel5)
            initLevel5 = true;
        else
            level5Value = null;*/
        /*if(level4Value== null || level4Value == ALL){
            level5Value = null;            
            return null;
        }*/
        return retrieveCTaxListValues('EUR_CRM_Level_4__c', 'EUR_CRM_Level_5__c', level4Value);
    }
    public List<SelectOption> getLevel6Options() {

        /*if(!initLevel6)
            initLevel6 = true;
        else
            level6Value = null;*/
        /*if(level5Value== null || level5Value == ALL){
            level6Value = null;
            return null;
        }*/
        return retrieveCTaxListValues('EUR_CRM_Level_5__c', 'EUR_CRM_Level_6__c', level5Value);
    }
    public List<SelectOption> getLevel7Options() {

        /*if(!initLevel7)
            initLevel7 = true;
        else
            level7Value = null;*/
        /*if(level6Value== null || level6Value == ALL){
            level7Value = null;
            return null;
        }*/
        return retrieveCTaxListValues('EUR_CRM_Level_6__c', 'EUR_CRM_Level_7__c', level6Value);
    }
    public List<SelectOption> getLevel8Options() {

        /*if(!initLevel8)
            initLevel8 = true;
        else
            level8Value = null;*/
        /*if(level7Value== null || level7Value == ALL){
            level8Value = null;
            return null;
        }*/
        return retrieveCTaxListValues('EUR_CRM_Level_7__c', 'EUR_CRM_Level_8__c', level7Value);
    }
    /*public List<SelectOption> getMgmtTypeOptions (){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
        EUR_CRM_Customer_Taxonomy__c.EUR_CRM_Management_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
    	options.add(new SelectOption(Label.EUR_CRM_Regie_and_Independent, Label.EUR_CRM_Regie_and_Independent));
	    if(managementTypeValue == null || managementTypeValue == ''){
	        managementTypeValue = Label.EUR_CRM_Regie_and_Independent;
	    }
        
	    for( Schema.PicklistEntry f : ple){
	  		options.add(new SelectOption(f.getValue(),f.getLabel() ));
		}       
       	//options.add(new SelectOption(Label.EUR_CRM_Regie_and_Independent, Label.EUR_CRM_Regie_and_Independent));
        return options;
    } */
    public void filterCTax() {
        System.Debug('$$$filterCTax:' + chainValue + ':' + level1Value + ':' + level2value + ':' + level3value + ':' + level4value + ':' + level5value + ':' + level6value + ':' + level7value + ':' + level8value);

        /*String SelectedChain = chainValue;
        String SelectedL1 = level1Value;
        String SelectedL2 = level2Value;
        String SelectedL3 = level3Value;
        String SelectedL4 = level4Value;
        String SelectedL5 = level5Value;
        String SelectedL6 = level6Value;
        String SelectedL7 = level7Value;
        String SelectedL8 = level8Value;*/

        String queryCTax = 'select id,name, recordtype.developername from EUR_CRM_Customer_Taxonomy__c Limit 1' ;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.EUR_CRM_SelectCusTaxWarningMessage));              
        system.debug('$$$filtering');
        queryCTax = 'select id,name, recordtype.developername from EUR_CRM_Customer_Taxonomy__c  where recordtype.Developername In ' + SurveyHeaderCustTax_FilterMap.get(surveyHeaderlocal.recordtype.developername) ;
        if (chainValue != null && chainValue != ALL)
            queryCTax += ' AND EUR_CRM_Chain__c = \'' + String.escapeSingleQuotes(chainValue) + '\'';

        if (level1Value != null && level1Value != ALL)
            queryCTax += ' AND EUR_CRM_Level_1__c = \'' + String.escapeSingleQuotes(level1Value) + '\'';

        if (level2value != null && level2Value != ALL)
            queryCTax += ' AND EUR_CRM_Level_2__c = \'' + String.escapeSingleQuotes(level2Value) + '\'';

        if (level3value != null && level3Value != ALL)
            queryCTax += ' AND EUR_CRM_Level_3__c = \'' + String.escapeSingleQuotes(level3Value) + '\'';

        if (level4value != null && level4Value != ALL)
            queryCTax += ' AND EUR_CRM_Level_4__c = \'' + String.escapeSingleQuotes(level4Value) + '\'';

        if (level5value != null && level5Value != ALL)
            queryCTax += ' AND EUR_CRM_Level_5__c = \'' + String.escapeSingleQuotes(level5Value) + '\'';

        if (level6value != null && level6Value != ALL)
            queryCTax += ' AND EUR_CRM_Level_6__c = \'' + String.escapeSingleQuotes(level6Value) + '\'';

        if (level7value != null && level7Value != ALL)
            queryCTax += ' AND EUR_CRM_Level_7__c = \'' + String.escapeSingleQuotes(level7Value) + '\'';

        if (level8value != null && level8Value != ALL)
            queryCTax += ' AND EUR_CRM_Level_8__c = \'' + String.escapeSingleQuotes(level8Value) + '\'';
        /*if(managementTypeValue !=null && managementTypeValue != Label.EUR_CRM_Regie_and_Independent)
            queryCTax += ' AND EUR_CRM_Management_Type__c = \''+ managementTypeValue+'\'';*/
        queryCTax += ' limit 10000';
        system.debug('$$$filterCTax:Query:' + queryCTax);

        customerTaxonomyList = (List<EUR_CRM_Customer_Taxonomy__c>) Database.query(queryCTax);
//        system.debug('$$$filterCTax:CTaxResult:' + customerTaxonomyList);
        setConCTax();

        /*chainValue = SelectedChain;
        level1Value = SelectedL1;
        level2Value = SelectedL2;
        level3Value = SelectedL3;
        level4Value = SelectedL4;
        level5Value = SelectedL5;
        level6Value = SelectedL6;
        level7Value = SelectedL7;
        level8Value = SelectedL8;*/
    }

    public List<SelectOption> retrieveCTaxListValues(String controllingField, String field, String controllingFieldValue) {


        System.Debug('$$$retrieveCTaxListValues:' + controllingField + ':' + field + ':' + controllingFieldValue);
        String query = 'select ' + field + ' from EUR_CRM_Customer_Taxonomy__c where recordtype.developername in ' + SurveyHeaderCustTax_FilterMap.get(surveyHeaderlocal.recordtype.developername);
        //if(controllingField != null)
        //    query += ' AND ' + controllingField + ' =: controllingFieldValue'; 

        Boolean flag = false;

        if (field == 'EUR_CRM_Level_8__c') {
            query += ' AND EUR_CRM_Level_7__c =: level7Value';
            flag = true;
        }
        if (field == 'EUR_CRM_Level_7__c' || flag) {
            query += ' AND EUR_CRM_Level_6__c =: level6Value';
            flag = true;
        }
        if (field == 'EUR_CRM_Level_6__c' || flag) {
            query += ' AND EUR_CRM_Level_5__c =: level5Value';
            flag = true;
        }
        if (field == 'EUR_CRM_Level_5__c' || flag) {
            query += ' AND EUR_CRM_Level_4__c =: level4Value';
            flag = true;
        }
        if (field == 'EUR_CRM_Level_4__c' || flag) {
            query += ' AND EUR_CRM_Level_3__c =: level3Value';
            flag = true;
        }
        if (field == 'EUR_CRM_Level_3__c' || flag) {
            query += ' AND EUR_CRM_Level_2__c =: level2Value';
            flag = true;
        }
        if (field == 'EUR_CRM_Level_2__c' || flag) {
            query += ' AND EUR_CRM_Level_1__c =: level1Value';
            flag = true;
        }
        if (field == 'EUR_CRM_Level_1__c' || flag) {
            query += ' AND EUR_CRM_Chain__c =: chainValue';
        }
        query += ' group by ' + field;
        AggregateResult[] groupedResults = Database.query(query);
        List<SelectOption> options = new List<SelectOption>();

        System.Debug('$$$retrieveCTaxListValues:' + query);
        //options.add(new SelectOption(ALL, ALL));
        //feb 10. 2015. remove 'All' option from parent record.
        //if(field != 'EUR_CRM_Chain__c')
        options.add(new SelectOption(ALL, ALL));

        for (AggregateResult ar : groupedResults) {
            String x = (String) ar.get(field);
            if (x == null)
                x = '';
            system.debug('@@' + x);
            options.add(new SelectOption(x, x));
        }

        return options;
    }
    public void setConCTax() {
        System.Debug('$$$setConCTax');
        conCTax = new ApexPages.StandardSetController(customerTaxonomyList);
        conCTax.setPageSize(20);
        Set<id> CTaxIdSet = New Set<Id>();
        /*for(EUR_CRM_Customer_Taxonomy__c CTax : customerTaxonomyList){
            CTaxIdSet.add(CTax.Id);
            //System.Debug(CTax.Id);
        }*/
        //Update Filtered Account At The Same Time
        String query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                ', EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c ' +
                ', EUR_CRM_Key_Account_Manager__c, EUR_JB_Customer_Taxonomy__c, EUR_CRM_Epicenter__c, EUR_CRM_Model_Shop__c, EUR_CRM_Reason_for_deactivation__c ' +
                ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c ' +
                'from EUR_CRM_Account__c where ' + accountRtFilterQuery + ' AND EUR_JB_Customer_Taxonomy__c in : customerTaxonomyList LIMIT 9999';

        cTaxQuery = query;

        System.debug('$$$ setConCTax query:' + query);
        //System.debug(con);
        this.con = null;
        this.con.setPageNumber(1);
        this.euAccounts = null;
        this.selectedAccounts = new Set<Id>();
        this.deselectedAccounts = new Set<Id>();
        this.isAllSelected = true;
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
    }
    public List<EUR_CRM_Customer_Taxonomy__c> getTaxList() {
        /*List<EUR_CRM_Customer_Taxonomy__c> taxList = new List<EUR_CRM_Customer_Taxonomy__c>();
        for(EUR_CRM_Customer_Taxonomy__c tax: (List<EUR_CRM_Customer_Taxonomy__c>) conCTax.getRecords()){
            taxList.add(tax);
        } */
        return conCTax.getRecords();
    }
    // indicates whether there are more records after the current page set.
    public Boolean hasNextCTax {
        get {
            return conCTax.getHasNext();
        }
        set;
    }
    // indicates whether there are more records before the current page set.
    public Boolean hasPreviousCTax {
        get {
            return conCTax.getHasPrevious();
        }
        set;
    }
    // returns the page number of the current page set
    public Integer pageNumberCTax {
        get {
            return conCTax.getPageNumber();
        }
        set;
    }
    // returns the first page of records
    public void firstCTax() {

        conCTax.first();
    }
    // returns the last page of records
    public void lastCTax() {

        conCTax.last();
    }
    // returns the previous page of records
    public void previousCTax() {

        conCTax.previous();
    }
    // returns the next page of records
    public void nextCTax() {

        conCTax.next();
    }
    public Integer getPagesCTax() {

        return (conCTax.getResultSize() / conCTax.getPageSize()) + 1;
    }
    public Integer getRecordSizeCTax() {

        return conCTax.getResultSize() != null ? conCTax.getResultSize() : 0;
    }
    public Integer getPageSizeCTax() {

        return conCTax.getPageSize() != null ? conCTax.getPageSize() : 0;
    }


    @TestVisible
    String getListviewFilter() {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setEndpoint(baseUrl + '/services/data/v41.0/sobjects/EUR_CRM_Account__c/listviews/' + filterId + '/describe');
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        try {
            response = http.send(request);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unauthorized endpoint, please check Setup->Security->Remote site settings and add the endpoint '+baseUrl));
            return '';
        }

        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String query = (String) results.get('query');
            Integer position = query.indexOf(' WHERE ');
            if (position != -1) {
                query = query.substring(position + 6);
                Integer orderByPosition = query.indexOf('ORDER BY ');
                if (orderByPosition!=-1) {
                    return query.substring(1,orderByPosition);
                }else{
                    return query;
                }

            }
        }
        return '';
    }

/* Account List View Section*/
    public void initAccountListView() {
        String listviewFilter = getListviewFilter();
        if (String.isNotBlank(listviewFilter)) {
            listviewFilter = ' AND ('+listviewFilter+')';
        }

        String query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                ', EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c ' +
                ', EUR_CRM_Key_Account_Manager__c, EUR_JB_Customer_Taxonomy__c, EUR_CRM_Epicenter__c, EUR_CRM_Model_Shop__c, EUR_CRM_Reason_for_deactivation__c ' +
                ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c ' +
                'from EUR_CRM_Account__c where ' + accountRtFilterQuery + listviewFilter;

        System.debug('#query:'+query);
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query + ' LIMIT 9999'));
        con.setPageSize(pSize);
        this.euAccounts = null;
        this.selectedAccounts = new Set<Id>();
        this.deselectedAccounts = new Set<Id>();
    }

    public SelectOption[] getListViewOptions() {
        List<SelectOption> selOpList = new List<SelectOption>();
        selOpList.add(new SelectOption('', '--None--'));
        selOpList.addAll(con.getListViewOptions());

        return selOpList;
    }
    public PageReference resetFilter() {
        System.debug('Changing filter to ' + filterId);

        if (filterOption == 'AccList') {
            initAccountListView();
        } else if (filterOption == 'CTax') {
            filterId = null;
            initCustomerTaxonomy();
        } else if (filterOption == 'PROS') {
            filterId = null;
            initPROS();
        }

        /*
            this.con = null;
            this.con.setPageNumber(1);
            this.con.setFilterId(filterId);
            this.euAccounts = null;
            //this.wrapAccounts = null;
            this.selectedAccounts = new Set<Id>();
            this.deselectedAccounts = new Set<Id>();
            this.isAllSelected = false;
            this.selectAll();
            System.debug('========================= this.selectedAccounts ' + this.selectedAccounts.size());*/


        return null;
    }

/*PROS Section*/
    Public Boolean initPROS() {
        System.Debug('>>>initPROS');
        //recTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c' + 'EUR_' + countryCode + '_OP_PROS_Segment_Mapping');
        //recTypeId = [Select Id FROM RecordType WHERE SObjectType = 'EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c' AND DeveloperName = 'EUR_FI_OP_PROS_Segment_Mapping'].Id;
        //String SurveyID = currentURLStr.split('=')[1];
        //System.Debug('@@@EUR_CRM_AccountFilterByPROSSegmentCtrl:filter:SurveyID:' + SurveyID);

        outletImages = new List<String>();
        outletTypes = new List<String>();
        selectedOutletImages = new List<String>();
        selectedOutletTypes = new List<String>();
        getOutletImages();
        getOutletTypes();
        createTable();


        return true;
    }
    public Set<String> retrievePROSSelection() {
        Set<String> PROSSet = New Set<String>();

        try {
            List<String> PROSStrList = surveyHeaderlocal.EUR_CRM_Account_Filter_PROS__c.Split('OR');
            System.Debug(PROSStrList);

            for (String PROS : PROSStrList) {
                List<String> SplitPart = PROS.remove('(EUR_CRM_Image_Level_Name__c = ').remove('EUR_CRM_Group_Outlet_Type_Name__c = ').remove('\'').remove(')').Split('AND');
                String IL = SplitPart[0].trim();
                String OT = SplitPart[1].trim();

                System.Debug('IL:' + IL);
                System.Debug('OT:' + OT);

                PROSSet.add(IL + ':' + OT);
            }
        } Catch (Exception e) {
            System.debug('EUR_CRM_AccountFilterByPROSSegmentCtrl: No PROS Available On Header.');
        }

        return PROSSet;
    }
    public void getOutletImages() {

        Schema.DescribeFieldResult fieldResult = EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c.EUR_CRM_Image_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            outletImages.add(f.getLabel());
        }
    }
    public void getOutletTypes() {

        Schema.DescribeFieldResult fieldResult = EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c.EUR_CRM_Group_Outlet_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            outletTypes.add(f.getLabel());
        }
    }
    public void createTable() {

        Set<String> existingProsKey = new Set<String>();
        /*for(EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c existingOPPros : [SELECT Id, Name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Image_Level__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c ]){
            existingProsKey.add(existingOPPros.EUR_CRM_Image_Level__c+':'+existingOPPros.EUR_CRM_Group_Outlet_Type__c);
        }*/
        existingProsKey = retrievePROSSelection();
        System.debug('&&EXISTING: ' + existingProsKey);

        opWrapList = new List<ObjectPromWrapper>();
        Integer opCtr = 1;
        for (String oImage : outletImages) {
            for (String otype : outletTypes) {
                String opWrapUnique = oImage + ':' + otype;
                System.debug('&&EXISTING2: ' + existingProsKey + ' ----- ' + opWrapUnique);
                System.debug('&&Add Option: ' + oImage + ' ----- ' + otype);
                if (existingProsKey.contains(opWrapUnique)) {
                    opWrapList.add(new ObjectPromWrapper(true, opCtr, oImage, otype));
                } else {
                    opWrapList.add(new ObjectPromWrapper(false, opCtr, oImage, otype));
                }

                opCtr++;
            }
        }

        if (existingProsKey != null) {
            filterPROS();
        }
    }
    public void filterPROS() {
        System.Debug('>>>PROS Filter');
        //isSelectorRerendered = true;
        whereClauseString = '';

        // get a list of all selected PROS Segmentation
        for (ObjectPromWrapper opWrap : opWrapList) {
            if (opWrap.isSelected == true) {
                if (whereClauseString != '') {
                    whereClauseString += ' OR ';
                }
                whereClauseString += '(EUR_CRM_Image_Level_Name__c = ' + '\'' + opWrap.opOutletImage + '\'';
                whereClauseString += ' AND EUR_CRM_Group_Outlet_Type_Name__c = ' + '\'' + opWrap.opOutletType + '\'' + ')';

                selectedOutletImages.add(opWrap.opOutletImage);
                selectedOutletTypes.add(opWrap.opOutletType);
            }
        }
        System.debug('>>>PROS Filter:' + whereClauseString);

        if (whereClauseString == '') {
            return;
        }


        String query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                ', EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c ' +
                ', EUR_CRM_Key_Account_Manager__c, EUR_JB_Customer_Taxonomy__c, EUR_CRM_Epicenter__c, EUR_CRM_Model_Shop__c, EUR_CRM_Reason_for_deactivation__c ' +
                ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c ' +
                'from EUR_CRM_Account__c where ' + accountRtFilterQuery + ' AND (' + whereClauseString + ') LIMIT 10000';

        System.Debug('>>>PROS Acc Qurey:' + query);

        //update surveyHeader;

        this.con = null;
        this.con.setPageNumber(psize);
        this.euAccounts = null;
        this.selectedAccounts = new Set<Id>();
        this.deselectedAccounts = new Set<Id>();
        this.isAllSelected = true;
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
    }


    public class ObjectPromWrapper {

        public Boolean isSelected { get; set; }
        public Integer indexNumber { get; set; }
        public String opOutletImage { get; set; }
        public String opOutletType { get; set; }
        public String uniquekey { get; set; }

        public ObjectPromWrapper(Boolean isSelected, Integer indexNumber, String opOutletImage, String opOutletType) {

            this.isSelected = isSelected;
            this.indexNumber = indexNumber;
            this.opOutletImage = opOutletImage;
            this.opOutletType = opOutletType;
            this.uniquekey = opOutletImage + ':' + opOutletType;

        }
    }

/*Set Account Pick List*/


/*Account Pick List Operation*/
    public class euAccountsWrapper {
        public Boolean isSelected { get; set; }
        public EUR_CRM_Account__c euAccount { get; set; }

        public euAccountsWrapper(EUR_CRM_Account__c euAccount, Boolean isSelected) {
            this.euAccount = euAccount;
            this.isSelected = isSelected;
        }
    }

    public List<EUR_CRM_Account__c> retrieveAccounts() {
        if (euAccounts == null) {
            integer pageNumber = this.con.getPageNumber();
            this.con.first();

            System.debug('Re-initializing euAccounts');
            euAccounts = new List<EUR_CRM_Account__c>();

            while (this.con.getHasNext()) {
//                System.debug(this.con.getRecords());
                euAccounts.addAll((List<EUR_CRM_Account__c>) this.con.getRecords());
                this.con.next();
            }

            // Add the last page to the list of accounts
//            System.debug(this.con.getRecords());
            euAccounts.addAll((List<EUR_CRM_Account__c>) this.con.getRecords());

            this.con.setPageNumber(pageNumber);
        }

        System.debug(euAccounts.size());
        return euAccounts;
    }
    public List<euAccountsWrapper> getWrapAccounts() {

        List<euAccountsWrapper> wrapAccounts = new List<euAccountsWrapper>();

        if (con == null) {
            return wrapAccounts;
        }

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

            if (surveyHeaderlocal.EUR_CRM_Active__c == true) {
                if (publishedAccountSet.Get(a.Id) != null) {
                    wrapAccount.IsSelected = true;
                } else {
                    wrapAccount.IsSelected = false;
                }
            }
            wrapAccounts.add(wrapAccount);
        }
//        System.debug(wrapAccounts);
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
//            System.debug(this.con.getRecords());
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
    //   return whether next page exists
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
        this.deselectedAccounts.remove(this.contextItem);

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
        this.deselectedAccounts.add(this.contextItem);
        isAllSelected = false;
    }
    public Boolean getHasSelectedAccounts() {

        return selectedAccounts.size() > 0;
    }
    //Method to Select All Record
    public void selectAll() {
        for (EUR_CRM_Account__c a : retrieveAccounts()) {
            selectedAccounts.add(a.id);
            this.deselectedAccounts.remove(a.id);
        }
        isAllSelected = true;
    }
    //Method to De Select All Records
    public void deSelectAll() {

        for (EUR_CRM_Account__c a : retrieveAccounts()) {
            selectedAccounts.remove(a.id);
            this.deselectedAccounts.add(a.id);
        }
        isAllSelected = false;
    }
    public PageReference validateAccounts() {
        isPermissible = true;
        return null;
    }

/*Create Survey*/
    public void quickSaveAccounts() {
        /*Savepoint sp = Database.setSavepoint();

        try{
            //Do Create
            PageReference pageRef = new PageReference('/' + currentURL);
            pageRef.setRedirect(true);
            return pageRef;
        }catch(Exception e){
            Database.rollback(sp);
            throw e;
            system.debug('@@ ERROR : ' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e) );
            return null;
        }*/

        if (filterOption == 'AccList') {
            surveyHeaderlocal.EUR_CRM_Account_Filter_PROS__c = Null;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Chain__c = Null;
            surveyHeaderlocal.EUR_CRM_Account_Filter_ID__c = filterId;

        } else if (filterOption == 'CTax') {
            surveyHeaderlocal.EUR_CRM_Account_Filter_PROS__c = Null;
            surveyHeaderlocal.EUR_CRM_Account_Filter_ID__c = Null;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Chain__c = chainValue;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_1__c = level1Value;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_2__c = level2Value;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_3__c = level3Value;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_4__c = level4Value;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_5__c = level5Value;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_6__c = level6Value;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_7__c = level7Value;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Level_8__c = level8Value;

        } else if (filterOption == 'PROS') {
            surveyHeaderlocal.EUR_CRM_Account_Filter_PROS__c = whereClauseString;
            surveyHeaderlocal.EUR_CRM_Account_Filter_CustTax_Chain__c = Null;
            surveyHeaderlocal.EUR_CRM_Account_Filter_ID__c = Null;

        }

        update surveyHeaderlocal;

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Filter Saved, Click Publish To Create Survey.'));

        //return null;
    }

    public PageReference saveAccounts() {
        quickSaveAccounts();
        return cancel();
    }

    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + surveyHeaderlocal.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    //Create
    public PageReference publishSurvey() {
        quickSaveAccounts();

        Map<String, String> surveyHeaderRecordTypeMapping = EUR_CRM_RecordTypeHelper.SurveyControllerExt_surveyHeaderRecordTypeMapping;
        System.Savepoint sp = Database.setSavepoint();
        try {
            List<EUR_CRM_Survey__c> existingSurvey = [select id from EUR_CRM_Survey__c Where EUR_CRM_Survey_Header__c = :surveyHeaderlocal.id];

            delete existingSurvey;

            String devName = surveyHeaderRecordTypeMapping.get(surveyHeaderlocal.recordtype.developername);
            RecordType rt = [select id from recordtype where sobjecttype = 'EUR_CRM_Survey__c' and developername = :devName];

            List<EUR_CRM_Survey__c> surveylist = new List<EUR_CRM_Survey__c>();
            for (EUR_CRM_Account__c a : retrieveAccounts()) {
                if (selectedAccounts.contains(a.Id)) {
                    EUR_CRM_Survey__c sy = new EUR_CRM_Survey__c(EUR_CRM_Account__c = a.Id, EUR_CRM_Survey_Header__c = surveyHeaderlocal.Id, recordtypeId = rt.id);
                    surveylist.add(sy);
                }
            }

            if (surveylist.size() > 0)
                insert surveylist;

            //update active
            surveyHeaderlocal.EUR_CRM_Active__c = true;
            update surveyHeaderlocal;

            PageReference pageRef = new PageReference('/' + surveyHeaderlocal.Id);
            pageRef.setRedirect(true);
            return pageRef;
        } catch (Exception ex) {
            if (ex.getTypeName() == 'DmlException') {
                Database.rollback(sp);
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, ex.getDMLMessage(0)));
            }
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
            return null;
        }
    }
}