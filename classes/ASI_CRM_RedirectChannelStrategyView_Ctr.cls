/*
    - This Controller controls the Page Traffic of the Contract Standard View Action.
*/

public class ASI_CRM_RedirectChannelStrategyView_Ctr {
    private ASI_CRM_CN_Channel_Strategy__c contract{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    private String paramList {get;set;}
    
    public ASI_CRM_RedirectChannelStrategyView_Ctr (ApexPages.StandardController controller) {
        
        Map<String, String> pageParam = ApexPages.currentPage().getParameters(); 
        paramList='';
        if(pageParam!=null){
            for(String param : pageParam.keySet()){
                if(pageParam.get(param)==null){
                    paramList +='&'+param+'=null';
                }else{
                    if(!param.contains('save_new')&&!param.contains('sfdc.override'))
                    paramList +='&'+param+'='+pageParam.get(param);
                }
            }
        }
        
        contract = (ASI_CRM_CN_Channel_Strategy__c)controller.getRecord();
        recordTypeId = ((ASI_CRM_CN_Channel_Strategy__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_CRM_CN_Channel_Strategy__c)controller.getRecord()).Id;
        recordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1])
             recordTypeName = rt.DeveloperName;
    }
    public PageReference redirect(){
        if(recordTypeName == 'ASI_NPL_CN_Channel_Strategy')
        {
            Schema.DescribeSObjectResult contractObj = ASI_CRM_CN_Channel_Strategy__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+ this.contract.id + '?nooverride=1'+ paramList);
            redirectPage.setRedirect(true);
        }
        else 
        {
            redirectPage =  new PageReference('/apex/ASI_CRM_CN_ChannelStratgy_Page?id='+ this.contract.id);
        }
        
        return redirectPage;
    }

}