/*********************************************************************************
 * Name: ASI_CRM_TH_MarketVisitPageCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/04/2016       Introv: Kevani Chow        
*********************************************************************************/
public without sharing class ASI_CRM_TH_MarketVisitPageCtrl{

public String strMVID { get; set; }

public String CurrentPage { get; set; }
public ASI_CRM_Market_Visit__c MarketVisit {get; set;}
Public Date VisitDate {get; set;}
Public List<ASI_CRM_Market_Visit__c> MarketVisitDetail{get; set;}
Public Id idAcc {get;set;}
Public Id idMv {get;set;}
Public List < ASI_CRM_Account_Group__c > acc {get;set;}
Public ASI_CRM_Account_Group__c objacc {get;set;}
Public String AccName {get;set;}
Public ASI_CRM_Market_Visit__c objmv {get;set;}
Public String BranchName {get;set;}
Public Id smRecordTypeId ;

//For Save
public Boolean isQuickSave {get;set;}

//For Initial
public Boolean init {get;set;}
public Integer initIndex {get;set;}

public String theRow {get; set;}
public Boolean repeatRow {get;set;}
public List<Integer> lstaddRows;

public List<SalesMovement> SalesMovementList {get; set;}
//For Delete Removed Row
public Map<String, SalesMovement> mapRemoveSalesMovement = new Map<String, SalesMovement>();


//Multipicklist
Public List<String> selectedObjectives {get; set;}
Public List<String> selectedWho {get; set;}
//Map Category > Brand
Map<String, List<ASI_MFM_Brand__c>> mapBrandKey = new Map<String, List<ASI_MFM_Brand__c>>();

//Map Brand > Category
Map<String, List<ASI_MFM_Sub_brand__c>> mapsubBrandKey = new Map<String, List<ASI_MFM_Sub_brand__c>>();

//For Checking display Others
Public String SelectOption{get;set;}
Public Boolean ObjOthers{get; set;}
Public Boolean WhoOthers{get; set;}

//Error Msg
Public String strErrMsgObjOthers {get; set;}
Public String strErrMsgWhoOthers {get; set;}
Public String strErrMsgUploadAtt {get; set;}

//Error Msg for mandatory field
//Public String strErrMsgAccName {get; set;}
Public String strErrMsgBranchName {get; set;}
Public String strErrMsgVisitDate {get; set;}
Public String strErrMsgAttendee {get; set;}
Public String strErrMsgObjectives {get; set;}
Public String strErrMsgWho {get; set;}


public ASI_CRM_TH_MarketVisitPageCtrl(ApexPages.StandardController stdController) {
    //for add row
    lstaddRows = new List<Integer>();
    repeatRow = false;   
    //for current page display
    currentPage = ApexPages.currentPage().getParameters().get('page');
    if(CurrentPage == null || CurrentPage =='')
    CurrentPage = '0';
    
    //Get the Information by Market Visit ID
    idAcc = ApexPages.currentPage().getParameters().get('accid');
    idMv =  ApexPages.currentPage().getParameters().get('mvid');
    
    //For Sales Movement Record
    SalesMovementList = new List<SalesMovement>();
    smRecordTypeId= Global_RecordTypeCache.getRTId('ASI_CRM_Sales_Movement__cASI_CRM_TH_SalesMovement');
    
    //For Save
    isQuickSave = true;
    
        
    Initial();

}

//Custom Class for displaying available Category
public class Category{
    public string CategoryName {get;set;}
    public string CategoryId {get; set;}
  }
    
//Custom Class for displaying available Brand
public class Brand{
    public string BrandName {get;set;}
    public string BrandId {get; set;}
  }
    
//Custom Class for displaying available subBrand
public class subBrand{
    public string subBrandName {get;set;}
    public string subBrandId {get; set;}
   }
   
   
//get multi-picklist values
    public List<SelectOption> getPromoTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_CRM_Sales_Movement__c.ASI_CRM_Promotion_Type__c.getDescribe();
        List<Schema.PicklistEntry> promoTypelist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : promoTypelist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    } 
    
 //Get multi-picklist fields' values
    public List<String> getMultiSelectValues(String values){
        List<String> selectedValues = new List<String>();
        if(!String.IsEmpty(values)){
            String[] tmpString = values.split(';');
            integer index = 0;
            For(String s : tmpString){
                s = s.replace('[', '').replace(']', '');
                //if(index != 0 && s.length() >= 1 && s[0])
                    //s = s.substring(1,s.length());
                        
                selectedValues.add(s);
                index++;
            }
        }
        system.debug('selectedValues: '+selectedValues);
        return selectedValues;
    }
//Get multi-picklist fields' values
    public String putMultiSelectValues(List<String> values){
        String strObjectives = '';
        if(values.size() > 0){
            //strObjectives = '[';
            for(String s: values){
                strObjectives += s+'; ';
            }
            if(!String.IsEmpty(strObjectives)){
                strObjectives = strObjectives.substring(0,strObjectives.length()-2);
                //strObjectives += ']';
            }
        }
        
        system.debug('strObjectives: '+strObjectives);
        return strObjectives;
    }
    
