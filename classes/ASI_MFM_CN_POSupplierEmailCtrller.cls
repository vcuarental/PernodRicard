public class ASI_MFM_CN_POSupplierEmailCtrller {
    
    Public String headerId{Get; Set;}
    
    Public List<String> getSubBrand(){
        
        List<ASI_MFM_PO_Line_Item__c> subBrandList = new List<ASI_MFM_PO_Line_Item__c>([SELECT ASI_MFM_Sub_brand_Code__r.Name FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c = : headerId AND ASI_MFM_Sub_brand_Code__c != NULL]);
        List<String> subBrandStr = new List<String>();
        
        if(subBrandList.size() > 0){
            for(ASI_MFM_PO_Line_Item__c obj : subBrandList){
                subBrandStr.add(obj.ASI_MFM_Sub_brand_Code__r.Name);
            }
        }
        Return subBrandStr;
    }
}