/******************************************************************
*Name:ASI_CRM_JP_CallPlanRedirectController
*Description: Controller for ASI_CRM_JP_CallPlanRedirectPage
*Change History:
*Date           Developer      Details
*April 8,2016   Hank           Created 
*
******************************************************************/
public without sharing class ASI_CRM_JP_CallPlanRedirectController{
    public ASI_CRM_Call_Plan__c plan;
    private String paramList {get;set;} 
    private String RecordTypeId{get;set;}
    private String RecordTypeName{get;set;}
    public ASI_CRM_JP_CallPlanRedirectController(ApexPages.StandardController controller) {
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
        system.debug('----- paramList : ' + paramList);
        plan = (ASI_CRM_Call_Plan__c)controller.getRecord();
        RecordTypeId = ((ASI_CRM_Call_Plan__c)controller.getRecord()).RecordTypeId;
        RecordTypeName = '';
        if(RecordTypeId == null){
            Schema.DescribeSObjectResult dsr = ASI_CRM_Call_Plan__c.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordType;
            for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()) {
                    defaultRecordType = rti;
                }
            }
            RecordTypeId = defaultRecordType.getRecordTypeId();   
        }
        if(RecordTypeId != null){
            RecordType rt = [select id,DeveloperName from recordtype where id = :RecordTypeId];
            RecordTypeName = rt.DeveloperName;
        }
    }
    public pageReference redirect(){
        Map<String, ASI_CRM_Redirect_Tbl__c> tblMap = ASI_CRM_Redirect_Tbl__c.getAll();
        Schema.DescribeSObjectResult planObj = ASI_CRM_Call_Plan__c.sObjectType.getDescribe();
        PageReference retPage;
        if(tblMap.get(RecordTypeName) != null){
            retPage = new PageReference('/'+ planObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&'+tblMap.get(RecordTypeName).ASI_CRM_Element_Id__c+'='+tblMap.get(RecordTypeName).ASI_CRM_Element_Value__c+'&nooverride=1'+ paramList);
        }else{
            retPage = new PageReference('/'+ planObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList);
        }
        return retPage;
    }
}