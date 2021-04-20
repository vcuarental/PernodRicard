public class ASI_MFM_KR_SelectProjectCodeController {
    public ASI_MFM_Plan__c plan {get; set;} {plan = new ASI_MFM_Plan__c();}
    public String FiscalYear{get;set;}{FiscalYear=null;}   
    public String ProjectCode{get;set;}{ProjectCode=null;}
    public String Module{get;set;}{ Module = apexpages.currentPage().getParameters().get('Module');}
    public List<ASI_MFM_Prefix__c> prefix {get; set;}{prefix = new List<ASI_MFM_Prefix__c>();}
    
    public ASI_MFM_KR_SelectProjectCodeController(){    }
    public void init(){
        //Get Today Fiscal Year
        string NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  // If today's month is Jan-Jun 
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{ //else If today's month is July to DEC
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        // Get Today Fiscal Year Finished
        FiscalYear=NowFY;
                
    }
        
    
    public PageReference proceed() {
    
        string prefix_name;
        string selected_prefix;
        string NextNumber;
        string PrC;
        String PromotionCode='';
        
        //Object ID
        string obj_id;
        //Prefix id
        string field_id;
        // Project Code
        string PC_field_id;
        // Fiscal year
        string FY_field_id;
        // Promotion Code
        string PrC_field_id;
        // Record Type Id   *******  Added by 2017-06-16 Linus@Introv
        string recordType_id;
        
        List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
        
        if(Module=='Plan'){
            obj_id = sObjectType.ASI_MFM_Plan__c.getKeyPrefix();
            field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Plan__c', 'ASI_MFM_Prefix__c');
            
            FY_field_id= ASI_MFM_Function.getFieldId('ASI_MFM_Plan__c', 'ASI_MFM_Fiscal_year__c');
            PC_field_id= ASI_MFM_Function.getFieldId('ASI_MFM_Plan__c', 'ASI_MFM_Project_Code__c');
            PrC_field_id= ASI_MFM_Function.getFieldId('ASI_MFM_Plan__c', 'ASI_MFM_Promotion_Code__c');
        }
       
        //Get ASI_MFM_Project_Code__c's code number
        
        ASI_MFM_Project_Code__c pccode =[select id,name,ASI_MFM_Code__c from ASI_MFM_Project_Code__c where id=:plan.ASI_MFM_Project_Code__c];
        
        //Check existing prefix object
        prefix=[select id,name,ASI_MFM_Next_Number__c from ASI_MFM_Prefix__c where ASI_MFM_Project_Code__c=:plan.ASI_MFM_Project_Code__c and ASI_MFM_Fiscal_year__c=:FiscalYear and ASI_MFM_Module__c=:Module and ASI_MFM_Inactive__c = false];
        
        if(prefix.size()>0){//exist
            prefix_name=prefix[0].name;
            selected_prefix=prefix[0].id;
            NextNumber=string.valueOf(prefix[0].ASI_MFM_Next_Number__c);
        }else{// Not exist ,Create new record
            //Get Prefix Record Type ID
            String NewPrefixName=pccode.ASI_MFM_Code__c+FiscalYear.substring(3,4);
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');  
            ASI_MFM_Prefix__c pf=new ASI_MFM_Prefix__c(name=NewPrefixName,recordTypeId=rt_map.get('ASI_MFM_KR_Prefix'),ASI_MFM_Project_Code__c=plan.ASI_MFM_Project_Code__c,ASI_MFM_Fiscal_year__c=FiscalYear,ASI_MFM_Module__c=Module);
            insert pf;
            prefix_name=pf.name;
            selected_prefix=pf.id;
            NextNumber='01';
        }
        
        // Added by 2017-06-16  Linus@Introv
        recordType_id = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan');
        
        PromotionCode=pccode.ASI_MFM_Code__c+FiscalYear.substring(3,4)+string.valueOf(integer.valueOf(NextNumber) + 1000).substring(1, 4);
        string url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&RecordType=' + recordType_id + '&Name=' + prefix_name;  
        
        
        if(Module=='Plan'){
            url+='&' + FY_field_id + '=' + FiscalYear+'&' + PrC_field_id + '=' + PromotionCode; 
            url+=  '&CF' + PC_field_id + '=' + pccode.name+ '&CF' + PC_field_id + '_lkid=' + plan.ASI_MFM_Project_Code__c ;
            
        }
        return new pageReference(url); 
    }
    
    
     @RemoteAction
    public static String[] findSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
             System.debug('sot is null' );
        
            return null;
        }
        
        // create the filter text
        String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
        //begin building the dynamic soql query
        
        String soql = 'select id, Name from ' + obj ;
        
        if(obj=='ASI_MFM_Project_Code__c')soql+=' where ASI_MFM_Inactive__c=false AND ASI_MFM_Fiscal_Year__c= \''+qry+'\'';     //Updated by 2018-06-21 Linus@introv
        
        soql+=' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
               
        try {
            sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
               results.add(String.valueOf(sobj.get('Name'))+','+sobj.id); 
            }       
        }
        catch (QueryException e) {
            return null;
        }
        return results;
   }
        
}