//Get Objectives MultiPicklist
public List<SelectOption> getObjectiveList() {    
        List<SelectOption> options = new List<SelectOption>();
        
        ASI_CRM_TH_Picklist_Setting__c listPicklistValues  = [SELECT ASI_CRM_Value__c FROM ASI_CRM_TH_Picklist_Setting__c 
                                                              WHERE ASI_CRM_Object__c = 'ASI_CRM_Market_Visit__c' 
                                                              AND ASI_CRM_Record_Type__c = 'ASI_CRM_TH_MarketVisit' 
                                                              AND ASI_CRM_Field__c = 'ASI_CRM_Objectives__c' 
                                                              AND Name = 'MV Objectives' LIMIT 1];
        
        String[] tmpString = listPicklistValues.ASI_CRM_Value__c.split(';');
        integer index = 0;
        For(String s : tmpString){
            s = s.replace('[', '').replace(']', '');
            options.add(new SelectOption(S, S));
            index++;
        }
        return options;
    }     

//Get Who Multipicklist
public List<SelectOption> getWhoList() {
        List<SelectOption> options = new List<SelectOption>();
        
        
        ASI_CRM_TH_Picklist_Setting__c listPicklistValues  = [SELECT ASI_CRM_Value__c FROM ASI_CRM_TH_Picklist_Setting__c 
                                                              WHERE ASI_CRM_Object__c = 'ASI_CRM_Market_Visit__c' 
                                                              AND ASI_CRM_Record_Type__c = 'ASI_CRM_TH_MarketVisit' 
                                                              AND ASI_CRM_Field__c = 'ASI_CRM_Who__c' 
                                                              AND Name = 'MV Who' LIMIT 1];
        
        String[] tmpString = listPicklistValues.ASI_CRM_Value__c.split(';');
        integer index = 0;
        For(String s : tmpString){
            s = s.replace('[', '').replace(']', '');
            options.add(new SelectOption(S, S));
            index++;
        }
        return options;
    }     
    
    
