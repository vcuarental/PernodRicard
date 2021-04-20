public class ASI_MFM_RentalRedirect_Ctrl {

    private ASI_MFM_RentalRedirect_Ctrl rental{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    public String retURL{get;set;}
    private String paramList {get;set;}
    
    public ASI_MFM_RentalRedirect_Ctrl (ApexPages.StandardController controller) {
        
        recordTypeId = ((ASI_MFM_Rental_Request__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_MFM_Rental_Request__c)controller.getRecord()).Id;
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
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
        
        // handle user with only one record type
        if(recordTypeId  == null){
            Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.ASI_MFM_Rental_Request__c;    
            List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
            system.debug(rtInfos);
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                System.debug(rtInfo);
                System.debug(rtInfo.isDefaultRecordTypeMapping());
                // For only one record type available user
                if(rtInfo.isAvailable() && rtInfo.getName() != 'Master') {               
                    //ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
                    recordTypeId  = rtInfo.getRecordTypeId();
                    break;
                }
            }
        }
        
        recordTypeName = 'null';
        System.debug(recordTypeId);
        if(recordTypeId != '' && recordTypeId != null){
            Recordtype rt = Global_RecordTypeCache.getRt(recordTypeId);
            recordTypeName = rt.DeveloperName;
        }
    }
    
    public PageReference redirect(){
        //if RecordTypeName = 'ASI_TH_CRM_Contract', redirect to its default create page. if 'ASI_CRM_CN_Contract', redirect to page 'ASI_CRM_CN_EditContractPage'
        
        System.debug(recordtypeName);
        //MT@Introv 20190528 start
        //record type renovation request also redirect to department section page
        //if(recordTypeName == 'ASI_MFM_CN_Renovation_Form'){
        if(recordTypeName == 'ASI_MFM_CN_Renovation_Form' || recordTypeName == 'ASI_MFM_CN_Renovation_Request'){
        //MT@Introv 20190528 end
            redirectPage =  new PageReference('/apex/ASI_MFM_CN_RentalReuqestCreationPage?RecordType='+recordTypeId + '&retURL='+retURL);
            
        }else{
            
            Schema.DescribeSObjectResult rentalObj = ASI_MFM_Rental_Request__c.sObjectType.getDescribe();
            if(recordTypeId != null)
                redirectPage = new PageReference('/'+ rentalObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList);
        }
        
        return redirectPage;
    }
}