public class ASI_MFM_PO_PDF_PageController {
    
    private final ASI_MFM_PO__c Po;
    public ASI_MFM_Plan__c plan{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
        
    public ASI_MFM_PO_PDF_PageController(ApexPages.StandardController stdController){
        //try{
        this.Po = (ASI_MFM_PO__c)stdController.getRecord();
        
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        
        ASI_MFM_PO__c poCurrent = [select ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c from ASI_MFM_PO__c where id =: Po.Id];
        System.debug('POId ' + Po.Id);
        
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,
            owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }
           
        System.debug('planId' + plan.id);
        System.debug('planName' + plan.Name);
        System.debug('planDescription' + plan.ASI_MFM_Plan_Description__c);
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
        ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_SKU_Code__r.ASI_MFM_SKU_Code__c 
        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: Po.Id order by ASI_MFM_Print_Sequence__c,name];
        
        for(ASI_MFM_PO_Line_Item__c poli : lineItemList){
            if(poli.ASI_MFM_Quantity__c == null){
                poli.ASI_MFM_Quantity__c = 0;
            }
            if(poli.ASI_MFM_Unit_Price__c == null){
                poli.ASI_MFM_Unit_Price__c = 0;
            }
            if(poli.ASI_MFM_Amount__c == null){
                poli.ASI_MFM_Amount__c = 0;
            }
            lineItem.add(poli);
        }
        //catch(exception e){e.getMessage();}
    }

    

    
}