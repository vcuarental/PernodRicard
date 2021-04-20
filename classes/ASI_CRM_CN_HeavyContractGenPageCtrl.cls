public class ASI_CRM_CN_HeavyContractGenPageCtrl {
    public Id contractId {get; set;}
    public boolean allowEdit {get; set;}
    public boolean forExternal {get; set;}
    public Boolean ForHightLight {get; set;}
    public string partName {get; set;}
    private List<string> validPartName {get; set;}{validPartName = new List<String>{'Body', 'Appendix'};}
    
    public ASI_CRM_CN_HeavyContractGenPageCtrl() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        contractId = params.get('id');
        
        string isEdit = params.get('edit');
        allowEdit = isEdit == '1' ? true : false;
        
        string isExternal = params.get('external');
        forExternal = isExternal == '1' ? true : false;
        
        String isHightLight = params.get('ForHightLight');
        ForHightLight = isHightLight == '1' ? true : false;
        
        String bodyPart = params.get('part');
        if (validPartName.contains(bodyPart)){
            partName = bodyPart;
        }
        
    }
}