/*Filename:    ASI_CRM_PreAppForm_RedirectView_Ctrl.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     This Controller controls the Page Traffic of the Pre-Approval Form Standard View Action.
*
* History
* -----------------------------------------------------------------------------
*/

public class ASI_CRM_PreAppForm_RedirectView_Ctrl {
    private ASI_HK_CRM_Pre_Approval_Form__c paForm{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    private String paramList {get;set;}
    
    public ASI_CRM_PreAppForm_RedirectView_Ctrl (ApexPages.StandardController controller) {
        
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
        
        paForm = (ASI_HK_CRM_Pre_Approval_Form__c)controller.getRecord();
        recordTypeId = ((ASI_HK_CRM_Pre_Approval_Form__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_HK_CRM_Pre_Approval_Form__c)controller.getRecord()).Id;
        recordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1])
             recordTypeName = rt.DeveloperName;
    }
    public PageReference redirect(){
        if(recordTypeName.startsWith('ASI_CRM_TW')){
            Schema.DescribeSObjectResult contractObj = ASI_HK_CRM_Pre_Approval_Form__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+ this.paForm.id + '?nooverride=1'+ paramList);
            redirectPage.setRedirect(true);
        }
        else{
            redirectPage =  new PageReference('/apex/ASI_HK_CRM_PAFCustomViewPage?id='+ recordId);
        }
        
        return redirectPage;
    }

}