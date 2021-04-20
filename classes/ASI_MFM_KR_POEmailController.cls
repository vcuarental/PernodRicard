public class ASI_MFM_KR_POEmailController
{
    /*
    public ASI_MFM_KR_POEmailController(ApexPages.StandardController controller) {
            this.header = (ASI_MFM_PO__c)controller.getRecord();
    }
    */
    public ASI_MFM_PO__c header{get;set;} 
    public Id headerId {get;set;} //current header Id
    public List<ASI_MFM_PO_Line_Item__c> poLines{get;set;} //current header's line itmes
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public boolean init()
    {
        poLines = [SELECT Id, Name,
                   ASI_MFM_PO__r.Name,
                   ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,
                   ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name,
                   ASI_MFM_Sub_brand_Code__r.Name,
                   ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,
                   ASI_MFM_PO__r.Owner.Name
                   FROM ASI_MFM_PO_Line_Item__c 
                   WHERE ASI_MFM_PO__c =: headerId 
                   AND recordType.developerName = 'ASI_MFM_KR_PO_Line_Item'];
        return true;        
    }//end method: init
}//end class