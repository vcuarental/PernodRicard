public abstract class EUR_CRM_AbstractSelectionItem{
    public Set<Id> existingIds {get;set;}
    public Map<Id,SObject> itemMap {get;set;}
    public abstract void add();
    public EUR_CRM_AbstractSelectionItem sCon {get;set;}
    public EUR_CRM_AbstractSelectionItem(){ 
        existingIds = new Set<Id>(); 
    }
}