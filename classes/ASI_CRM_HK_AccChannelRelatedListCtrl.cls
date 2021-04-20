public class ASI_CRM_HK_AccChannelRelatedListCtrl {
    public ApexPages.StandardController standardController {get;set;}
    public Account Header {get;set;}
    private String soql {get;set;} 
    public transient List<ASI_HK_CRM_Pre_Approval_Form__c> HeaderItem{get;set;}
    public transient List<ASI_HK_CRM_Pre_Approval_Form_Item__c> LineItem{get;set;}
    public Set<Id> childAc = new Set<Id>(); //20160704, added by Leo
    
    //public List<CustomSKUMechanicDetail> CustomSKUMechanicDetailsList{ get; set; }
    //public CustomSKUMechanicDetail cmd;
    public boolean hasFOC = false;
    
    //public Map<string, List<CustomSKUMechanicDetail>> POLinesMap {set;get;}{ POLinesMap = new Map<string, List<CustomSKUMechanicDetail>>(); }
    //public String mapPOlineJSON {get{return JSON.serialize(POLinesMap);}}

    public ASI_CRM_HK_AccChannelRelatedListCtrl(ApexPages.StandardController controller){
        this.standardController = controller;
        this.Header = (Account) this.standardController.getRecord();   
        if(this.Header !=null && this.Header.Id !=null){
            for(Account outlet : [Select id, Name, ASI_HK_CRM_Customer_Code__c FROM Account where Id =: this.Header.Id limit 1]){
                this.Header = outlet;
                system.debug('----Header: '+this.Header);
            }
            //20160704, added by Leo
            List<Account> childL = new List<Account>([SELECT id FROM Account WHERE parentId =: this.Header.Id]);
            for(Account da: childL)
            {
                childAc.add(da.Id);
            }
            //20160704, added by Leo
            init(); 
        } else {system.debug('Null Header');}
    }

    public Set<id> PAFSet {set; get;}
    public void init() {

        PAFSet = new set<id>();
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCusts = [SELECT id, ASI_CRM_HK_Pre_Approval_Form__c FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Customer__c = :header.id OR ASI_CRM_HK_Customer__c IN: childAc]; //20160704, edited by Leo, add child set id
        for(ASI_CRM_HK_Pre_Approval_Form_Customer__c PAFCust :PAFCusts) {
            PAFSet.add(PAFCust.ASI_CRM_HK_Pre_Approval_Form__c);
        }
        List<ASI_HK_CRM_Pre_Approval_Form__c> PAFHead = [SELECT id FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE (ASI_HK_CRM_PAF_Customer__c = :header.id Or ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c =: header.ASI_HK_CRM_Customer_Code__c) OR ASI_HK_CRM_PAF_Customer__c IN: childAc]; //20160704, edited by Leo, add child set id
        for(ASI_HK_CRM_Pre_Approval_Form__c PAF :PAFHead) {
            PAFSet.add(PAF.id);
        }
        
        soql = 'Select ' +          
            'id, Name, ASI_HK_CRM_PAF_Raised_Date__c, ASI_HK_CRM_PAF_Status__c, ASI_HK_CRM_PAF_Customer__c, ASI_HK_CRM_PAF_Customer__r.Name, ASI_HK_CRM_PAF_Start_Date__c, ASI_HK_CRM_PAF_End_Date__c ' +
            // Arthur 20180222 Start
            ',ASI_HK_CRM_Adjusted_Start_Date__c, ASI_HK_CRM_Adjusted_End_Date__c '+
            // Arthur 20180222 End
            ',Owner.Name ' +
            ',CreatedBy.Name ' +
            ',ASI_CRM_Promotion_Category__r.Name ' +
            ',ASI_HK_CRM_Total_Investment_Value__c ' +
            ',ASI_HK_CRM_PAF_Customer__r.parentId ' +
            ',ASI_HK_CRM_PAF_Nature_of_Promotion__c '+
            'FROM ASI_HK_CRM_Pre_Approval_Form__c ' +
            'WHERE id IN :PAFSet' 
            +
            ' Order by ASI_HK_CRM_PAF_Start_Date__c DESC'
            ;
        system.debug('soql:::' + soql);
        runQuery();
        
    }
 
 
     public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                try{
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                }catch(Exception e){
                    System.debug('---------------SetCon:------'+e);
                }
            }
            setCon.setPageSize(1000);//20160823 Ben @ Elufa
            return setCon;
        }
        set;
    }


    // Initialize setCon and return a list of record    
     
    public List<ASI_HK_CRM_Pre_Approval_Form__c> getPAFHeaders() {
         return (List<ASI_HK_CRM_Pre_Approval_Form__c>) setCon.getRecords();
    }    

    public PageReference NewPAF() {
        ASI_CRM_HK_FieldIdMapping__c CustomSetting = [SELECT ASI_CRM_Object_Short__c, ASI_CRM_Customer_Field_Id__c, ASI_CRM_RecordTypeId__c FROM ASI_CRM_HK_FieldIdMapping__c WHERE Name = 'ASI_CRM_HK_NewPAFFields'];
        string headerDesc = encodingutil.urlEncode(this.Header.Name, 'UTF-8'); //20160201, added by Leo, encode string into html format
        //20160201, changed by Leo, change url sequence, id first than value
        string url='/' + CustomSetting.ASI_CRM_Object_Short__c + '/e?' + CustomSetting.ASI_CRM_Customer_Field_Id__c + '_lkid=' + Header.id + '&' + CustomSetting.ASI_CRM_Customer_Field_Id__c + '=' + headerDesc + '&Name=%5BAuto+Assign-Do+Not+Change%5D&RecordType=' + CustomSetting.ASI_CRM_RecordTypeId__c;
        PageReference pageRef = new PageReference(url);
        return pageRef;
    }
    
    public void runQuery() {
            
            HeaderItem = new  List<ASI_HK_CRM_Pre_Approval_Form__c>();
            //LineItem = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            
            HeaderItem = getPAFHeaders();  
   
    }
    
}