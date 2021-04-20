/********************************************************************************
* Class to make DML operations on LAT_BR_Sales_Prediction__c.
*
* NAME: LAT_BR_SalesPredictionDAO.cls
* AUTHOR: Mariano Boezio                           DATE: 15/09/2014
********************************************************************************/
public with sharing class LAT_BR_SalesPredictionDAO {
    private LAT_BR_Sales_Prediction__c salesPrediction;
    
    public LAT_BR_SalesPredictionDAO(){
        this.salesPrediction = new LAT_BR_Sales_Prediction__c();
    }
    
    // Seters
    public void setCA(Decimal ca) {
        this.salesPrediction.LAT_BR_SP_CA__c = ca;
    }
    
    public void setCreditAnalisis (String caID) {
        this.salesPrediction.LAT_BR_SP_Credit_Analisis__c = caID;
    }
    
    public void setPreviousFY (Boolean PreviousFY) {
        this.salesPrediction.LAT_BR_SP_Previous_FY__c = PreviousFY;
    }
    
    public void setPrice (Decimal price) {
        this.salesPrediction.LAT_BR_SP_Price__c = price;
    }
    
    public void setSKU (String SKU) {
        this.salesPrediction.LAT_BR_SP_SKU__c = SKU;
    }
    
    public void setInstance (LAT_BR_Sales_Prediction__c sp) {
        this.salesPrediction = sp;
    }
    
    // Geters
    public Decimal getCA() {
        return this.salesPrediction.LAT_BR_SP_CA__c;
    }
    
    public String getCreditAnalisis () {
        return this.salesPrediction.LAT_BR_SP_Credit_Analisis__c;
    }
    
    public Boolean getPreviousFY () {
        return this.salesPrediction.LAT_BR_SP_Previous_FY__c;
    }
    
    public Decimal getPrice () {
        return this.salesPrediction.LAT_BR_SP_Price__c;
    }
    
    public String getSKU () {
        return this.salesPrediction.LAT_BR_SP_SKU__c;
    }
    
    public LAT_BR_Sales_Prediction__c getInstance() {
        return this.salesPrediction;
    }
    
    public static List<LAT_BR_SalesPredictionDAO> getListSalesPredictionPerAC( String CreditAnalisisId ) {
        List<LAT_BR_SalesPredictionDAO> daoList = new List<LAT_BR_SalesPredictionDAO>(); 
        for (LAT_BR_Sales_Prediction__c sp:[SELECT Id,
                                                  LAT_BR_SP_CA__c, 
                                                  LAT_BR_SP_Credit_Analisis__c, 
                                                  LAT_BR_SP_Previous_FY__c, 
                                                  LAT_BR_SP_Price__c,
                                                  LAT_BR_SP_SKU__c
                                                FROM LAT_BR_Sales_Prediction__c 
                                                WHERE LAT_BR_SP_Credit_Analisis__c =: CreditAnalisisId]) {
           LAT_BR_SalesPredictionDAO dao = new LAT_BR_SalesPredictionDAO();
           dao.setInstance(sp);
           daoList.add(dao);
       }
       
       return daoList;
   }
   
   public static List<Schema.PicklistEntry> getPicklistSKU() {
       return LAT_BR_Sales_Prediction__c.LAT_BR_SP_SKU__c.getDescribe().getPickListValues();
   }
   
   //DMLS
   public static void upsertList(List<LAT_BR_SalesPredictionDAO> daoList) {
       List<LAT_BR_Sales_Prediction__c> spList = new List<LAT_BR_Sales_Prediction__c>();
       for (LAT_BR_SalesPredictionDAO spdao :daoList) {
           spList.add(spdao.getInstance());
       } 
       upsert spList;
   }

   public static void deleteDAO(LAT_BR_SalesPredictionDAO dao) {
      if (dao.getInstance().id != null) {
        delete dao.getInstance();
      }
   }
}