/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_AccrueAchievements Class.
  @Author:      IPC
  @History:     MAR.26.2015 - Created
*/
@isTest 
private class EUR_CRM_DE_TestDeleteOPVariations{

    @isTest
    private static void testDeleteOPVariation(){
        List<Recordtype> objPromoVariationRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_ObjPromo_OnTrade_Variation__c');
        Id rtid = null;
        for(RecordType rt : objPromoVariationRecordTypes){
            if(rt.developername == 'EUR_DE_ObjPromo_Promo_Variation'){
                rtid = rt.id;
            }
        }
        EUR_CRM_ObjPromo_OnTrade_Variation__c opVar = new EUR_CRM_ObjPromo_OnTrade_Variation__c(name='absolut' , recordtypeid = rtid,EUR_CRM_Is_Active__c = true);
        insert opVar;
        
        opVar.EUR_CRM_Is_Active__c = false;
        
        update opVar;
        System.assertNotEquals(null, opVar.EUR_CRM_Is_Active__c);
    }

}