public void Initial(){
   init = true;
   initIndex = 0;
   strMVID=idMv;
   //Get Account Name
   acc = [SELECT Id, Name FROM ASI_CRM_Account_Group__c WHERE id=:idAcc LIMIT 1];
   AccName = acc[0].Name;
   objacc=acc[0];
   
   //for multipicklist
   selectedObjectives = new List<String>(); 
   selectedWho = new List<String>();
   
    
   MarketVisitDetail = new List<ASI_CRM_Market_Visit__c>();
   system.debug('strMVID: '+strMVID);
   If (strMVID!=null){
   MarketVisitDetail = [SELECT id, ASI_CRM_Action_Plans__c, ASI_CRM_Account_Group__c,ASI_CRM_Account_Group__r.Name,
                               ASI_CRM_Attendee__c, ASI_CRM_Account_Name__c, ASI_CRM_Branch_Name__c,
                               ASI_CRM_Insight__c,ASI_CRM_KeyIssuesOpportunities__c,
                               ASI_CRM_Objectives__c,ASI_CRM_Objectives_Others__c,ASI_CRM_Report_Summary__c,
                               ASI_CRM_Visit_Date__c,ASI_CRM_Who__c, ASI_CRM_Who_Others__c
                               FROM ASI_CRM_Market_Visit__c WHERE ASI_CRM_Account_Group__c=:idAcc AND id=:strMVID LIMIT 1];                          

   MarketVisit = new ASI_CRM_Market_Visit__c();
   
   If (MarketVisitDetail.size()>0){
       objmv=MarketVisitDetail[0];

       MarketVisit.ASI_CRM_Account_Name__c=MarketVisitDetail[0].ASI_CRM_Account_Name__c;
       MarketVisit.ASI_CRM_Branch_Name__c=MarketVisitDetail[0].ASI_CRM_Branch_Name__c;
       MarketVisit.ASI_CRM_Action_Plans__c=MarketVisitDetail[0].ASI_CRM_Action_Plans__c;
       MarketVisit.ASI_CRM_Attendee__c=MarketVisitDetail[0].ASI_CRM_Attendee__c;
       MarketVisit.ASI_CRM_Insight__c=MarketVisitDetail[0].ASI_CRM_Insight__c;
       MarketVisit.ASI_CRM_KeyIssuesOpportunities__c=MarketVisitDetail[0].ASI_CRM_KeyIssuesOpportunities__c;
       MarketVisit.ASI_CRM_Objectives_Others__c=MarketVisitDetail[0].ASI_CRM_Objectives_Others__c;
       MarketVisit.ASI_CRM_Who_Others__c=MarketVisitDetail[0].ASI_CRM_Who_Others__c;
       MarketVisit.ASI_CRM_Report_Summary__c=MarketVisitDetail[0].ASI_CRM_Report_Summary__c;
       
       //BranchName=MarketVisitDetail[0].ASI_CRM_Branch_Name__c;
       VisitDate=MarketVisitDetail[0].ASI_CRM_Visit_Date__c;
       strMVID = MarketVisitDetail[0].id;
       selectedObjectives = getMultiSelectValues(MarketVisitDetail[0].ASI_CRM_Objectives__c);
       selectedWho = getMultiSelectValues(MarketVisitDetail[0].ASI_CRM_Who__c);
       
       }
       
    }else{
   
       MarketVisit = new ASI_CRM_Market_Visit__c();
       
       MarketVisit.ASI_CRM_Account_Name__c='';
       MarketVisit.ASI_CRM_Branch_Name__c='';
       MarketVisit.ASI_CRM_Action_Plans__c='';
       MarketVisit.ASI_CRM_Attendee__c='';
       MarketVisit.ASI_CRM_Insight__c='';
       MarketVisit.ASI_CRM_KeyIssuesOpportunities__c='';
       MarketVisit.ASI_CRM_Objectives__c='';
       MarketVisit.ASI_CRM_Report_Summary__c='';
       MarketVisit.ASI_CRM_Who__c='';
   
       VisitDate = Date.today();
       
   }  
   
   if(strMVID==null){
       strErrMsgUploadAtt='Please quick save the record in order to upload attachment';
       }    
   
   system.debug('***strMVID: '+strMVID);
   
   
   
   //Map Category > Brand
   Id brandRecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Brand__cASI_TH_CRM_BRAND');
   List <ASI_MFM_Brand__c> BrandOption = new List<ASI_MFM_Brand__c>();
   BrandOption = [SELECT Id, Name, ASI_TH_CRM_Category__c FROM ASI_MFM_Brand__c WHERE RecordTypeId =: brandRecordTypeId ORDER BY Name];
   
   for(ASI_MFM_Brand__c brands: BrandOption){
       List<ASI_MFM_Brand__c> BrandListrecord = new List<ASI_MFM_Brand__c>();
       if(mapBrandKey.get(brands.ASI_TH_CRM_Category__c)!=null && mapBrandKey.get(brands.ASI_TH_CRM_Category__c).size()>0){
   
           BrandListrecord = mapBrandKey.get(brands.ASI_TH_CRM_Category__c);
           BrandListrecord.add(brands);
           mapBrandKey.put(brands.ASI_TH_CRM_Category__c, BrandListrecord);
       
       }else{
           BrandListrecord.add(brands);
           mapBrandKey.put(brands.ASI_TH_CRM_Category__c, BrandListrecord);
           
          }
       }

   
    //Map Sub Brand > Brand
   Id subbrandRecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand');
   List <ASI_MFM_Sub_brand__c> subBrandOption = new List<ASI_MFM_Sub_brand__c>();
   subBrandOption = [SELECT Id, Name, ASI_MFM_Brand__c, ASI_TH_CRM_Active__c FROM ASI_MFM_Sub_brand__c WHERE ASI_TH_CRM_Active__c=true AND RecordTypeId =: subbrandRecordTypeId ORDER BY Name];

   for(ASI_MFM_Sub_brand__c subbrands: subBrandOption){
       List<ASI_MFM_Sub_brand__c> subBrandListrecord = new List<ASI_MFM_Sub_brand__c>();
       if(mapsubBrandKey.get(subbrands.ASI_MFM_Brand__c)!=null && mapsubBrandKey.get(subbrands.ASI_MFM_Brand__c).size()>0){
       
           subBrandListrecord = mapsubBrandKey.get(subbrands.ASI_MFM_Brand__c);
           subBrandListrecord.add(subbrands);
           mapsubBrandKey.put(subbrands.ASI_MFM_Brand__c, subBrandListrecord);
           
       }else{
           subBrandListrecord.add(subbrands);
           mapsubBrandKey.put(subbrands.ASI_MFM_Brand__c, subBrandListrecord);
       }
   }
   
   //Salesmovement record function 

   List<ASI_CRM_Sales_Movement__c> SalesMovements = new List<ASI_CRM_Sales_Movement__c>();
   If(strMVID!=null){
   
       SalesMovements = [SELECT Id, ASI_CRM_Market_Visit__c, ASI_CRM_Account__c,
                                ASI_CRM_Brand__c, ASI_CRM_Promotion_Period_From__c,
                                ASI_CRM_Promotion_Period_To__c, ASI_CRM_Promotion_Type__c,
                                ASI_CRM_Promotion_Type_Others__c, ASI_CRM_Remarks__c,
                                ASI_CRM_RSP__c, ASI_CRM_Sub_brand__c,
                                ASI_CRM_TH_Category__c FROM ASI_CRM_Sales_Movement__c WHERE RecordTypeId =:smRecordTypeId AND ASI_CRM_Market_Visit__c=:strMVID];
       
   }
   if (SalesMovements.size()>0){
       for(ASI_CRM_Sales_Movement__c sMovement: SalesMovements){
   
           SalesMovement SalesMovement  = new SalesMovement();
           salesmovement.SalesMovementId= sMovement.id;
           if(sMovement.ASI_CRM_TH_Category__c==null && sMovement.ASI_CRM_Remarks__c!=null){
               salesmovement.CategoryId = '0';
           }else{
               salesmovement.CategoryId = sMovement.ASI_CRM_TH_Category__c;
           }

           salesmovement.PromotionFrom = sMovement.ASI_CRM_Promotion_Period_From__c;
           salesmovement.PromotionTo = sMovement.ASI_CRM_Promotion_Period_To__c;
           salesmovement.CategoryList=getCategoryList();
           salesmovement.SelectedPromoType = getMultiSelectValues(sMovement.ASI_CRM_Promotion_Type__c);
           salesmovement.PromotionOther = sMovement.ASI_CRM_Promotion_Type_Others__c;
           salesmovement.RSP = sMovement.ASI_CRM_RSP__c;
           salesmovement.Remark = sMovement.ASI_CRM_Remarks__c;
           salesmovement.MarketVisitId = sMovement.ASI_CRM_Market_Visit__c;
       
           SalesMovementList.add(Salesmovement);
           system.debug('initIndex: '+initIndex);
           getBrandOption();
           
           if(sMovement.ASI_CRM_Brand__c==null && sMovement.ASI_CRM_Remarks__c!=null){
               salesmovement.BrandId = '0';
           }else{
               salesmovement.BrandId = sMovement.ASI_CRM_Brand__c;
           }
           getsubBrandOption();
           if(sMovement.ASI_CRM_Sub_brand__c==null && sMovement.ASI_CRM_Remarks__c!=null){
               salesmovement.SubBrandId = '0';
           }else{
               salesmovement.SubBrandId = sMovement.ASI_CRM_Sub_brand__c;
           }
           initIndex = ++initIndex;
           system.debug(SalesMovementList); 
          }
      }else{
            
           SalesMovement SalesMovement  = new SalesMovement();
           
           salesmovement.CategoryList=getCategoryList();
           if(getCategoryList()!=null)
               salesmovement.CategoryId = getCategoryList()[0].getValue();
           salesmovement.PromotionFrom = Date.today();
           salesmovement.PromotionTo = Date.today();
           salesmovement.SelectedPromoType = null;
           salesmovement.PromotionOther = '';
           salesmovement.RSP = null;

           
           SalesMovementList.add(Salesmovement);
           
           getBrandOption();
           salesmovement.BrandId = SalesMovementList[0].BrandList[0].getValue();
           getsubBrandOption();
           salesmovement.SubBrandId = SalesMovementList[0].subBrandList[0].getValue();
                                                                  
    }
    
    init = false;

}



