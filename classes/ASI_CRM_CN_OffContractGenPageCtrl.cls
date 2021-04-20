public class ASI_CRM_CN_OffContractGenPageCtrl {
    public Id contractId {get; set;}
    public boolean allowEdit {get; set;}
    public boolean forExternal {get; set;}
    public Boolean ForHighLight {get; set;}
    public string partName {get; set;}
    private List<string> validPartName {get; set;}{validPartName = new List<String>{'Body', 'Appendix'};}
    
    public ASI_CRM_CN_OffContractGenPageCtrl() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        contractId = params.get('id');
        
        string isEdit = params.get('edit');
        allowEdit = isEdit == '1' ? true : false;
        
        string isExternal = params.get('external');
        forExternal = isExternal == '1' ? true : false;
        
        String isHighLight = params.get('ForHighLight');
        ForHighLight = isHighLight == '1' ? true : false;
        
        String bodyPart = params.get('part');
        if (validPartName.contains(bodyPart)){
            partName = bodyPart;
        }
        
    }
}