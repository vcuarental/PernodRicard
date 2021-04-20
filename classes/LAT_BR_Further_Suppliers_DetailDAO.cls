/********************************************************************************
* Class to make DML operations on LAT_BR_Further_Suppliers_Detail__c.
*
* NAME: LAT_BR_Further_Suppliers_DetailDAO.cls
* AUTHOR: Mariano Boezio                           DATE: 15/09/2014
********************************************************************************/
public with sharing class LAT_BR_Further_Suppliers_DetailDAO {
    private LAT_BR_Further_Suppliers_Detail__c supliersDetail;
    
    public LAT_BR_Further_Suppliers_DetailDAO  (){
        this.supliersDetail = new LAT_BR_Further_Suppliers_Detail__c ();
    }
    
    // Setters
    public void setCreditAnalysis (String caId){
        this.supliersDetail.LAT_BR_FSD_Credit_Analisis__c = caId;
    }
    
    public void setAssociate(Boolean associate){
        this.supliersDetail.LAT_BR_FSD_Associate__c = associate;
    }
    
    public void setAssocName(String assocName){
        this.supliersDetail.LAT_BR_FSD_Associate_Name__c = assocName;
    }
    
    public void setCreditLimit(Decimal creditLimit){
        this.supliersDetail.LAT_BR_FSD_Credit_Limit__c = creditLimit;
    }
    
    public void setCurrentDebit(Decimal currentDebit){
        this.supliersDetail.LAT_BR_FSD_Current_Debit__c = currentDebit;
    }
    
    public void setHigherAccumulation(Decimal accum){
        this.supliersDetail.LAT_BR_FSD_Higher_Accumulation__c = accum;
    }
    
    public void setInstance(LAT_BR_Further_Suppliers_Detail__c dao) {
        this.supliersDetail= dao;
    }
    
    // Getters
    public String getCreditAnalysis (){
        return this.supliersDetail.LAT_BR_FSD_Credit_Analisis__c ;
    }
    
    public Boolean getAssociate(){
        return this.supliersDetail.LAT_BR_FSD_Associate__c;
    }
    
    public String getAssocName(){
        return this.supliersDetail.LAT_BR_FSD_Associate_Name__c;
    }
    
    public Decimal getCreditLimit(){
        return this.supliersDetail.LAT_BR_FSD_Credit_Limit__c;
    }
    
    public Decimal getCurrentDebit(){
        return this.supliersDetail.LAT_BR_FSD_Current_Debit__c;
    }
    
    public Decimal getHigherAccumulation(){
        return this.supliersDetail.LAT_BR_FSD_Higher_Accumulation__c;
    }
    
    public LAT_BR_Further_Suppliers_Detail__c getInstance() {
        return this.supliersDetail;
    }
    
    public static List<LAT_BR_Further_Suppliers_DetailDAO > getListsupliersDetailnalisisPerAC( String CreditAnalisisId ) {
        List<LAT_BR_Further_Suppliers_DetailDAO > daoList = new List<LAT_BR_Further_Suppliers_DetailDAO >(); 
        for (LAT_BR_Further_Suppliers_Detail__c bp:[SELECT Id,
                                                  LAT_BR_FSD_Associate__c, 
                                                  LAT_BR_FSD_Associate_Name__c, 
                                                  LAT_BR_FSD_Credit_Analisis__c, 
                                                  LAT_BR_FSD_Credit_Limit__c,
                                                  LAT_BR_FSD_Current_Debit__c,
                                                  LAT_BR_FSD_Higher_Accumulation__c
                                                FROM LAT_BR_Further_Suppliers_Detail__c
                                                WHERE LAT_BR_FSD_Credit_Analisis__c =: CreditAnalisisId]) {
           LAT_BR_Further_Suppliers_DetailDAO  dao = new LAT_BR_Further_Suppliers_DetailDAO ();
           dao.setInstance(bp);
           daoList.add(dao);
       }
       
       return daoList;
   }
   
   // DMLs
   public static void upsertList(List<LAT_BR_Further_Suppliers_DetailDAO > daoList) {
       List<LAT_BR_Further_Suppliers_Detail__c> fsdList = new List<LAT_BR_Further_Suppliers_Detail__c>();
       for (LAT_BR_Further_Suppliers_DetailDAO  fsdpdao :daoList) {
           fsdList.add(fsdpdao.getInstance());
       } 
       upsert fsdList;
   }
}