/***********************************************************
Created by Stella Li(IntroV Limited)     26 Feb 2015
Revised by Twinkle Li(Introv Limited)    14 Oct 2016, add 2 more images for displaying
************************************************************/
public with sharing class ASI_CRM_TW_MerchanTaskReportPDF_Ctrl{

    public String PageId {set;get;}
    public ASI_CRM_Merchandiser_Task__c thisMDR{set;get;}
    public List<Attachment> images{set;get;}
    
    public Attachment image1{set;get;}
    public Attachment image2{set;get;}
    public Attachment image3{set;get;}
    public Attachment image4{set;get;}
    
    public boolean showImg1{set;get;}
    public boolean showImg2{set;get;}
    public boolean showImg3{set;get;}
    public boolean showImg4{set;get;}
    
   // public string accId{set;get;}
   // public ASI_CRM_AccountsAdditionalField__c accountAdditionalField {set;get;}
   
   /*public ASI_CRM_TW_MerchanTaskReportPDF_Ctrl() {

    }*/
    public ASI_CRM_TW_MerchanTaskReportPDF_Ctrl(ApexPages.StandardController controller) {
        thisMDR=new ASI_CRM_Merchandiser_Task__c() ;
       //accountAdditionalField =new ASI_CRM_AccountsAdditionalField__c();
       
        images=new list<Attachment>();
        image1=new Attachment();
        image2=new Attachment();
        image3=new Attachment();
        image4=new Attachment();
        
        showImg1=false;
        showImg2=false;
        showImg3=false;
        showImg4=false;
        
        PageId = ApexPages.currentPage().getParameters().get('id');
        
        if (PageId != null){
            thisMDR=[SELECT id, Name,ASI_CRM_Promotion_Status__r.ASI_CRM_Account__r.ASI_HK_CRM_Address__c,ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__r.ASI_CRM_Plan__r.Name,ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c,ASI_CRM_Promotion_Status__r.ASI_CRM_JDE_Account_Number__c,
                    ASI_CRM_Start_Date__c, ASI_CRM_Promotion_Status__r.ASI_CRM_Channel__c,ASI_CRM_End_Date__c,ASI_CRM_Outlet_Type__c,ASI_CRM_Outlet_Image__c,
                    ASI_CRM_Grade__c, ASI_CRM_Promotion_Status__r.ASI_CRM_Account__r.Owner.Name, ASI_CRM_Promotion_Code__c, ASI_CRM_Promotion_Name__c, 
                    ASI_CRM_Photo_Date__c, ASI_CRM_Purchase_Due_Date__c, ASI_CRM_Task__c,ASI_CRM_Remarks__c
                    FROM ASI_CRM_Merchandiser_Task__c WHERE id = :PageId ];      
          /* accId = thisMDR.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c;
           if(accId !=null){
               accountAdditionalField = getAccountsAdditionalField_DynamiCSOQL(accId);
               System.Debug(accountAdditionalField);           
           }
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'--'+accId );
           ApexPages.addMessage(myMsg); */  
           images=[SELECT Id,Name,ContentType FROM Attachment where ParentId =:PageId order by LastModifiedDate DESC];

           if (images!=null && images.size()==1){
               showImg1=true;
               showImg2=false;
               image1=images[0];
           }else if(images!=null && images.size()==2){
               showImg1=true;
               showImg2=true;
               image1=images[0];
               image2=images[1];
           }else if(images!=null && images.size()==3){
               showImg1=true;
               showImg2=true;
               showImg3=true;
               image1=images[0];
               image2=images[1];
               image3=images[2];
           }else if(images!=null && images.size()>=4){
               showImg1=true;
               showImg2=true;
               showImg3=true;
               showImg4=true;
               image1=images[0];
               image2=images[1];
               image3=images[2];
               image4=images[3];
           }
        }
    }
      /* public ASI_CRM_AccountsAdditionalField__c getAccountsAdditionalField_DynamiCSOQL(String accId) {  
        System.Debug(accId);
        String query = 'SELECT ';    
        for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_TW_AdditionalField.getFields()) {    
            query += f.getFieldPath() + ', ';    
        }                  
         query += 'Id, Name, ASI_CRM_Account__c, ASI_CRM_CN_Legal_Name__c, ASI_CRM_CN_Inactive_Flag__c, ASI_CRM_TW_Parent_Account__c , ASI_TH_CRM_OutletType__c ,  ASI_CRM_IsParentAccount__c, ASI_CRM_Service_Pack__c, ASI_CRM_Segmentation_Criteria__c, ' +
        'ASI_CRM_City__c, ASI_CRM_Town__c, ASI_CRM_TW_Street__c, ASI_CRM_TW_Section__c, ASI_CRM_TW_Lane__c, ASI_CRM_TW_Alley__c, ASI_CRM_TW_Number__c,' +
        'ASI_CRM_TW_Number_Hyphen__c, ASI_CRM_TW_Floor__c, ASI_CRM_TW_Hyphen__c, ASI_CRM_TW_Suite__c, ASI_CRM_TW_Phone_Area_Code__c, ASI_CRM_TW_Phone_Number__c, ASI_CRM_TW_Phone_Ext__c, ASI_CRM_Approval_Status__c, ' +
        'ASI_CRM_TW_Fax_Area_Code__c, ASI_CRM_TW_Fax_Number__c, ASI_CRM_Channel__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Grade__c, ASI_CRM_Sales_Potential__c, ASI_CRM_Region__c, ASI_CRM_TW_No_Visit__c, ASI_CRM_TW_No_Required_Visit__c  ' +
        'FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = \''+accId+'\' LIMIT 1';  
        
        System.Debug(query);  
        if(Database.query(query) != null && Database.query(query).size() > 0)
            return Database.query(query);    
        
        return null;
    
    }  */  
}