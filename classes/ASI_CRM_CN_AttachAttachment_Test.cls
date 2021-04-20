@isTest
private class ASI_CRM_CN_AttachAttachment_Test {
    
    static testMethod void testMethod1(){
        ASI_CRM_Order_Form__c tmpOF = new ASI_CRM_Order_Form__c(ASI_CRM_Order_Form_Name__c = '1', ASI_CRM_Order_Form_Type__c = '2',recordtypeid=Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form'));
        insert tmpOF;
        
        test.startTest();
        
        ASI_CRM_CN_AttachAttachment con = new ASI_CRM_CN_AttachAttachment();
        
        con.headerID = tmpOF.id;
        con.getNote();
        con.getAttachment();
        test.stopTest();
    }
    
}