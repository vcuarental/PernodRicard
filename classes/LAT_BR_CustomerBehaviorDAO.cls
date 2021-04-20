/********************************************************************************
* Class to make DML operations on LAT_BR_Customer_Behavior__c.
*
* NAME: LAT_BR_CustomerBehaviorDAO.cls
* AUTHOR: Mariano Boezio                           DATE: 16/09/2014
********************************************************************************/
public with sharing class LAT_BR_CustomerBehaviorDAO {
    private LAT_BR_Customer_Behavior__c behavior;
    
    public LAT_BR_CustomerBehaviorDAO (){
        this.behavior = new LAT_BR_Customer_Behavior__c ();
    }
    
    // Setters
    public void setName(String name){
        this.behavior.Name = name;
    }
    
    public void setValue(String value){
        this.behavior.LAT_BR_Value__c = value;
    }
    
    public void setWeight(Decimal Weight){
        this.behavior.LAT_BR_Weight__c = weight;
    }
    
    public void setInstance(LAT_BR_Customer_Behavior__c dao) {
        this.behavior = dao;
    }
    
    // Getters
    public String getName(){
        return this.behavior.Name;
    }
    
    public String getValue(){
        return this.behavior.LAT_BR_Value__c;
    }
    
    public Decimal getWeight(){
        return this.behavior.LAT_BR_Weight__c;
    }
    
    public LAT_BR_Customer_Behavior__c getInstance(){
        return this.behavior;
    }
    
    public static Map<String, List<SelectOption>> getCustomerBehaviors() {
        List<LAT_BR_Customer_Behavior__c> cbList = [SELECT id,
                                                          Name,
                                                          LAT_BR_Value__c,
                                                          LAT_BR_Weight__c
                                                    FROM LAT_BR_Customer_Behavior__c 
                                                    ORDER BY Name, LAT_BR_Value__c, LAT_BR_Weight__c DESC];
        Map<String, List<SelectOption>> behaviorMap = new Map<String, List<SelectOption>>();
        Map<String, List<tempWraper>> TempMap = new Map<String, List<tempWraper>>();
        for(LAT_BR_Customer_Behavior__c cb: cbList) {
            SelectOption so = new SelectOption(String.valueOf(cb.LAT_BR_Weight__c), cb.LAT_BR_Value__c);
            /*if(behaviorMap.get(cb.Name) != null) {
                behaviorMap.get(cb.Name).add(so);
            } else {
                Map<String, Decimal> valuesMap = new Map<String, Decimal>();
                behaviorMap.put(cb.Name, new List<SelectOption> {new SelectOption('', ''),so});
            }*/

            if (TempMap.get(cb.Name) != null) {
                TempMap.get(cb.Name).add(new tempWraper(so));
            } else {
                TempMap.put(cb.Name, new List<tempWraper> {new tempWraper(so)});
            }
        }

        for (String cbName: TempMap.keySet()) {
            TempMap.get(cbName).sort();
        }

        for (String cbName: TempMap.keySet()) {
          List<SelectOption> soList = new List<SelectOption>{new SelectOption('', '')};
          for (tempWraper tw: TempMap.get(cbName)) {
              soList.add(tw.so);
          }
          behaviorMap.put(cbName, soList);
        }

        return behaviorMap;
   }
   
   // DMLs
   public static void upsertList(List<LAT_BR_CustomerBehaviorDAO> daoList) {
       List<LAT_BR_Customer_Behavior__c> bpList = new List<LAT_BR_Customer_Behavior__c>();
       for (LAT_BR_CustomerBehaviorDAO spdao :daoList) {
           bpList.add(spdao.getInstance());
       } 
       upsert bpList;
   }

   public class tempWraper implements Comparable {

        public Integer valueNumber {get;Set;}
        public SelectOption so    {get;Set;}
        
        public Integer compareTo(Object o) {
            tempWraper wrapper = (tempWraper)o;
            return valueNumber - wrapper.valueNumber;
        }
        
        public tempWraper(SelectOption so){
            this.so = so;
            this.valueNumber = so.getLabel().isNumeric() ? Integer.valueOf(so.getLabel()) : 0;
        }
    }

}