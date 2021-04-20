public class ASI_eForm_KR_DonationRequest_MgtAllCtrl {
    public ASI_eForm_Donation_Request__c DonationRequest { get; set; } {DonationRequest = new ASI_eForm_Donation_Request__c();} 
    public  String DetailLineJSON {set;get;}{DetailLineJSON=null;}
    public string RecordTypeID {get;set;}
    public boolean ROEdit {set;get;} {ROEdit=true;}
    public ASI_eForm_KR_DonationRequest_MgtAllCtrl(apexpages.standardController sc) {
        String RecordId = ApexPages.currentPage().getParameters().get('id'); //sc.getId()
        this.DonationRequest=[select Id,ASI_eForm_Sales_Admin__c, ASI_eForm_Status__c,RecordType.DeveloperName from ASI_eForm_Donation_Request__c where Id = : RecordId ];
    }
    
    public pageReference init(){// ASI_eForm_KR_Donation_Request
        RecordTypeID=Global_RecordTypeCache.getRtId('ASI_eForm_Donation_Request_Line_Items__cASI_eForm_KR_Donation_Request_Line');
        if(this.DonationRequest !=null && this.DonationRequest.Id !=null){
            List<ASI_eForm_Donation_Request_Line_Items__c> DonationRequestLineList = [select Id,ASI_eForm_Donation_Request__c,ASI_eForm_Qty_Btl__c,ASI_eForm_SKU__c,ASI_eForm_SKU__r.Name,ASI_eForm_SKU__r.ASI_KOR_SKU_Name__c,ASI_eForm_SKU__r.ASI_eForm_Name_for_Donation_Request__c,ASI_eForm_SKU__r.ASI_eForm_Unit_Cost__c from ASI_eForm_Donation_Request_Line_Items__c  where ASI_eForm_Donation_Request__c =:DonationRequest.Id ];
            DetailLineJSON=JSON.serialize(DonationRequestLineList);
        }
        if(DonationRequest.RecordType.DeveloperName=='ASI_eForm_KR_Donation_Request_RO'){
            /*
            list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_eForm_KR_Donation_Handler' AND UserOrGroupId=:UserInfo.getUserId()];
            if(gms.size()>0){
                ROEdit = true;
            }else{
                ROEdit = false; 
            }
            */
            if(DonationRequest.ASI_eForm_Sales_Admin__c == UserInfo.getUserId()){
                ROEdit = true;
            }else{
                ROEdit = false; 
            }
        }
        return null;
    }
    
    public PageReference BackHeader() {
        return  new PageReference('/' + DonationRequest.Id); 
    }
    
    @RemoteAction
    public static string UpdateLineItem(List<ASI_eForm_Donation_Request_Line_Items__c> Linelist,List<string> deletelist){
        string Mesg ='Save Success !';
        set<string> DeletelineIdSet =new set<string>();
        for(string pid:deletelist){
            DeletelineIdSet.add(pid);
        }
        List<ASI_eForm_Donation_Request_Line_Items__c> DeleteLines=[select Id,Name from ASI_eForm_Donation_Request_Line_Items__c where id in : DeletelineIdSet];
        if(DeleteLines.size()>0){
            delete DeleteLines;
        }
        upsert Linelist;
        return Mesg;
    }
    
    @RemoteAction
    public static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) return null;
        String filter = qry;
        String soql='';
        if(filter != '' || filter != null)
            soql = 'select '+statement+' from ' + obj + filter +' order by Name';
        else
            soql = 'select '+statement+' from ' + obj +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        List<String> results = new List<String>();
        sobjs = Database.query(soql);
        return sobjs;
    }
    
}