public without sharing class ASI_CRM_CN_AB_AdminDelCtrl
{
    ASI_CRM_Anti_Bribery__c header;
    public ASI_CRM_CN_AB_AdminDelCtrl(ApexPages.StandardController stdController)
    {
        header = (ASI_CRM_Anti_Bribery__c) stdController.getRecord();
    }
    
    public PageReference adminDel(){
        String headerId = header.Id;
        if(headerId!=null && headerId!=''){
            try
            {
                delete header;
            }
            catch(System.DmlException e)
            {
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0));
                //ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
        PageReference pageRef = new PageReference('/'+headerId.substring(0, 3));
        return pageRef;
    }
}