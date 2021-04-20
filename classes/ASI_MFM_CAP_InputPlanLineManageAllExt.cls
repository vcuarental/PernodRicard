/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_InputPlanLineManageAllExt
 * Description: Controller Class for ASI_MFM_CAP_InputPlanItemsPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-21       Laputa                              Rewrite Manage All Page
 ****************************************************************************************************************************/

public with sharing class ASI_MFM_CAP_InputPlanLineManageAllExt {
    //Object Record Type Developer Name
    public Id PLAN_LINE_ITEM_RECORD_TYPE_ID {get{return Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__c' + 'ASI_MFM_CAP_Plan_Line_Item');}} 
    
        //Public Data Storage Parameters
        public ASI_MFM_Plan__c plan {get; private set;}
    public ASI_MFM_Plan_Line_Item__c planLineItem {get; set;}
    
    //Private Data Storage Parameters
    private List<ASI_MFM_Plan_Line_Item__c> planLineItemList {get;set;} {planLineItemList = new List<ASI_MFM_Plan_Line_Item__c>();}
    private Map<String, Account> supplierMap {get;set;}{supplierMap = new Map<String, Account>();}
    
    //User and Page Properties
    //  Regional IT Admin - Check if the current user have access to editable fields for Final read only plan
    public boolean isRegionalITAdmin {get;set;}
    //  Owner
    public boolean isCurrentUserOwner {get;set;}
    
    // Check if Header is final status
    public String viewMode {
        get{
                if (!isFinal && !isSubmitted)
                        return 'DRAFT';
                if ((isFinal && !(isRegionalITAdmin || isCurrentUserOwner)) || isSubmitted )
                        return 'ReadNONIT';
                if ((isFinal && (isRegionalITAdmin || isCurrentUserOwner) && !isSubmitted ))
                        return 'ReadIT';
                return '';
        }
    }
    
    public boolean isReadOnly {
        get {
                return (!(viewMode == 'DRAFT'));
        }
    }
    public boolean isSubmitted {get;set;}
    public boolean isDraft {get; set;}
    public boolean isFinal {get;set;}
    
    // What group should have IT admin rights
    public final Set<String> groupExceptionList = new Set<String>{'ASI_MFM_CAP_Regional_IT_Dept_Admin'};
    
    //Data Stroage => JSON String for VF Page
    public String planLineItemJSON {get {return toJsonString(planLineItemList);}}
    
    //Object Picklist Value Map
    private Map<String, String> apCodeMap {get; set;}{apCodeMap = new Map<String, String>();}
    private Map<String, String> buCodeMap {get; set;}{buCodeMap = new Map<String, String>();}
    private Map<String, String> quotationMap {get; set;}{quotationMap = new Map<String, String>();}
    
    //Picklist Value Map => JSON String for VF Page
    public String apCodeMapJson {get {return toJsonString(apCodeMap);}}
    public String buCodeMapJson {get {return toJsonString(buCodeMap);}}
    public String quotationJson {get {return toJsonString(quotationMap);}}
    
    //Auto Complete Value Map => JSON String for VF Page
    public String supplierListJson {get {return toJsonString(supplierMap.keySet());}}
    
    
    //Page Parameters
    public String saveErrorMessage {get;set;}
    
    //Other Parameters
    private final static String IS_QUICK_SAVE                           = 'isQuickSave';
    private final static String UPSERT_PLAN_LINE_ITEM_LIST_JSON     = 'upsertPlanLineItemListJson';
    private final static String DELETE_PLAN_LINE_ITEM_ID_LIST_JSON  = 'deletePlanLineItemIdListJson';
    
    public boolean isCAPEX {get;set;}
    
    
    public ASI_MFM_CAP_InputPlanLineManageAllExt(ApexPages.standardSetController sc) {
        id pid = apexpages.currentPage().getParameters().get('id');
        plan = database.query(ASI_MFM_function.buildQuery('ASI_MFM_Plan__c') + ' where id = :pid');
        if(plan.ASI_MFM_Plan_Type__c == 'CAPEX' && plan.ASI_MFM_TH_Prefix_Name__c == false){
            isCAPEX = true;
        }else{
            isCAPEX = false;
        }
        this.isFinal = false;
        this.isSubmitted = false;
        if (!String.isBlank(plan.ASI_MFM_Status__c) && plan.ASI_MFM_Status__c.equalsIgnoreCase('Fial')){
                this.isFinal = true;
        }
        if(plan.recordtypeid != Global_RecordTypeCache.getRtId('ASI_MFM_Plan__c' + 'ASI_MFM_CAP_TW_Plan')) {
            if(plan.recordtypeid == Global_RecordTypeCache.getRtId('ASI_MFM_Plan__c'+'ASI_MFM_CAP_Plan_Read_Only') && plan.ASI_MFM_Status__c != 'Submitted')
                this.isFinal = true;
            else if (plan.ASI_MFM_Status__c == 'Submitted')
                this.isSubmitted = true;
        } else {
            if (!String.isBlank(plan.ASI_MFM_Status__c) && plan.ASI_MFM_Status__c.equalsIgnoreCase('Draft')) {
                isDraft = true;
            } else {
                isDraft = false;
            }
        }
        this.isRegionalITAdmin = false;
        List<Group> relatedGroup = getGroupsForUser(userinfo.getuserid());
        for (Group i : relatedGroup)
        {
            if (groupExceptionList.contains(i.DeveloperName))
                this.isRegionalITAdmin = true;
        }
        
        isCurrentUserOwner = false;
        if (userinfo.getuserid() == plan.ownerid) {
            isCurrentUserOwner = true;
        }
        
        init(plan);
    }
    
    /*  Initialize the following
        1. AP Code Picklist
        2. BU Code Picklist
        3. Quotation Picklist
        4. Auto complete of Supplier
    */
    public void init(ASI_MFM_Plan__c plan){
        planLineItemList = getPlanLineItem(plan.Id);
        
        List<ASI_MFM_AP_Code__c> apCodeList = [SELECT Id, Name, ASI_MFM_OPEX__c
                                                                                        FROM ASI_MFM_AP_Code__c 
                                                                                        WHERE RecordType.DeveloperName = 'ASI_MFM_CAP_AP_Code'
                                                                                        AND isDeleted = false
                                                                                        AND ASI_MFM_Inactive__c = false
                                                                                        ORDER by Name] ;
        List<ASI_MFM_BU__c> buCodeList = [SELECT Id, Name, ASI_MFM_OPEX__c
                                                                                FROM ASI_MFM_BU__c 
                                                                                WHERE RecordType.DeveloperName = 'ASI_MFM_CAP_BU'
                                                                                AND isDeleted = false
                                                                                AND ASI_MFM_Inactive__c = false
                                                                                ORDER by Name] ;
        for (ASI_MFM_AP_Code__c apCode : apCodeList){
                if (plan.ASI_MFM_Plan_Type__c == 'CAPEX' && apCode.ASI_MFM_OPEX__c == false){
                        apCodeMap.put(apCode.Name, apCode.Id);
                } else if (plan.ASI_MFM_Plan_Type__c == 'OPEX' && apCode.ASI_MFM_OPEX__c == true){
                        apCodeMap.put(apCode.Name, apCode.Id);
                }
        }
        
        for (ASI_MFM_BU__c buCode : buCodeList){
                if (plan.ASI_MFM_Plan_Type__c == 'CAPEX' && buCode.ASI_MFM_OPEX__c == false){
                        buCodeMap.put(buCode.Name, buCode.Id);
                } else if (plan.ASI_MFM_Plan_Type__c == 'OPEX' && buCode.ASI_MFM_OPEX__c == true){
                        buCodeMap.put(buCode.Name, buCode.Id);
                }
        }
        
        quotationMap = retrievePicklistValues(ASI_MFM_Plan_Line_Item__c.ASI_MFM_Quotation__c.getDescribe());
        
        supplierMap = new Map<String, Account>();
        for(Account supplier : retrieveSupplierList('Id, name', '', 50)) {
            supplierMap.put(supplier.Id, supplier);
        }
    }
    
    @RemoteAction
    public static List<Account> retrieveSupplierList(String fieldString, String whereClause, Integer limitRecord){
        return (List<Account>) ASI_MFM_CAP_InputPlanItemsHelper.findList('Account', fieldString, whereClause, limitRecord);
    }
    
    public PageReference savePlanLineItem() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        Boolean isQuickSave = String.isBlank(params.get(IS_QUICK_SAVE)) ? false : Boolean.valueOf(params.get(IS_QUICK_SAVE));
            String upsertPlanLineItemListJson  = params.get(UPSERT_PLAN_LINE_ITEM_LIST_JSON);
            String removePlanLineItemIdListJson  = params.get(DELETE_PLAN_LINE_ITEM_ID_LIST_JSON);
            
            List<ASI_MFM_Plan_Line_Item__c> upsertPlanLineItemList;
        List<String> removePlanLineItemIdList;
        
        upsertPlanLineItemList   = (List<ASI_MFM_Plan_Line_Item__c>) fromJsonString(upsertPlanLineItemListJson, List<ASI_MFM_Plan_Line_Item__c>.class);
        removePlanLineItemIdList = (List<String>) fromJsonString(removePlanLineItemIdListJson, List<String>.class);
        
        if(removePlanLineItemIdList != null && removePlanLineItemIdList.size() > 0) {
                List<ASI_MFM_Plan_Line_Item__c> removeDataList = new List<ASI_MFM_Plan_Line_Item__c>();
            for(String removeDataId : removePlanLineItemIdList) {
                removeDataList.add(new ASI_MFM_Plan_Line_Item__c(Id = removeDataId));
            }
            Database.delete(removeDataList);
        }
        
        system.debug(upsertPlanLineItemList);
        
        if(upsertPlanLineItemList != null && upsertPlanLineItemList.size() > 0) {
            for(ASI_MFM_Plan_Line_Item__c pi : upsertPlanLineItemList) {
                if(pi.ASI_MFM_Supplier_Name__c == null){
                    pi.ASI_MFM_Supplier_Name__c = null;
                } 
            }
            
                Schema.SObjectField idField = ASI_MFM_Plan_Line_Item__c.Fields.Id;
                Database.UpsertResult[] planLineItemUpsertResults = Database.upsert (upsertPlanLineItemList, idField, true);
            system.debug(planLineItemUpsertResults);
                saveErrorMessage = '';
                for(Database.UpsertResult upsertResult : planLineItemUpsertResults){
                        //Have error
                        if (!upsertResult.isSuccess()){
                                isQuickSave = true;
                                if (upsertResult.isCreated()){
                                        saveErrorMessage += 'Create error: ';
                                } else {
                                        saveErrorMessage += 'Update error: ';
                                }
                                for(Database.Error err : upsertResult.getErrors()){
                                        saveErrorMessage += err.getMessage();
                                }
                        }
                }
        }
        
        //After saving records
        if(isQuickSave) {
                        planLineItemList = getPlanLineItem(plan.Id);
                        if (!String.isBlank(saveErrorMessage)){
                system.debug(saveErrorMessage);
                                Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,saveErrorMessage));
                        }
                return null;
        } else {
                if (!String.isBlank(saveErrorMessage)){
                system.debug(saveErrorMessage);
                                Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,saveErrorMessage));
                                return null;
                        } else {
                                PageReference pageRef = new PageReference('/' + plan.Id);
                    pageRef.setRedirect(true);
                    return pageRef;
                        }
                
        }
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + plan.Id);
            pageRef.setRedirect(true);
            return pageRef;
    }
    
    // return list of all groups the user belongs to via direct or indirect membership
    public Group[] getGroupsForUser(Id userId){

        Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
     return [
           select Id
            , Name ,
            DeveloperName 
         from Group
        where Id IN: groupIds];

    }

    // return all ids the user belongs to via direct or indirect membership
    public Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){

        Set<Id> output = new Set<Id>();

        Set<Id> nestedGroupIds = new Set<Id>();

        // only query actual groups and not roles and queues
        list<GroupMember> records = [
            select id
                 , GroupId
                 , UserOrGroupId
              from GroupMember
         where UserOrGroupId =: userOrGroupIds
            and UserOrGroupId != null];

        for (GroupMember record:records)
        {
            // found a group, remember for traversal
            if (!(record.UserOrGroupId + '').startsWith('005'))
            {
                nestedGroupIds.add(record.UserOrGroupId);   
            }
            else
            {
                output.add(record.GroupId);
            }
        }

        // call self to get nested groups we found
        if (nestedGroupIds.size() > 0)
        {
            output.addAll(getGroupsForIds(nestedGroupIds));
        }

        return output;
    }
    
    private Map<String, String> retrievePicklistValues(Schema.DescribeFieldResult fieldResult) {
                Map<String, String> picklistValueMap = new Map<String, String>();

                List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry picklistEntry : picklistEntryList) {
                picklistValueMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
        }

        return picklistValueMap;
        }
        
        
    
    private static Object fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }
    
    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }
        
        private List<ASI_MFM_Plan_Line_Item__c> getPlanLineItem(Id planId){
                return [SELECT Id, 
                                        ASI_MFM_AP_Code__c,
                                        ASI_MFM_AP_Code__r.Name,
                                        ASI_MFM_BU_Code__c,
                                        ASI_MFM_BU_Code__r.Name,
                                        ASI_MFM_Dummy_PO__c,
                                        ASI_MFM_Generate_PO__c,
                                        ASI_MFM_Justification__c,
                                        ASI_MFM_List_Item_Description__c,
                                        ASI_MFM_Plan__c,
                                        ASI_MFM_Quotation_Available_Date__c,
                                        ASI_MFM_Quotation__c,
                                        ASI_MFM_Supplier_Name__c,
                                        ASI_MFM_Supplier_Name__r.Name,
                                        ASI_MFM_T_E__c,
                                        ASI_MFM_Total_Cost__c, 
                                        RecordTypeId, RecordType.DeveloperName 
                                FROM ASI_MFM_Plan_Line_Item__c
                                WHERE ASI_MFM_Plan__c = :planId ORDER BY Name];
                
        }
}