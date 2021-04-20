/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_POReceipt_TriggerClass
 * Description: 
 * Test Class: ASI_MFM_CAP_POReceipt_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-21       Wilken Lee           	[WL 1.0] Only auto create payment line if there is no payment line created by user
 ****************************************************************************************************************************/
public without sharing class ASI_MFM_CAP_POReceipt_TriggerClass {
    //public static void routineAfterUpdate(list<ASI_MFM_PO_Receipt__c> trigger_new, map<id, ASI_MFM_PO_Receipt__c> trigger_oldMap) {   
    public static void routineBeforeUpdate(list<ASI_MFM_PO_Receipt__c> trigger_new, map<id, ASI_MFM_PO_Receipt__c> trigger_oldMap) {   //[WL 1.0]
	
        List<Id> paymentHeaderIDList = new List<Id>();
         for (ASI_MFM_PO_Receipt__c p:trigger_new){
			//Added by Hector on 20181023, Generate Payment Line and trigger Payment turns Final when PO Receipt turns Final
            if (Global_RecordTypeCache.getRt(p.RecordTypeId).developerName.contains('ASI_MFM_CAP_PO_Receipt') &&
            		p.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted'){
            	paymentHeaderIDList.add(p.ASI_MFM_Payment__c);            	
            }
         }
		 
		/*[WL 1.0] BEGIN*/
		List<ASI_MFM_Payment__c> paymentHeaderList = [SELECT Id, ASI_MFM_CAP_PO__c, ASI_MFM_Status__c
														,(SELECT ID FROM Payment_Line_Items__r), ASI_MFM_Payment_Amount__c//[WL 2.0]
														FROM ASI_MFM_Payment__c
    													WHERE Id in :paymentHeaderIdList];
		Map<Id,ASI_MFM_Payment__c> paymentId_Map = new Map<Id,ASI_MFM_Payment__c>();
		List<Id> paymentCreateLineIDList = new List<Id>();
		List<ASI_MFM_Payment__c> paymentToUpdate = new List<ASI_MFM_Payment__c>();
		
		for (ASI_MFM_Payment__c pay:paymentHeaderList){
			paymentId_Map.put(pay.Id, pay);
		}

		for (ASI_MFM_PO_Receipt__c p:trigger_new){
			if (Global_RecordTypeCache.getRt(p.RecordTypeId).developerName.contains('ASI_MFM_CAP_PO_Receipt') &&
            		p.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted')
			{
				ASI_MFM_Payment__c payment = paymentId_Map.get(p.ASI_MFM_Payment__c);
				Integer counter = 0;
				
				system.debug('PO Receipt Payment: ' + p.ASI_MFM_Payment__c + ' Map: ' + paymentId_Map.get(p.ASI_MFM_Payment__c));
				system.debug('payment.Payment_Line_Items__r.size(): ' + payment.Payment_Line_Items__r.size());
				if (payment.Payment_Line_Items__r.size() > 0){
					for (ASI_MFM_Payment_Line_Item__c payLine:payment.Payment_Line_Items__r){
						counter++;
					}
				}			
					
				if (counter > 0){ //[WL 1.0] Payment already has payment line, only update status to Final								
					if (p.ASI_MFM_Amount__c != payment.ASI_MFM_Payment_Amount__c)
						p.addError('Error, Payment Amount is different from Receipt Amount. Please correct Payment Amount to align with Receipt Amount');
					else {
						payment.ASI_MFM_Status__c = 'Final';
						paymentToUpdate.add(payment);
					}
				}
				else {
					paymentCreateLineIDList.add(p.ASI_MFM_Payment__c);
				}			
			}
			
				if (paymentToUpdate.size() > 0)
				update paymentToUpdate;
		}
		/*[WL 1.0] END*/
		
        //Added by Hector on 20181023, Generate Payment Line and trigger Payment turns Final when PO Receipt turns Final
        ASI_MFM_CAP_HK_PaymentGeneration.GeneratePaymentLineFromPOReceipt(paymentCreateLineIDList);    
    }
}