@isTest
public class LAT_StockCheckSchedulerTest {
 
  @isTest static void LAT_UY_StockCheckBatchTest(){
    
   	SchedulableContext sc = null;
		LAT_StockCheckScheduler tsc = new LAT_StockCheckScheduler();
		tsc.execute(sc);
      
    LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
      Name = 'UY_StockBusinessUnits',
      LAT_Value__c = 'test@zimmic.com');
    insert cfg;

    Database.BatchableContext batchCtx = null;
    LAT_UY_StockCheckBatch tscuy = new LAT_UY_StockCheckBatch();
    tscuy.execute(batchCtx, new List<sObject>());
  }

  @isTest static void LAT_AR_StockCheckBatchTest(){
    LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
      Name = 'AR_StockBusinessUnits',
      LAT_Value__c = 'test@zimmic.com');
    insert cfg;
      
    Database.BatchableContext batchCtx = null;
    LAT_AR_StockCheckBatch tsc = new LAT_AR_StockCheckBatch();
    tsc.execute(batchCtx, new List<sObject>());
       	/*Database.BatchableContext BC = null;
            EUR_CRM_DeactivateSurveys ds = new EUR_CRM_DeactivateSurveys();
            ds.execute(BC,(List<sObject>) ( new List<EUR_CRM_Survey__c>{survey }));
      EUR_CRM_DE_DeactivateOPAccountMappings  controller = new EUR_CRM_DE_DeactivateOPAccountMappings();
            controller.start(null);
            Database.BatchableContext bc = null;
            controller.execute(bc, ops);
            EUR_CRM_DE_DeactivateOPAccountMappings.deactivate( ops);
            for(EUR_CRM_ObjPromo_Account_Mapping__c op : [select EUR_CRM_Is_Active__c  from EUR_CRM_ObjPromo_Account_Mapping__c where id in:opIds ]){
                system.assert(!(op.EUR_CRM_Is_Active__c));
            }*/
  }
  
}