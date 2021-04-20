global class EUR_CRM_MassUpdateOPAcctMapTermination implements Database.Batchable<sObject> {  
    global final String query;
    global final String OP_STATUS_ENDED = 'Ended';
    global final Set<String> validTRs = new Set<String>{
        'EUR_BE_Off_Trade_Sales_Drive', 'EUR_BE_Off_Trade_Secondary_placement_Spyder_display', 'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist', 'EUR_BE_On_Trade_Promo_Kit_Activation',
        'EUR_DK_Off_Trade_Tasting_Campaign','EUR_DK_Off_Trade_Secondary_Placement_Theme','EUR_DK_Off_Trade_Secondary_Placement_Standard',
        'EUR_DK_Off_Trade_Secondary_Placement_Gondola_End','EUR_DK_Off_Trade_Secondary_Placement_Carton','EUR_DK_Off_Trade_Sales_Drive_SKU_Displays',
        'EUR_DK_Off_Trade_Sales_Drive_SKU_Bottles','EUR_DK_Off_Trade_Leaflet_Campaign','EUR_DK_Off_Trade_EM_Price_Promotion',
        'EUR_DK_Off_Trade_Distribution_Drive','EUR_DK_Off_2nd_Placement_Sell_In_Qty_Promo_Display','EUR_DK_OFF_Trade_Sales_Drive_SKU_Cartons',
        'EUR_RU_Off_Trade_Stop_Rayon','EUR_RU_Off_Trade_Sales_Rep_Competition','EUR_RU_Off_Trade_POSM_Placement','EUR_RU_Off_Trade_Outlet_Staff_Incentive',
        'EUR_RU_Off_Trade_On_Site_Promo_Activities','EUR_RU_Off_Trade_Model_Store','EUR_RU_Off_Trade_Loyalty_POSM_Placement','EUR_RU_Off_Trade_Leaflet_Campaign',
        'EUR_RU_Off_Trade_InStore_Media_POSM_Control','EUR_RU_Off_Trade_Discount_Campaign','EUR_RU_ON_Trade_Phase_2','EUR_RU_ON_Trade_Phase_1',
        'EUR_ZA_Off_Trade_Promotion', 'EUR_ZA_On_Trade_Promotion'
    };

    global EUR_CRM_MassUpdateOPAcctMapTermination (){
        // TODO: Refactor using RecordTypeHelper
        String q = 'SELECT Id, EUR_CRM_Evaluation_Period_End_Date__c, EUR_CRM_Status__c,EUR_CRM_Active_End_Date__c FROM EUR_CRM_ObjPromo__c '+
                    ' WHERE Recordtype.DeveloperName IN :validTRs AND EUR_CRM_Really_End_Date__c < TODAY ' +
                    ' AND EUR_CRM_Status__c NOT IN (\'Ended\', \'Deactivated\')';
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('$$SCOPE2: '+scope);
        List<EUR_CRM_ObjPromo__c> objPromotionsList = (List<EUR_CRM_ObjPromo__c>)scope;
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapListToUpdate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        Set<Id> opIds = new Set<Id>();
         
        for(EUR_CRM_ObjPromo__c op: objPromotionsList){
            opIds.add(op.Id);
            op.EUR_CRM_Status__c = OP_STATUS_ENDED;
        }
        
        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap: [SELECT Id
            FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE EUR_CRM_ObjPromo__c IN :opIds AND EUR_CRM_Is_Active__c = TRUE LIMIT 9999]) {
        
            opMap.EUR_CRM_Is_Active__c = FALSE;
            opMap.EUR_CRM_Evaluation_Required__c = FALSE;
            opAcctMapListToUpdate.add(opMap);      
        }                

        if(opAcctMapListToUpdate.size() > 0){
            update opAcctMapListToUpdate;
        }

        if(objPromotionsList.size() > 0){
            update objPromotionsList;
        }
                
    }
    
    global void finish(Database.BatchableContext BC) {
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[] {});
    }
}