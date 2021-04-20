/*********************************************************************************
 * Name: ASI_CRM_SG_CalculateROIinTrigger
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-11-24       Wilken Lee     			[WL 1.0] OldMap need to be passed for ROI calculation as well for scenario when FOC/Payment updated from one contract to another
 * 2017-12-09		Laputa: Vincent			[VL 1.0] Merge 2 roi helper into one
 */
public with sharing class ASI_CRM_SG_CalculateROIinTrigger extends ASI_CRM_SG_TriggerAbstract {
    
    public ASI_CRM_SG_CalculateROIinTrigger() {
        super('ASI_CRM_SG_CalculateROIinTrigger');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
            List<sObject> records = newMap.values();
			
            if (records[0].getSObjectType().getDescribe().getName()=='ASI_TH_CRM_PaymentRequest__c'){
				Set<Id> contractIDList = new Set<Id>();
                
				/*[WL 1.0] BEGIN*/
				if (oldMap != null){
					List<ASI_TH_CRM_PaymentRequest__c> paymentOldMap = oldMap.values();
					
					for (ASI_TH_CRM_PaymentRequest__c payment: paymentOldMap){
						ASI_TH_CRM_PaymentRequest__c newPayment = (ASI_TH_CRM_PaymentRequest__c)newMap.get(payment.Id);
                        if (payment.ASI_TH_CRM_Contract__c != null && newPayment.ASI_TH_CRM_Contract__c != payment.ASI_TH_CRM_Contract__c) {
                            contractIDList.add(payment.ASI_TH_CRM_Contract__c);
                        }
						contractIDList.add(payment.ASI_TH_CRM_Contract__c);						
					}
					
                    /* [VL 1.0] BEGIN */
                    /*
                    if (contractIDList.size()>0){
                        ASI_CRM_SG_ROI_Helper roiContract = new ASI_CRM_SG_ROI_Helper(contractIDList);
                        roiContract.calculateROI();
                    }
                    */
                    /* [VL 1.0] END */
				}
				/*[WL 1.0] END*/
                
                ASI_CRM_SG_ROI_Helper roi = new ASI_CRM_SG_ROI_Helper(contractIDList, (List<ASI_TH_CRM_PaymentRequest__c>)records);
                roi.calculateROI();
				
            } else
            if (records[0].getSObjectType().getDescribe().getName()=='ASI_FOC_Free_Goods_Request__c'){
				Set<Id> contractIDList = new Set<Id>();
                
				/*[WL 1.0] BEGIN*/
				if (oldMap != null){
					List<ASI_FOC_Free_Goods_Request__c> focOldMap = oldMap.values();
					
					for (ASI_FOC_Free_Goods_Request__c foc: focOldMap){
						ASI_FOC_Free_Goods_Request__c newFOC = (ASI_FOC_Free_Goods_Request__c)newMap.get(foc.Id);
                        if (foc.ASI_CRM_Contract__c != null && newFOC.ASI_CRM_Contract__c != foc.ASI_CRM_Contract__c) {
                            contractIDList.add(foc.ASI_CRM_Contract__c);
                        }
                        						
					}
					
                    /* [VL 1.0] BEGIN */
                    /*
                    if (contractIDList.size()>0){
                        ASI_CRM_SG_ROI_Helper roiContract = new ASI_CRM_SG_ROI_Helper(contractIDList);
                        roiContract.calculateROI();                        
                    }
                    */
                    /* [VL 1.0] END */
				}	
				/*[WL 1.0] END*/
                
                ASI_CRM_SG_ROI_Helper roi = new ASI_CRM_SG_ROI_Helper(contractIDList, (List<ASI_FOC_Free_Goods_Request__c>)records);
                roi.calculateROI();
											
            } else
            if (records[0].getSObjectType().getDescribe().getName()=='ASI_CRM_Credit_Debit_Note__c'){
                ASI_CRM_SG_ROI_Helper roi = new ASI_CRM_SG_ROI_Helper((List<ASI_CRM_Credit_Debit_Note__c>)records);
                roi.calculateROI();
            }
    }

}