/*********************************************************************************
* Name: ASI_MFM_CN_SCPayment_PDFController
* Description: Controller class for Structure Cost Payment PDF 
* Related PDF : ASI_MFM_CN_SCPayment_PDFPage 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 31/03/2017       Tony Ren                 Created          
*/

public with sharing class ASI_MFM_CN_RentalApprovalPDFController {
    private final static Map<String, Schema.SObjectField> RentalRequest_FIELD_MAP = Schema.SObjectType.ASI_MFM_Rental_Request__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> RentalRequestDetail_FIELD_MAP = Schema.SObjectType.ASI_MFM_Rental_Request_Line__c.fields.getMap();
    
    Public transient Double totalAmountSum {Get; Set;}{totalAmountSum = 0;}
    Public transient Double totalCAPEXSum {Get; Set;}{totalCAPEXSum = 0;}
    Public transient Double totalOPEXSum {Get; Set;}{totalOPEXSum = 0;}
    
    public id HeaderID {set;get;}
    Public ASI_MFM_Rental_Request__c rentalRequest {Get; Set;}
    
    Public List<ASI_MFM_Rental_Request_Line__c> rentalLine { Get; Set;}{rentalLine = new List<ASI_MFM_Rental_Request_Line__c>();}
    Public List<ASI_MFM_Rental_Request_Line__c> contractLine { Get; Set;}{contractLine = new List<ASI_MFM_Rental_Request_Line__c>();}
    Public Map<id, List<ASI_MFM_Rental_Request_Line__c>> mapContractDetails { Get; Set;}{mapContractDetails = new Map<id, List<ASI_MFM_Rental_Request_Line__c>>();}
    
    public ASI_MFM_CN_RentalApprovalPDFController(){}
    
    
    Public ASI_MFM_CN_RentalApprovalPDFController(ApexPages.StandardController controller){
        this.rentalRequest = (ASI_MFM_Rental_Request__c)controller.getRecord();
    }
    
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public boolean init(){
        rentalRequest=RetrieveRentalRequestInfo(HeaderID);  //rentalLine=RetrieveRentalRequestDetailsInfo(HeaderID);
        
        if(rentalRequest.ASI_MFM_Leasing_Rate_Proposal__c != null && rentalRequest.ASI_MFM_Leasing_Rate_Proposal__c.length() > 20){
            rentalRequest.ASI_MFM_Leasing_Rate_Proposal__c = ASI_MFM_CN_StructureCostHelperClass.splitString(rentalRequest.ASI_MFM_Leasing_Rate_Proposal__c, 20);
        }
        
        if(rentalRequest.ASI_MFM_Current_Leasing_Renovation__c!=null && rentalRequest.ASI_MFM_Current_Leasing_Renovation__c.length() > 20){
            rentalRequest.ASI_MFM_Current_Leasing_Renovation__c = ASI_MFM_CN_StructureCostHelperClass.splitString(rentalRequest.ASI_MFM_Current_Leasing_Renovation__c, 20);
        }
        
        if(rentalRequest.ASI_MFM_Building_Name_1__c != Null && rentalRequest.ASI_MFM_Building_Name_1__c.length() > 10){
            
            rentalRequest.ASI_MFM_Building_Name_1__c = ASI_MFM_CN_StructureCostHelperClass.splitString(rentalRequest.ASI_MFM_Building_Name_1__c, 10);
        }
        
        if(rentalRequest.ASI_MFM_Building_Name_2__c != Null && rentalRequest.ASI_MFM_Building_Name_2__c.length() > 10){
            
            rentalRequest.ASI_MFM_Building_Name_2__c = ASI_MFM_CN_StructureCostHelperClass.splitString(rentalRequest.ASI_MFM_Building_Name_2__c, 10);
        }
        
        if(rentalRequest.ASI_MFM_Building_Name_3__c != Null && rentalRequest.ASI_MFM_Building_Name_3__c.length() > 10){
            
            rentalRequest.ASI_MFM_Building_Name_3__c = ASI_MFM_CN_StructureCostHelperClass.splitString(rentalRequest.ASI_MFM_Building_Name_3__c, 10);
        }
        
        rentalLine = new List<ASI_MFM_Rental_Request_Line__c>();
        contractLine = new List<ASI_MFM_Rental_Request_Line__c>();
        mapContractDetails = new Map<id, List<ASI_MFM_Rental_Request_Line__c>>();
        
        for(ASI_MFM_Rental_Request_Line__c obj : [SELECT id
                                                  , ASI_MFM_Renovation_Item__c
                                                  , ASI_MFM_Renovation_Space__c
                                                  , ASI_MFM_Market_benchmark_RMB__c
                                                  , ASI_MFM_Market_investigationProposalRMB__c
                                                  , ASI_MFM_Total_Amount__c
                                                  , ASI_MFM_CAPEX_Budget__c
                                                  , ASI_MFM_OPEX_Budget__c
                                                  , ASI_MFM_Remarks__c
                                                  , ASI_MFM_Amount_Per_Month__c
                                                  , ASI_MFM_Completion__c
                                                  , ASI_MFM_CIP_Amount__c
                                                  , ASI_MFM_Contract__c
                                                  , ASI_MFM_Detail__c
                                                  , ASI_MFM_ETL__c
                                                  , ASI_MFM_ExpenseType__r.Name
                                                  , ASI_MFM_Paid_Amount__c
                                                  , ASI_MFM_Period_From__c
                                                  , ASI_MFM_Period_To__c
                                                  , ASI_MFM_Rental_Request__c
                                                  , ASI_MFM_Rental_Request_Line__c
                                                  , ASI_MFM_Tax_Code__r.Name
                                                  , RecordType.developerName
                                                  FROM ASI_MFM_Rental_Request_Line__c
                                                  WHERE ASI_MFM_Rental_Request__c = : HeaderID
                                                  AND (RecordType.developerName Like 'ASI_MFM_CN_Rental_Item'
                                                       OR RecordType.developerName Like 'ASI_MFM_CN_Rental_Contract_Line')
                                                 ]){
                                                     
                                                     //20170721 Introv
                                                     if(obj.ASI_MFM_Contract__c != Null && obj.ASI_MFM_Contract__c != '' && obj.ASI_MFM_Contract__c.length() > 10)
                                                         obj.ASI_MFM_Contract__c = ASI_MFM_CN_StructureCostHelperClass.splitString(obj.ASI_MFM_Contract__c, 10);
                                                     
                                                     if(obj.RecordType.developerName == 'ASI_MFM_CN_Rental_Item'){
                                                         rentalLine.add(obj);
                                                     }else if(obj.RecordType.developerName == 'ASI_MFM_CN_Rental_Contract_Line' && !obj.ASI_MFM_Detail__c){
                                                         
                                                         List<ASI_MFM_Rental_Request_Line__c> tmp = new List<ASI_MFM_Rental_Request_Line__c>();
                                                         
                                                         contractLine.add(obj);
                                                         mapContractDetails.put(obj.id, tmp);
                                                         
                                                     }else if(obj.RecordType.developerName == 'ASI_MFM_CN_Rental_Contract_Line' && obj.ASI_MFM_Detail__c){
                                                         
                                                         List<ASI_MFM_Rental_Request_Line__c> tmp = new List<ASI_MFM_Rental_Request_Line__c>();
                                                         
                                                         if(mapContractDetails.containsKey(obj.ASI_MFM_Rental_Request_Line__c)){
                                                             tmp = mapContractDetails.get(obj.ASI_MFM_Rental_Request_Line__c);
                                                         }
                                                         
                                                         tmp.add(obj);
                                                         
                                                         mapContractDetails.put(obj.ASI_MFM_Rental_Request_Line__c, tmp);
                                                     }
                                                 }
        
        for(ASI_MFM_Rental_Request_Line__c obj : rentalLine){
            
            
            if(obj.ASI_MFM_Total_Amount__c != Null)
                totalAmountSum += obj.ASI_MFM_Total_Amount__c;
            if(obj.ASI_MFM_CAPEX_Budget__c != Null)
                totalCAPEXSum += obj.ASI_MFM_CAPEX_Budget__c;
            if(obj.ASI_MFM_OPEX_Budget__c != Null)
                totalOPEXSum += obj.ASI_MFM_OPEX_Budget__c;
        }
        return true;
    }
    
    private ASI_MFM_Rental_Request__c RetrieveRentalRequestInfo(String HeaderId) {
        String query = 'SELECT ' + genQueryField(RentalRequest_FIELD_MAP) + 
            ' , Owner.Name, RecordType.DeveloperName,RecordType.Name, ASI_MFM_Related_Kickoff_Form_ID__r.Name, ASI_MFM_City__r.Name ' +
            ' FROM ASI_MFM_Rental_Request__c ' + ' Where Id = \''+HeaderId+'\' ';
      //system.assertEquals(expected, query);
        List<ASI_MFM_Rental_Request__c> RentalRequestList = (List<ASI_MFM_Rental_Request__c>) Database.query(query);
        return RentalRequestList.size() > 0 ? RentalRequestList.get(0) : null;
    }
    
     
    /*private List<ASI_MFM_Rental_Request_Line__c>  RetrieveRentalRequestDetailsInfo(String HeaderId) {
        String query = 'SELECT ' + genQueryField(RentalRequestDetail_FIELD_MAP) + 
            ', RecordType.DeveloperName,RecordType.Name ' + 
            ' FROM ASI_MFM_Rental_Request_Line__c ' + 
            ' Where ASI_MFM_Rental_Request__c = \''+HeaderId+'\'';
        List<ASI_MFM_Rental_Request_Line__c> RentalRequestLineList = (List<ASI_MFM_Rental_Request_Line__c>) Database.query(query);
        return RentalRequestLineList.size() > 0 ? RentalRequestLineList : null;
    }*/
    
    
    
       /***************  * *  Tools Function    ***************/
 
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
    
}