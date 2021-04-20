public class ASI_MFM_KR_POReceiptToolBarController {

    public ASI_MFM_PO_Receipt__c header                         {set;get;}
    public Id headerId                                          {set;get;}
    public Set<String>  brandGroups                             {set;get;}
    public List<String> brandGroupNames                         {set;get;}
    
    
    public ASI_MFM_KR_POReceiptToolBarController (ApexPages.StandardController controller) {
        
        this.header = (ASI_MFM_PO_Receipt__c)controller.getRecord();
        this.headerId = this.header.Id;
        this.brandGroups = new Set<String>();
        this.brandGroupNames = new List<String>();
        
    }
    
    public void init(){
        
        header = [Select id , ASI_MFM_Status__c , ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c,  ASI_MFM_PO__r.ASI_MFM_Email_Sent_Time__c from ASI_MFM_PO_Receipt__c where id=: this.headerId];
        
        for(ASI_MFM_PO_Receipt_Item__c prLine : [Select id ,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c , ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name 
                                                  from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__c!=null and ASI_MFM_PO_Receipt__c =: this.headerId] ){
                                                      
                                                      brandGroups.add(prLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name);
                                                  }
        
        brandGroupNames = new List<String>(brandGroups);
    }
    

}