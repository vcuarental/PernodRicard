/*
=== Usage ===
    Allow users creating and editing multiple records in single page
    
=== Steps ===
    - Import the codes (MassCreateAndUpdateController.cls, MassCreateAndUpdate.component)
    - Create Custom Setting named "MassCreateAndUpdateSetting" and Setting Type is List
    - Create fields for MassCreateAndUpdateSetting: DisplayFields__c, FieldsToParam__c
    - Create a VF page including the component in MassCreateAndUpdate.component
    - Set the component attribute according to your preferences (See 
      MassCreateAndUpdate.component for detail)
 
=== Custom Setting Description ===
    MassCreateAndUpdateSetting:
        Name:
            Specify which object and record type this setting belongs to
            Format: Object__c:Record_Type_1
            If record type is not specified, the settings would be applied to all types
                of the object
        DisplayFields__c:
            The columns of fields which are shown in the edit page
            Format: Field1__c, Field2__c&req=T&width=150px, Field3__c&read=A
            Attributes:
                Attribute Name      Values          Description
                req                 T               Whether the field is mandatory
                width               150px/25%       The column width
                read                N/O/A           Set this attribute if need readonly. readonly for (N = new records, O = old records, A = all records)
                skipClone           T               Skip cloning the value for column // TODO: Now only for fast mode
        FieldsToParam__c:
            Show the default value of fields when creating new record
            Specify the mapping of field name (API Name) and URL parameter names
            Format: Field1__c => param1
            In above example, if the url is "https://xxx?param1=DefaultValue", it
                will assign "DefaultValue" to Field1__c when creating new record
*/
public with sharing class ASI_MFM_MassCreateAndUpdateController_P extends ASI_MFM_AbstractComponentController_P {

    public static final String ACTION_EDIT = 'edit';
    public static final String ACTION_CLONE = 'clone';
    public static final String ACTION_ADD_NEW = 'add_new';
    public static final String ACTION_REMOVE_NEW = 'remove_new';
    public static final String RTNAME_MASTER = 'General';
    public static final String RTDEVNAME_MASTER = '_General_';
    public static final Integer NUM_OF_HIDDEN_ROW = 15;
    private static final String FIELD_PARAM_REQUIRED = 'req';
    private static final String FIELD_PARAM_COL_WIDTH = 'width';
    private static final String FIELD_PARAM_READ_ONLY = 'read';
    private static final String FIELD_PARAM_COL_KEY = 'ckey';
    private static final String FIELD_PARAM_SKIP_CLONE = 'skipClone';
    private static final String DELIM_SETTING_KEY = ':';
    private static final String DELIM_RT = ',';
    private static final String DELIM_FIELDS = ',';
    private static final String DELIM_FIELD_ELEMENTS = '&';
    private static final String DELIM_FIELD_SETTING = '=';
    private static final String DEF_ORDER_BY = 'Name';

    // Attributes
    public Boolean isFastModeBool { get; set; }
    public String sObjTypeStr { get; set; }
    public String displayFieldsStr { get; set; }
    public String whereStatm { get; set; }
    public String orderByStr { get { if (orderByStr == null || orderByStr.trim().length() == 0) orderByStr = DEF_ORDER_BY; return orderByStr; } set; }
    public String includeRecordTypesValue { get; set; }
    public String fieldToURLParamStr { get; set; }
    public String pageBlockTitleStr { get {if (pageBlockTitleStr == null) return sObjLabel; return pageBlockTitleStr;} set; }
    public String successLinkValue { get; set; }
    public String cancelLinkValue { get; set; }
    public String modeValue { get { if (modeValue == null) modeValue = MODE_BOTH; return modeValue; } set { if (value == null) modeValue = MODE_BOTH; else modeValue = value.toUpperCase(); } }
    public Boolean isDefaultEditVal { get; set; }
    public Boolean showAllRTValue { get; set; }
    public Boolean isUseFirstRowForNew { get; set; }
    public String altSObjectTypeNameValue { get; set; }
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    // Data used in VF page
    public String sObjLabel { get; private set; }
    public List<RecordTypeElement> theRecordTypeElementList { get; set; }
    public List<SelectOption> recordTypeOptionList { get; set; }
    public Integer numOfRecordType { get; set; }
    public String selectedRecordType { get; set; }
    public List<PageBlockActionBtn> pageBlockActionBtnList { get; set; }
    
    // Modes
    public String MODE_NEW { get { return 'NEW'; } private set; }
    public String MODE_EDIT { get { return 'EDIT'; } private set; }
    public String MODE_BOTH { get { return 'BOTH'; } private set; }
    // Parameter Names
    public String PARAM_RTID { get { return 'rtid'; } private set;} // record type id
    public String PARAM_TRID { get { return 'rid'; } private set;} // record id
    public String PARAM_NUM_OF_SHOW_ROW { get { return 'showRowNum'; } private set;}
    
    private Schema.SObjectType sObjType;
    private Map<String, String> fieldNameToValueMap;
    private decimal last_plan_balance;
    private boolean negative_pol_balance = false;
    
    public ASI_MFM_MassCreateAndUpdateController_P() {}

    public ASI_MFM_objectPickListHelper helper1{ get; set; }
    public String lookupToPicklist { get; set; } 
    public List<String> checkPicklist { get; set; }
    public Set<String> checkPicklistSet { get; set; }
    public Map<String,List<selectOption>> allLookPicklist { get; set;} 
    
    //20171221 Introv
    Public Boolean resetDeleteCount {Get; Set;}
    
    //For Sub-brand Allocation
    //public List<ASI_MFM_Sub_brand_Allocation__c> theSubBrandAllocationList { get; set; }
    //public List<ASI_MFM_Sub_brand__c> subBrandList = new List <ASI_MFM_Sub_brand__c>();
    //public Map<id, String> setofSubBrand = new Map<id, String>();
    //public List<SelectOption> subBrand_All_Picklist {set; get;}
    //public Set<id> setOfsubBrandID {set; get;}
    public List<interimData> results {get; set;}
    public integer index = 0;
    public integer rowSelected_index {set; get;}
    //public List <ASI_MFM_Sub_brand_Allocation__c> delItemList = new List <ASI_MFM_Sub_brand_Allocation__c>(); 
    //public boolean SBAllocation {set; get;}  
    //public ASI_MFM_PO__c objPO {set; get;}
    //For Sub-brand Allocation - END
    
    public List<RecordType> recordTypeList {set; get;}  
    public Map<String, Schema.SObjectField> sObjFieldMap {set; get;}  
    public List<DisplayCol> commonDisplayColList {set; get;} 
    public Map<String, String> fieldToValueMap {set; get;}
	public Map<String, ASI_MFM_MassCreateAndUpdateSetting__c> allSettingMap {set; get;}
    
    //For Paging 
    public static final String QUERY_MODE_COUNT = 'count';
    public static final String QUERY_MODE_RECORD = 'record';
    public static final Integer OFFSET_MAX_LIMIT = 2000; //limit of max offset by salesforce 
	public static final Integer DEFAULT_PAGING_LIMIT = 10; 
    public integer PageLimit {get;set;} // Number of records to show per page
    public integer PageNumber {get;set;} // Current page number start from 1
    public integer PageIndex { get { return (PageNumber - 1); } } // Zero based version of the page number
	public integer RecordCount {get;set;} // Total number of records in the pageable list
    public integer PageCount { get { return getPageCount(); } } // Total number of pages
    public integer offset { get { return getOffset(); } } //The zero based index where the current page starts
	Public String newInputPageNum {get;set;} // page number user enter in paging input
 	public boolean AllowMoveNext { get{ return ((PageIndex + 1) < PageCount); } } // Indicates if the user can move to the next page
    public boolean AllowMovePrev { get{ return (PageIndex > 0); } } // Indicates if the user can move to the previous page
	public integer maxNumOfRowAllowCreated = 0;//the max number of row in current table show
    
    //Page Message
    public String level {get; set;}
	public String message {get; set;}
    public void showPageMessage() {
 	 	if(level == 'WARNING') {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, message));
  		}else if(level == 'ERROR') {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message)); 
        }else if(level == 'INFO') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message)); 
        }
	}
    
    public integer getOffset(){
        integer iOffset = 0;
        iOffset = (PageLimit * PageIndex);
		iOffset = (iOffset > OFFSET_MAX_LIMIT)? OFFSET_MAX_LIMIT : iOffset;
        return iOffset;
    }
    
    public integer getPageCount() {
        integer iPageCount = 1;
        if (RecordCount != 0 && PageLimit != 0) {
            iPageCount = ((RecordCount>OFFSET_MAX_LIMIT)? (OFFSET_MAX_LIMIT/PageLimit) : (RecordCount/PageLimit)) + ((Math.mod(RecordCount, PageLimit)) > 0 ? 1 : 0);
        }
        return iPageCount;
    }
   
    //For Paging - END
    
    public Set<String> getcheckPicklistSet(){
        return checkPicklistSet;
    }
    
    //For Sub-brand Allocation
    public Class interimData{
        public String id{ 
            get{
                if(String.isBlank(id)){
                    return null;
                }
                return id;
            } 
            set;
        }
        public integer rowindex {get; set;}
        public ASI_MFM_Sub_brand_Allocation__c ppl {get; set;}
    }
    //For Sub-brand Allocation - END
    
    public Boolean init() {
        
        //20171221 Introv
        resetDeleteCount = false;
        
        system.debug('PageLimit: '+PageLimit);
        if(PageLimit==null || PageLimit==0 || PageLimit<0){
        	PageLimit = DEFAULT_PAGING_LIMIT;
    	}
        system.debug('PageLimit: '+PageLimit);
        maxNumOfRowAllowCreated = PageLimit * 2;

        PageNumber = 1;
		RecordCount = 0;
        newInputPageNum = ''+PageNumber;
        
        System.debug('abcit' + lookupToPicklist);
        checkPicklist = lookupToPicklist.split(',', 0);
        checkPicklistSet = new Set<String>();
        allLookPickList = new Map<String,List<selectOption>>();
        for(String s: checkPickList){ System.debug('bcd' + s);}
        
        if(checkPicklist != null)
         if(checkPicklist[0] != 'hello')
            {
                ASI_MFM_Plan__c plan;
                ASI_MFM_PO__c  po;
                if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c') {
                    plan = [select RecordType.DeveloperName, ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c,ASI_MFM_Prefix__r.ASI_MFM_Location__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__r.ASI_MFM_BU_Code__c,ASI_MFM_Prefix__r.Name from ASI_MFM_Plan__c where id = :apexpages.currentPage().getParameters().get('id')];
                } 
                if (sObjTypeStr == 'ASI_MFM_PO_Line_Item__c') {
                    po = [select id, name, ASI_MFM_Plan__r.id,ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c, RecordType.DeveloperName, ASI_MFM_Prefix__r.ASI_MFM_Location__c, ASI_MFM_Prefix__r.Name, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__r.ASI_MFM_BU_Code__c from ASI_MFM_PO__c where id = :apexpages.currentPage().getParameters().get('id')];
                } 
                
                //Wilken 20161108, Add FOC Item for TW CRM
                ASI_FOC_Free_Goods_Request__c foc;
                if (sObjTypeStr == 'ASI_FOC_Request_Item__c') {
                    foc = [select id, name, RecordType.DeveloperName from ASI_FOC_Free_Goods_Request__c where id = :apexpages.currentPage().getParameters().get('id')];
                } 
                
                system.debug('Has FOC: ' + foc); 
                //ASI_MFM_Plan__c pli = [select id, RecordType.DeveloperName from ASI_MFM_Plan__c where id = :apexpages.currentPage().getParameters().get('id')];

              for(String s: checkPicklist){ 
                 checkPicklistSet.add(s);
                 System.debug('bcd9 ' + sObjTypeStr);
                 System.debug('bcd10 ' + s);
                 System.debug('bcd11' + whereStatm);
                 sObjTypeStr = sObjTypeStr.trim();
                 s = s.trim();
                 if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' && s == 'ASI_MFM_A_C_Code__c')
                 {
                     System.debug('cdj0 ' +  apexpages.currentPage().getParameters().get('id'));
                     if (plan != null)
                     {
                         if (plan.RecordType.DeveloperName.contains('ASI_MFM_TW'))
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,whereStatm);
                         else if (plan.RecordType.DeveloperName.contains('ASI_MFM_JP')){
                             String whereStat = ' recordtype.developername =\'ASI_JP_A_C_Code\'  ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         // Added By Alan Wong (Elufa) 24Feb2015
                         // Display A_C code by market
                         else if (plan.RecordType.DeveloperName.contains('ASI_MFM_SG')){
                             String whereStat = ' recordtype.developername =\'ASI_MFM_SG_A_C_Code\'  AND ASI_MFM_Dummy_A_C__c != True  ';
                             whereStat += ' AND ASI_MFM_Market__c = \'' + plan.ASI_MFM_Prefix__r.ASI_MFM_Location__c + '\' ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         // Added By Alan Wong (Elufa) 22April2015
                         // Display User A_C code only
                         else if (plan.RecordType.DeveloperName.contains('ASI_MFM_TH')){
                             string AC_Prefix = plan.ASI_MFM_Prefix__r.Name.substring(0,3);
                             String whereStat = ' recordtype.developername =\'ASI_MFM_TH_A_C_Code\'  AND ASI_MFM_Dummy_A_C__c != True AND ASI_MFM_TH_Prefix__c LIKE \'%' + AC_Prefix + '%\' ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }
                 else if (sObjTypeStr == 'ASI_MFM_PO_Line_Item__c' && (s == 'ASI_MFM_A_C_Code__c' || s == 'ASI_MFM_Sub_brand_Code__c'))
                 {
                     System.debug('cdj1 ' +  apexpages.currentPage().getParameters().get('id') );
                      if (po!= null)
                     {
                         string whereStat = ''; 
                            
                         if (po.RecordType.DeveloperName.contains('ASI_MFM_TW') && s == 'ASI_MFM_Sub_brand_Code__c'){
                             whereStat = ' ASI_TH_CRM_Active__c = true AND ASI_CRM_TW_Company__c = \'PRT\' ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         // 2017-08-24  Linus@introv
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);    
                     }else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                         
                 }
                 else if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' && s == 'ASI_MFM_Sub_brand_Code__c')
                 {
                     
                     if (plan != null)
                     {
                         System.debug('cdj0 ' +  apexpages.currentPage().getParameters().get('id'));
                         if (plan.RecordType.DeveloperName.contains('ASI_MFM_TW')){
                            String whereStat = ' ASI_CRM_TW_Company__c =\'PRT\' AND ASI_TH_CRM_Active__c = true ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }
                 else if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' && s == 'ASI_MFM_AP_Code__c')
                 {
                     System.debug('cdj0 ' +  apexpages.currentPage().getParameters().get('id'));
                     if (plan != null)
                     {
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }else if ((sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' || sObjTypeStr == 'ASI_MFM_PO_Line_Item__c' ) && s == 'ASI_MFM_Customer_Name__c')
                 {
                    String whereStat = ' recordtype.developername =\'ASI_MFM_MY_Customer\'  ';
                    String GF_whereStat = ' recordtype.developername =\'ASI_GF_Customer\'  ';

                     helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }
                 // Added by Alan Wong(Elufa) 20150504 Inavtive sub-brand allocation
                 else if ((sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' || sObjTypeStr == 'ASI_MFM_PO_Line_Item__c' ) && s == 'ASI_MFM_Sub_brand_Allocation_Type__c')
                 {
                     System.debug('cdj0 ' +  apexpages.currentPage().getParameters().get('id'));
                     if (plan != null)
                     {
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else if (po != null)
                     {
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }
                 //Added by Wilken 20161108, TW CRM uses FOC Object Manage All with SKU picklist
                 /*else if ((sObjTypeStr == 'ASI_FOC_Request_Item__c') && s == 'ASI_FOC_SKU__c')
                 {
                    if (foc.RecordType.DeveloperName.contains('ASI_CRM_TW_FOC')){
                         String whereStat = ' recordtype.developername =\'ASI_MFM_TW_SKU_Code\' and ASI_HK_CRM_Active__c = TRUE AND ASI_HK_CRM_IsPOSProduct__c = FALSE ';
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                    }
                    else if(foc.RecordType.DeveloperName.contains('ASI_CRM_TW_POSM')){
                         String whereStat = ' recordtype.developername =\'ASI_MFM_TW_SKU_Code\' and ASI_HK_CRM_Active__c = TRUE AND ASI_HK_CRM_IsPOSProduct__c = TRUE ';
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                    }
                 }*/
                 else 
                     helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 allLookPickList.put(s,helper1.pickList);
              }
          }



        // Initialize basic components
        if (pageControllerValue != null)
            this.pageBlockActionBtnList = ((ASI_MFM_MassCreateAndUpdateAbstract_P)pageControllerValue).mcau_initPageBlockActionButtonList();
        if (this.pageBlockActionBtnList == null) this.pageBlockActionBtnList = new List<PageBlockActionBtn>();
        
        // Handle SF object information
        sObjType = Schema.getGlobalDescribe().get(sObjTypeStr);
        sObjLabel = sObjType.getDescribe().getLabel();
        
        // Handle record types
		this.recordTypeList = this.getRecordTypeList();
        if (recordTypeList.size() == 0) { // Record type is not enabled for this sobject type
            recordTypeList.add(new RecordType(Name = RTNAME_MASTER, DeveloperName = RTDEVNAME_MASTER));
        }
        this.numOfRecordType = recordTypeList.size();
        this.selectedRecordType = recordTypeList.get(0).DeveloperName;
        
        // Handle display fields
		this.sObjFieldMap = sObjType.getDescribe().fields.getMap();
		this.commonDisplayColList = getDisplayColListByFieldStr(displayFieldsStr, sObjFieldMap);
        
        // Handle default field values
		this.fieldToValueMap = new Map<String, String>();
        if (fieldToURLParamStr != null) fieldToValueMap = getDefaultFieldValueMapFromStr(fieldToURLParamStr);
        
        this.recordTypeOptionList = new List<SelectOption>();
		this.allSettingMap = ASI_MFM_MassCreateAndUpdateSetting__c.getAll();
        if (modeValue == MODE_EDIT) isDefaultEditVal = true;

		First();
        return true;
    }
    
    /**
     * 
     */
    public void queryResult(integer newPageNumber){ 
    	queryResultData(newPageNumber, false);
    }
    public void queryCount(){
    	queryResultData(1, true);    
    }
    public void queryResultData(integer newPageNumber, boolean isQueryCount){
        integer newPageIndex = (newPageNumber - 1);
        integer newOffset = (PageLimit * newPageIndex);
        integer newRecordCount = 0;
        
        //limit of max offset by salesforce 
        if(newOffset>OFFSET_MAX_LIMIT){
           newOffset = OFFSET_MAX_LIMIT;
        }
        
        theRecordTypeElementList = new List<RecordTypeElement>();
        // Handle record types one by one
        for (RecordType tempRT : recordTypeList) {
            Boolean hasRecordType = (tempRT.DeveloperName != RTDEVNAME_MASTER);
            ID rtId = hasRecordType ? tempRT.Id : null;
            recordTypeOptionList.add(new SelectOption(tempRT.DeveloperName, tempRT.Name));
            ASI_MFM_MassCreateAndUpdateSetting__c rtSetting = getSettingByRecordType(allSettingMap, tempRT.DeveloperName);
            // Get the display fields from settings if no common display fields defined
            List<DisplayCol> displayColList = commonDisplayColList;
            if (commonDisplayColList == null || commonDisplayColList.size() == 0) {
                displayColList = getDisplayColListFromSetting(rtSetting, sObjFieldMap);
            }
            
            // Get default field values from settings if no common default values defined
            if (fieldToValueMap.size() == 0 && fieldToURLParamStr != null)
                fieldToValueMap = getDefaultFieldValueMapFromStr(rtSetting.ASI_MFM_FieldsToParam__c);
            
            // Check other required fields
            Boolean needRecordTypeIdField = hasRecordType;
            if (hasRecordType) {
                for (DisplayCol dc : displayColList) {
                    for (DisplayField df : dc.displayFieldList) {
                        if (df.name.toUpperCase() == 'RECORDTYPEID')
                            needRecordTypeIdField = false;
                    }
                }
            }
            // Generate the query string
            List<sObject> existingSObjList = new List<sObject>();
            if (modeValue == MODE_BOTH || modeValue == MODE_EDIT) {
                String displayFieldCommaStr = getCommaStringFromDisplayColList(displayColList);
                if (needRecordTypeIdField) displayFieldCommaStr += ', RecordTypeId';
				if (isQueryCount) displayFieldCommaStr = 'Count()';
                String queryStr = 'SELECT ' + displayFieldCommaStr + ' FROM ' + sObjTypeStr;
                String wholeWhereStatm = '';
                if (whereStatm != null && whereStatm.trim().length() > 0) wholeWhereStatm += ' (' + whereStatm + ')';
                if (hasRecordType) wholeWhereStatm += (wholeWhereStatm.length() == 0 ? '' : ' AND') + ' (RecordTypeId = :rtId)';
                if (wholeWhereStatm.trim().length() > 0) queryStr += ' WHERE ' + wholeWhereStatm;
                if (!isQueryCount && orderByStr != null && orderByStr.trim().length() > 0) queryStr += ' ORDER BY ' + orderByStr;
				if (!isQueryCount) queryStr += (newOffset>OFFSET_MAX_LIMIT)? ' OFFSET '+ OFFSET_MAX_LIMIT : ' Limit ' + PageLimit + ' OFFSET '+ newOffset;
                
                // Query the results
                system.debug('rtId: '+rtId);
                System.debug('queryString: ' + queryStr);
                integer QueryCount = 0;
				if(isQueryCount){
					QueryCount= Database.countQuery(queryStr);
                }else{
                	existingSObjList = Database.query(queryStr);
                }
                system.debug('existingSObjList: '+ existingSObjList);
                
                //find max record count
                if(isQueryCount){
                	if(QueryCount>newRecordCount){
                    	newRecordCount = QueryCount;
                    	RecordCount = newRecordCount;
                    }
                }
            }
            if(!isQueryCount){
            	theRecordTypeElementList.add(new RecordTypeElement(sObjType, tempRT, existingSObjList, displayColList, fieldToValueMap, isDefaultEditVal, isUseFirstRowForNew, isFastModeBool, maxNumOfRowAllowCreated));
            }
        }  
    }
    
    /**
     * Methods used by other classes
     */
    
    public void clearAll() {
        for (RecordTypeElement rtEle : theRecordTypeElementList) {
            rtEle.deleteAll();
        }
    }
    
    /**
     * Page Actions
     */

    public PageReference commitAll() {
        return commitAll(true);
    }
    
    public PageReference commitAllByQuickSave() {
        return commitAll(false);
    }
    
    public PageReference commitAll(boolean isChangePage) {

        List<sObject> insertList = new List<sObject>();
        List<sObject> updateList = new List<sObject>();
        List<sObject> deleteList = new List<sObject>();
        for (RecordTypeElement rtEle : theRecordTypeElementList) {//20171220
            for (TableRow tr : rtEle.myRecordList) {
                System.debug('Debug Log : ' + tr);
                if (!tr.isBlankAndHidden) {
                    if (tr.isDelete) {
                        if (tr.mySObj.Id != null)
                            deleteList.add(tr.mySObj);
                    } else if (tr.isNew) {
                        if (tr.mySObj.getsObjectType() == asi_mfm_po_line_item__c.sObjectType) {
                            tr.mySObj = asi_mfm_POLineItem.setAmount((asi_mfm_po_line_item__c)tr.mySObj);
                        }
                        insertList.add(tr.mySObj.clone(false, true)); 
                    } else if (tr.isEdit) {
                        updateList.add(tr.mySObj);
                    }
                }
            }
        }
        System.Savepoint sp = database.setSavepoint();
        
        if (deleteList.size() > 0) {
            try {
                database.delete(deleteList);
                
            } catch (DmlException dmle) {
                
                //20171221 Introv
                resetDeleteCount = false;
                
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = deleteList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));
                }
                database.rollback(sp);
                return null;
            }
        }
        if (updateList.size() > 0) {
            try { 
                database.update(updateList);
                
            } catch (DmlException dmle) {
                
                //20171221 Introv
                resetDeleteCount = false;
                
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = updateList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));                  
                }
                database.rollback(sp);
                return null;
            }
        }
        if (insertList.size() > 0) {
            try {  
                database.insert(insertList);
                
            } catch (DmlException dmle) {
                
                //20171221 Introv
                resetDeleteCount = false;
                
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = insertList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));
                }
                database.rollback(sp);
                return null;
            }
        }   
// Custom change starts
         if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c') {
//Modified by Alan on 20150315
             ASI_MFM_Plan__c plan = [select id,ASI_MFM_Single_Approval__c , RecordType.DeveloperName,ASI_MFM_Plan_Amount__c,ASI_MFM_Total_PO_Amount__c from ASI_MFM_Plan__c where id = :apexpages.currentPage().getParameters().get('id')];
         }
        
        //20171221 Introv
        resetDeleteCount = true;
        
// Custom change ends
        if(isChangePage==true){
        	return new PageReference(successLinkValue);
        }else{
            changePage();
			apexpages.addMessage(new apexpages.message(apexpages.severity.CONFIRM, 'Save Success, Please note that all new lines have been reordered to the last page')); 
    	    return null;
        }
    }
    
    /*
     * Methods for non-fast mode only
     * Start {
     */
    public PageReference triggerPageBlockAction() {
        PageReference redirectPage = null;
        String pbBtnId = ApexPages.currentPage().getParameters().get('PARAM_PB_BTN_ID');
        if (pageControllerValue != null) redirectPage = ((ASI_MFM_MassCreateAndUpdateAbstract_P)pageControllerValue).mcau_triggerPageBlockAction(this, pbBtnId);
        return redirectPage;
    }
    
    public PageReference addNewRow() {
        String rtid = ApexPages.currentPage().getParameters().get(PARAM_RTID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.createNewSObject();
        if (pageControllerValue != null) ((ASI_MFM_MassCreateAndUpdateAbstract_P)pageControllerValue).mcau_triggerActionForSObject(this, ACTION_ADD_NEW, tr.mySObj);
        return null;
    }
    public void addNewRowByInfo(String rtDevName, sObject sObj) {
        System.debug('sb8:' + rtDevName);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtDevName);
        TableRow tr = null;
        System.debug('sb9:' + getRTElementByRTDevName(rtDevName));
        if (curRTEle != null) {
            tr = curRTEle.createNewSObject(sObj);
            System.debug('sc0:');
        }
        if (tr != null && pageControllerValue != null){
            ((ASI_MFM_MassCreateAndUpdateAbstract_P)pageControllerValue).mcau_triggerActionForSObject(this, ACTION_ADD_NEW, tr.mySObj);
            System.debug('sc1:');
        }
    }
    
    public PageReference cloneRow() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.cloneNewSObjectByTableRowId(trid);
        if (pageControllerValue != null) ((ASI_MFM_MassCreateAndUpdateAbstract_P)pageControllerValue).mcau_triggerActionForSObject(this, ACTION_CLONE, tr.mySObj);
        return null;
    }
    
    public PageReference enableForEdit() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.enableForEditByTableRowId(trid);
        if (pageControllerValue != null) ((ASI_MFM_MassCreateAndUpdateAbstract_P)pageControllerValue).mcau_triggerActionForSObject(this, ACTION_EDIT, tr.mySObj);
        return null;
    }
    
    public PageReference removeNew() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        TableRow tr = deleteRow(rtid, trid);
        if (pageControllerValue != null) ((ASI_MFM_MassCreateAndUpdateAbstract_P)pageControllerValue).mcau_triggerActionForSObject(this, ACTION_REMOVE_NEW, tr.mySObj);
        return null;
    }
    
    public PageReference deleteOld() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        TableRow tr = deleteRow(rtid, trid);
        if (pageControllerValue != null) ((ASI_MFM_MassCreateAndUpdateAbstract_P)pageControllerValue).mcau_triggerActionForSObject(this, ACTION_REMOVE_NEW, tr.mySObj);
        return null;
    }
    
    public TableRow deleteRow(String rtid, String trid) {
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.removeByTableRowId(trid);
        return tr;
    }
    
    /*
     * Methods for non-fast mode only
     * } End
     */
    
    /*
     * Methods for fast mode only
     * Start {
     */
    
    public PageReference addMoreBlankRows() {
        
        List<TableRow> tmp = new List<TableRow>();
        Integer existingRow = 0;
        
        for (RecordTypeElement rtEle : theRecordTypeElementList) {//20171220
            for (TableRow tr : rtEle.myRecordList) {
                System.debug('Debug Log : ' + tr);
                if (!tr.isBlankAndHidden) {
                    if (tr.isDelete) {
                        if (tr.mySObj.Id != null){
                            tmp.add(tr);
                        }
                    } else if (tr.isNew) {
                        
                        tmp.add(tr); 
                    } else if (tr.isEdit) {
                        tmp.add(tr);
                    }
                }
            }
            
            rtEle.myRecordList = tmp;
            existingRow = tmp.size();
        }
        
        String rtid = ApexPages.currentPage().getParameters().get(PARAM_RTID);
        String numOfShowRowStr = ApexPages.currentPage().getParameters().get(PARAM_NUM_OF_SHOW_ROW);
        Integer numOfShowRow = numOfShowRowStr != null ? Integer.valueOf(numOfShowRowStr) : 1;
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        
        for (Integer i = 0; i < (maxNumOfRowAllowCreated - existingRow); i++) {//20171220 Introv
            TableRow tr = curRTEle.createNewSObject();
            tr.isBlankAndHidden = true;
        }        
        return null;
    }
    
    /*
     * Methods for fast mode only
     * } End
     */
     
    public void refresh() {
    }
    
    private RecordTypeElement getRTElementByRTDevName(String rtId) {
        for (RecordTypeElement rtEle : theRecordTypeElementList) {
            if (rtEle.myRecordType.DeveloperName == rtId)
                return rtEle;
        }
        return null;
    }
    
    /**
     * Methods used by init()
     */
    
    private List<RecordType> getRecordTypeList() {
        List<RecordType> allRecordTypeList = database.query('SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = :sObjTypeStr AND IsActive = true ORDER BY Name');
        List<RecordType> recordTypeList = new List<RecordType>();
        system.debug('includeRecordTypesValue: '+includeRecordTypesValue);
        // include only part of record types if needed
        if (includeRecordTypesValue != null) {
            Set<String> recordTypeStringSet = new Set<String>(strToStrList(includeRecordTypesValue, DELIM_RT));
            for (RecordType tempRT : allRecordTypeList) {
                if (recordTypeStringSet.contains(tempRT.DeveloperName))
                    recordTypeList.add(tempRT);
            }
        } else {
            recordTypeList = allRecordTypeList;
        }
        return recordTypeList;
    }
    
    private ASI_MFM_MassCreateAndUpdateSetting__c getSettingByRecordType(Map<String, ASI_MFM_MassCreateAndUpdateSetting__c> allSettingMap, String recordTypeDevName) {
        String settingKey = (recordTypeDevName == RTDEVNAME_MASTER) ? sObjTypeStr : sObjTypeStr + DELIM_SETTING_KEY + recordTypeDevName;
        ASI_MFM_MassCreateAndUpdateSetting__c rtSetting = allSettingMap.get(settingKey);
        if (rtSetting == null) {
            settingKey = (recordTypeDevName == RTDEVNAME_MASTER) ? altSObjectTypeNameValue : altSObjectTypeNameValue + DELIM_SETTING_KEY + recordTypeDevName;
            rtSetting = allSettingMap.get(settingKey);
        }
        return rtSetting;
    }
    
    private List<DisplayCol> getDisplayColListByFieldStr(String fieldsStr, Map<String, Schema.SObjectField> sObjFieldMap) {
        //Add by Abel
        List<DisplayCol> result = new List<DisplayCol>();  
        Set<String> nowPickListSet = getCheckPicklistSet();  //Add by Abel
        boolean fieldIsPicklist = false;  //Add by Abel
        if (fieldsStr != null && fieldsStr.trim().length() > 0) {
            List<String> fieldList = fieldsStr.split(DELIM_FIELDS, 0);
            DisplayCol curDC = null;
            for (String fieldStr : fieldList) { // Field1__c&req=t&key=value, Field2__c
                List<String> fieldEleList = fieldStr.trim().split(DELIM_FIELD_ELEMENTS, 0);
                String fieldDevName = fieldEleList.get(0).trim();
                Schema.SObjectField sObjField = sObjFieldMap.get(fieldDevName);
                if (sObjField != null) { // if field exists
                    // Create display field
                    //Add by Abel
                    fieldIsPicklist = CheckPicklistSet.contains(fieldDevName);  //Add by Abel
                        System.debug('bcd 7' + fieldDevName);  //Add by Abel
                        System.debug('bcd 7' + fieldIsPicklist);  //Add by Abel
                        
                    
                    DisplayField df = new DisplayField(sObjField.getDescribe().getLabel(), fieldDevName, fieldIsPicklist);  //Add by Abel
                    String colKey = null;
                    String colLabel = null;
                    String colWidth = null;
                    if (fieldEleList.size() > 1) {
                        for (Integer i = 1; i < fieldEleList.size(); i++) { // req=t&key=value
                            List<String> keyAndValue = fieldEleList.get(i).split(DELIM_FIELD_SETTING, 2);
                            if (keyAndValue.size() == 2) {
                                String key = keyAndValue.get(0).trim().toLowerCase();
                                String value = keyAndValue.get(1).trim();
                                if (FIELD_PARAM_COL_KEY == key) {
                                    colKey = value;
                                    colLabel = value;
                                } else if (FIELD_PARAM_COL_WIDTH == key) {
                                    // TODO: get the maximum value
                                    colWidth = value;
                                }
                                assignDisplayFieldProperty(df, key, value);
                            }
                        }
                        if (colLabel == null) {
                            colLabel = df.label;
                            df.label = null;
                        }
                    }
                    if (curDC == null || colKey == null || curDC.colKey != colKey) {
                        curDC = new DisplayCol(colKey, colLabel);
                        result.add(curDC);
                        curDC.colWidth = colWidth;
                    }
                    curDC.addDisplayField(df);
                    system.debug('Field label: ' + df.label);
                    system.debug('Field name: ' + df.name);
                    system.debug('Is required: ' + df.isrequired);
                } else {
                    System.debug('Unknown field: ' + fieldDevName);
                }
            }
        }
        if (result.size() == 0) {
            DisplayCol dc = new DisplayCol(null, null);
            result.add(dc);
            dc.addDisplayField(new DisplayField('Name', 'Name'));
        }
        return result;
    }
    
    private void assignDisplayFieldProperty(DisplayField df, String key, String value) {
        if (FIELD_PARAM_REQUIRED == key) {
            if (value.toLowerCase() == 't' || value.toLowerCase() == 'true')
                df.isRequired = true;
        } else if (FIELD_PARAM_COL_WIDTH == key) {
            df.width = value;
        } else if (FIELD_PARAM_READ_ONLY == key) {
            df.readonlyMode = value.toLowerCase();
        } else if (FIELD_PARAM_COL_KEY == key) {
            df.colKey = value;
        } else if (FIELD_PARAM_SKIP_CLONE == key) {
            df.skipClone = value != null && value.toLowerCase() == 't' || value.toLowerCase() == 'true';
        }
    }
    
    private List<DisplayCol> getDisplayColListFromSetting(ASI_MFM_MassCreateAndUpdateSetting__c rtSetting, Map<String, Schema.SObjectField> sObjFieldMap) {
        if (rtSetting == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'List of display fields is not specified for the object: ' + sObjTypeStr + '. Please edit Custom Setting MassCreateAndUpdateSetting'));
            return null;
        }
        String settingDF = rtSetting.ASI_MFM_DisplayFields__c;
        if (settingDF == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Empty displayField' + sObjTypeStr + '. Please edit Custom Setting MassCreateAndUpdateSetting'));
            return null;
        }
        return getDisplayColListByFieldStr(settingDF, sObjFieldMap);
    }
    
    private String getCommaStringFromDisplayColList(List<DisplayCol> dcList) {
        String result = '';
        for (DisplayCol dc : dcList) {
            List<DisplayField> dfList = dc.displayFieldList;
            for (DisplayField df : dfList) {
                result += ', ' + df.name;
            }
        }
        if (result.length() > 2)
            return result.substring(2);
        return '';
    }
    
    private Map<String, String> getDefaultFieldValueMapFromStr(String fieldToParamStr) {
        Map<String, String> fieldNameToValueMap = new Map<String, String>();
        if (fieldToParamStr != null && fieldToParamStr.trim().length() > 0) {
            Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
            Map<String, String> fieldToParamMap = strToStrMap(fieldToParamStr);
            Set<String> fieldNameSet = fieldToParamMap.keySet();
            for (String fieldName : fieldNameSet) {
                String paramName = fieldToParamMap.get(fieldName);
                fieldNameToValueMap.put(fieldName, urlParamMap.get(paramName));
            }
        }
        return fieldNameToValueMap;
    }
    
    /**
     * Other Utils
     */
    
    private List<String> strToStrList(String inputStr) { return this.strToStrList(inputStr, ','); }
    private List<String> strToStrList(String inputStr, String delim) {
        List<String> result = new List<String>();
        if (inputStr != null && delim != null) {
            List<String> inputStrList = inputStr.split(delim, 0);
            for (String ele : inputStrList) {
                result.add(ele.trim());
            }
        }
        return result;
    }
    
    private String strListToStr(List<String> inputStrList) { return this.strListToStr(inputStrList, ','); }
    private String strListToStr(List<String> inputStrList, String delim) {
        String result = '';
        if (inputStrList != null && delim != null) {
            for (String ele : inputStrList) {
                result += delim + ele;
            }
        }
        if (result.length() >= delim.length()) {
            return result.substringAfter(delim);
        }
        return '';
    }
    
    private Map<String, String> strToStrMap(String mapStr) {
        Map<String, String> result = new Map<String, String>();
        if (mapStr.trim().length() > 0) {
            List<String> mapList = strToStrList(mapStr, ',');
            for (String ms : mapList) {
                List<String> keyAndValue = ms.split('=>', 2);
                if (keyAndValue.size() != 2)
                    ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.WARNING, 'Incorrect Map String: ' + mapStr + '. Please check the Custom Setting MassCreateAndUpdateSetting'));
                else
                    result.put(keyAndValue.get(0).trim(), keyAndValue.get(1).trim());
            }
        }
        return result;
    }
    
    //sub-brand allocation
    /*public void sba_addRow(){    
        if(results != null && results.size() > 0){
            interimData sbaObj = new interimData();
            sbaObj.ppl = new ASI_MFM_Sub_brand_Allocation__c();
            sbaObj.rowindex = index;
            sbaObj.ppl.ASI_MFM_PO__c = apexpages.currentPage().getParameters().get('id');
            sbaObj.ppl.recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation');            
            results.add(0,sbaObj);
            index++;
        }else{
            results = new List<interimData>();
            interimData sbaObj = new interimData();
            sbaObj.ppl = new ASI_MFM_Sub_brand_Allocation__c();
            sbaObj.rowindex = index;
            sbaObj.ppl.ASI_MFM_PO__c = apexpages.currentPage().getParameters().get('id');
            sbaObj.ppl.recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation');
            results.add(sbaObj);
            index++; 
        }
    }*/
    /*public void sba_cloneRow(){
        interimData selected_itm;
        List<interimData> cloneList = new List<interimData>();
        
         for(interimData rpl : results){
            if(rpl.rowindex == rowSelected_index){
                selected_itm = new interimData();
                selected_itm.rowindex = index;
                selected_itm.ppl = new ASI_MFM_Sub_brand_Allocation__c();
                selected_itm.ppl.ASI_MFM_PO__c = apexpages.currentPage().getParameters().get('id');
                selected_itm.ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                selected_itm.ppl.ASI_MFM_Sub_brand_percentage__c = rpl.ppl.ASI_MFM_Sub_brand_percentage__c;
                selected_itm.ppl.recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation');
                
                cloneList.add(selected_itm);
                index++;
            }
         }
         results.addall(cloneList);
    }*/
    /*public void sba_deleteRow(){
        interimData selected_rpl;
        integer i = 0;
        integer c = 0;
        List <integer> temp_index = new List <integer>();
        
        for(interimData r : results){  
            if(r.rowindex == rowSelected_index){
                temp_index.add(i);
                if(r.ppl.id != null)
                    delItemList.add(r.ppl);
            }
            i++;
        }       
        for(integer n : temp_index){
            if(n!=0){
                if(c>0) n=n-c;
                results.remove(n);
                c++;
            }else{
                results.remove(0);
                c++;
            }
        }
    }*/
    //End of sub-brand allocation
    
    public class RecordTypeElement {
        public RecordType myRecordType { get; set; }
        public List<TableRow> myRecordList { get; set; }
        public List<TableRow> myDisplayRecordList {
            get {
                if (myRecordList == null) return null;
                List<TableRow> tempList = new List<TableRow>();
                for (TableRow tr : myRecordList)
                    if (tr.isDelete != true)
                        tempList.add(tr);
                return tempList;
            }
            set;
        }
        public List<DisplayCol> myDisplayColList { get; set; }
        public Set<String> myDisplayFieldSet;
        private Schema.SObjectType sObjType;
        private Map<String, String> fieldNameToValueMap;
        private Boolean hasRecordType;
        public Integer tableRowNextId;
        private Boolean isCreateBeforeFirstRow;
        private Boolean isFastMode;
        public Integer maxNumOfRowAllowCreated;
        
        public RecordTypeElement(Schema.SObjectType sObjType, RecordType recordType, List<sObject> sObjList, List<DisplayCol> displayColList
            , Map<String, String> fieldNameToValueMap, Boolean isAllEdit, Boolean isCreateBeforeFirstRow, Boolean isFastMode, Integer maxNumOfRowAllowCreated) {
            this.myRecordType = recordType;
            this.myDisplayColList = displayColList;
            this.sObjType = sObjType;
            this.fieldNameToValueMap = fieldNameToValueMap;
            this.hasRecordType = (myRecordType.DeveloperName != RTDEVNAME_MASTER);
            this.tableRowNextId = 1;
            this.isCreateBeforeFirstRow = isCreateBeforeFirstRow;
            this.isFastMode = isFastMode;
            this.maxNumOfRowAllowCreated = maxNumOfRowAllowCreated;
            this.myRecordList = new List<TableRow>();
            
            for (sObject tempSObj : sObjList) {
                TableRow tr = new TableRow(this, tempSObj, false);
                if (isAllEdit) tr.isEdit = true;
                this.myRecordList.add(tr);
            }
            if (isFastMode) {
                for (Integer i = 0; i < maxNumOfRowAllowCreated - sObjList.size(); i++) {//20171220 Introv
                    TableRow tr = createNewSObject(isCreateBeforeFirstRow);
                    tr.isBlankAndHidden = true;
                }
            }
            // Assign display fields developer name to set for later search
            Schema.DescribeSObjectResult sObjTypeDescribe = sObjType.getDescribe();
            Map<String, Schema.SObjectField> sObjFieldMap = sObjTypeDescribe.fields.getMap();
            this.myDisplayFieldSet = new Set<String>();
            for (DisplayCol dc : displayColList) {
                List<DisplayField> displayFieldList = dc.displayFieldList;
                for (DisplayField df : displayFieldList) {
                    this.myDisplayFieldSet.add(df.name);
                }
            }
        }
        
        public TableRow enableForEditByTableRowId(String trId) {
            TableRow tr = getTableRowById(trId);
            if (tr != null)
                tr.isEdit = true;
            return tr;
        }
        
        public TableRow removeByTableRowId(String trId) {
            Integer size = myRecordList.size();
            for (Integer i = 0; i < size; i++) {
                TableRow tr = myRecordList.get(i);
                if (tr.id != null && tr.id == trid) {
                    if (tr.isNew) {
                        //20171220 Introv
                        
                        /*myRecordList[i].mySObj = this.sObjType.newSObject();
                        myRecordList[i].isBlankAndHidden = true;
                        return myRecordList[i];*/
                        
                        //20171220 End
                        return myRecordList.remove(i);
                    } else {
                        tr.isDelete = true;
                        return tr;
                    }
                }
            }
            return null;
        }
        
        public TableRow createNewSObject() { return createNewSObject(this.isCreateBeforeFirstRow); }
        public TableRow createNewSObject(Boolean beforeFirstRow) { return createNewSObject(!beforeFirstRow ? this.myRecordList.size() : 0, this.sObjType.newSObject()); }
        public TableRow createNewSObject(sObject newSObj) { return createNewSObject(!this.isCreateBeforeFirstRow ? this.myRecordList.size() : 0, newSObj); }
        public TableRow createNewSObject(Integer index, sObject newSObj) {
            system.debug('sd0: enter');
            if (hasRecordType)
                newSObj.put('RecordTypeId', myRecordType.Id);
            Set<String> fieldNameSet = fieldNameToValueMap.keySet();
            system.debug('sd1:' + myRecordType.Id);
// Custom change starts
            Map<String, Schema.SObjectField> field_map = newSObj.getSObjectType().getDescribe().fields.getMap();
            for (String fieldName : fieldNameSet) {
                system.debug('sd2:' + fieldNameToValueMap.get(fieldName));
                if (fieldNameToValueMap.get(fieldName) != null) {
                    if (field_map.get(fieldName).getDescribe().getType().name() == 'Date') {
                        newSObj.put(fieldName, date.parse(fieldNameToValueMap.get(fieldName)));
                    }
                    else {
                         system.debug('sd3:' + fieldName);
                        system.debug('sd4:' + fieldNameToValueMap.get(fieldName));
                        newSObj.put(fieldName, fieldNameToValueMap.get(fieldName));
                    }
                }
            }
// Custom change ends
            return addNewTableRow(index, newSObj);
        }
        
        public TableRow cloneNewSObjectByTableRowId(String trId) {
            TableRow tr = getTableRowById(trId);
            if (tr != null)
                return cloneNewSObject(tr.mySObj);
            return null;
        }
        public TableRow cloneNewSObject(sObject sObj) { return cloneNewSObject(sObj, this.isCreateBeforeFirstRow); }
        public TableRow cloneNewSObject(sObject sObj, Boolean beforeFirstRow) { return cloneNewSObject(sObj, !beforeFirstRow ? this.myRecordList.size() : 0); }
        public TableRow cloneNewSObject(sObject sObj, Integer index) {
            sObject newSObj = sObj.clone(false, true, false, false);
            if (hasRecordType)
                newSObj.put('RecordTypeId', myRecordType.Id);
            Set<String> fieldNameSet = fieldNameToValueMap.keySet();
            for (String fieldName : fieldNameSet) {
                if (!myDisplayFieldSet.contains(fieldName))
                    newSObj.put(fieldName, fieldNameToValueMap.get(fieldName));
            }
            return addNewTableRow(index, newSObj);
        }
        
        public void deleteAll() {
            List<TableRow> newTRList = new List<TableRow>();
            Integer size = myRecordList.size();
            for (Integer i = 0; i < size; i++) {
                TableRow tr = myRecordList.get(i);
                if (!tr.isNew) {
                    tr.isDelete = true;
                    newTRList.add(tr);
                }
            }
            myRecordList = newTRList;
        }
        
        private TableRow addNewTableRow(Integer index, SObject newSObj) {
            TableRow tr = new TableRow(this, newSObj, true);
            if (this.myRecordList.size() == 0 || index >= this.myRecordList.size())
                this.myRecordList.add(tr);
            else
                this.myRecordList.add(index, tr);
            return tr;
        }
    
        private TableRow getTableRowBySObjId(ID sObjId) {
            for (TableRow tr : myRecordList) {
                if (tr.mySObj.Id != null && tr.mySObj.Id == sObjId)
                    return tr;
            }
            return null;
        }
        private TableRow getTableRowById(String trid) {
            for (TableRow tr : myRecordList) {
                if (tr.id != null && tr.id == trid)
                    return tr;
            }
            return null;
        }
    }
    
    public class TableRow {
        public String id { get; private set; }
        public sObject mySObj { get; set; }
        public Boolean isNew { get; set; }
        public Boolean isEdit { get; set; }
        public Boolean isDelete { get; set; }
        public Boolean isBlankAndHidden { get; set; }
        private RecordTypeElement rtEle;
        
        public TableRow(RecordTypeElement rtEle, sObject mySObj, Boolean isNew) {
            this.id = String.valueOf(rtEle.tableRowNextId++);
            this.mySObj = mySObj;
            this.isNew = isNew;
            this.isEdit = isNew;
            this.isDelete = false;
            this.isBlankAndHidden = false;
        }
    }
    
    public class DisplayCol {
        public String colKey { get; set; }
        public String colLabel { get; set; }
        public List<DisplayField> displayFieldList { get; set; }
        public String colWidth { get; set; }
        
        public DisplayCol(String colKey, String colLabel) {
            this.colKey = colKey;
            this.colLabel = colLabel;
            this.displayFieldList = new List<DisplayField>();
        }
        
        public void addDisplayField(DisplayField displayField) {
            this.displayFieldList.add(displayField);
        }
    }
    
    public class DisplayField {
        public String label { get; set; }
        public String name { get; set; }
        public Boolean isRequired { get; set; }
        public String readonlyMode { get; set; }
        public String width { get; set; }
        public String colKey { get; set; }
        public Boolean skipClone { get; set; }
        public Boolean isPickList { get; set; }  //Add by Abel
        
        public DisplayField(String label, String name) {
            this.label = label;
            this.name = name;
            this.isRequired = false;
            this.readonlyMode = null;
            this.width = 'auto';
        }

//Add by Abel        
        public DisplayField(String label, String name, Boolean isPickList) {
            this.label = label;
            this.name = name;
            this.isRequired = false;
            this.readonlyMode = null;
            this.width = 'auto';
            this.isPickList = isPickList;
        }        
        
    }
    
    public with sharing class PageBlockActionBtn {
        public String id { get; set; }
        public String label { get; set; }
        
        public PageBlockActionBtn(String id, String label) {
            this.id = id;
            this.label = label;
        }
    }
    
