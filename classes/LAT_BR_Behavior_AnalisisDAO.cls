/********************************************************************************
* Class to make DML operations on LAT_BR_Behavior_Analisis__c.
*
* NAME: LAT_BR_Behavior_AnalisisDAO.cls
* AUTHOR: Mariano Boezio                           DATE: 15/09/2014
********************************************************************************/
public with sharing class LAT_BR_Behavior_AnalisisDAO {
    private LAT_BR_Behavior_Analisis__c behaviorA;
    
    public LAT_BR_Behavior_AnalisisDAO (){
        this.behaviorA = new LAT_BR_Behavior_Analisis__c();
    }
    
    // Setters
    public void setCreditAnalysis (String caId){
        this.behaviorA.LAT_BR_BA_Credit_Analysis__c = caId;
    }
    
    public void setCustomerBehavior(String CustomerBehavior){
        this.behaviorA.LAT_BR_BA_Customer_Behavior__c = CustomerBehavior;
    }
    
    public void setValue(String value){
        this.behaviorA.LAT_BR_BA_Value__c = value;
    }
    
    public void setWeight(Decimal Weight){
        this.behaviorA.LAT_BR_BA_Weight__c = weight;
    }
    
    public void setInstance(LAT_BR_Behavior_Analisis__c dao) {
        this.behaviorA = dao;
    }
    
    // Getters
    public String getCreditAnalysis (){
        return this.behaviorA.LAT_BR_BA_Credit_Analysis__c;
    }
    
    public String getCustomerBehavior(){
        return this.behaviorA.LAT_BR_BA_Customer_Behavior__c;
    }
    
    public String getValue(){
        return this.behaviorA.LAT_BR_BA_Value__c;
    }
    
    public Decimal getWeight(){
        return this.behaviorA.LAT_BR_BA_Weight__c;
    }
    
    public LAT_BR_Behavior_Analisis__c getInstance(){
        return this.behaviorA;
    }
    
    public static Map<String, LAT_BR_Behavior_AnalisisDAO> getListBehaviorAnalisisPerACPerBehavior ( String CreditAnalisisId ) {
        Map<String, LAT_BR_Behavior_AnalisisDAO> daoList = new Map<String, LAT_BR_Behavior_AnalisisDAO>(); 
        for (LAT_BR_Behavior_Analisis__c bp:[SELECT Id,
                                                  LAT_BR_BA_Credit_Analysis__c, 
                                                  LAT_BR_BA_Value__c, 
                                                  LAT_BR_BA_Weight__c, 
                                                  LAT_BR_BA_Customer_Behavior__c
                                                FROM LAT_BR_Behavior_Analisis__c
                                                WHERE LAT_BR_BA_Credit_Analysis__c =: CreditAnalisisId]) {
           LAT_BR_Behavior_AnalisisDAO dao = new LAT_BR_Behavior_AnalisisDAO();
           dao.setInstance(bp);
           daoList.put(bp.LAT_BR_BA_Customer_Behavior__c, dao);
       }
       
       return daoList;
   }
   
   // DMLs
   public static void upsertList(List<LAT_BR_Behavior_AnalisisDAO> daoList) {
       List<LAT_BR_Behavior_Analisis__c> baList = new List<LAT_BR_Behavior_Analisis__c>();
       for (LAT_BR_Behavior_AnalisisDAO badao :daoList) {
           baList.add(badao.getInstance());
       } 
       upsert baList;
   }
}