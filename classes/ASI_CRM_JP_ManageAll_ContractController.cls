/*********************************************************************************
 * Name: ASI_CRM_JP_ManageAll_ContractController
 * Description: Controller class for Manage All page for Purchase Contract. JP Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/11/2014       Laputa:Conrad           Created
 * 03/12/2014       Laputa:Conrad           Implemented SPTD, Direct and Indirect recordtypes
 * 08/12/2014       Laputa:Conrad           Implemented Spread function
 * 15/12/2014       Laputa:Conrad           Implement read Only feature
 *              
*/
public class ASI_CRM_JP_ManageAll_ContractController {
    
    public static String CONTRACT_LINE_ITEM_TABLE_PREFIX {get{ return 'ContractLineItemTable_';}}
    public static String CONTRACT_LINE_ITEM_NEWRECORD_PREFIX {get{ return 'zzzzzzCONTRACTNEWZ';}}
    
    public Integer CONTRACT_LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public ID headerID {get;set;}
    public ASI_CRM_Purchase_Contract__c contractObj {get;set;}
    public Map<String, ASI_CRM_Purchase_Contract_Line_Item__c> allContractTargetMap {get;set;}
    public Map<String, ASI_MFM_Item_Group__c> allItemsGroupJPMap {get;set;}
    public List<ASI_CRM_Purchase_Contract_Line_Item__c> contractLinesToDelete {get;set;}
    // Map used for cloning New Records
    public Set<String> contractLineFieldSet{get;set;}
    
    public boolean isRebate {get;set;}
    public boolean isDirectRebate {get;set;}
    public boolean isIndirectRebate {get;set;}
    public boolean isSPTD {get;set;}
    public boolean isSalesPlanning {get;set;}
    public boolean isReadOnly {get;set;}
    
    public final Set<String> groupExceptionListSalesPlanning = new Set<String>{'ASI_CRM_JP_Sales_Planning'};
    
    public ID recordtypeContractLineID {get;set;}
    
    public ASI_CRM_JP_ManageAll_ContractController(ApexPages.StandardController stdCon) {

        this.headerId = ApexPages.currentPage().getParameters().get('id');
        contractObj = retrieveContractHeader(this.headerId);
        
        isRebate = false;
        isDirectRebate = false;
        isIndirectRebate = false;
        isSPTD = false;
        isReadOnly = false;
        isSalesPlanning = false;
        
        // Check if current user is a Sales Planning group or not
        List<Group> relatedGroup = getGroupsForUser(userinfo.getuserid());
        for (Group i : relatedGroup)
        {
            if (groupExceptionListSalesPlanning.contains(i.DeveloperName))
                this.isSalesPlanning = true;
        }
        
        // Add a second checking for Roles under a public group
        if(isSalesPlanning == false) {
            isSalesPlanning  = checkRoleGroup(groupExceptionListSalesPlanning);
        }
        
        if(contractObj.ASI_CRM_Status__c == 'Complete' || contractObj.ASI_CRM_Status__c == 'Submitted') {
            isSalesPlanning = false;
        }
        
        
        if (contractObj.recordtype.developerName.contains('ASI_CRM_JP_SPTD_Contract')) {
            isSPTD = true;
            recordtypeContractLineID = Global_RecordTypeCache.getRTId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item');
        }
        
        if (contractObj.recordtype.developerName.contains('ASI_CRM_JP_Direct_Rebate') || contractObj.recordtype.developerName.contains('ASI_CRM_JP_Indirect_Rebate')) {
            isRebate = true;
        }
        
        if (contractObj.recordtype.developerName.contains('ASI_CRM_JP_Direct_Rebate')) {
            isDirectRebate = true;
            recordtypeContractLineID = Global_RecordTypeCache.getRTId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item');
        }
        
        if (contractObj.recordtype.developerName.contains('ASI_CRM_JP_Indirect_Rebate')) {
            isIndirectRebate = true;
            recordtypeContractLineID = Global_RecordTypeCache.getRTId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Indirect_Rebate_Contract_Line_Item');
        }
        
        if (contractObj.recordtype.developerName.contains('Read_Only') || contractObj.ASI_CRM_Status__c == 'Submitted') {
            isReadOnly = true;
        }
        
        contractLinesToDelete = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        
        //Retrieve all existing Contract Lines
        allContractTargetMap = retrieveContractTarget(contractObj);
        //allContractTargetMap = sortMap(allContractTargetMap, 'ASC');
        // Retrieve a Map of All JP Item Group
        Map<ID, ASI_MFM_Item_Group__c> itemsGroupMap = new Map<ID, ASI_MFM_Item_Group__c>([SELECT ID, Name, ASI_CRM_Ex_Price__c 
                                                                                            FROM ASI_MFM_Item_Group__c
                                                                                            WHERE recordtype.developername = 'ASI_CRM_JP_Item_Group']);
        
        allItemsGroupJPMap = new Map<String, ASI_MFM_Item_Group__c>();
                                                                                            
        for(ASI_MFM_Item_Group__c itemGroup : itemsGroupMap.values()) {
            allItemsGroupJPMap.put((String)itemGroup.id, itemGroup);
        }
    }

