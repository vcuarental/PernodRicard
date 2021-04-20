public class ASI_CRM_KH_WebmergeContractCtrl{
    public string webmergeMappingId {get;set;}
    public ASI_CRM_KH_WebmergeContractCtrl(ApexPages.StandardController controller){
        List<webm__Webmerge_Mapping__c>webmergeMappingIds = [Select id from webm__Webmerge_Mapping__c where name = 'ASI CRM KH Contract'];
        if(webmergeMappingIds != null && webmergeMappingIds.size()>0){
            webmergeMappingId = webmergeMappingIds[0].Id;
        }
    }
}