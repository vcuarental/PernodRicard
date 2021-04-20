/*********************************************************************************
 * Name:ASI_CRM_SG_Protect_Delete 
 * Description: Class to protect approved records from getting deleted
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/03/2015       Laputa: Conrad          Created
 * 13/02/2017       Wilken          		Delete corresponding FOC Carry Over after deleting Draft FOC
 * 2017-12-06       Laputa: Vincent    		Block delete if payment / FOC is system generated
*********************************************************************************/

public with sharing class ASI_CRM_SG_Protect_Delete extends ASI_CRM_SG_TriggerAbstract {


    public ASI_CRM_SG_Protect_Delete () {
        super('ASI_CRM_SG_Protect_Delete ');
        
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
		if (tAction == ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_DELETE){
			Map<ID,sObject> validsObjectMap = new Map<ID,sObject>();
			
			Set<ID> headerPaymentIds = new Set<ID>();
			Set<ID> headerFOCIds = new Set<ID>();
			for(sObject sObj : sObjList) {
				if(Global_RecordTypeCache.getRt((ID)(sObj.get('recordTypeid'))).developerName.contains('ASI_CRM_SG_Payment_Request_Detail')) {
					headerPaymentIds.add((ID)(sObj.get('ASI_TH_CRM_Payment_Request__c')));
				} 
				if(Global_RecordTypeCache.getRt((ID)(sObj.get('recordTypeid'))).developerName.contains('ASI_SG_CRM_Request_Items')) {
					headerFOCIds.add((ID)(sObj.get('ASI_FOC_Request_Order__c')));
				}
			}
			
			if(headerPaymentIds.size() > 0) {
				validsObjectMap = new Map<ID,sObject>([SELECT ID, name, recordtypeID, ASI_CRM_System_Generated__c FROM ASI_TH_CRM_PaymentRequest__c WHERE ID IN : headerPaymentIds]);
			} else if (headerFOCIds.size() > 0) {
				validsObjectMap = new Map<ID,sObject>([SELECT ID, name, recordtypeID, ASI_CRM_SG_System_Generated__c, ASI_FOC_Request_Status__c FROM ASI_FOC_Free_Goods_Request__c WHERE ID IN : headerFOCIds]);
			}
			
			for(sObject sObj : sObjList) {
				if(Global_RecordTypeCache.getRt((ID)(sObj.get('recordTypeid'))).developerName.contains('Read_Only')) {
					sObj.addError('Not allowed to delete Approved records');
				}
				if(headerPaymentIds.size() > 0) {
					if(Global_RecordTypeCache.getRt((ID)(validsObjectMap.get((ID)(sObj.get('ASI_TH_CRM_Payment_Request__c')))).get('recordTypeid')).developerName.contains('Read_Only')) {
						sObj.addError('Not allowed to delete Approved records');
					}/* else
					if((Boolean)validsObjectMap.get((ID)(sObj.get('ASI_TH_CRM_Payment_Request__c'))).get('ASI_CRM_System_Generated__c')) {
						sObj.addError('Not allowed to delete system generated records');
					}*/
				}
				if(headerFOCIds.size() > 0) {
					if(Global_RecordTypeCache.getRt((ID)(validsObjectMap.get((ID)(sObj.get('ASI_FOC_Request_Order__c')))).get('recordTypeid')).developerName.contains('Read_Only')) {
						sObj.addError('Not allowed to delete Approved records');
					}/* else
					if((Boolean)validsObjectMap.get((ID)(sObj.get('ASI_FOC_Request_Order__c'))).get('ASI_CRM_SG_System_Generated__c') && (String)validsObjectMap.get((ID)(sObj.get('ASI_FOC_Request_Order__c'))).get('ASI_FOC_Request_Status__c')!='Draft') {
						sObj.addError('Not allowed to delete system generated records');
					}
                    */
				}
			}
		}
		else if (tAction == ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_DELETE){
			List<ASI_CRM_SG_FOC_Carry_Over__c> focCarryOverDeleteList = new List<ASI_CRM_SG_FOC_Carry_Over__c>();
			Map<Id, ASI_FOC_Free_Goods_Request__c> focMap = new Map<Id,ASI_FOC_Free_Goods_Request__c>();
            List<String> yearList = new List<String>();
            List<Integer> monthList = new List<Integer>();
            List<Id> contractIdList = new List<Id>();
            
			for (sObject sObj : sObjList){
                ASI_FOC_Free_Goods_Request__c freeGoods = (ASI_FOC_Free_Goods_Request__c)sObj;
				if(Global_RecordTypeCache.getRt((ID)(freeGoods.get('recordTypeid'))).developerName.contains('ASI_CRM_SG_FOC')) {
					if (freeGoods.ASI_FOC_Request_Status__c == 'Draft' && freeGoods.ASI_CRM_SG_System_Generated__c == true){
						focMap.put(freeGoods.Id, freeGoods);
                        yearList.add(freeGoods.ASI_CRM_SG_Year__c);
                        monthList.add(Integer.ValueOf(freeGoods.ASI_CRM_SG_Month__c));
                        contractIdList.add(freeGoods.ASI_CRM_Contract__c);
					}
				}
			}
			
            List<ASI_CRM_SG_FOC_Carry_Over__c> carryOverList = [select id, ASI_CRM_SG_Year__c, ASI_CRM_SG_Month__c, ASI_CRM_SG_Contract__c from ASI_CRM_SG_FOC_Carry_Over__c 
				where ASI_CRM_SG_Year__c in :yearList and ASI_CRM_SG_Month__c in :monthList and ASI_CRM_SG_Contract__c in :contractIdList];
            
            for (ASI_CRM_SG_FOC_Carry_Over__c c:carryOverList){
                for (ASI_FOC_Free_Goods_Request__c f:focMap.values()){
                    if (c.ASI_CRM_SG_Year__c == f.ASI_CRM_SG_Year__c && c.ASI_CRM_SG_Month__c == Integer.ValueOf(f.ASI_CRM_SG_Month__c) && c.ASI_CRM_SG_Contract__c == f.ASI_CRM_Contract__c)
                        focCarryOverDeleteList.add(c);
                }
            }
            
            if (focCarryOverDeleteList.size() > 0)
                delete focCarryOverDeleteList;
		}
    }
}