// Custom change starts
    private string formatMsg(string msg) {
        if (msg.contains('duplicate value found: ASI_MFM_Sys_Deduplication_Key__c')) {
            msg = 'Duplicated Plan Line Items are detected. Please Adjust';
        }
        return msg;
    }
// Custom change ends    

    public void changePage(){
		system.debug('changePage');
		system.debug('newInputPageNum : '+ newInputPageNum);
        queryCount(); 
        if(newInputPageNum!=null){
            PageNumber = integer.valueOf(newInputPageNum);
            system.debug('PageNumber : '+PageNumber);
            if (PageNumber <= 0) {   
                PageNumber = 1;
            }
            if (PageNumber > PageCount) {
                PageNumber = PageCount;
            }
            queryResult(PageNumber);
        }
	}
    
    public void First(){
		queryCount(); 
        PageNumber = 1;
        newInputPageNum = ''+PageNumber;
        queryResult(PageNumber);
    }
    public void Previous(){
		queryCount(); 
        PageNumber--;
        if (PageNumber <= 0) {   
            PageNumber = 1;
        }
        newInputPageNum = ''+PageNumber;
        queryResult(PageNumber);
    }
    public void Next(){
		queryCount(); 
        PageNumber++;
        if (PageNumber > PageCount) {
            PageNumber = PageCount;
        }
        newInputPageNum = ''+PageNumber;
        queryResult(PageNumber);
    }
    public void Last(){
        queryCount();
        PageNumber = PageCount; 
        newInputPageNum = ''+PageNumber;
        queryResult(PageNumber);
    }
}