public with sharing class LAT_BR_VFC14_CustomerBehaviorController {
    
    public List<CBWrapper> cbList                                {get;set;}
    public Boolean ExportToExcel                                 {get;set;}
    public Boolean showMessage                                   {get;set;}
    public Map<String, List<LAT_BR_Customer_Behavior__c>> NameCb {get;set;}
    
    public LAT_BR_VFC14_CustomerBehaviorController (){
        this.ExportToExcel = false;
        this.init();
    }
    
    private void init() {
        this.showMessage = false;
        if (ApexPages.currentPage().getParameters().get('export') != null ) {
            this.ExportToExcel = true;
        }
        
        List<LAT_BR_Customer_Behavior__c> objList = [SELECT id, LAT_BR_Value__c, LAT_BR_Weight__c, Name
                                                        FROM LAT_BR_Customer_Behavior__c
                                                        ORDER by  Name, LAT_BR_Value__c, LAT_BR_Weight__c];
        
        this.cbList = new List<CBWrapper>();
        
        NameCb = new Map<String, List<LAT_BR_Customer_Behavior__c>>();
        for (LAT_BR_Customer_Behavior__c cb: objList) {
            if (NameCb.get(cb.Name) != null) {
                NameCb.get(cb.Name).add(cb);
            } else {
                NameCb.put(cb.Name, new List<LAT_BR_Customer_Behavior__c>{cb});
            }
            this.cbList.add(new CBWrapper(cb));
        }
        this.cbList.sort();
    }
    
    public void addBehavior() {
        this.cbList.add(new CBWrapper(new LAT_BR_Customer_Behavior__c()));
    }
    
    public void save() {
        try {
            List<LAT_BR_Customer_Behavior__c> toUpsert = new List<LAT_BR_Customer_Behavior__c>();
            this.showMessage = false;
            for (CBWrapper wrp: cbList) {
                if (wrp.cb.Name != '' 
                    && wrp.cb.LAT_BR_Value__c != null 
                    && wrp.cb.LAT_BR_Weight__c != null) {
                    wrp.cb.Name = wrp.cb.Name.normalizeSpace();
                    wrp.cb.LAT_BR_Value__c = wrp.cb.LAT_BR_Value__c.normalizeSpace();
                    toUpsert.add(wrp.cb);
                } else {
                    wrp.error = true;
                    this.showMessage = true;
                }
            } 
            upsert toUpsert;
            
        } catch (Exception e) {
            this.saveException(e);
        }
    }
    
    public void removeSelected() {
        
        List<LAT_BR_Customer_Behavior__c> toDelete = new List<LAT_BR_Customer_Behavior__c>();
        for (CBWrapper wrp: cbList) {
            if(wrp.remove && wrp.cb.id != null) {
                toDelete.add(wrp.cb);
            }
        }
        try {
            delete toDelete;
        } catch (Exception e) {
            this.saveException(e);
        }
        this.init();
    }
    
    public List<SelectOption> getComportamentos() {
        String[] Comportamentos = LAT_GeneralConfigDao.getValueAsStringArray('COMPORTAMENTO_DO_CLIENTE',',');
        List<SelectOption> options = new List<SelectOption>();
        
        for(String comp: Comportamentos){
            options.add(new SelectOption(comp, comp));
        }
        
        return options;
    }

    private void saveException(Exception e) {
        system.debug('Exception:' + e.getMessage() + 
                        ' Line: ' + e.getLineNumber() + 
                        ' Cause: ' + e.getCause()); 
        
        LAT_DebugUtil debugUtil = new LAT_DebugUtil();
        debugUtil.addData('Exception:' + e.getMessage() + 
                        ' Line: ' + e.getLineNumber() + 
                        ' Cause: ' + e.getCause());
        debugUtil.setOrigin('LAT_BR_VFC14_CustomerBehaviorController');
        debugUtil.insertDebug();
    }
    
    public class CBWrapper implements Comparable{
        public LAT_BR_Customer_Behavior__c cb      {get;set;}
        public Integer valueNumber                 {get;set;}
        public Boolean remove                      {get;set;}
        public Boolean error                       {get;set;}

        public Integer compareTo(Object o) {
            CBWrapper wrapper = (CBWrapper)o;
            if (this.cb.Name == wrapper.cb.Name) {
                return valueNumber - wrapper.valueNumber;
            } else {
                return 0;
            }
        }
        
        public CBWrapper(LAT_BR_Customer_Behavior__c cb){
            this.cb = cb;  
            this.valueNumber = cb.LAT_BR_Value__c != null && cb.LAT_BR_Value__c.isNumeric() ? Integer.valueOf(cb.LAT_BR_Value__c) : 0;
            this.remove = false;
            this.error = false;
        }
    }
}