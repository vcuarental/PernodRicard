/* 
*Interval      			: Daily
*Target Object 			: EUR_CRM_ObjPromo__c 
*Condition   :
*1. EUR_CRM_Status__c = 'Published' and
*2. EUR_CRM_Active_Start_Date__c = Today and
*3. EUR_CRM_Active_End_Date__c  > Today
*4. Valid Record Type
*Update      :
*EUR_CRM_ObjPromo__c = 'Active'
*
*Finish      :
*Trigger EUR_CRM_BE_MassActivateOPAccountMapping to update related O/P Account Mapping
*
*/

global class EUR_CRM_MassActivateOP implements Database.Batchable<sObject> {
    
    List<String> validRecordType = New List<String>{'EUR_BE_Off_Trade_Sales_Drive',
        'EUR_BE_Off_Trade_Secondary_placement_Spyder_display',
        'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist',
        'EUR_BE_On_Trade_Promo_Kit_Activation',
        'EUR_ZA_Off_Trade_Promotion',
        'EUR_ZA_On_Trade_Promotion'
        /*,'EUR_RU_ON_Trade_Phase_1',
        'EUR_RU_ON_Trade_Phase_2',
        'EUR_RU_Off_Trade_Discount_Campaign',
        'EUR_RU_Off_Trade_InStore_Media_POSM_Control',
        'EUR_RU_Off_Trade_Leaflet_Campaign',
        'EUR_RU_Off_Trade_Loyalty_POSM_Placement',
        'EUR_RU_Off_Trade_Model_Store',
        'EUR_RU_Off_Trade_On_Site_Promo_Activities',
        'EUR_RU_Off_Trade_Outlet_Staff_Incentive',
        'EUR_RU_Off_Trade_POSM_Placement',
        'EUR_RU_Off_Trade_Sales_Rep_Competition',
        'EUR_RU_Off_Trade_Stop_Rayon'*/}; 
            
            String query =  'SELECT Id, EUR_CRM_Status__c ,EUR_CRM_Active_Start_Date__c, EUR_CRM_Active_End_Date__c  ' + 
            'FROM EUR_CRM_ObjPromo__c ' + 
            'WHERE RecordType.DeveloperName in : validRecordType AND EUR_CRM_Status__c = \'Published\' AND EUR_CRM_Active_Start_Date__c <= TODAY AND EUR_CRM_Active_End_Date__c > TODAY';
    
    global EUR_CRM_MassActivateOP() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<EUR_CRM_ObjPromo__c> updateOPList = new List<EUR_CRM_ObjPromo__c>();
        
        for(EUR_CRM_ObjPromo__c objPromo : (List<EUR_CRM_ObjPromo__c>)scope){
            objPromo.EUR_CRM_Status__c = 'Active';
            updateOPList.add(objPromo);
        }
        
        update updateOPList;
    }
    
    global void finish(Database.BatchableContext BC) {
        /*EUR_CRM_BE_MassActivateOPAccountMapping  batchJob = new EUR_CRM_BE_MassActivateOPAccountMapping();
Id batchId = Database.executeBatch(batchJob,200);*/
    }
    
}