public with sharing class ASI_CRM_CN_AddRSPController {

    public class Row {
        public ASI_TH_CRM_RSP__c RSP {get;set;}
        public string ItemGroupName {get;set;} 
        public integer Index {get;set;}
    }
    
    public ASI_CRM_AccountsAdditionalField__c AccountAdditional {get;set;}
    public list<Row> RSPRows {get;set;}
    public boolean CloseWindow{get;set;} 
    public string delRowIndex {get;set;}
    public string SearchText {get;set;}
    public list<ASI_MFM_Item_Group__c> SearchResults {get;set;}
    public boolean MoreResults {get;set;}
    public Id SelectedItemGroupId {get;set;}
    
    public string Msg{get;set;}
    
    public RecordType rt;
    
    public ASI_CRM_CN_AddRSPController(ApexPages.StandardController controller) {

        AccountAdditional = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();
        
        string s = ApexPages.currentPage().getParameters().get('searchText');
        if(s!=null && s!='') {
            SearchText = s;
            search();
        }
    }
    
    public void init() {
        
        if(RSPRows==null) {
            
            rt = Global_RecordTypeCache.getRtRec('ASI_TH_CRM_RSP__c'+'ASI_CRM_CN_RSP');
            
            RSPRows = new list<Row>();    
            
            AggregateResult result = [SELECT MAX(ASI_CRM_CN_Input_Date_Time__c) FROM ASI_TH_CRM_RSP__c WHERE ASI_CRM_CN_Customer__c = :AccountAdditional.Id AND RecordTypeId=:rt.Id];
            if(result.get('expr0')!=null) {
                datetime latestTime = (datetime)result.get('expr0');
                integer i = 0;
                for(ASI_TH_CRM_RSP__c prevRSP :[SELECT Id, ASI_CRM_CN_Item_Group__c, ASI_CRM_CN_Item_Group__r.Name, ASI_CRM_CN_Quantity__c, ASI_CRM_CN_RSP__c
                                                FROM ASI_TH_CRM_RSP__c
                                                WHERE ASI_CRM_CN_Customer__c =:AccountAdditional.Id AND RecordTypeId=:rt.Id AND ASI_CRM_CN_Input_Date_Time__c=:latestTime]) 
                {
                    Row r = new Row();
                    r.Index = i++;
                    r.RSP = new ASI_TH_CRM_RSP__c(
                        ASI_CRM_CN_Customer__c=AccountAdditional.Id, 
                        RecordTypeId=rt.Id,
                        ASI_CRM_CN_Item_Group__c=prevRSP.ASI_CRM_CN_Item_Group__c,
                        ASI_CRM_CN_Quantity__c=prevRSP.ASI_CRM_CN_Quantity__c,
                        ASI_CRM_CN_RSP__c=prevRSP.ASI_CRM_CN_RSP__c);
                    r.ItemGroupName = prevRSP.ASI_CRM_CN_Item_Group__r.Name;
                    RSPRows.add(r);
                }   
            }
        }
    }
    
    public PageReference addRow() {
        return Page.ASI_CRM_CN_AddRSP2Page;
    }
    
    public void delRow() {
        if(delRowIndex!=null) {
            integer index = integer.valueOf(delRowIndex);
            if(index<RSPRows.size()){
                RSPRows.remove(index);
                for(integer i=index; i<RSPRows.size(); i++)
                    RSPRows[i].Index= i;
            }
        }
    }
    
    public PageReference back(){
        return Page.ASI_CRM_CN_AddRSPPage;
    }
        
    public void search() {
        if(SearchText!=null) {
            string searchStr = '%' + SearchText + '%';
            integer count = [SELECT COUNT()
                             FROM ASI_MFM_Item_Group__c 
                             WHERE Name LIKE :searchStr AND ASI_CRM_CN_Consumer_Website__c=TRUE];
            MoreResults = count>500;
            SearchResults = [SELECT Id, Name 
                             FROM ASI_MFM_Item_Group__c 
                             WHERE Name LIKE :searchStr AND ASI_CRM_CN_Consumer_Website__c=TRUE 
                             ORDER BY Name LIMIT 500];
        }
    }
    
    public PageReference selectItemGroup() {
        
        if(SearchResults==null) return null;
        
        Row r = new Row();
        r.Index = RSPRows.size();
        r.RSP = new ASI_TH_CRM_RSP__c(
            ASI_CRM_CN_Customer__c=AccountAdditional.Id,
            RecordTypeId=rt.Id,
            ASI_CRM_CN_Item_Group__c=SelectedItemGroupId
        );
        for(ASI_MFM_Item_Group__c ig :SearchResults)
            if(ig.Id==SelectedItemGroupId)
            r.ItemGroupName = ig.Name;
        RSPRows.add(r);
        return Page.ASI_CRM_CN_AddRSPPage;
    }
    
   /*add by Stella Li*/
    public pagereference submit() {
        string errorMessage;
        Database.SaveResult insertResult;
        if(RSPRows.size()>0) {
            datetime now = datetime.Now();
        
            list<ASI_TH_CRM_RSP__c> rsps = new list<ASI_TH_CRM_RSP__c>();
            for(Row r :RSPRows) {
                r.RSP.ASI_CRM_CN_Input_Date_Time__c = now;
                insertResult = Database.insert(r.RSP,false);
                system.debug('Result.......'+insertResult.isSuccess());
            }
                if (!insertResult.isSuccess())
             {
                  errorMessage = '';             
              for(Database.Error err : insertResult.getErrors())
              {
                errorMessage += (err.getMessage() + '  ');
                system.debug(errorMessage);
              }
                            
              ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, errorMessage);
              ApexPages.addmessage(errMsg);  
              CloseWindow = true;
              system.debug(errMsg);     
             }
             else{
              CloseWindow = false;
             
            }
        
           
        }
          return null;
    }

}