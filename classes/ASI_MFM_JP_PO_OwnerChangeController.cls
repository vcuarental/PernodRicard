public without sharing class ASI_MFM_JP_PO_OwnerChangeController 
{
    List<poWrapper> poList;
    
    public String searchPOName { get; set; }
    public String newOwnerName { get; set; }
    public String searchPOOwner { get; set; }
    public User newOwner{get;set;}
    public User currentOwner{get;set;}
    
    public ASI_MFM_JP_PO_OwnerChangeController(){
        newOwner= new User();
        currentOwner= new User();
    }
    
    public void POSearch(){
        getPOs();
    }
    
    public void ResetPOSearch(){
        searchPOName='';
        searchPOOwner='';
        newOwnerName ='';
        getPOs();
    }
    
    public void POReassign(){
        String[] sa=null;
        sa=newOwnerName.split(' ');
        String revName='';
        
        if(sa!=null){
            for(Integer i =sa.size()-1;i>=0;i-- ){
                revName+=' '+sa[i];
            }
        }
        
        if(revName.length()>0)    
            revName=revName.substring(1);
           
        List<User> users=[select id from user where name= :newOwnerName or name= :revName];
        
        if(users.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'New owner not found'));
            return;
        }   
        
        List<ASI_MFM_PO__c> selectedPOs = new List<ASI_MFM_PO__c>();    
        
        for(poWrapper po : poList){
            if(po.selected == true){
                po.po.ownerid=users[0].id;
                selectedPOs.add(po.po);
            }
        }
     
        if(selectedPOs.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No selected po(s)'));
            return;
        }
        update selectedPOs;         
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Done, owner change to '+newOwnerName));
        ResetPOSearch();
    }
        
    public List<poWrapper> getPOs()
    {
        poList = new List<poWrapper>();
        String whereCondition=' where recordtype.developername in (\'ASI_MFM_JP_PO\',\'ASI_MFM_JP_PO_Read_Only\') ' ;
        if(searchPOName!=null && !searchPOName.trim().equals('')){
            whereCondition+=' and (Name like \'%'+searchPOName+'%\'';
        }else {
            whereCondition+=' and (Name=\'\'';
        }
        
        if(searchPOOwner!=null && !searchPOOwner.trim().equals('')){
            whereCondition+=' or owner.name like \'%'+searchPOOwner+'%\'';
        }
  System.debug(whereCondition);      
        List<ASI_MFM_PO__c> serchResult=
            Database.query('select id,Name, ASI_MFM_Status__c,ownerid, owner.name , ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c,ASI_MFM_PO_Amount__c,ASI_MFM_Plan__r.name from ASI_MFM_PO__c '+whereCondition+') limit 100');
        for(ASI_MFM_PO__c po : serchResult)
            poList.add(new poWrapper(po));
        return poList;
    }
/*    
    public PageReference getSelected()
    {
        selectedPOs .clear();
        for(poWrapper po : poList)
            if(po.selected == true)
                selectedPOs.add(po.po);
        return null;
    }
    
    public List<ASI_MFM_PO__c> GetSelectedPOs()
    {
        if(selectedPOs .size()>0)
            return selectedPOs ;
        else
            return null;
    }    
*/    
    public class poWrapper
    {
        public ASI_MFM_PO__c po {get; set;}
        public Boolean selected {get; set;}
        public poWrapper(ASI_MFM_PO__c p)
        {
            po = p;
            selected = false;
        }
    }
}