    public boolean checkRoleGroup(Set<String> groupException) {
        boolean isRoleGroup = false;
        
        List<group> genericGroup = [SELECT ID, Name, developername from group where developername IN : groupException LIMIT 1];
        if(genericGroup.size() > 0) {
            ID currentUserRoleID = userinfo.getuserroleid();
            ID genericGroupID = genericGroup.get(0).id;
                
            List<groupMember> genericGroupMemberList = [Select id, UserOrGroupId, GroupId from GroupMember where GroupId = : genericGroupID];
                
            List<group> userRoleGroup = [SELECT ID, name, developername, relatedID, type FROM Group WHERE relatedID = : currentUserRoleID];
            Set<ID> groupToRoleIDSet = new Set<ID>();
            for(group userRoleG : userRoleGroup) {
                groupToRoleIDSet.add(userRoleG.id);
            }
                
            for(groupMember grpMem : genericGroupMemberList) {
                if(groupToRoleIDSet.contains(grpMem.UserOrGroupId)) {
                    isRoleGroup = true;
                    return isRoleGroup;
                }
            }
        }
        
        return isRoleGroup;
    }

    private ASI_CRM_Purchase_Contract__c retrieveContractHeader(ID contractObjID ){
        ASI_CRM_Purchase_Contract__c header =  new ASI_CRM_Purchase_Contract__c();
        Map<String, Schema.SObjectField> contractFieldMap = Schema.SObjectType.ASI_CRM_Purchase_Contract__c.fields.getMap();
        String theQuery = 'Select ';
            
        for(String fields  : contractFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
             
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += ', recordtype.developername, owner.name, createdby.name, ASI_CRM_BS_Retailer_Ship_To__r.ASI_CRM_Customer_Headquarter__c ' +
        ' From ASI_CRM_Purchase_Contract__c where  ID = ' + '\'' + headerID + '\' ';
         
        List<ASI_CRM_Purchase_Contract__c> contractList = (List<ASI_CRM_Purchase_Contract__c>)Database.query(theQuery); 
        if (contractList.size() > 0) {
            header = contractList.get(0);
        }
        return header;
    
    }

    private Map<String, ASI_CRM_Purchase_Contract_Line_Item__c> retrieveContractTarget(ASI_CRM_Purchase_Contract__c contractObj){
    
        Map<String, ASI_CRM_Purchase_Contract_Line_Item__c> contractTargetMap = new Map <String, ASI_CRM_Purchase_Contract_Line_Item__c>();
        
           if (headerID != null) 
           {
             Map<String, Schema.SObjectField> contractDetailsFieldMap = Schema.SObjectType.ASI_CRM_Purchase_Contract_Line_Item__c.fields.getMap();
             String theQuery = 'Select ';
            
             contractLineFieldSet = contractDetailsFieldMap.keySet();
            
             for(String fields  : contractLineFieldSet){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_CRM_Item_Group__r.name, ASI_CRM_Item_Group__r.ASI_CRM_Standard_Cost__c, ASI_CRM_Pay_To__r.ASI_CRM_Pay_to_No__c, ASI_CRM_Pay_To__r.ASI_CRM_Pay_to_Name__c ' +
             +', ASI_CRM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_CRM_AP_Code__r.name  ' +
             ' From ASI_CRM_Purchase_Contract_Line_Item__c where ASI_CRM_Purchase_Contract__c = ' + '\'' + headerID + '\' ORDER BY ID ASC';
         
             List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItems = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)Database.query(theQuery);       
             
             for(ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLine : purchaseContractLineItems) {
                 contractTargetMap.put((String)purchaseContractLine.id, purchaseContractLine);
                 
             }
                       
            }
            
        return contractTargetMap;
    }
    
    public PageReference saveContract () {
        Pagereference ref;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        System.debug('Flag - Save Contract - isQuickSave:' + isQuickSaveStr);
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
        
        Savepoint sp = Database.setSavepoint();
        try {
            List<ASI_CRM_Purchase_Contract_Line_Item__c> contractLineToUpsert = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
            
            // Sort the order of the way Contract Lines are inputted by users
            List<String> sortMapKey = new List<String>();
            for(String key : allContractTargetMap.keySet()) {
                sortMapKey.add(key);
            }
            
            sortMapKey.sort();
            
            for(String key : sortMapKey) {
                contractLineToUpsert.add(allContractTargetMap.get(key));
            }
            if (contractLineToUpsert.size() > 0) {
                upsert contractLineToUpsert;
            }
            if (contractLinesToDelete.size() > 0) {
                delete contractLinesToDelete;
            }
        }
        catch (exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,ex.getDmlMessage(0)));
            Database.rollback(sp);
            return null;
        }
        