Public List<SelectOption> getCategoryList(){


   //Category picklist        
       List<SelectOption> options = new List<SelectOption>();
       Id catRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Category__cASI_TH_CRM_Category');
       List <ASI_TH_CRM_Category__c> CategoryOption = [SELECT Id, Name FROM ASI_TH_CRM_Category__c 
                                                                   WHERE RecordTypeId =: catRecordTypeId ORDER BY Name];
       
       if(CategoryOption.size()>0){
           for(ASI_TH_CRM_Category__c cat :CategoryOption){
               Category c = new Category();
               c.CategoryName = cat.Name;
               c.CategoryId = cat.Id;
               options.add(new SelectOption(c.CategoryId,c.CategoryName)); 
            }
            options.add(new SelectOption('0','Other'));
        }
    
    
    return options;


}

    

Public void getBrandOption(){ 


    //Get row Integer
      Integer rowIndex;
        if(theRow == null)
            rowIndex = 0;
        else
            rowIndex = Integer.valueof(theRow)-1;

    If (repeatRow){
    
        rowIndex = rowIndex+1;
        system.debug('getBrandOption rowIndex: '+ rowIndex);
    
    }
    
    If (init){
        rowIndex = initIndex;
        system.debug('getBrandOption rowIndex: '+ initIndex);
    }

   //Brand picklist
       SalesMovementList[rowIndex].BrandList = new List<SelectOption>();   
       if(SalesMovementList[rowIndex].CategoryId!='0'){
       List <ASI_MFM_Brand__c> ListMapBrand = new List<ASI_MFM_Brand__c>();

           for(String key :mapBrandKey.keyset()){
               if(key == SalesMovementList[rowIndex].CategoryId){
                   ListMapBrand = mapBrandKey.get(key);
               }
            }
            
            for (ASI_MFM_Brand__c brands: ListMapBrand){
               Brand b = new Brand();
               b.BrandName = brands.Name;
               b.BrandId = brands.Id;
               SalesMovementList[rowIndex].BrandList.add(new SelectOption(b.BrandId,b.BrandName));
            }
            
               }
            SalesMovementList[rowIndex].BrandList.add(new SelectOption('0','Other'));
            
           if(SalesMovementList[rowIndex].BrandList.size()==1){
               SalesMovementList[rowIndex].BrandId='0';
               getsubBrandOption();
           }
         
        

}


Public void getsubBrandOption(){ 

     //Get row Integer
      Integer rowIndex;
        if(theRow == null)
            rowIndex = 0;
        else
            rowIndex = Integer.valueof(theRow)-1;
            
            
    If (repeatRow){
    
        rowIndex = rowIndex+1;
        system.debug('getsubBrandOption rowIndex: '+ rowIndex);
    }
    
    If (init){
        rowIndex = initIndex;
        system.debug('getBrangetsubBrandOptiondOption rowIndex: '+ initIndex);
    } 

    //subBrand picklist 
       SalesMovementList[rowIndex].SubBrandList = new List<SelectOption>();    
       if(SalesMovementList[rowIndex].BrandId!='0'){
       List <ASI_MFM_Sub_brand__c> ListMapSubBrand = new List<ASI_MFM_Sub_brand__c>();
           for(String key :mapsubBrandKey.keyset()){
               if(key == SalesMovementList[rowIndex].BrandId){
               
               ListMapSubBrand = mapsubBrandKey.get(key);
               }
            }
            
            for (ASI_MFM_Sub_brand__c subbrands: ListMapSubBrand){
               subBrand sb = new subBrand();
               sb.subBrandName = subbrands.Name;
               sb.subBrandId = subbrands.Id;
               SalesMovementList[rowIndex].SubBrandList.add(new SelectOption(sb.subBrandId,sb.subBrandName));
                }
            }
            
            SalesMovementList[rowIndex].SubBrandList.add(new SelectOption('0','Other'));
            
           
         

}



