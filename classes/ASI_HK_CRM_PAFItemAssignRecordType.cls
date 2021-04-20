public with sharing class ASI_HK_CRM_PAFItemAssignRecordType extends ASI_HK_CRM_TriggerAbstract {
    
    private static ID RTID_NO_MECHANIC = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_NO_MECHANIC).Id;
    private static ID RTID_FOC = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_FOC).Id;
    private static ID RTID_FOC_BULK = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_FOC_BULK).Id;
    private static ID RTID_VARIABLE = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_VARIABLE).Id;
    private static ID RTID_FIXED = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_FIXED).Id;
	private static ID RTID_FIXED_BOTTLE = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_FIXED_BOTTLE).Id;
    private static Map<String, ID> mechanicToRTIdMap = new Map<String, ID> {
        'PAF Item - FOC' => RTID_FOC 
        , 'PAF Item - FOC Bulk' => RTID_FOC_BULK
        , 'PAF Item - Variable' => RTID_VARIABLE
        , 'PAF Item - Fixed Amount' => RTID_FIXED
		, 'PAF Item - Fixed Bottle' => RTID_FIXED_BOTTLE
    };
    
    public ASI_HK_CRM_PAFItemAssignRecordType() {
        super('ASI_HK_CRM_PAFItemAssignRecordType');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
            && !isBypassByCurrentUser()) {
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> pafItemList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)sObjList;
            
            Map<ID, ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechanicMap = null;
            
            for (ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem : pafItemList) {
                try {
                    if (tAction == TriggerAction.BEFORE_INSERT || ((ASI_HK_CRM_Pre_Approval_Form_Item__c)oldMap.get(pafItem.Id)).ASI_HK_CRM_Mechanic__c != pafItem.ASI_HK_CRM_Mechanic__c) {
                        if (pafItem.ASI_HK_CRM_Mechanic__c == null) {
                            pafItem.RecordTypeId = RTID_NO_MECHANIC;
                        } else {
                            if (mechanicMap == null) {
                                mechanicMap = new Map<ID, ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>([SELECT Id, ASI_HK_CRM_Mechanic_Type__c FROM ASI_HK_CRM_Pre_Approval_Form_Mechanic__c]);
                            }
                            ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mechanic = mechanicMap.get(pafItem.ASI_HK_CRM_Mechanic__c);
                            pafItem.RecordTypeId = mechanicToRTIdMap.get(mechanic.ASI_HK_CRM_Mechanic_Type__c);
                            if (pafItem.RecordTypeId == null)
                                throw new ASI_HK_CRM_CustomException(String.format('Undefined Mechanic Type: {0}', new String[] {mechanic.ASI_HK_CRM_Mechanic_Type__c}));
                            //20160321, added by Leo
                            if(pafItem.ASI_CRM_HK_All_Product__c && pafItem.RecordTypeId != RTID_VARIABLE)
                                throw new ASI_HK_CRM_CustomException(String.format('{0} not allow for All Product.', new String[] {mechanic.ASI_HK_CRM_Mechanic_Type__c}));
                            //20160321, added by Leo
                        }
                    }
                } catch (Exception e) {
                    pafItem.addError(e);
                }
            }
        }
    }

}