public class ASI_MFM_KR_PR_TriggerClass
{
    public static void beforeInsertMethod(List<ASI_MFM_Purchase_Request__c> triggerNew)
    {
        /*
Map<Id,User> userMap 
= new Map<Id,User>([SELECT Id, Name,
ASI_KOR_Commission_Code__c 
FROM User 
WHERE ASI_KOR_Commission_Code__c!=NULL]); //get all user with cimmission code
List<ASI_eForm_HR_MDM__c> mdmList 
= new List<ASI_eForm_HR_MDM__c>([SELECT Id, Name,
ASI_eForm_Employee_Company_Code__c,
ASI_eForm_Employee_Company_Name_MDM__c
FROM ASI_eForm_HR_MDM__c
WHERE recordType.developerName LIKE 'ASI_eForm_KR_HR_MDM']); //get all mdm record
Map<String,ASI_eForm_HR_MDM__c> mdmMap = new Map<String,ASI_eForm_HR_MDM__c>();

for(ASI_eForm_HR_MDM__c mdm: mdmList)
{
mdmMap.put(mdm.Name, mdm);//put mdm list to map
}//end for
*/
        set<id> px_set = new set<id>();
        
        for(ASI_MFM_Purchase_Request__c pr: triggerNew)
        {
            //check: if map cantain key
            /* if(mdmMap.containsKey(userMap.get(pr.OwnerId).ASI_KOR_Commission_Code__c)){
pr.ASI_MFM_Type__c = mdmMap.get(userMap.get(pr.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Name_MDM__c; //get PR owner company name
pr.ASI_MFM_KR_companyCode__c = mdmMap.get(userMap.get(pr.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Code__c; //get PR owner company code
}*/
            if (pr.asi_mfm_prefix__c != null) {
                px_set.add(pr.asi_mfm_prefix__c);
            }
            
        }//end for
        
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name,ASI_MFM_Company__c, asi_mfm_next_number__c,RecordType.DeveloperName, ASI_MFM_Default_BU__c,ASI_MFM_Default_Customer__c from asi_mfm_prefix__c where asi_mfm_module__c = 'PR' and id in :px_set for update]);
        for(ASI_MFM_Purchase_Request__c pr: triggerNew){
            if (px_map.containsKey(pr.asi_mfm_prefix__c)) {
                if (Global_RecordTypeCache.getRt(pr.recordTypeId).developerName.contains('ASI_MFM_KR') ){
                    pr.name = px_map.get(pr.asi_mfm_prefix__c).ASI_MFM_Company__c + string.valueOf(px_map.get(pr.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000000).substring(1, 7);
                    pr.ASI_MFM_Type__c=px_map.get(pr.asi_mfm_prefix__c).name;
                }
                px_map.get(pr.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }
        }
        ASI_MFM_Function.updatePrefix(px_map.values());     
    }//end method: beforeInsertMethod
    
    
    
    //Update or insert
    public static void BeforeUpsertMethod(list<ASI_MFM_Purchase_Request__c> trigger_new, map<id, ASI_MFM_Purchase_Request__c> trigger_oldMap) {
        //  function 1: Retrieve exchange rate if no input 
        
        // PR ID Set
        set<id> pr_set = new set<id>();
        date last_effective_date=date.today();
        //  Current Currency Set
        set<string> ccy_set = new set<string>(); 
        
        string base_ccy = trigger_new[0].ASI_MFM_Local_Currency__c;    
        
        string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
        
        Map<String, decimal> ExchangeRateMap = new Map<String, decimal>();
        
        for (ASI_MFM_Purchase_Request__c pr:trigger_new) {
            if (pr.ASI_MFM_Exchange_Rate__c==null || (pr.ASI_MFM_Exchange_Rate__c!=null && trigger_oldMap!=null && pr.ASI_MFM_Currency__c!=trigger_oldMap.get(pr.id).ASI_MFM_Currency__c )) { // && (pr.ASI_MFM_Exchange_Rate__c==null || pr.ASI_MFM_Currency__c!=trigger_oldMap.get(pr.id).ASI_MFM_Currency__c)){
                ccy_set.add(pr.ASI_MFM_Currency__c);
            }
            
            
        }//End For Loop
        
        //system.debug(ccy_set+'Test ExchangeRateMap : '+base_ccy);
        //Get Exchange rate 
        if(ccy_set.size()>0){
            for(ASI_MFM_Exchange_Rate__c xr : [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc]){
                if(!ExchangeRateMap.containsKey(xr.ASI_MFM_Counter_Currency__c) && xr.ASI_MFM_Exchange_Rate__c!=null){
                    ExchangeRateMap.put(xr.ASI_MFM_Counter_Currency__c,xr.ASI_MFM_Exchange_Rate__c);
                }
            }  
        }// Get Exchange rate  -- End
        
        
        // Retrieve exchange rate 
        for (ASI_MFM_Purchase_Request__c pr:trigger_new) {
            //Current Currency is in local Currency, set exchange rate as 1.00000 
            if (pr.ASI_MFM_Currency__c == pr.ASI_MFM_Local_Currency__c &&pr.ASI_MFM_Local_Currency__c!=null) {
                pr.ASI_MFM_Exchange_Rate__c = 1;
            }
            if (ExchangeRateMap.containsKey(pr.ASI_MFM_Currency__c) && (pr.ASI_MFM_Exchange_Rate__c==null || (  trigger_oldMap !=NULL && pr.ASI_MFM_Currency__c!=trigger_oldMap.get(pr.id).ASI_MFM_Currency__c && pr.ASI_MFM_Exchange_Rate__c==trigger_oldMap.get(pr.id).ASI_MFM_Exchange_Rate__c ))){
                // if (ExchangeRateMap.containsKey(pr.ASI_MFM_Currency__c) && pr.ASI_MFM_Exchange_Rate__c==null && (trigger_oldMap ==NULL || ( trigger_oldMap !=NULL && pr.ASI_MFM_Currency__c!=trigger_oldMap.get(pr.id).ASI_MFM_Currency__c && (pr.ASI_MFM_Exchange_Rate__c==NULL || pr.ASI_MFM_Exchange_Rate__c==trigger_oldMap.get(pr.id).ASI_MFM_Exchange_Rate__c) ))){
                pr.ASI_MFM_Exchange_Rate__c=ExchangeRateMap.get(pr.ASI_MFM_Currency__c);
            }
            
            if(pr.ASI_MFM_Exchange_Rate__c==null){
                pr.ASI_MFM_Exchange_Rate__c.AddError('Cannot found Exchange Rate from DataBase, Please input.');
            }
            // Update  Company Code
            if(pr.ASI_MFM_Type__c=='PRK'){
                pr.ASI_MFM_Company_Code__c='222';
            }
            if(pr.ASI_MFM_Type__c=='PRKI'){
                pr.ASI_MFM_Company_Code__c='286';
            }
            
            //If Approved PR, updated PR Approved Date 
            if(trigger_oldMap!=null){
                //ASI_MFM_Status__c
                if(pr.ASI_MFM_Status__c=='Approved' && pr.ASI_MFM_Status__c != trigger_oldMap.get(pr.id).ASI_MFM_Status__c){
                    pr.ASI_MFM_PR_Date__c=date.today();
                }
            }
        }//End For Loop         
        
        // Added by 2017-12-20 Linus@introv, Modified by 2018-02-23 Linus@introv
        // Auto-fill ASI_MFM_Brand_Manager retrieved from user profile  
        // Auto-fill ASI_Line_Manager retrived from user profile      
        Set<Id> userid = new Set<Id>();
        Map<Id, User> mapUser = new map<Id,User>();
                
        for(User u: [Select id, ASI_MFM_Team__c, ASI_MFM_Brand_Manager__c, ManagerId from User where CompanyName = 'Pernod Ricard Korea']){
            mapUser.put(u.id, u);
        }
        
        for(ASI_MFM_Purchase_Request__c pr: trigger_new){
            if(mapUser.get(pr.OwnerId).ASI_MFM_Team__c == 'Brand Marketing'){
                pr.ASI_MFM_Brand_Manager__c = mapUser.get(pr.OwnerId).ASI_MFM_Brand_Manager__c;
                pr.ASI_MFM_Line_Manager__c = mapUser.get(pr.OwnerId).ManagerId;
            }
            /*else if(mapUser.get(pr.OwnerId).ASI_MFM_Team__c == 'Trade Marketing' || mapUser.get(pr.OwnerId).ASI_MFM_Team__c == 'Trade Operation'){
                pr.ASI_MFM_Brand_Manager__c = mapUser.get(pr.OwnerId).ManagerId;
                pr.ASI_MFM_Line_Manager__c = mapUser.get(mapUser.get(pr.OwnerId).ManagerId).ManagerId;
            }*/
            else{                
                pr.ASI_MFM_Line_Manager__c = mapUser.get(pr.OwnerId).ManagerId;
            }            
        }        
        // End - Auto-fill ASI_MFM_Brand_Manager
        
    }//end method: BeforeUpsertMethod
    
    
    
    
    
    
    public static void routineBeforeDelete(list<ASI_MFM_Purchase_Request__c> trigger_old) {
        set<id> pr_set = new set<id>(); 
        list<ASI_MFM_PO__c> po_list = new list<ASI_MFM_PO__c>();
        map<id, integer> pr_map = new map<id, integer>(); // <PR id, number of PO> 
        for (ASI_MFM_Purchase_Request__c p:trigger_old) {  
            pr_set.add(p.id);
        }
        
        if(pr_set.size()>0  && !ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_KR_PR_TriggerClass.routineBeforeDelete','KR')){
            po_list=[select id,ASI_MFM_Purchase_Request__c from ASI_MFM_PO__c where ( RecordType.DeveloperName ='ASI_MFM_KR_PO' or  RecordType.DeveloperName =:'ASI_MFM_KR_PO_Read_Only') and  ASI_MFM_Purchase_Request__c in: pr_set];
            //Count Number of PO
            for(ASI_MFM_PO__c po: po_list){
                if(!pr_map.containsKey(po.ASI_MFM_Purchase_Request__c)){
                    pr_map.put(po.ASI_MFM_Purchase_Request__c, 1);
                }else{
                    integer CountNumber=pr_map.get(po.ASI_MFM_Purchase_Request__c)+1;
                    pr_map.remove(po.ASI_MFM_Purchase_Request__c);
                    pr_map.put(po.ASI_MFM_Purchase_Request__c,CountNumber);//remove
                }//End
            }
            
            for (ASI_MFM_Purchase_Request__c p:trigger_old) { 
                if(pr_map.containsKey(p.id) && !test.isRunningTest()){
                    p.addError('Not allowed to delete because it has related PO');
                }
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}//end class