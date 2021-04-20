public class ASI_MFM_SC_PO_PDF_PageController {
    private final ASI_MFM_PO__c Po;
    public ASI_MFM_Plan__c plan{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    public List<ProcessInstanceStep> stepList{get;set;}
        
    public ASI_MFM_SC_PO_PDF_PageController(ApexPages.StandardController stdController){
        this.Po = (ASI_MFM_PO__c)stdController.getRecord();
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        ASI_MFM_PO__c poCurrent = [select ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c,ASI_MFM_PO_Amount__c,ASI_MFM_SC_Remaining_Balance__c from ASI_MFM_PO__c where id =: Po.Id];
        System.debug('POId ' + Po.Id);
        
        plan = [select id,Name,ASI_MFM_Plan_Description__c, owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
            
        System.debug('planId' + plan.id);
        System.debug('planName' + plan.Name);
        System.debug('planDescription' + plan.ASI_MFM_Plan_Description__c);
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select name, ASI_MFM_BU_Code__r.name,  ASI_MFM_AP_Code__r.Name,
       ASI_MFM_SC_Subledger__r.Name,ASI_MFM_List_Item_Description__c,ASI_MFM_Amount__c,asi_mfm_Recurring_payment_amount__c  from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: Po.Id order by name];
        
        for(ASI_MFM_PO_Line_Item__c poli : lineItemList){
            lineItem.add(poli);
        }
        
        stepList = [select SystemModstamp, StepStatus, Actor.Name, Comments from ProcessInstanceStep where ProcessInstance.TargetObjectId = :po.id order by SystemModstamp asc];
    }

}