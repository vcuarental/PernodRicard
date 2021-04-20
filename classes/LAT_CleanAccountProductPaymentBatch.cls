/**********************************************
 Company: ValueNet 
 Dev: Juan Pablo Cubo       Version: 1
 Modified by: Elena J. Schwarzböck
**********************************************/

global class LAT_CleanAccountProductPaymentBatch implements Database.Batchable<sObject>,Database.Stateful {

    public Id idCAPP {get; set;}
    public string timeStamp {get; set;}
    public string country {get; set;}

    global Database.QueryLocator start(Database.BatchableContext BC){
        if(timeStamp == null || country == null){
            System.abortJob(BC.getJobId());
        } 
        string query = 'SELECT Id FROM LAT_Account_product_payment__c '; 
               query += 'WHERE TimeStamp__c !=: timeStamp '; 
               query += 'AND ExternalUniqueKey__c LIKE \'' + country + '-%\'';
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        List <LAT_Account_product_payment__c> appsDelete = new List <LAT_Account_product_payment__c>();
        for (sObject s : scope) {
            appsDelete.add((LAT_Account_product_payment__c)s);
        }
        delete appsDelete;
    }

    global void finish(Database.BatchableContext BC){
        LAT_Clean_Account_Product_Payment__c CAPP_record = [SELECT Id, LAT_Status__c, LAT_ApexJobId__c
                                                            FROM LAT_Clean_Account_Product_Payment__c WHERE Id =: idCAPP];
        CAPP_record.LAT_Status__c = 'Completed';
        CAPP_record.LAT_ApexJobId__c = BC.getJobId();
        try{update CAPP_record;}catch(exception e){}  
    }
    
}