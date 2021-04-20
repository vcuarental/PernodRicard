public class ASI_MFM_KR_PORCMapWrapper {
    private Map<string, List<ASI_MFM_PO_Receipt_Item__c>> aMap;
    
    public ASI_MFM_KR_PORCMapWrapper(Map<string, List<ASI_MFM_PO_Receipt_Item__c>> aMap) {
        this.aMap = aMap;
    }
    public ASI_MFM_KR_PORCMapWrapper(){
        this.aMap=new Map<string, List<ASI_MFM_PO_Receipt_Item__c>>();
    }
         
    public Map<string, List<ASI_MFM_PO_Receipt_Item__c>> getMap() {
        return aMap;
    }
}