/********************************************************************************
* Class to make DML operations on LAT_BR_CISP_Information__c.
*
* NAME: LAT_BR_Further_Suppliers_DetailDAO.cls
* AUTHOR: Mariano Boezio                           DATE: 15/09/2014
********************************************************************************/
public with sharing class LAT_BR_CISP_InformationDAO {
    private LAT_BR_CISP_Information__c cispInfo;
    
    public LAT_BR_CISP_InformationDAO (){
        this.cispInfo = new LAT_BR_CISP_Information__c ();
    }
    
    // Setters
    public void setCreditAnalysis (String caId){
        this.cispInfo.LAT_BR_CISPI_Credit_Analisis__c = caId;
    }
    
    public void setCompany(String company){
        this.cispInfo.LAT_BR_CISPI_Company__c = company;
    }
    
    public void setCISPI(String cispi){
        this.cispInfo.LAT_BR_CISPI_CISP_Information__c = cispi;
    }
    
    public void setData(Date data){
        this.cispInfo.LAT_BR_CISPI_Date__c = data;
    }
    
    public void setGreaterAccum(Decimal GreaterAccum){
        this.cispInfo.LAT_BR_CISPI_Greater_Accumulation__c = GreaterAccum;
    }
    
    public void setLimitValue(Decimal LimitValue){
        this.cispInfo.LAT_BR_CISPI_Limit_Value__c = LimitValue;
    }
    
    public void setOrdination(Decimal Ordination){
        this.cispInfo.LAT_BR_CISPI_Ordination__c = Ordination;
    }
    
    public void setInstance(LAT_BR_CISP_Information__c dao) {
        this.cispInfo = dao;
    }
    
    // Getters
    public String getCreditAnalysis (){
        return this.cispInfo.LAT_BR_CISPI_Credit_Analisis__c;
    }
    
    public String getCompany(){
        return this.cispInfo.LAT_BR_CISPI_Company__c;
    }
    
    public String getCISPI(){
        return this.cispInfo.LAT_BR_CISPI_CISP_Information__c;
    }
    
    public Date getData(){
        return this.cispInfo.LAT_BR_CISPI_Date__c;
    }
    
    public Decimal getGreaterAccum(){
        return this.cispInfo.LAT_BR_CISPI_Greater_Accumulation__c;
    }
    
    public Decimal getLimitValue(){
        return this.cispInfo.LAT_BR_CISPI_Limit_Value__c;
    }
    
    public Decimal getOrdination(){
        return this.cispInfo.LAT_BR_CISPI_Ordination__c;
    }
    
    public LAT_BR_CISP_Information__c getInstance() {
        return this.cispInfo;
    }
    
    public static List<LAT_BR_CISP_InformationDAO> getListcispInfonalisisPerAC( String CreditAnalisisId ) {
        List<LAT_BR_CISP_InformationDAO> daoList = new List<LAT_BR_CISP_InformationDAO>(); 
        for (LAT_BR_CISP_Information__c bp:[SELECT Id,
                                                  toLabel(LAT_BR_CISPI_CISP_Information__c), 
                                                  LAT_BR_CISPI_Company__c, 
                                                  LAT_BR_CISPI_Credit_Analisis__c, 
                                                  LAT_BR_CISPI_Date__c,
                                                  LAT_BR_CISPI_Greater_Accumulation__c,
                                                  LAT_BR_CISPI_Limit_Value__c,
                                                  LAT_BR_CISPI_Ordination__c
                                                FROM LAT_BR_CISP_Information__c
                                                WHERE LAT_BR_CISPI_Credit_Analisis__c =: CreditAnalisisId]) {
           LAT_BR_CISP_InformationDAO dao = new LAT_BR_CISP_InformationDAO();
           dao.setInstance(bp);
           daoList.add(dao);
       }
       
       return daoList;
   }
   
   public static List<Schema.PicklistEntry> getPicklistCISPInfo() {
       return LAT_BR_CISP_Information__c.LAT_BR_CISPI_CISP_Information__c.getDescribe().getPickListValues();
   }
   
   // DMLs
   public static void upsertList(List<LAT_BR_CISP_InformationDAO> daoList) {
       List<LAT_BR_CISP_Information__c> cispList = new List<LAT_BR_CISP_Information__c>();
       for (LAT_BR_CISP_InformationDAO cispdao :daoList) {
           cispList.add(cispdao.getInstance());
       } 
       upsert cispList;
   }
}