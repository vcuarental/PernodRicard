public class EUR_CRM_DE_CreateOPOnTradePageContrller{ 
    private Set<String> validRecordTypes  = new Set<String> {
        'EUR_DE_OnTrade_PROS_TMKT_Promo'}; 
    private Boolean isValid = false; 
 
    private Boolean isEdit = false; 
    private String chosenRT;
    public EUR_CRM_ObjPromo__c objPromo {get; set;}
    
    public List<SelectOption> regionOptions {get; set;} 
    //public List<SelectOption> territoryOptions {get; set;} 
    public String  regionValue {get; set;} 
    public String  territoryValue {get; set;} 
    
    public EUR_CRM_DE_CreateOPOnTradePageContrller(ApexPages.StandardController stdController) {
          Id objPromoId =  stdController.getId();
          System.debug('Flag - ObjPromoId:' + objPromoId);
          /*
          
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.recordtype.developername}" />        
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.name}" />   
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.EUR_CRM_Type__c}" />
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.EUR_CRM_Status__c}" />
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.EUR_CRM_PROS_Group_Outlet__c}" />
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.EUR_CRM_Active_Start_Date__c}" />
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.EUR_CRM_PROS_Image_Level__c}" />
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.EUR_CRM_Active_End_Date__c}" /> 
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.EUR_CRM_Region__c}" />
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.EUR_CRM_Territory__c}" />
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.RecordType.developername}" />
                    <apex:inputhidden value="{!EUR_CRM_ObjPromo__c.RecordTypeid}" /> 
          */
          objPromo = new EUR_CRM_ObjPromo__c(); 
          
          String objectRT = null;
          if(objPromoId  != null){
          objPromo = [select id, recordtype.developername, name, EUR_CRM_Type__c,  EUR_CRM_Status__c, EUR_CRM_PROS_Group_Outlet__c, EUR_CRM_Active_Start_Date__c,
          EUR_CRM_PROS_Image_Level__c, EUR_CRM_DocServer_Asset_Tags__c, 
          EUR_CRM_Active_End_Date__c,OwnerId , EUR_CRM_Region__c, EUR_CRM_Territory__c, RecordTypeid from EUR_CRM_ObjPromo__c where id =:objPromoId];
              objectRT = objPromo.recordtype.developername;
              regionValue = objPromo.EUR_CRM_Region__c;
              territoryValue = objPromo.EUR_CRM_Territory__c;
              isEdit = true;
              }
          else{
              chosenRT = retrieveRecordType();//ApexPages.CurrentPage().GetParameters().Get('RecordType');
              System.debug('Flag - Chosen Record Type:' + chosenRT);
              objPromo.ownerid = UserInfo.getUserId();
              RecordType rt = [select Id,DeveloperName from RecordType where id =:chosenRT ];
              objectRT =rt.developername;
              objPromo.recordtypeid = rt.id;
              regionValue = System.Label.EUR_CRM_All_Regions;
              territoryValue = System.Label.EUR_CRM_All_Territories; 
          }
          isValid = validRecordTypes.contains(objectRT );
          regionOptions  = getRegionOptions();
    }
    public PageReference redirect(){ 
        if(!isValid){
            if(!isEdit){
                String url = '/' + EUR_CRM_ObjPromo__c.SObjectType.GetDescribe().GetKeyPrefix() + '/e?RecordType=' + chosenRT + '&nooverride=1';
                return new ApexPages.PageReference(url).SetRedirect(true);
            }else{
                String url = '/' + objPromo.id + '/e?retURL=%2F' + objPromo.id + '&nooverride=1';
                return new ApexPages.PageReference(url).SetRedirect(true);
            }
        }
        return null;
    }
    
    private String retrieveRecordType(){
        if (ApexPages.CurrentPage().GetParameters().Get('RecordType') == null) {
            Schema.DescribeSObjectResult describeObj = Schema.SObjectType.EUR_CRM_ObjPromo__c;    
            List<Schema.RecordTypeInfo> rtInfos = describeObj.getRecordTypeInfos();
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                if(rtInfo.isDefaultRecordTypeMapping()) {               
                    ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
                    break;
                }
            }
        }

        return ApexPages.CurrentPage().GetParameters().Get('RecordType');
    }
    
    private List<SelectOption> getRegionOptions(){
        
        List<SelectOption> regionOptions = new List<SelectOption>();
        //regionOptions.add(new SelectOption(System.Label.EUR_CRM_All_Regions,System.Label.EUR_CRM_All_Regions));
        regionOptions.add(retrieveAllRegionsOption());
        for(EUR_CRM_Region__c region : [select name from EUR_CRM_Region__c where recordtype.developername = 'EUR_DE_Region' order by name]){
            if(!region.name.contains('Off'))
                regionOptions.add(new SelectOption(region.name, region.name));
        }
        return regionOptions;
    }
    
    public List<SelectOption> getTerritoryOptions(){
        
        List<SelectOption> territoryOptions= new List<SelectOption>();
        if(regionValue != ALL_REGIONS ){
           // territoryOptions.add(new SelectOption(System.Label.EUR_CRM_All_Territories,System.Label.EUR_CRM_All_Territories));
            territoryOptions.add(retrieveAllTerritoriesOption());           

            
            for(EUR_CRM_Territory__c territory: [select name from EUR_CRM_Territory__c where EUR_CRM_Region__c in
                                                 (select id from EUR_CRM_Region__c where name=:regionValue) and recordtype.developername = 'EUR_DE_Territory'
                                                   order by name]){
                territoryOptions.add(new SelectOption(territory.name, territory.name));
            }
        }
        return territoryOptions;
    }
    
    public PageReference handleSave(){
        objPromo.EUR_CRM_Region__c = regionValue;
        objPromo.EUR_CRM_Territory__c = territoryValue;
        upsert objPromo;
        return new ApexPages.PageReference('/'+objPromo.id).SetRedirect(true);
    }
    
    private final String ALL_REGIONS = 'All Regions';
    private final String ALL_TERRITORIES= 'All Territories';
    
    private SelectOption retrieveAllRegionsOption(){
        Schema.DescribeFieldResult fieldResult = EUR_CRM_ObjPromo__c.EUR_CRM_Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            SelectOption option;
       for( Schema.PicklistEntry f : ple){
           if(f.getValue() == ALL_REGIONS){
               option =new SelectOption(f.getValue(), f.getLabel());
               break;
           } 
       }       
       return option;
    }
        
    private SelectOption retrieveAllTerritoriesOption(){
        Schema.DescribeFieldResult fieldResult = EUR_CRM_ObjPromo__c.EUR_CRM_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            SelectOption option;
       for( Schema.PicklistEntry f : ple){
           if(f.getValue() == ALL_TERRITORIES){
               option =new SelectOption(f.getValue(), f.getLabel());
               break;
           } 
       }       
       return option;
    }
}