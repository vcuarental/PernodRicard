/*********************************************************************************
 * Name:        ASI_CRM_SG_ReUpdate_Image_Level
 * Description: Changes Image Level after approval
 * Test Class:  ASI_CRM_SG_Customer_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-2-20        IPC: Alvin Lomod        Created
 * 2015-10-19       Wilken Lee              Updated to change Customer related records' owner base on JDE 
 *                                          Test method added to ASI_CRM_SG_Customer_Test
 * 2017-06-28       Wilken Lee              [WL 1.0] Update FOC Carry Over owner based on Customer Owner
 * 2018-03-22       Wilken Lee              [WL 2.0] ICM117666265 Delete Contract's Mass Upload Log (For PDF) when outlet owner change
 * 2018-08-27		Wilken Lee				[WL 3.0] Remove Account record update
*********************************************************************************/

public with sharing class ASI_CRM_SG_ReUpdate_Image_Level{

    public static void assignJDECustomerNumber(List<ASI_CRM_AccountsAdditionalField__c> trigger_new, Map<ID,ASI_CRM_AccountsAdditionalField__c> oldMap){
        //Removed on 2015-12-14, next customer number to be retrieved by ETL from JDE when customer is interfaced
        /*List<ASI_CRM_AccountsAdditionalField__c> updateCustNumberList = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        for (ASI_CRM_AccountsAdditionalField__c cust:trigger_new){
            if (cust.ASI_CRM_ToJDE__c && !oldMap.get(cust.id).ASI_CRM_ToJDE__c && cust.ASI_CRM_MY_CustomerCode__c == null)
                updateCustNumberList.add(cust);
            
            System.debug('updateCustNumberList Size: ' + updateCustNumberList.size() + ' cust.ASI_CRM_ToJDE__c: ' + cust.ASI_CRM_ToJDE__c + ' oldMap.get(cust.id).ASI_CRM_ToJDE__c: ' + oldMap.get(cust.id).ASI_CRM_ToJDE__c + ' cust.ASI_CRM_MY_CustomerCode__c: ' + cust.ASI_CRM_MY_CustomerCode__c);
        }       
        
        if (updateCustNumberList.size() > 0){
            //Get current running number
            ASI_HK_CRM_Running_Number__c runningNumber = [select ASI_HK_CRM_Running_Number__c from ASI_HK_CRM_Running_Number__c where ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_JDE_Customer_Number' limit 1];
            
            if (runningNumber != null){             
                for (ASI_CRM_AccountsAdditionalField__c customer:updateCustNumberList){
                    customer.ASI_CRM_MY_CustomerCode__c = String.ValueOf(runningNumber.ASI_HK_CRM_Running_Number__c++);
                }
                
                //update updateCustNumberList;
                update runningNumber;
            }
        }*/
    }
    
    
    public static void updateCustomerRelatedRecordOwner(List<ASI_CRM_AccountsAdditionalField__c> updatedCustomer, Map<ID,ASI_CRM_AccountsAdditionalField__c> oldMap){
        
        Map<ID,ID> custOwnerIDMap = new Map<ID,ID>();
        /*[WL 3.0] BEGIN*/
		//Map<ID,ID> acctOwnerIDMap = new Map<ID,ID>();
		/*[WL 3.0] END*/
        
        for(ASI_CRM_AccountsAdditionalField__c cust:updatedCustomer){
            if (cust.ownerID != oldMap.get(cust.id).ownerID){
                system.debug('Customer ID: ' + cust.Id + ' New Customer OwnerID: ' + cust.ownerID + ' Old Customer OwnerID: ' + oldMap.get(cust.id).ownerID);
                custOwnerIDMap.put(cust.ID, cust.OwnerID);
				/*[WL 3.0] BEGIN*/
                //acctOwnerIDMap.put(cust.ASI_CRM_Account__c, cust.OwnerID);
				/*[WL 3.0] END*/
            }
        }
        
        if(custOwnerIDMap.size() > 0){
            List<ASI_TH_CRM_Contract__c> contractListUpdate = new List<ASI_TH_CRM_Contract__c>();
            List<ASI_FOC_Free_Goods_Request__c> focListUpdate = new List<ASI_FOC_Free_Goods_Request__c>();
            List<ASI_TH_CRM_PaymentRequest__c> pymtListUpdate = new List<ASI_TH_CRM_PaymentRequest__c>();
            
			/*[WL 3.0] BEGIN*/
			//List<Account> accountListUpdate = new List<Account>();
			/*[WL 3.0] END*/
			
            List<ASI_CRM_Pros_Segmentation__c> prosListUpdate = new List<ASI_CRM_Pros_Segmentation__c>();
            /*[WL 1.0 Begin]*/
            List<ASI_CRM_SG_FOC_Carry_Over__c> carryOverListUpdate = new List<ASI_CRM_SG_FOC_Carry_Over__c>();
            /*[WL 1.0 End]*/
            
            //Update Contract Owners
            List<ASI_TH_CRM_Contract__c> contractList = [select ownerID, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_SG_PDF_Attachment__c from ASI_TH_CRM_Contract__c where ASI_CRM_CN_Outlet_WS__c in :custOwnerIDMap.keySet()];
            Set<Id> massUploadLogIDSet = new Set<Id>();
            for (ASI_TH_CRM_Contract__c contract:contractList){
                system.debug('contract ID: ' + contract.Id + ' Contract OwnerID: ' + contract.ownerID + ' Customer OwnerID: ' + custOwnerIDMap.get(contract.ASI_CRM_CN_Outlet_WS__c));
                if (contract.ownerID != custOwnerIDMap.get(contract.ASI_CRM_CN_Outlet_WS__c)){
                    contract.ownerID = custOwnerIDMap.get(contract.ASI_CRM_CN_Outlet_WS__c);
                    
                    /*[WL 2.0] BEGIN*/
                    system.debug('PDF Attachment field' + contract.ASI_CRM_SG_PDF_Attachment__c);
                    if (contract.ASI_CRM_SG_PDF_Attachment__c != null){                 
                        
                        Id convertedID;
                        String convertedStr;
                        
                        convertedStr = contract.ASI_CRM_SG_PDF_Attachment__c.substringAfter(':');
                        convertedID = (Id)convertedStr.substringBefore(';');
                        massUploadLogIDSet.add(convertedID);        

                        system.debug('convertedStr: ' + convertedStr + ' convertedID:' + convertedID + ' massUploadLogIDSet: ' + massUploadLogIDSet);
                        contract.ASI_CRM_SG_PDF_Attachment__c = null;
                    }
                    /*[WL 2.0] END*/
                    contractListUpdate.add(contract);
                }
            }
        
            /*[WL 2.0] BEGIN*/
            List<Attachment> massUploadLogAttachmentList = [select ParentId from Attachment where Id in :massUploadLogIDSet];
            Set<Id> logToDelete = new Set<Id>();
            for (Attachment a: massUploadLogAttachmentList){
                logToDelete.add(a.ParentId);
            }
            
            system.debug('massUploadLogAttachmentList size: ' + massUploadLogAttachmentList.size());
            List<ASI_MFM_Mass_Upload_Log__c> logList = [select id from ASI_MFM_Mass_Upload_Log__c where id in :logToDelete];
            delete logList;
            /*[WL 2.0] BEGIN*/
            
            //Update FOC Owners
            List<ASI_FOC_Free_Goods_Request__c> focList = [select ownerID, ASI_CRM_Outlet__c from ASI_FOC_Free_Goods_Request__c where ASI_CRM_Outlet__c in :custOwnerIDMap.keySet()];
            
            for (ASI_FOC_Free_Goods_Request__c foc:focList){
                if (foc.ownerID != custOwnerIDMap.get(foc.ASI_CRM_Outlet__c)){
                    foc.ownerID = custOwnerIDMap.get(foc.ASI_CRM_Outlet__c);
                    focListUpdate.add(foc);
                }
            }
            
            //Update Payment Request Owners
            List<ASI_TH_CRM_PaymentRequest__c> pymtList = [select ownerID, ASI_CRM_CN_OutletWS__c from ASI_TH_CRM_PaymentRequest__c where ASI_CRM_CN_OutletWS__c in :custOwnerIDMap.keySet()];
            
            for (ASI_TH_CRM_PaymentRequest__c pymt:pymtList){
                if (pymt.ownerID != custOwnerIDMap.get(pymt.ASI_CRM_CN_OutletWS__c)){
                    pymt.ownerID = custOwnerIDMap.get(pymt.ASI_CRM_CN_OutletWS__c);
                    pymtListUpdate.add(pymt);
                }
            }          
            
			//Update Account Owners
			/*[WL 3.0] BEGIN*/
            /*List<Account> acctList = [select ownerID from Account where ID in :acctOwnerIDMap.keySet()];
            
            for (Account acct:acctList){
                system.debug('Account ID: ' + acct.Id + 'Existing Account OwnerID: ' + acct.ownerID + ' New Account OwnerID: ' + acctOwnerIDMap.get(acct.ID));
                acct.ownerID = acctOwnerIDMap.get(acct.ID);
                accountListUpdate.add(acct);
            }*/           
			/*[WL 3.0] END*/

            //20160606 Wilken: Update PROS Owners
            List<ASI_CRM_Pros_Segmentation__c> prosList = [select ownerID, ASI_CRM_SG_Customer__c from ASI_CRM_Pros_Segmentation__c where ASI_CRM_SG_Customer__c in :custOwnerIDMap.keySet()];
            
            for (ASI_CRM_Pros_Segmentation__c pros:prosList){
                pros.ownerID = custOwnerIDMap.get(pros.ASI_CRM_SG_Customer__c);
                prosListUpdate.add(pros);
            }
            
            /*[WL 1.0 Begin]*/
            List<ASI_CRM_SG_FOC_Carry_Over__c> carryOverList = [select ownerID, ASI_CRM_SG_Outlet__c from ASI_CRM_SG_FOC_Carry_Over__c where ASI_CRM_SG_Outlet__c in :custOwnerIDMap.keySet()];
            
            for (ASI_CRM_SG_FOC_Carry_Over__c carryOver:carryOverList){
                carryOver.ownerID = custOwnerIDMap.get(carryOver.ASI_CRM_SG_Outlet__c);
                carryOverListUpdate.add(carryOver);
            }
            /*[WL 1.0 End]*/
            
            //Update result if related records' owner is different from latest Customer Owner
            if (contractListUpdate.size() > 0)
                update contractListUpdate;
            if (focListUpdate.size() > 0)
                update focListUpdate;
            if (pymtListUpdate.size() > 0)
                update pymtListUpdate;
//            if (accountListUpdate.size() > 0)
//                update accountListUpdate;
            if (prosListUpdate.size() > 0)
                update prosListUpdate;
            /*[WL 1.0 Begin]*/
            if (carryOverListUpdate.size() >0)
                update carryOverListUpdate;
            /*[WL 1.0 End]*/
        }
    }
    
    public static void updateCustomerImageLevel(List<ASI_CRM_AccountsAdditionalField__c> updatedCustomer, List<ASI_CRM_AccountsAdditionalField__c> oldData){
        
        List<ASI_CRM_AccountsAdditionalField__c> custToUpdate = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        for(Integer x = 0; x < updatedCustomer.size(); x++){
            if(updatedCustomer[x].ASI_CRM_SG_SYS_Pending_Approval__c && updatedCustomer[x].ASI_CRM_SG_SYS_Pending_Approval__c != oldData[x].ASI_CRM_SG_SYS_Pending_Approval__c){
                custToUpdate.add(updatedCustomer[x]);
            }
        }
        
        if(custToUpdate.size() > 0){
           Map<Id, ASI_CRM_Pros_Segmentation__c> cpMap = prosToUpdate(custToUpdate);
           updatePros(custToUpdate, cpMap);
        }
    
    }
    
    public static Map<Id, ASI_CRM_Pros_Segmentation__c> prosToUpdate(List<ASI_CRM_AccountsAdditionalField__c> custList){
        
        Map<Id, ASI_CRM_Pros_Segmentation__c> custProsMap = new Map<Id, ASI_CRM_Pros_Segmentation__c>();
        
        Set<Id> custIds = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c c : custList){
            custIds.add(c.Id);
        }
        
        for(ASI_CRM_Pros_Segmentation__c pros : [SELECT Id, ASI_CRM_SG_Customer__c, ASI_CRM_SG_Image_Level_Threshold__c, ASI_CRM_SG_Image_Level__c FROM ASI_CRM_Pros_Segmentation__c WHERE ASI_CRM_SG_Customer__c in: custIds]){
            custProsMap.put(pros.ASI_CRM_SG_Customer__c, pros);
        }
        
        return custProsMap;
    }
    
    public static void updatePros(List<ASI_CRM_AccountsAdditionalField__c> custList, Map<Id, ASI_CRM_Pros_Segmentation__c> custProsMap){
        
        List<ASI_CRM_Pros_Segmentation__c> prosListToUpdate = new List<ASI_CRM_Pros_Segmentation__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c  cus : custList){
            ASI_CRM_Pros_Segmentation__c ps = custProsMap.get(cus.Id);
            system.debug('**New ILT '+ Id.valueOf(cus.ASI_CRM_SG_SYS_New_Image_Level_Threshold__c.substringBeforeLast('&')));
            ps.ASI_CRM_SG_Image_Level_Threshold__c = Id.valueOf(cus.ASI_CRM_SG_SYS_New_Image_Level_Threshold__c.substringBeforeLast('&'));
            
            prosListToUpdate.add(ps);
            
        }
        
        update prosListToUpdate;
        
    }

}