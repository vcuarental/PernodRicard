public without sharing class ASI_MY_CRM_SalesOrder_Ctrl {
    public static final String foc = 'FOC';
    public static final String focr = 'FOC Return';
    public static final String so_without_ch = 'Sales Order - Without Credit Hold';
    public static final String so_with_ch = 'Sales Order - With Credit Hold';
    public static final String sor_without_ch = 'Sales Order Return - Without Credit Hold';
    public static final String sor_with_ch = 'Sales Order Return - With Credit Hold';
    public static final String dn = 'Debit Note';
    public static final String cn = 'Credit Note';
    
    public static Map<String, String> getOrderTypeMapping(){
        Map<String, String> m_Order_Type = new Map<String, String>();
        List<ASI_CRM_MY_Order_Type_Mapping__c> l_Order_Type = 
            												[SELECT 
                                                           ASI_CRM_MY_Order_Type_Code__c,
                                                           ASI_CRM_MY_Order_Type__c 
                                                           FROM ASI_CRM_MY_Order_Type_Mapping__c];
        for(ASI_CRM_MY_Order_Type_Mapping__c order_type : l_Order_Type){
            if(String.isNotBlank(order_type.ASI_CRM_MY_Order_Type_Code__c) && String.isNotBlank(order_type.ASI_CRM_MY_Order_Type__c)){
                m_Order_Type.put(order_type.ASI_CRM_MY_Order_Type_Code__c, order_type.ASI_CRM_MY_Order_Type__c);
            }
        }
        
        return m_Order_Type;
    }
    
    public static Map<Id, ASI_CRM_Dynamic_Approval_Route__c> getDynamicApprovalMap(){
        List<ASI_CRM_Dynamic_Approval_Route__c> dynamicApprovalList =
                                                            [SELECT id,
                                                             ASI_CRM_End_of_Dynamic_Route__c,
                                                             ASI_CRM_User__c,
                                                             ASI_CRM_Type__c,
                                                             ASI_CRM_Approval_Limit__c,
                                                             ASI_CRM_Manager_ID__c 
                                                            FROM ASI_CRM_Dynamic_Approval_Route__c
                                                            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_MY_Dynamic_Approval_Route')];
        Map<Id, ASI_CRM_Dynamic_Approval_Route__c> m_dynamicApproval = new Map<Id, ASI_CRM_Dynamic_Approval_Route__c>();
        for(ASI_CRM_Dynamic_Approval_Route__c dynamicApprova : dynamicApprovalList){
            m_dynamicApproval.put(dynamicApprova.ASI_CRM_User__c, dynamicApprova);
        }
        
        return m_dynamicApproval;
    }
    
    public static Map<String, ASI_CRM_Fix_Approval_Route__c> getFixApprovalMap(){
        List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = 
                                                        [SELECT id, 
                                                         ASI_CRM_CN_Approver_1__c,
                                                         ASI_CRM_CN_Approver_2__c,
                                                         ASI_CRM_CN_Approver_3__c,
                                                         ASI_CRM_CN_Approver_4__c,
                                                         ASI_CRM_CN_Approver_5__c,
                                                         ASI_CRM_CN_Approver_6__c,
                                                         ASI_CRM_CN_Approver_7__c,
                                                         ASI_CRM_CN_Approver_8__c,
                                                         ASI_CRM_CN_Approver_9__c,
                                                         ASI_CRM_CN_Approval_Limit_1__c,
                                                         ASI_CRM_CN_Approval_Limit_2__c,
                                                         ASI_CRM_CN_Approval_Limit_3__c,
                                                         ASI_CRM_CN_Approval_Limit_4__c,
                                                         ASI_CRM_CN_Approval_Limit_5__c,
                                                         ASI_CRM_CN_Approval_Limit_6__c,
                                                         ASI_CRM_CN_Approval_Limit_7__c,
                                                         ASI_CRM_CN_Approval_Limit_8__c,
                                                         ASI_CRM_CN_Approval_Limit_9__c,
                                                         ASI_CRM_CN_Type__c
                                                        FROM ASI_CRM_Fix_Approval_Route__c
                                                        WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_MY_Fix_Approval_Route')];
        
        Map<String, ASI_CRM_Fix_Approval_Route__c> m_FixApproval = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c fixApproval : fixApprovalList){
            m_FixApproval.put(fixApproval.ASI_CRM_CN_Type__c, fixApproval);
        }
        
        return m_FixApproval;
        
    }
    
	public static Map<Id, ASI_CRM_Fix_Approval_Route__c> getSub_Brand_TypeFixApprovalMap(){
        List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = 
                                                        [SELECT 
                                                         ASI_CRM_MY_Sub_Brand__c,
                                                         ASI_CRM_CN_Approver_1__c,
                                                         ASI_CRM_CN_Approver_2__c,
                                                         ASI_CRM_CN_Approver_3__c,
                                                         ASI_CRM_CN_Approval_Limit_1__c,
                                                         ASI_CRM_CN_Approval_Limit_2__c,
                                                         ASI_CRM_CN_Approval_Limit_3__c
                                                        FROM ASI_CRM_Fix_Approval_Route__c
                                                        WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_MY_Sub_Brand_Type_Fix_Approval_Route')
                                                        AND ASI_CRM_MY_Sub_Brand__c != null];
        
        Map<Id, ASI_CRM_Fix_Approval_Route__c> m_FixApproval = new Map<Id, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c fixApproval : fixApprovalList){
            m_FixApproval.put(fixApproval.ASI_CRM_MY_Sub_Brand__c, fixApproval);
        }
        
        return m_FixApproval;
        
    }
     
    public static Map<Id, Id> getCODI_FixApprovalMap(){
        List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = 
                                                        [SELECT 
                                                         ASI_CRM_CN_Approver_1__c,
                                                         ASI_CRM_CODI_User__c
                                                        FROM ASI_CRM_Fix_Approval_Route__c
                                                        WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_MY_CODI_Approval_Route')];
        
        Map<Id, Id> m_FixApproval = new Map<Id, Id>();
        for(ASI_CRM_Fix_Approval_Route__c fixApproval : fixApprovalList){
            m_FixApproval.put(fixApproval.ASI_CRM_CODI_User__c, fixApproval.ASI_CRM_CN_Approver_1__c);
        }
        
        return m_FixApproval;
        
    } 
    
}