public void addRow(){
    //for define recent row index
        Integer rowIndex;
        if(theRow == null)
            rowIndex = 0;
        else
            rowIndex = Integer.valueof(theRow)-1;
        
        lstaddRows.add(rowIndex);     
        
        
        if(lstaddRows != null && lstaddRows.size() > 0){  
               repeatRow = true;
               SalesMovement sm = new SalesMovement();
               sm.CategoryList=getCategoryList();
               sm.CategoryId = SalesMovementList[rowIndex].CategoryId;   
               sm.BrandId = SalesMovementList[rowIndex].BrandId;     
               sm.SubBrandId = SalesMovementList[rowIndex].SubBrandId;        
               sm.PromotionFrom =SalesMovementList[rowIndex].PromotionFrom;
               sm.PromotionTo = SalesMovementList[rowIndex].PromotionTo;
               sm.selectedPromoType = SalesMovementList[rowIndex].selectedPromoType;
               sm.PromotionOther = SalesMovementList[rowIndex].PromotionOther;
               sm.RSP = SalesMovementList[rowIndex].RSP;
               sm.Remark = SalesMovementList[rowIndex].Remark;
               sm.MarketVisitId = strMVID;
               
               
               SalesMovementList.add(sm);
               getBrandOption();
               getsubBrandOption(); 
               
               system.debug('SalesMovementList in addrow: '+SalesMovementList[rowIndex].SubBrandId);
               repeatRow = false; 

        }
}

public void removeRow(){

     Integer rowIndex;
     if(theRow == null)
         rowIndex = 0;
       else
         rowIndex = Integer.valueof(theRow)-1;
        
        if(SalesMovementList.size()>1){
            mapRemoveSalesMovement.put(SalesMovementList[rowIndex].SalesMovementId, SalesMovementList[rowIndex]);    
            SalesMovementList.remove(rowIndex);
        }

}

//Upload photo attachment
@RemoteAction
public static String insertAttachment(String strParentID, String attachmentBody, String attachmentName, String pType, String attachmentId) {   
        
        if(attachmentBody != null) {
            Attachment att = getAttachment(attachmentId);
            String newBody = '';
            if(att.Body != null) {
                newBody = EncodingUtil.base64Encode(att.Body);
            }
            newBody += attachmentBody;
            att.Body = EncodingUtil.base64Decode(newBody);
            if(attachmentId == null) {
                att.Name = attachmentName;
                att.parentId = strParentID;
            }
            
            if(strParentID!=null){
                upsert att;
                return att.id;
            }else{ 
                return null;
                
            }
            
            
        } else {
            
            return 'Attachment Body was null';
        }
    }
private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }


    public PageReference quickSave() {
        Boolean saveSuccess = SaveChanges();
        PageReference redirectPage = null;

        if (saveSuccess) {
            if(isQuickSave)
            {

                
                redirectPage = Page.ASI_CRM_TH_MarketVisitPage;                
                redirectPage.getParameters().put('accid', objacc.id);
                redirectPage.getParameters().put('mvid',strMVID);
                redirectPage.getParameters().put('page', currentPage);
                redirectPage.setRedirect(true);
                system.debug('redirectPage: '+redirectPage);
                
                return redirectPage;
            }
            else
            {
               redirectPage = new PageReference('/'+objacc.id);
               
                redirectPage = new PageReference('/'+strMVID);
                redirectPage.setRedirect(true);
            }
        }
        return redirectPage;
    }
   
public PageReference Save() {
        Boolean blnValidation =  true;     
        isQuickSave = false;
        
        return quickSave(); 
    }

