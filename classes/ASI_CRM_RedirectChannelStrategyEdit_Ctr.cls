/*
    - This Controller controls the Page Traffic of the Contract Standard Edit Action.
*/

public class ASI_CRM_RedirectChannelStrategyEdit_Ctr {
    private ASI_CRM_CN_Channel_Strategy__c contract{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
        
    public ASI_CRM_RedirectChannelStrategyEdit_Ctr (ApexPages.StandardController controller) {
        
        recordTypeId = ((ASI_CRM_CN_Channel_Strategy__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_CRM_CN_Channel_Strategy__c)controller.getRecord()).Id;
        recordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1])
             recordTypeName = rt.DeveloperName;
    }
    public PageReference redirect(){

        if(recordTypeName == 'ASI_NPL_CN_Channel_Strategy')
        {
            redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
        else 
        {
            
            redirectPage =  new PageReference('/apex/ASI_CRM_CN_ChannelStratgy_EditPage?id='+ recordId);
            
        }
        return redirectPage;
    }

}