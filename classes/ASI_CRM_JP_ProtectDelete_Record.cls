/*********************************************************************************
 * Name:ASI_CRM_JP_ProtectDelete_Record
 * Description: Generic class to protect lines to be deleted
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/01/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_ProtectDelete_Record extends ASI_CRM_JP_TriggerAbstract {

    public static Final Map<String, String> masterDetailFields = new Map<String, String>{
                                                                                'ASI_CRM_Call_Detail__c' => 'ASI_CRM_Call_Plan__c',
                                                                                'ASI_CRM_Payment_Invoice_Line_Item__c' => 'ASI_CRM_Payment_Invoice__c',
                                                                                'ASI_CRM_Purchase_Contract_Line_Item__c' => 'ASI_CRM_Purchase_Contract__c'
                                                                            };
    
    public static Final Set<String> recordtypeProtectKeyword = new Set<String>{
                                                                            'ASI_CRM_JP_Call_Plan_Locked',
                                                                            'ASI_CRM_JP_Indirect_Rebate_Invoice_Read_Only',
                                                                            'ASI_CRM_JP_SPTD_Cash_Invoice_Read_Only',
                                                                            'ASI_CRM_JP_SPTD_FOC_Invoice_Read_Only',
                                                                            'ASI_CRM_JP_Direct_Rebate_Contract_Read_Only',
                                                                            'ASI_CRM_JP_Indirect_Rebate_Contract_Read_Only',
                                                                            'ASI_CRM_JP_SPTD_Contract_Read_Only'
                                                                        };
    
    public ASI_CRM_JP_ProtectDelete_Record() {
        super('ASI_CRM_JP_ProtectDelete_Record');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<sObject> validsObject = new List<sObject>();
        Set<ID> sObjectHeaderIds = new Set<ID>();
        String headerObject = '';
        Map<ID, sObject> headersObjectMap = new Map<ID, sObject>();
        
        for(sObject obj : sObjList) {
        
            String sObjectName = obj.getSObjectType().getDescribe().getName();
            if(masterDetailFields.containsKey(sObjectName)) {
                String sObjectMasterField = masterDetailFields.get(sObjectName);
                headerObject = sObjectMasterField;
                sObjectHeaderIds.add((ID)(obj.get(sObjectMasterField)));
            } else {
                String recordtypeDevelopername = Global_RecordTypeCache.getRt((ID)(obj.get('recordtypeid'))).developername;
                if(recordtypeProtectKeyword.contains(recordtypeDevelopername)) {
                    validsObject.add(obj);
                }
            }
        }
        
        if(sObjectHeaderIds.size() > 0 && headerObject != '') {
            String query = 'SELECT ID, Name, recordtype.developername FROM ' + headerObject + ' WHERE ID IN : sObjectHeaderIds ';
            List<sObject> sObjectList = database.query(query);
            for(sObject obj : sObjectList) {
                headersObjectMap.put((id)(obj.get('id')), obj);
            }
        }
        
        if(headersObjectMap.size() > 0) {
            for(sObject obj : sObjList) {

                if(headersObjectMap.containsKey((ID)(obj.get(headerObject)))) {
                    sObject header = headersObjectMap.get((ID)(obj.get(headerObject)));
                    if(recordtypeProtectKeyword.contains((String)((header.getSObject('recordtype')).get('developername')))) {
                        validsObject.add(obj);
                    }
                }
            }
        }
        
        if(validsObject.size() > 0) {
            for(sObject obj : sObjList) {
                obj.adderror(Label.ASI_CRM_JP_Invalid_Delete);
            }
        }
        
    }

}