/*public void saveAction(){
    Boolean blnIsError = false;
    strErrMsgAccName='';
    strErrMsgBranchName='';
    strErrMsgVisitDate='';
    strErrMsgAttendee='';
    strErrMsgObjectives='';
    strErrMsgObjOthers='';
    strErrMsgWho='';
    strErrMsgWhoOthers='';

   
//Upsert Market Visit    
      ASI_CRM_Market_Visit__c saveMarketVisit = new ASI_CRM_Market_Visit__c();
       
       saveMarketVisit.Id=strMVID;
       saveMarketVisit.ASI_CRM_Account_Group__c=IdAcc;
       saveMarketVisit.ASI_CRM_Action_Plans__c=MarketVisit.ASI_CRM_Action_Plans__c;
       saveMarketVisit.ASI_CRM_Insight__c=MarketVisit.ASI_CRM_Insight__c;
       saveMarketVisit.ASI_CRM_KeyIssuesOpportunities__c=MarketVisit.ASI_CRM_KeyIssuesOpportunities__c;
       saveMarketVisit.ASI_CRM_Report_Summary__c=MarketVisit.ASI_CRM_Report_Summary__c;
       
       if(MarketVisit.ASI_CRM_Account_Name__c==null||MarketVisit.ASI_CRM_Account_Name__c==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgAccName = 'Account Name is required';
       }else{
            saveMarketVisit.ASI_CRM_Account_Name__c=MarketVisit.ASI_CRM_Account_Name__c;
       }

       if(MarketVisit.ASI_CRM_Branch_Name__c==null||MarketVisit.ASI_CRM_Branch_Name__c==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgBranchName = 'Branch Name is required';
       }else{
            saveMarketVisit.ASI_CRM_Branch_Name__c=MarketVisit.ASI_CRM_Branch_Name__c;
       }

      if(MarketVisit.ASI_CRM_Attendee__c==null||MarketVisit.ASI_CRM_Attendee__c==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgAttendee = 'Attendee is required';
       }else{
            saveMarketVisit.ASI_CRM_Attendee__c=MarketVisit.ASI_CRM_Attendee__c;
       }
      
      if(VisitDate==null){
           currentPage = '0';
           blnIsError = true;
           strErrMsgVisitDate = 'Visit Date is required';
       }else{
           saveMarketVisit.ASI_CRM_Visit_Date__c=VisitDate;
       }
      
       if(putMultiSelectValues(selectedObjectives)==null||putMultiSelectValues(selectedObjectives)==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgObjectives = 'Objective is required';
       }else{
           saveMarketVisit.ASI_CRM_Objectives__c=putMultiSelectValues(selectedObjectives);
       }

       if(putMultiSelectValues(selectedWho)==null||putMultiSelectValues(selectedWho)==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgWho = 'Who is required';
       }else{
           saveMarketVisit.ASI_CRM_Who__c=putMultiSelectValues(selectedWho);
       }
                      
       if(putMultiSelectValues(selectedObjectives).contains('Others')==true && MarketVisit.ASI_CRM_Objectives_Others__c==null){
           currentPage = '0';
           strErrMsgObjOthers='Other Objectives is required';
           blnIsError = true;
       }else{
           saveMarketVisit.ASI_CRM_Objectives_Others__c=MarketVisit.ASI_CRM_Objectives_Others__c;
       }
       
       if(putMultiSelectValues(selectedWho).contains('Others')==true && MarketVisit.ASI_CRM_Who_Others__c==null){
           currentPage = '0';
           strErrMsgWhoOthers='Other Who is required';
           blnIsError = true;
       }else{
           saveMarketVisit.ASI_CRM_Who_Others__c=MarketVisit.ASI_CRM_Who_Others__c;
       }
       
       if(blnIsError==false){
           upsert saveMarketVisit;
           strMVID = saveMarketVisit.id;
       }
             
       system.debug('strErrMsgVisitDate: '+strErrMsgVisitDate);
       system.debug('strErrMsgAttendee: '+strErrMsgAttendee);
       system.debug('strErrMsgObjectives: '+strErrMsgObjectives);
       system.debug('strErrMsgObjOthers: '+strErrMsgObjOthers);
       system.debug('strErrMsgWho: '+strErrMsgWho);
       system.debug('strErrMsgWhoOthers: '+strErrMsgWhoOthers);

//Remove Sales Movement
    List<ASI_CRM_Sales_Movement__c> removeSalesMovementList = new List<ASI_CRM_Sales_Movement__c>();
    if(mapRemoveSalesMovement != null && mapRemoveSalesMovement.size() > 0){
            removeSalesMovementList = [SELECT Id FROM ASI_CRM_Sales_Movement__c WHERE Id IN: mapRemoveSalesMovement.keySet()];
            delete removeSalesMovementList;
        }
//Upsert Sales Movement
      List<ASI_CRM_Sales_Movement__c> saveSalesMovementList = new List<ASI_CRM_Sales_Movement__c>();
       
       for(SalesMovement sm :SalesMovementList){
       ASI_CRM_Sales_Movement__c saveSalesMovement = new ASI_CRM_Sales_Movement__c();
           
           sm.strErrMsgPTypeOthers='';
           sm.strErrMsgRemark = '';
           sm.strErrMsgRSP = '';
           
           saveSalesMovement.id=sm.SalesMovementId;
           saveSalesMovement.RecordTypeId=smRecordTypeId;
           //saveSalesMovement.ASI_CRM_Account__c=IdAcc;
           if(sm.CategoryId!='0'){
               saveSalesMovement.ASI_CRM_TH_Category__c =sm.CategoryId;
           }else{
               saveSalesMovement.ASI_CRM_TH_Category__c =null;
           }
           if(sm.BrandId!='0'){
               system.debug('sm.BrandId'+sm.BrandId);
               saveSalesMovement.ASI_CRM_Brand__c=sm.BrandId;
           }else{
                saveSalesMovement.ASI_CRM_Brand__c=null;
           }
           if(sm.SubBrandId!='0'){
               system.debug('sm.SubBrandId'+sm.SubBrandId);
               saveSalesMovement.ASI_CRM_Sub_brand__c=sm.SubBrandId;
           }else{
               saveSalesMovement.ASI_CRM_Sub_brand__c=null;
           }
 
           if(sm.RSP==0 || sm.RSP==null){
              currentPage='1';
              sm.strErrMsgRSP = 'RSP is required';
              blnIsError = true;           
             }else{
               saveSalesMovement.ASI_CRM_RSP__c=sm.RSP;
             }
           
           
           saveSalesMovement.ASI_CRM_Market_Visit__c=strMVID;
           
           if(sm.SubBrandId=='0'&& sm.Remark==''){
               currentPage='1';
               sm.strErrMsgRemark = 'Remark is required';
               blnIsError = true;
             }else{
                saveSalesMovement.ASI_CRM_Remarks__c=sm.Remark;
             }
            
               
           if (putMultiSelectValues(sm.SelectedPromoType).contains('Others') && sm.PromotionOther==''){
               currentPage='1';
                sm.strErrMsgPTypeOthers='Others is required';
                blnIsError = true;
             }else{
               saveSalesMovement.ASI_CRM_Promotion_Type_Others__c=sm.PromotionOther;
             }
             
            saveSalesMovement.ASI_CRM_Promotion_Period_From__c=sm.PromotionFrom;
            saveSalesMovement.ASI_CRM_Promotion_Period_To__c=sm.PromotionTo;
            saveSalesMovement.ASI_CRM_Promotion_Type__c=putMultiSelectValues(sm.SelectedPromoType);
              
            saveSalesMovementList.add(saveSalesMovement);
          }
          
          if (blnIsError == true){
              
          }else{
              strErrMsgUploadAtt='';
              system.debug('upsert saveSalesMovement: '+saveSalesMovementList);
              upsert saveSalesMovementList;
              
              
          }
          
          currentPage='1';

}
*/
public Boolean SaveChanges() {
Boolean blnIsError = false;
    //strErrMsgAccName='';
    strErrMsgBranchName='';
    strErrMsgVisitDate='';
    strErrMsgAttendee='';
    strErrMsgObjectives='';
    strErrMsgObjOthers='';
    strErrMsgWho='';
    strErrMsgWhoOthers='';
    currentPage=null;

   
//Upsert Market Visit    
      ASI_CRM_Market_Visit__c saveMarketVisit = new ASI_CRM_Market_Visit__c();
       
       saveMarketVisit.Id=strMVID;
       saveMarketVisit.ASI_CRM_Account_Group__c=IdAcc;
       saveMarketVisit.ASI_CRM_Action_Plans__c=MarketVisit.ASI_CRM_Action_Plans__c;
       saveMarketVisit.ASI_CRM_Insight__c=MarketVisit.ASI_CRM_Insight__c;
       saveMarketVisit.ASI_CRM_KeyIssuesOpportunities__c=MarketVisit.ASI_CRM_KeyIssuesOpportunities__c;
       saveMarketVisit.ASI_CRM_Report_Summary__c=MarketVisit.ASI_CRM_Report_Summary__c;
       
       /*
       if(MarketVisit.ASI_CRM_Account_Name__c==null||MarketVisit.ASI_CRM_Account_Name__c==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgAccName = 'Account Name is required';
       }else{
            saveMarketVisit.ASI_CRM_Account_Name__c=MarketVisit.ASI_CRM_Account_Name__c;
       }
       */

       if(MarketVisit.ASI_CRM_Branch_Name__c==null||MarketVisit.ASI_CRM_Branch_Name__c==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgBranchName = 'Branch Name is required';
       }else{
            saveMarketVisit.ASI_CRM_Branch_Name__c=MarketVisit.ASI_CRM_Branch_Name__c;
       }

      if(MarketVisit.ASI_CRM_Attendee__c==null||MarketVisit.ASI_CRM_Attendee__c==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgAttendee = 'Attendee is required';
       }else{
            saveMarketVisit.ASI_CRM_Attendee__c=MarketVisit.ASI_CRM_Attendee__c;
       }
      
      if(VisitDate==null){
           currentPage = '0';
           blnIsError = true;
           strErrMsgVisitDate = 'Visit Date is required';
       }else{
           saveMarketVisit.ASI_CRM_Visit_Date__c=VisitDate;
       }
      
       if(putMultiSelectValues(selectedObjectives)==null||putMultiSelectValues(selectedObjectives)==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgObjectives = 'Objective is required';
       }else{
           saveMarketVisit.ASI_CRM_Objectives__c=putMultiSelectValues(selectedObjectives);
       }

       if(putMultiSelectValues(selectedWho)==null||putMultiSelectValues(selectedWho)==''){
           currentPage = '0';
           blnIsError = true;
           strErrMsgWho = 'Who is required';
       }else{
           saveMarketVisit.ASI_CRM_Who__c=putMultiSelectValues(selectedWho);
       }
                      
       if(putMultiSelectValues(selectedObjectives).contains('Others')==true && MarketVisit.ASI_CRM_Objectives_Others__c==null){
           currentPage = '0';
           strErrMsgObjOthers='Other Objectives is required';
           blnIsError = true;
       }else{
           saveMarketVisit.ASI_CRM_Objectives_Others__c=MarketVisit.ASI_CRM_Objectives_Others__c;
       }
       
       if(putMultiSelectValues(selectedWho).contains('Others')==true && MarketVisit.ASI_CRM_Who_Others__c==null){
           currentPage = '0';
           strErrMsgWhoOthers='Other Who is required';
           blnIsError = true;
       }else{
           saveMarketVisit.ASI_CRM_Who_Others__c=MarketVisit.ASI_CRM_Who_Others__c;
       }
       
       if(blnIsError==false){
           upsert saveMarketVisit;
           strMVID = saveMarketVisit.id;
           strErrMsgUploadAtt='';
       }
             
       system.debug('strErrMsgVisitDate: '+strErrMsgVisitDate);
       system.debug('strErrMsgAttendee: '+strErrMsgAttendee);
       system.debug('strErrMsgObjectives: '+strErrMsgObjectives);
       system.debug('strErrMsgObjOthers: '+strErrMsgObjOthers);
       system.debug('strErrMsgWho: '+strErrMsgWho);
       system.debug('strErrMsgWhoOthers: '+strErrMsgWhoOthers);

//Remove Sales Movement
    List<ASI_CRM_Sales_Movement__c> removeSalesMovementList = new List<ASI_CRM_Sales_Movement__c>();
    if(mapRemoveSalesMovement != null && mapRemoveSalesMovement.size() > 0){
            removeSalesMovementList = [SELECT Id FROM ASI_CRM_Sales_Movement__c WHERE Id IN: mapRemoveSalesMovement.keySet()];
            delete removeSalesMovementList;
        }
//Upsert Sales Movement
      List<ASI_CRM_Sales_Movement__c> saveSalesMovementList = new List<ASI_CRM_Sales_Movement__c>();
       
       for(SalesMovement sm :SalesMovementList){
       ASI_CRM_Sales_Movement__c saveSalesMovement = new ASI_CRM_Sales_Movement__c();
           
           sm.strErrMsgPTypeOthers='';
           sm.strErrMsgRemark = '';
           sm.strErrMsgRSP = '';
           sm.strErrMsgPromoDate='';
           
           saveSalesMovement.id=sm.SalesMovementId;
           saveSalesMovement.RecordTypeId=smRecordTypeId;
           //saveSalesMovement.ASI_CRM_Account__c=IdAcc;
           if(sm.CategoryId!='0'){
               saveSalesMovement.ASI_CRM_TH_Category__c =sm.CategoryId;
           }else{
               saveSalesMovement.ASI_CRM_TH_Category__c =null;
           }
           if(sm.BrandId!='0'){
               system.debug('sm.BrandId'+sm.BrandId);
               saveSalesMovement.ASI_CRM_Brand__c=sm.BrandId;
           }else{
                saveSalesMovement.ASI_CRM_Brand__c=null;
           }
           if(sm.SubBrandId!='0'){
               system.debug('sm.SubBrandId'+sm.SubBrandId);
               saveSalesMovement.ASI_CRM_Sub_brand__c=sm.SubBrandId;
           }else{
               saveSalesMovement.ASI_CRM_Sub_brand__c=null;
           }
 
           if(sm.RSP==0 || sm.RSP==null){
           if(CurrentPage == null || CurrentPage =='')
              currentPage='1';
              sm.strErrMsgRSP = 'RSP is required';
              blnIsError = true;           
             }else{
               saveSalesMovement.ASI_CRM_RSP__c=sm.RSP;
             }
           
           
           saveSalesMovement.ASI_CRM_Market_Visit__c=strMVID;
           
           if(sm.SubBrandId=='0'&& sm.Remark==''){
           if(CurrentPage == null || CurrentPage =='')
               currentPage='1';
               sm.strErrMsgRemark = 'Remark is required';
               blnIsError = true;
             }else{
                saveSalesMovement.ASI_CRM_Remarks__c=sm.Remark;
             }
            
               
           if (putMultiSelectValues(sm.SelectedPromoType).contains('Others') && sm.PromotionOther==''){
           if(CurrentPage == null || CurrentPage =='')
               currentPage='1';
                sm.strErrMsgPTypeOthers='Others is required';
                blnIsError = true;
             }else{
               saveSalesMovement.ASI_CRM_Promotion_Type_Others__c=sm.PromotionOther;
             }
             
            if(sm.PromotionFrom > sm.PromotionTo){
                currentPage='1';
                sm.strErrMsgPromoDate='Promotion Date From should be before Promotion Date To';
                blnIsError = true; 
            }else{
                saveSalesMovement.ASI_CRM_Promotion_Period_From__c=sm.PromotionFrom;
                saveSalesMovement.ASI_CRM_Promotion_Period_To__c=sm.PromotionTo;
            }
            saveSalesMovement.ASI_CRM_Promotion_Type__c=putMultiSelectValues(sm.SelectedPromoType);
              
            saveSalesMovementList.add(saveSalesMovement);
          }
          
          if (blnIsError == true){
              return false;
          }else{
              strErrMsgUploadAtt='';
              system.debug('upsert saveSalesMovement: '+saveSalesMovementList);
              upsert saveSalesMovementList;
              
              return true;
          }

}


public class SalesMovement{

    Public Id SalesMovementId {get; set;}
    Public String CategoryId {get; set;}
    Public String BrandId {get; set;}
    Public String SubBrandId {get; set;}
    //Picklist Value
    Public List<SelectOption> CategoryList{get;set;}
    Public List<SelectOption> BrandList{get;set;}
    Public List<SelectOption> SubBrandList{get;set;}
    Public Date PromotionFrom {get; set;}
    Public Date PromotionTo {get; set;}
    //For multi picklist
    Public List<String> selectedPromoType { get; set; }
    Public String PromotionOther {get; set;}
    Public Decimal RSP {get; set;}
    Public String Remark {get; set;}
    Public Id MarketVisitId {get; set;}    
    Public String strErrMsgPTypeOthers {get; set;}
    Public String strErrMsgRemark {get; set;}
    Public String strErrMsgRSP {get; set;}
    Public String strErrMsgPromoDate {get; set;}

}

}