        if (!isQuickSave){
            ref = new PageReference('/'+contractObj.Id);
            ref.setRedirect(true);
        }else{
            allContractTargetMap = retrieveContractTarget(contractObj);
        }
        return ref;
    }
    
    public void addContractLine () {
        
        string newIDCounter = newCounterCreator();
        ASI_CRM_Purchase_Contract_Line_Item__c newContract = new ASI_CRM_Purchase_Contract_Line_Item__c
                                    (
                                         ASI_CRM_Purchase_Contract__c = contractObj.id,
                                         recordtypeid = recordtypeContractLineID,
                                         ASI_CRM_Current_Indirect_Rebate__c = 0
                                    );
        allContractTargetMap.put(CONTRACT_LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, newContract);
        
        //allContractTargetMap = sortMap(allContractTargetMap, 'ASC');
    }
    
    public void cloneContractLine () {

        string newIDCounter = newCounterCreator();
    
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractLineID = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID');
        
        //String param_apValue = params.get('PARAM_CONTRACT_AP_VALUE');
        
        if (allContractTargetMap.containsKey(param_contractLineID)) {
        
            ASI_CRM_Purchase_Contract_Line_Item__c contractLine = allContractTargetMap.get(param_contractLineID);
            ASI_CRM_Purchase_Contract_Line_Item__c contractLineClone = null;
            
            contractLineClone = contractLine.clone(false, true, false, false);
            
            // Avoid Spread Values to be copied to the new cloned lines
            contractLineClone.ASI_CRM_Month_1_Cost__c = null;
            contractLineClone.ASI_CRM_Month_2_Cost__c = null;
            contractLineClone.ASI_CRM_Month_3_Cost__c = null;
            contractLineClone.ASI_CRM_Month_4_Cost__c = null;
            contractLineClone.ASI_CRM_Month_5_Cost__c = null;
            contractLineClone.ASI_CRM_Month_6_Cost__c = null;
            contractLineClone.ASI_CRM_Month_7_Cost__c = null;
            contractLineClone.ASI_CRM_Month_8_Cost__c = null;
            contractLineClone.ASI_CRM_Month_9_Cost__c = null;
            contractLineClone.ASI_CRM_Month_10_Cost__c = null;
            contractLineClone.ASI_CRM_Month_11_Cost__c = null;
            contractLineClone.ASI_CRM_Month_12_Cost__c = null;
            
            allContractTargetMap.put(CONTRACT_LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, contractLineClone);
            //allContractTargetMap = sortMap(allContractTargetMap, 'ASC');
        }
        
    }
    
    public void removeContractLine () {
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractLineID = params.get('PARAM_CONTRACT_LINE_ID');
        
        if (allContractTargetMap.containsKey(param_contractLineID)) {
            ASI_CRM_Purchase_Contract_Line_Item__c contractLine = allContractTargetMap.get(param_contractLineID);
            allContractTargetMap.remove(param_contractLineID);
            if(!param_contractLineID.contains(CONTRACT_LINE_ITEM_NEWRECORD_PREFIX)) {
                contractLinesToDelete.add(contractLine);
            }
        }
        
        
    }
    
    public String newCounterCreator() {
    
        String idNew;
        IF(CONTRACT_LINE_ITEM_NEWRECORD_COUNTER == null) {
            CONTRACT_LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            CONTRACT_LINE_ITEM_NEWRECORD_COUNTER+=1;
        }
        
        String zParser = '';
        Integer oneDigitCounter = CONTRACT_LINE_ITEM_NEWRECORD_COUNTER;
        
        if(CONTRACT_LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = CONTRACT_LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(CONTRACT_LINE_ITEM_NEWRECORD_COUNTER, 10);
        }
        
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
        
    }
    
    public PageReference cancel() {
        Pagereference ref;
        ref = new PageReference('/'+contractObj.Id);
        ref.setRedirect(true);
        return ref;
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
      
}