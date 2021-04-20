/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/
public class LAT_BR_ArchiveProducts implements Database.Batchable<sObject>{
    
    //MIGRATED 14/11/2016 
   public Database.QueryLocator start(Database.BatchableContext BC){
      if(!Utils.wasMigrationDone('1')){
        return Database.getQueryLocator('SELECT LAT_IsRefactorProduct__c FROM Product2 where LAT_IsRefactorProduct__c != \'Y\' and recordType.developerName = \'BRA_Standard\'');
      }else{
        return Database.getQueryLocator('SELECT LAT_IsRefactorProduct__c FROM LAT_Product__c where LAT_IsRefactorProduct__c != \'Y\' and recordType.developerName = \'BRA_Standard\'');
      }
   }
   
   //MIGRATED 14/11/2016 
   public void execute(Database.BatchableContext BC, List<sObject> scope){
      if(!Utils.wasMigrationDone('1')){
        Id rt = Global_RecordTypeCache.getRtId('Product2'+'BRA_Standard_Archived');
        List<Product2> toUpdate = new List<Product2>();
        for(sObject ob : scope){
            Product2 pr = (Product2)ob;
            pr.recordTypeId = rt;
            toUpdate.add(pr);
        }
        update toUpdate;
        }else{
          Id rt = Global_RecordTypeCache.getRtId('LAT_Product__c'+'BRA_Standard_Archived');
          List<LAT_Product__C> toUpdate = new List<LAT_Product__C>();
          for(sObject ob : scope){
              LAT_Product__C pr = (LAT_Product__C)ob;
              pr.recordTypeId = rt;
              toUpdate.add(pr);
          }
          update toUpdate;
        } 
   }
   
   public void finish(Database.BatchableContext BC){
   
   }
   
   
   


}