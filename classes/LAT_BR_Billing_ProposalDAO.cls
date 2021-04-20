/********************************************************************************
* Class to make DML operations on LAT_BR_Billing_Proposal__c.
*
* NAME: LAT_BR_Billing_ProposalDAO.cls
* AUTHOR: Mariano Boezio                           DATE: 15/09/2014
********************************************************************************/
public with sharing class LAT_BR_Billing_ProposalDAO {
    private LAT_BR_Billing_Proposal__c billingProposal;
    
    public LAT_BR_Billing_ProposalDAO(){
        this.billingProposal = new LAT_BR_Billing_Proposal__c();
    }
    
    // Setters
    public void setCreditAnalysis (String caId){
        this.billingProposal.LAT_BR_BP_Credit_Analisis__c = caId;
    }
    
    public void setPreviousFY(Boolean value){
        this.billingProposal.LAT_BR_BP_Previous_FY__c = value;
    }
    
    public void setQuarter(String quarter){
        this.billingProposal.LAT_BR_BP_Quarter__c = quarter;
    }
    
    public void setValue(Decimal value){
        this.billingProposal.LAT_BR_BP_Value__c = value;
    }
    
    public void setFY(Decimal value){
        this.billingProposal.LAT_BR_BP_FY__c = value;
    }
    
    public void setInstance(LAT_BR_Billing_Proposal__c dao) {
        this.billingProposal = dao;
    }
    
    // Getters
    public String getCreditAnalysis (){
        return this.billingProposal.LAT_BR_BP_Credit_Analisis__c;
    }
    
    public Boolean getPreviousFY(){
        return this.billingProposal.LAT_BR_BP_Previous_FY__c;
    }
    
    public String getQuarter(){
        return this.billingProposal.LAT_BR_BP_Quarter__c;
    }
    
    public Decimal getValue(){
        return this.billingProposal.LAT_BR_BP_Value__c;
    }
    
    public Decimal getFY(){
        return this.billingProposal.LAT_BR_BP_FY__c;
    }
    
    public LAT_BR_Billing_Proposal__c getInstance(){
        return this.billingProposal;
    }
    
    public static List<LAT_BR_Billing_ProposalDAO> getListBillingProposalPerAC( String CreditAnalisisId ) {
        List<LAT_BR_Billing_ProposalDAO> daoList = new List<LAT_BR_Billing_ProposalDAO>(); 
        for (LAT_BR_Billing_Proposal__c bp:[SELECT Id,
                                                  LAT_BR_BP_Credit_Analisis__c, 
                                                  LAT_BR_BP_Previous_FY__c, 
                                                  toLabel(LAT_BR_BP_Quarter__c), 
                                                  LAT_BR_BP_Value__c,
                                                  LAT_BR_BP_FY__c
                                                FROM LAT_BR_Billing_Proposal__c
                                                WHERE LAT_BR_BP_Credit_Analisis__c =: CreditAnalisisId]) {
           LAT_BR_Billing_ProposalDAO dao = new LAT_BR_Billing_ProposalDAO();
           dao.setInstance(bp);
           daoList.add(dao);
       }
       
       return daoList;
   }
   
   public static List<Schema.PicklistEntry> getPicklistQuarter() {
       return LAT_BR_Billing_Proposal__c.LAT_BR_BP_Quarter__c.getDescribe().getPickListValues();
   }
   
   // DMLs
   public static void upsertList(List<LAT_BR_Billing_ProposalDAO> daoList) {
       List<LAT_BR_Billing_Proposal__c> bpList = new List<LAT_BR_Billing_Proposal__c>();
       for (LAT_BR_Billing_ProposalDAO spdao :daoList) {
           bpList.add(spdao.getInstance());
       } 
       upsert bpList;
   }
}