/****************************
Filename:     ASI_CRM_TH_ActualOfftakeHead_TriggerCls
Author:       Kevani Chow (Introv Limited)
Purpose:      Handle ASI_CRM_TH_ActualOfftakeHeader__c Trigger Logic
Created Date: 14-04-2016
Test Class:	　ASI_CRM_TH_ActualOfftake_Test
******************************/


public with sharing class ASI_CRM_TH_ActualOfftakeHead_TriggerCls {
    public static void routineBeforeUpdate(list<ASI_CRM_ActualOfftakeHeader__c> trigger_new){    
      map<id, ASI_TH_CRM_Actual_Offtake__c> Map_Offtake = new Map<id, ASI_TH_CRM_Actual_Offtake__c>();
      
      //Get All the OfftakeHeader id from Trigger
      Set <String> setActualOfftakeHeader = new set<String>();
      List<ASI_TH_CRM_Actual_Offtake__c> UpdateOfftakeList = new  List<ASI_TH_CRM_Actual_Offtake__c>();
    
      for(ASI_CRM_ActualOfftakeHeader__c header : trigger_new){
         if(header.ASI_CRM_Verified__c==true){
           setActualOfftakeHeader.add(header.Id);
         }
      }

               
      Id OfftakeRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TH_ActualOfftakeTemp');
      List<ASI_TH_CRM_Actual_Offtake__c> OfftakeList = new  List<ASI_TH_CRM_Actual_Offtake__c>();
      
        if (setActualOfftakeHeader.size()>0){
        
          OfftakeList = [SELECT Id, Name, ASI_TH_CRM_From_Wholesaler__c, ASI_TH_CRM_Outlet__c, ASI_TH_CRM_Quantity__c, ASI_CRM_ActualOfftakeHeader__c, ASI_CRM_WS_Copy__c, ASI_CRM_Outlet_Copy__c FROM ASI_TH_CRM_Actual_Offtake__c WHERE  RecordTypeId =:OfftakeRecordTypeId AND ASI_CRM_ActualOfftakeHeader__r.Id in: setActualOfftakeHeader];            
        
          for(ASI_CRM_ActualOfftakeHeader__c header : trigger_new){
              for(ASI_TH_CRM_Actual_Offtake__c thisOfftake: OfftakeList){
                 if (OfftakeList.size()>0){
                      //ASI_TH_CRM_Actual_Offtake__c updateOfftake = new ASI_TH_CRM_Actual_Offtake__c();     
                      //Vincent@2018/05/28 To ensure the child actual offtakes' outlet, and wholesaler is not blank
                     if (thisOfftake.ASI_TH_CRM_From_Wholesaler__c == null && thisOfftake.ASI_CRM_ActualOfftakeHeader__c == header.id && !ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CRM_TH_ActualOfftakeHead_TriggerCls ')) {
                         header.addError('Actual Offtake ' + thisOfftake.name + ' has blank \'Wholesaler\'. This is most likely caused by data input mistake. Please go to the record, and add valid wholesaler to the record.');
                     }
                     if (thisOfftake.ASI_TH_CRM_Outlet__c == null && thisOfftake.ASI_CRM_ActualOfftakeHeader__c == header.id && !ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CRM_TH_ActualOfftakeHead_TriggerCls ')) {
                         header.addError('Actual Offtake ' + thisOfftake.name + ' has blank \'Outlet\'. This is most likely caused by data input mistake. Please go to the record, and add valid outlet to the record.');
                     }
                 }
              }
          }
          
        //Temp save those Headers which needed to be updated
        Set <String> setUpdateActualOfftakeHeader = new set<String>(); 
        
        //Update Offtake and OfftakeHeader
        for(ASI_TH_CRM_Actual_Offtake__c updateOfftakeRecord: OfftakeList){
        
             if (OfftakeList.size()>0){
                  //ASI_TH_CRM_Actual_Offtake__c updateOfftake = new ASI_TH_CRM_Actual_Offtake__c();     
      			  //Vincent@2018/05/28 To ensure the child actual offtakes' outlet, and wholesaler is not blank
/*                 if (updateOfftakeRecord.ASI_TH_CRM_From_Wholesaler__c == null) {
                     updateOfftakeRecord.addError('Actual Offtake ' + updateOfftakeRecord.name + ' has blank \'Wholesaler\'. This is most likely caused by data input mistake. Please go to the record, and add valid wholesaler to the record.');
                 }
                 if (updateOfftakeRecord.ASI_TH_CRM_Outlet__c == null) {
                     updateOfftakeRecord.addError('Actual Offtake ' + updateOfftakeRecord.name + ' has blank \'Outlet\'. This is most likely caused by data input mistake. Please go to the record, and add valid outlet to the record.');
                 }
*/                  if (updateOfftakeRecord.ASI_CRM_Outlet_Copy__c==updateOfftakeRecord.ASI_CRM_WS_Copy__c ){

                       updateOfftakeRecord.ASI_TH_CRM_Quantity__c=updateOfftakeRecord.ASI_CRM_Outlet_Copy__c;
                       updateOfftakeRecord.RecordTypeId=Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_TH_CRM_Actual_Offtake');
                       UpdateOfftakeList.add(updateOfftakeRecord);
                     
                     }else{
                      
                         //Add those Header with offtake conflict into a set
                         setUpdateActualOfftakeHeader.add(updateOfftakeRecord.ASI_CRM_ActualOfftakeHeader__c); 
                     }
                   }
                }
                Update UpdateOfftakeList;
                
                //Update OfftakeHeader
                for(ASI_CRM_ActualOfftakeHeader__c headerList : trigger_new){
                
                    if (setUpdateActualOfftakeHeader.contains(headerList.id) &&headerList.ASI_CRM_Verified__c==true){
                        headerList.ASI_CRM_Verified__c= false;
                   }
                }
             }                    
    }
}