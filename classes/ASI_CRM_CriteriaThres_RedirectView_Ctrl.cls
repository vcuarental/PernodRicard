/*Filename:    ASI_CRM_CriteriaThres_RedirectView_Ctrl.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     This Controller controls the Page Traffic of the Criteria Threshold Standard View Action.
*
* History
* -----------------------------------------------------------------------------
*/

public class ASI_CRM_CriteriaThres_RedirectView_Ctrl {
    private ASI_CRM_Criteria_Threshold__c cThreshold{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    private String paramList {get;set;}
    
    public ASI_CRM_CriteriaThres_RedirectView_Ctrl (ApexPages.StandardController controller) {
        
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
        
        cThreshold = (ASI_CRM_Criteria_Threshold__c)controller.getRecord();
        recordTypeId = ((ASI_CRM_Criteria_Threshold__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_CRM_Criteria_Threshold__c)controller.getRecord()).Id;
        recordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1])
             recordTypeName = rt.DeveloperName;
    }
    public PageReference redirect(){
        if(recordTypeName.startsWith('ASI_CRM_SG')){
            redirectPage =  new PageReference('/apex/ASI_CRM_CriteriaThresholdPage?id='+ recordId);
        }
        else if(recordTypeName.startsWith('ASI_CRM_TW')){
            redirectPage =  new PageReference('/apex/ASI_CRM_TW_CriteriaThresholdPage?id='+ recordId);
        }
        else if(recordTypeName.startsWith('ASI_CRM_TH')){
            //Added by Twinkle @04/03/2016
            redirectPage =  new PageReference('/apex/ASI_CRM_TH_CriteriaThresholdPage?id='+ recordId);
        }
        else{
            Schema.DescribeSObjectResult contractObj = ASI_CRM_Criteria_Threshold__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+ this.cThreshold.id + '?nooverride=1'+ paramList);
            redirectPage.setRedirect(true);
        }
        
        return redirectPage;
    }

}