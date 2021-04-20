public without sharing class ASI_TnE_KR_spendTableController
{
    public List<ASI_TnE_ClaimHeader__c> relatedHeaders {get; set;}
    
    public Class interimData{
        public ASI_TnE_ClaimHeader__c hea {get; set;}
    }
    
    public List<interimData> results {get; set;}
    public Decimal curActSpending {get; set;}
    
    public Boolean display {get; set;} 
    
    public ASI_TnE_KR_spendTableController(ApexPages.StandardController controller)
    {
        Set<ID>headerIDSet = new Set<ID>();
        ASI_TnE_ClaimHeader__c curHeader = (ASI_TnE_ClaimHeader__c) controller.getRecord();
        //get current header info
        ASI_TnE_ClaimHeader__c curHeaderInfo 
            = new List<ASI_TnE_ClaimHeader__c>([SELECT Id, Name,
                                                ASI_TnE_KR_Payee__r.Id,
                                                ASI_TnE_KR_GL_Date__c,
                                                ASI_TnE_KR_YTD_Spending__c
                                                FROM ASI_TnE_ClaimHeader__c
                                                WHERE Id =: curHeader.Id])[0];
        //get GL month, year, and current header actual spending
        Integer month = curHeaderInfo.ASI_TnE_KR_GL_Date__c.month();
        Integer year = curHeaderInfo.ASI_TnE_KR_GL_Date__c.year();
        curActSpending = curHeaderInfo.ASI_TnE_KR_YTD_Spending__c;
        
        //get all related header which belongs to current header payee, filter by GL month,year record type
        relatedHeaders = [SELECT Id, Name,
                          Owner.Name, 
                          ASI_TnE_Status__c,
                          ASI_TnE_KR_Payee__r.Name,
                          ASI_TnE_KR_YTD_Budget__c,
                          ASI_TnE_KR_YTD_Spending__c,
                          ASI_TnE_KR_GL_Date__c, 
                          LastModifiedDate
                          FROM ASI_TnE_ClaimHeader__c 
                          WHERE ASI_TnE_KR_Payee__c =: curHeaderInfo.ASI_TnE_KR_Payee__r.Id
                          AND (RecordType.DeveloperName = 'ASI_TnE_KR_TnE' 
                               OR RecordType.DeveloperName = 'ASI_TnE_KR_TnE_Finance_View' 
                               OR RecordType.DeveloperName = 'ASI_TnE_KR_Cash' 
                               OR RecordType.DeveloperName = 'ASI_TnE_KR_Cash_Finance_View')
                          AND CALENDAR_MONTH(ASI_TnE_KR_GL_Date__c) =: month 
                          AND CALENDAR_YEAR(ASI_TnE_KR_GL_Date__c) =: year
                          AND Id !=: curHeaderInfo.Id
                          ORDER BY LastModifiedDate DESC];
        
        //this will display in page
        results = new List<interimData>();
        for(ASI_TnE_ClaimHeader__c header:relatedHeaders){
            interimData temp = new interimData();
            temp.hea=header;
            results.add(temp);
        }
        if(results.size()>0){
            display=true;
        }else{
            display=false;
        }
    }
}