/*
    Developed by Kendy Tam: 09/06/2014
    Batch to generate the RSP 
*/
global with sharing class ASI_CRM_TW_SalesVolumeCalculation_Batch implements Database.Batchable<sObject> ,Database.Stateful{   

   global Database.QueryLocator start(Database.BatchableContext BC){   

      //String soqlQuery = 'SELECT SUM(ASI_CRM_Depletion__c) Depletion,ASI_CRM_Outlet__c Outlet,ASI_CRM_AccountsAdditionalField__c customer, ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c CategoryCode  FROM ASI_CRM_OutletDepletion__c WHERE ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c in (\'WHY\',\'BRY\',\'WSP\',\'CHP\',\'WIN\') AND ASI_CRM_Date__c >= :fromDate AND ASI_CRM_Date__c < :toDate GROUP BY ASI_CRM_Outlet__c,ASI_CRM_AccountsAdditionalField__c, ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c';
       
      String soqlQuery = 'SELECT Id,Name FROM Account WHERE RecordType.DeveloperName = \'ASI_CRM_TW_Outlet\'';
       
      System.debug('soqlQuery:' + soqlQuery);
   
      return Database.getQueryLocator(soqlQuery);
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
       if (scope == null) return;
              
       Integer month = Date.today().month();
   
       //Remarked due to change request
       /*
       if (!Test.isRunningTest()){
           if (month != 2 && month != 5 && month != 8 && month != 11) return;
       }
       */
       
       List<ASI_CRM_CalculatedSegmentation__c> calculatedSegmentations = new List<ASI_CRM_CalculatedSegmentation__c>();
       List<ASI_CRM_CalculatedSalesVolume__c> calculatedSalesVolumes = new List<ASI_CRM_CalculatedSalesVolume__c>();
       
        //Changed by William Yang due to change request, manage the month range in custom setting 
        Integer monthFrom = -2; //default value if custom setting not found
        Integer monthTo = -1; //default value if custom setting not found
        ASI_CRM_TW_Settings__c customSettingTW = [SELECT id, ASI_CRM_TW_CalSaleVolumeFrom__c, ASI_CRM_TW_CalSaleVolumeTo__c FROM ASI_CRM_TW_Settings__c];
        if(customSettingTW != null && customSettingTW.ASI_CRM_TW_CalSaleVolumeFrom__c != null && customSettingTW.ASI_CRM_TW_CalSaleVolumeTo__c != null)
        {
            monthFrom = (Integer)customSettingTW.ASI_CRM_TW_CalSaleVolumeFrom__c;
            monthTo = (Integer)customSettingTW.ASI_CRM_TW_CalSaleVolumeTo__c; 
        }
       
       Date tmpMonth = Date.today().addMonths(monthFrom);       
       Date fromDate = Date.newInstance(tmpMonth.year(),tmpMonth.month(),1);
       tmpMonth = Date.today().addMonths(monthTo);
       Date toDate = Date.newInstance(tmpMonth.year(),tmpMonth.month(),1);
                          
       Map<String,Account> outletIds = new Map<String,Account>();
//       Map<String,String> customerIds = new Map<String,String>();
//       Map<String,String> productCategoryIds = new Map<String,String>();
       
       for(sObject sObj : scope){
           Account outlet = (Account) sObj;
         
           outletIds.put(outlet.Id,outlet);
//           customerIds.put(String.valueOf(outletDepletion.get('Customer')),String.valueOf(outletDepletion.get('Customer'))); 
//           productCategoryIds.put(String.valueOf(outletDepletion.get('CategoryCode')),String.valueOf(outletDepletion.get('CategoryCode')));  
       }
       
       List<ASI_CRM_CalculatedSegmentation__c> delCalculatedSegmentations = [SELECT Id FROM ASI_CRM_CalculatedSegmentation__c WHERE ASI_CRM_Outlet__c IN :outletIds.keySet() AND ASI_CRM_Date__c >= :fromDate AND ASI_CRM_Date__c < :toDate];
       
       List<ASI_CRM_CalculatedSalesVolume__c > delSalculatedSalesVolumess = [SELECT Id FROM ASI_CRM_CalculatedSalesVolume__c WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_CalculatedSalesVolume_RcrdTyp') AND ASI_CRM_Outlet__c IN :outletIds.keySet() AND ASI_CRM_Date__c >= :fromDate AND ASI_CRM_Date__c < :toDate];
            
       if(delCalculatedSegmentations != null && delCalculatedSegmentations.size() > 0 ){
           delete delCalculatedSegmentations;
       }
       
       if(delSalculatedSalesVolumess != null && delSalculatedSalesVolumess .size() > 0 ){
           delete delSalculatedSalesVolumess;
       } 
       
       List<AggregateResult> outletDepletions = [SELECT SUM(ASI_CRM_Depletion__c) Depletion,ASI_CRM_Outlet__c Outlet,ASI_CRM_AccountsAdditionalField__c Customer, ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c CategoryCode  FROM ASI_CRM_OutletDepletion__c WHERE ASI_CRM_Outlet__r.Id IN :outletIds.KeySet() AND ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c IN ('WHY','BRY','WSP','CHP','WIN')  AND ASI_CRM_Date__c >= :fromDate AND ASI_CRM_Date__c < :toDate GROUP BY ASI_CRM_Outlet__c,ASI_CRM_AccountsAdditionalField__c, ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c];
       
       List<AggregateResult> prtOutletDepletions = [SELECT SUM(ASI_CRM_Depletion__c) Depletion,ASI_CRM_Outlet__c Outlet,ASI_CRM_AccountsAdditionalField__c Customer, ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c CategoryCode  FROM ASI_CRM_OutletDepletion__c WHERE ASI_CRM_Outlet__r.Id IN :outletIds.KeySet() AND ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c IN ('WHY','BRY','WSP','CHP','WIN') AND ASI_CRM_SubBrand__r.ASI_CRM_TW_Company__c = 'PRT' AND ASI_CRM_Date__c >= :fromDate AND ASI_CRM_Date__c < :toDate GROUP BY ASI_CRM_Outlet__c,ASI_CRM_AccountsAdditionalField__c, ASI_CRM_SubBrand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c];
       
       //Map<Id,Account> outlets = new Map<Id, Account>([SELECT Id,Name FROM Account WHERE Id IN  :outletIds.keySet()]);
       List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Id,Name,ASI_CRM_Account__c,ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN  :outletIds.keySet()];
       
       Map<Id,ASI_HK_CRM_Product_Category__c> productCategories = new Map<Id, ASI_HK_CRM_Product_Category__c>([SELECT Id,Name, ASI_HK_CRM_Category_Code__c FROM ASI_HK_CRM_Product_Category__c WHERE ASI_HK_CRM_Category_Code__c IN ('WHY','BRY','WSP','CHP','WIN')]);
        
       Map<String, Map<String,ASI_CRM_CalculatedSalesVolume__c>> outletSalesVolumeMap = new Map<String, Map<String,ASI_CRM_CalculatedSalesVolume__c>>();
             
       for(AggregateResult outletDepletion : outletDepletions){
                     
           String outlet = String.valueOf(outletDepletion.get('Outlet'));
           String customer = String.valueOf(outletDepletion.get('Customer'));
           String categoryCode = String.valueOf(outletDepletion.get('CategoryCode'));
           
           ASI_CRM_CalculatedSalesVolume__c calculatedSalesVolume = new ASI_CRM_CalculatedSalesVolume__c();
           
           calculatedSalesVolume.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_CalculatedSalesVolume_RcrdTyp');
           calculatedSalesVolume.ASI_CRM_Date__c = fromDate;
           calculatedSalesVolume.ASI_CRM_Outlet__c = outlet;
           calculatedSalesVolume.ASI_CRM_AccountsAdditionalField__c = customer;      
           calculatedSalesVolume.ASI_CRM_Total__c = (Integer)(Decimal.valueOf(String.valueOf(outletDepletion.get('Depletion')))/(monthTo-monthFrom));
                      
           for(ASI_HK_CRM_Product_Category__c productCategory : productCategories.values()){
               if (categoryCode == productCategory.ASI_HK_CRM_Category_Code__c){
                   calculatedSalesVolume.ASI_CRM_ProductCategory__c = productCategory.Id;
                   break;
               }
           }
          
           for(AggregateResult outletDepletionPRT : prtOutletDepletions){
               if(outlet == String.valueOf(outletDepletionPRT.get('Outlet')) && customer == String.valueOf(outletDepletionPRT.get('Customer')) && categoryCode == String.valueOf(outletDepletionPRT.get('CategoryCode'))){
                    if(outletDepletionPRT.get('Depletion') != null)
                        calculatedSalesVolume.ASI_CRM_PRTVolume__c = (Integer)(Decimal.valueOf(String.valueOf(outletDepletionPRT.get('Depletion')))/(monthTo-monthFrom));
                    else
                        calculatedSalesVolume.ASI_CRM_PRTVolume__c = 0;
                   break;
               }
           }
           
           Map<String,ASI_CRM_CalculatedSalesVolume__c> salesVolumeMap = outletSalesVolumeMap.get(outlet);
           
           if(salesVolumeMap == null){
               salesVolumeMap = new Map<String,ASI_CRM_CalculatedSalesVolume__c>();
           }
           
           salesVolumeMap.put(categoryCode,calculatedSalesVolume);
           outletSalesVolumeMap.put(outlet,salesVolumeMap); 
       }
       
       List<ASI_CRM_SegmentationCriteria__c> segmentationCriterias = [SELECT Id,ASI_CRM_SalesPotential__c,ASI_CRM_Grade__c,ASI_CRM_GradingCriteriaFrom__c,ASI_CRM_GradingCriteriaTo__c,ASI_CRM_SOMCriteriaFrom__c,ASI_CRM_SOMCriteriaTo__c FROM ASI_CRM_SegmentationCriteria__c];
       
       for(ASI_CRM_AccountsAdditionalField__c customer: customers){
           ASI_CRM_CalculatedSegmentation__c calculatedSegmentation  = new ASI_CRM_CalculatedSegmentation__c();
           
           calculatedSegmentation.ASI_CRM_Date__c = fromDate;
           calculatedSegmentation.ASI_CRM_Outlet__c = customer.ASI_CRM_Account__c;
           calculatedSegmentation.ASI_CRM_AccountsAdditionalField__c = customer.Id;       
       
           Map<String,ASI_CRM_CalculatedSalesVolume__c> salesVolumeMap = outletSalesVolumeMap.get(customer.ASI_CRM_Account__c);
           
           if(salesVolumeMap!=null)
           {
                Decimal total = 0;
                Decimal prtTotal = 0;
                Decimal rate = 0;
                
                ASI_CRM_CalculatedSalesVolume__c whyCalculatedSalesVolume = salesVolumeMap.get('WHY');
                ASI_CRM_CalculatedSalesVolume__c bryCalculatedSalesVolume = salesVolumeMap.get('BRY');

                if(whyCalculatedSalesVolume != null)
                {
                    if(whyCalculatedSalesVolume.ASI_CRM_Total__c != null)
                        total += whyCalculatedSalesVolume.ASI_CRM_Total__c;
                    if(whyCalculatedSalesVolume.ASI_CRM_PRTVolume__c != null)
                        prtTotal += whyCalculatedSalesVolume.ASI_CRM_PRTVolume__c;
                }   
                
                if(bryCalculatedSalesVolume != null)
                {
                    if(bryCalculatedSalesVolume.ASI_CRM_Total__c != null)
                        total += bryCalculatedSalesVolume.ASI_CRM_Total__c;
                    if(bryCalculatedSalesVolume.ASI_CRM_PRTVolume__c != null)
                        prtTotal += bryCalculatedSalesVolume.ASI_CRM_PRTVolume__c;
                }   
               
               if(customer.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c == 'HBR'){
                   ASI_CRM_CalculatedSalesVolume__c wspCalculatedSalesVolume = salesVolumeMap.get('WSP');
                   ASI_CRM_CalculatedSalesVolume__c chpCalculatedSalesVolume = salesVolumeMap.get('CHP');
                   
                   if(wspCalculatedSalesVolume != null)
                    {
                        if(wspCalculatedSalesVolume.ASI_CRM_Total__c != null)
                            total += wspCalculatedSalesVolume.ASI_CRM_Total__c;
                        if(wspCalculatedSalesVolume.ASI_CRM_PRTVolume__c != null)
                            prtTotal += wspCalculatedSalesVolume.ASI_CRM_PRTVolume__c;
                    }   
                    
                    if(chpCalculatedSalesVolume != null)
                    {
                        if(chpCalculatedSalesVolume.ASI_CRM_Total__c != null)
                            total += chpCalculatedSalesVolume.ASI_CRM_Total__c;
                        if(chpCalculatedSalesVolume.ASI_CRM_PRTVolume__c != null)
                            prtTotal += chpCalculatedSalesVolume.ASI_CRM_PRTVolume__c;
                    }               
               }
               
               rate = total != 0 ? prtTotal / total * 100 : 0; 
               
               for(ASI_CRM_SegmentationCriteria__c segmentationCriteria : segmentationCriterias){
                   if(total >= segmentationCriteria.ASI_CRM_GradingCriteriaFrom__c && total <= segmentationCriteria.ASI_CRM_GradingCriteriaTo__c && rate >= segmentationCriteria.ASI_CRM_SOMCriteriaFrom__c && rate <= segmentationCriteria.ASI_CRM_SOMCriteriaTo__c){
                       calculatedSegmentation.ASI_CRM_Grade__c = segmentationCriteria.ASI_CRM_Grade__c;
                       calculatedSegmentation.ASI_CRM_SalesPotential__c = segmentationCriteria.ASI_CRM_SalesPotential__c;
                       break;
                   } 
               }
               
               calculatedSegmentations.add(calculatedSegmentation);
               /*
               for(ASI_CRM_CalculatedSalesVolume__c calculatedSalesVolume : salesVolumeMap.values()){
                   calculatedSalesVolume.ASI_CRM_CalculatedSegmentation__c = calculatedSegmentation.Id;
                   calculatedSalesVolumes.add(calculatedSalesVolume);
               }
               */
           }
       }
        if(calculatedSegmentations!=null && calculatedSegmentations.size()>0)
            insert calculatedSegmentations;
            
        for(ASI_CRM_AccountsAdditionalField__c customer: customers){
            for(ASI_CRM_CalculatedSegmentation__c calculatedSegmentation : calculatedSegmentations){
                if(calculatedSegmentation.ASI_CRM_Outlet__c == customer.ASI_CRM_Account__c){
                    Map<String,ASI_CRM_CalculatedSalesVolume__c> salesVolumeMap = outletSalesVolumeMap.get(customer.ASI_CRM_Account__c);
                    
                    for(ASI_CRM_CalculatedSalesVolume__c calculatedSalesVolume : salesVolumeMap.values()){
                        calculatedSalesVolume.ASI_CRM_CalculatedSegmentation__c = calculatedSegmentation.Id;
                        calculatedSalesVolumes.add(calculatedSalesVolume);
                    }
                }
            }
        }       
        
        system.debug('Calculated Sales Volume: '+calculatedSalesVolumes);
        if(calculatedSalesVolumes!=null && calculatedSalesVolumes.size()>0)
            insert calculatedSalesVolumes;
   }

   global void finish(Database.BatchableContext BC){

   } 
}