/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetailPrintController
 * Description: Print call details pdf in list view
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/1/2014       Laputa: Hank            Created
*********************************************************************************/
public with sharing class ASI_CRM_JP_CallDetailPrintController{
        
    private ApexPages.StandardSetController standardController;
    public List<ASI_CRM_Call_Detail__c> detailList{get;set;}
    public ASI_CRM_Call_Plan__c header{get;set;}
    public List<GroupDetail> detailsgroup{get;set;}
    private List<String> strIds = new List<String>();

    public ASI_CRM_JP_CallDetailPrintController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        strIds = ApexPages.currentPage().getParameters().get('recs').split(',',-2);
        Map<String, Schema.SObjectField> visitingFieldMap = Schema.SObjectType.ASI_CRM_Call_Detail__c.fields.getMap();
        String theQuery = 'Select ';
        for(String fields  : visitingFieldMap.keySet()){
            theQuery += fields + ' ,';
        } 
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += ', ASI_CRM_Customer__r.ASI_CRM_CN_Address__c, ASI_CRM_Pay_To__r.Name,ASI_CRM_Pay_To__r.ASI_CRM_Account_Number__c,ASI_CRM_Tax_Routing__r.Name, ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c, ASI_CRM_Item_3__r.Name ,ASI_CRM_Item_2__r.Name, ASI_CRM_Item_1__r.Name, ASI_CRM_Activity_Sub_brand_2__r.Name, ASI_CRM_Activity_Sub_brand_3__r.Name, ASI_CRM_Activity_Sub_brand_1__r.Name, ASI_CRM_Customer__r.Name, ASI_CRM_Activity_Sub_brand_1__r.ASI_MFM_Brand__r.Name, ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.Name, ASI_CRM_Customer__r.RecordType.developername, ASI_CRM_Customer__r.ASI_CRM_VN_Channel__c, ASI_CRM_Activity_Sub_brand_1__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c  From ASI_CRM_Call_Detail__c where ID IN :strIds';
        detailList  = (List<ASI_CRM_Call_Detail__c>)Database.query(theQuery);
        
        visitingFieldMap = Schema.SObjectType.ASI_CRM_Call_Plan__c.fields.getMap();
        theQuery = 'Select ';
        for(String fields  : visitingFieldMap.keySet()){
            theQuery += fields + ' ,';
        } 
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += ', owner.name From ASI_CRM_Call_Plan__c where ID = ' + '\'' + detailList.get(0).ASI_CRM_Call_Plan__c + '\' ';
        List<ASI_CRM_Call_Plan__c> visitingList = (List<ASI_CRM_Call_Plan__c>)Database.query(theQuery); 
        if (visitingList.size() > 0){
            header = visitingList.get(0);
        }
        
        Set<Id> cusIdSet = new Set<Id>();
        for(ASI_CRM_Call_Detail__c d:detailList){
            cusIdSet.add(d.ASI_CRM_Customer__c);
        }
        List<ASI_CRM_Listing_List__c> listingList = [Select ASI_CRM_Customer__c, ASI_CRM_Item_Group__c, ASI_CRM_Reg_Volume_Monthly__c From ASI_CRM_Listing_List__c Where ASI_CRM_Customer__r.Id In :cusIdSet];
        Map<String, Integer> saleMap = new Map<String, Integer>();
        detailsgroup = new List<GroupDetail>();
        for(ASI_CRM_Listing_List__c l:listingList){
            saleMap.put(String.valueOf(l.ASI_CRM_Customer__c) + String.valueOf(l.ASI_CRM_Item_Group__c), Integer.valueOf(l.ASI_CRM_Reg_Volume_Monthly__c));
        }
        for(ASI_CRM_Call_Detail__c d:detailList){
            GroupDetail gro = new GroupDetail();
            gro.detail = d;
            gro.mthSale1 = saleMap.get(String.valueOf(d.ASI_CRM_Customer__c) + String.valueOf(d.ASI_CRM_Item_1__c));
            gro.mthSale2 = saleMap.get(String.valueOf(d.ASI_CRM_Customer__c) + String.valueOf(d.ASI_CRM_Item_2__c));
            gro.mthSale3 = saleMap.get(String.valueOf(d.ASI_CRM_Customer__c) + String.valueOf(d.ASI_CRM_Item_3__c));
            gro.totalAttendees = d.ASI_CRM_Number_of_PRJ_Sales_Attendees__c + d.ASI_CRM_Number_of_Attendees_BS__c + d.ASI_CRM_Number_of_Attendees_Other__c;
            detailsgroup.add(gro);
        }
    }
    
    public class GroupDetail{
        public ASI_CRM_Call_Detail__c detail{get;set;}
        public Decimal totalAttendees{ get;set;}
        public Integer mthSale1{get;set;}
        public Integer mthSale2{get;set;}
        public Integer mthSale3{get;set;}
    }
}