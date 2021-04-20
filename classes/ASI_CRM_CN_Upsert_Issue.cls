/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Upsert_Issue/*')
global without sharing class ASI_CRM_CN_Upsert_Issue{
    global Class Issue{
    global list <IssueStructure> Issuelist{set;get;}    
    }
 @HttpPost
    global static string UpsertIssue (String jsonString ){ 
    /* Sample Json Format
    {"jsonString":"{\"Issuelist\":[{\"RecordID\":\"\",\"Bottle_Sight_1\":\"1\",\"Bottle_Sight_2\":\"1\",\"Bottle_Sight_3\":\"1\",\"Bottle_Sight_4\":\"1\",\"Bottle_Sight_5\":\"1\",\"Bottle_Sight_6\":\"1\",\"Product2\":\"test\",\"Product3\":\"test\",\"CityID\":\"a9AM00000008OaE\",\"Consumer_Name\":\"Test\",\"Date_Of_Purchase\":\"2014/11/30\",\"Detail\":\"Test\",\"Discussion_With_Seller\":\"Test\",\"IOM_Detail\":\"Test\",\"Expectation\":\"Test\",\"How_Complaint_Learnt\":\"Internal\",\"Location\":\"TEst\",\"Lot_Code\":\"Test\",\"Manufacturing_Date\":\"2014/11/30\",\"Manufacturing_Date2\":\"2014/11/30\",\"Manufacturing_Date3\":\"2014/11/30\",\"Lookalike_Detail\":\"test\",\"Origin_Of_GMA\":\"test\",\"Origin_Of_GMA2\":\"test\",\"OutletID\":\"001M000000W3OsTIAV\",\"Packing_Specification\":\"test\",\"Description\":\"test\",\"Price1\":\"99\",\"Price2\":\"99\",\"Price3\":\"99\",\"Product\":\"MCB 1L\",\"Reason_For_Complaint\":\"No\",\"Referred_BTL\":\"99\",\"Remarks\":\"test\",\"Traceability_Detail\":\"test\",\"Sub_brandID\":\"a7FM00000008eLF\",\"Tel_No\":\"61234567\",\"Distributor_Contact_Info\":\"test\",\"Distributor_Contact_Person\":\"test\",\"recordType\":\"012M00000000UBW\",\"AccountID\":\"001M000000W3P8CIAV\",\"Local_Update_Time\":\"2014/12/01 11:30\"},{\"RecordID\":\"a8vM00000008P6A\",\"Bottle_Sight_1\":\"1\",\"Bottle_Sight_2\":\"1\",\"Bottle_Sight_3\":\"1\",\"Bottle_Sight_4\":\"1\",\"Bottle_Sight_5\":\"1\",\"Bottle_Sight_6\":\"1\",\"Product2\":\"test\",\"Product3\":\"test\",\"CityID\":\"a9AM00000008OaE\",\"Consumer_Name\":\"Test\",\"Date_Of_Purchase\":\"2014/11/30\",\"Detail\":\"Test\",\"Discussion_With_Seller\":\"Test\",\"IOM_Detail\":\"Test\",\"Expectation\":\"Test\",\"How_Complaint_Learnt\":\"Internal\",\"Location\":\"TEst\",\"Lot_Code\":\"Test\",\"Manufacturing_Date\":\"2014/11/30\",\"Manufacturing_Date2\":\"2014/11/30\",\"Manufacturing_Date3\":\"2014/11/30\",\"Lookalike_Detail\":\"test\",\"Origin_Of_GMA\":\"test\",\"Origin_Of_GMA2\":\"test\",\"OutletID\":\"001M000000W3OsTIAV\",\"Packing_Specification\":\"test\",\"Description\":\"test\",\"Price1\":\"99\",\"Price2\":\"99\",\"Price3\":\"99\",\"Product\":\"MCB 1L\",\"Reason_For_Complaint\":\"No\",\"Referred_BTL\":\"99\",\"Remarks\":\"test\",\"Traceability_Detail\":\"test\",\"Sub_brandID\":\"a7FM00000008eLF\",\"Tel_No\":\"61234567\",\"Distributor_Contact_Info\":\"test\",\"Distributor_Contact_Person\":\"test\",\"AccountID\":\"001M000000W3P8CIAV\",\"Local_Update_Time\":\"2014/12/01 11:30\",\"WeChatID\":\"112233\"}]}"}
    */
    Issue Issue1 = (Issue)JSON.deserialize(jsonString,Issue.class);
    
    List <ASI_CRM_Issue_Zone__c> a = New List<ASI_CRM_Issue_Zone__c>();
   
    for(IssueStructure c1: Issue1.Issuelist) {
            ASI_CRM_Issue_Zone__c b = New ASI_CRM_Issue_Zone__c();
        
            if( c1.RecordID != null && c1.RecordID !=''){
                b.id = c1.RecordID;
            }
            b.ASI_CRM_Bottles_Sighted1__c=c1.Bottle_Sight_1;
            b.ASI_CRM_Bottles_Sighted2__c=c1.Bottle_Sight_2;
            b.ASI_CRM_Bottles_Sighted3__c=c1.Bottle_Sight_3;
            b.ASI_CRM_Qty2__c=c1.Bottle_Sight_4;
            b.ASI_CRM_Qty3__c=c1.Bottle_Sight_5;
            b.ASI_CRM_Qty__c=c1.Bottle_Sight_6;
            b.ASI_CRM_Product2__c=c1.Product2;
            b.ASI_CRM_Product3__c=c1.Product3;
           
            if(c1.CityID==null || c1.CityID==''){
                  b.ASI_CRM_City__c=null;
            }else{
                  b.ASI_CRM_City__c=c1.CityID;
            }
      
            b.ASI_CRM_Complainant_Name__c=c1.Consumer_Name;
            if(c1.Date_Of_Purchase!= null && c1.Date_Of_Purchase!= ''){
                   
                    integer YYYY= integer.valueof(c1.Date_Of_Purchase.left(4));
                    integer MM= integer.valueof(c1.Date_Of_Purchase.mid(5,2));
                    integer DD= integer.valueof(c1.Date_Of_Purchase.right(2));
                   
                    b.ASI_CRM_Date_Of_Purchase__c = date.newinstance(YYYY,MM,DD);
            }else{
                    b.ASI_CRM_Date_Of_Purchase__c = date.today();
                 }

            b.ASI_CRM_detail_information__c=c1.Detail;
            b.ASI_CRM_Discussion_with_seller__c=c1.Discussion_With_Seller;
            b.ASI_CRM_CN_ImageOutletDetail__c=c1.IOM_Detail;
            b.ASI_CRM_Complainant_s_Expected_Solution__c=c1.Expectation;
            b.ASI_CRM_How_this_complaint_is_learnt__c=c1.How_Complaint_Learnt;
            b.ASI_CRM_Location_Others__c=c1.Location;
            b.ASI_CRM_Lot_Code_on_Bottle__c=c1.Lot_Code;
            if(c1.Manufacturing_Date!= null && c1.Manufacturing_Date!= ''){
                   
                    integer YYYY= integer.valueof(c1.Manufacturing_Date.left(4));
                    integer MM= integer.valueof(c1.Manufacturing_Date.mid(5,2));
                    integer DD= integer.valueof(c1.Manufacturing_Date.right(2));
                   
                    b.ASI_CRM_Manufacture_Date_Time_on_Bottle__c= date.newinstance(YYYY,MM,DD);
            }
        
            if(c1.Manufacturing_Date2!= null && c1.Manufacturing_Date2!= ''){
                       
                        integer YYYY= integer.valueof(c1.Manufacturing_Date2.left(4));
                        integer MM= integer.valueof(c1.Manufacturing_Date2.mid(5,2));
                        integer DD= integer.valueof(c1.Manufacturing_Date2.right(2));
                       
                        b.ASI_CRM_Manufacture_Date_on_Bottle2__c= date.newinstance(YYYY,MM,DD);
                }
        
            if(c1.Manufacturing_Date3!= null && c1.Manufacturing_Date3!= ''){
                       
                        integer YYYY= integer.valueof(c1.Manufacturing_Date3.left(4));
                        integer MM= integer.valueof(c1.Manufacturing_Date3.mid(5,2));
                        integer DD= integer.valueof(c1.Manufacturing_Date3.right(2));
                       
                        b.ASI_CRM_Manufacture_Date_on_Bottle3__c= date.newinstance(YYYY,MM,DD);
                }
            b.ASI_CRM_CN_Lookalike_detail__c=c1.Lookalike_Detail;
            b.ASI_CRM_CN_Origin_of_GMA__c=c1.Origin_Of_GMA;
            b.ASI_CRM_CN_external_detail__c=c1.Origin_Of_GMA2;
          
            if(c1.OutletID==null || c1.OutletID==''){
                   b.ASI_CRM_Outlet_Involved__c=null;
            }else{
                   b.ASI_CRM_Outlet_Involved__c=c1.OutletID;
            }
      
            b.ASI_CRM_Packing_Specification__c=c1.Packing_Specification;
            b.ASI_CRM_CN_Description__c=c1.Description;
            b.ASI_CRM_Price1__c=c1.Price1;
            b.ASI_CRM_Price2__c=c1.Price2;
            b.ASI_CRM_Price3__c=c1.Price3;
            b.ASI_CRM_Product1__c=c1.Product;
            b.ASI_CRM_Reason_for_Complaint__c=c1.Reason_For_Complaint;
            b.ASI_CRM_Qty_Affected__c=c1.Referred_BTL;
            b.ASI_CRM_Remarks_Additional_Info__c=c1.Remarks;          
            b.ASI_CRM_CN_Traceability_Detail__c=c1.Traceability_Detail;
           
            if(c1.Sub_brandID==null || c1.Sub_brandID==''){
                   b.ASI_CRM_Sub_brand__c=null;
            }else{
                   b.ASI_CRM_Sub_brand__c=c1.Sub_brandID;
            }
            b.ASI_CRM_Tel_No__c=c1.Tel_No;
            b.ASI_MFM_WS_Distributor_Contact_Info__c=c1.Distributor_Contact_Info;
            b.ASI_CRM_WS_Distributor_Contact_Person__c=c1.Distributor_Contact_Person;
        	b.ASI_CRM_WeChat_ID__c=c1.WeChatID;
            
            if(c1.AccountID==null || c1.AccountID==''){
                  b.ASI_CRM_WS_Distributor_Involved__c=null;
            }else{
                  b.ASI_CRM_WS_Distributor_Involved__c=c1.AccountID;
            }
      
            b.RecordTypeID=c1.RecordType;
            if(c1.Local_Update_Time!= null && c1.Local_Update_Time!= ''){
                   
                    integer YYYY = integer.valueof(c1.Local_Update_Time.left(4));
                    integer MM = integer.valueof(c1.Local_Update_Time.mid(5,2));
                    integer DD = integer.valueof(c1.Local_Update_Time.mid(8,2));
                    integer HH = integer.valueof(c1.Local_Update_Time.mid(11,2));
                    integer Min = integer.valueof(c1.Local_Update_Time.right(2));
                    b.ASI_CRM_Local_Update_Time__c= Datetime.newInstance(YYYY,MM,DD,HH,Min,0);
            }else{
                     b.ASI_CRM_Local_Update_Time__c= Datetime.now();
                  }
        b.ASI_CRM_QR_Code_Sticker_Issue_Category__c = c1.qrCodeStickerIssueCategory;
        b.ASI_CRM_Can_log_in_PRC_website__c = c1.canYouLogInPRCQRCodeWebsite;
        b.ASI_CRM_website_content__c = c1.whatsTheWebsiteContent;
        b.ASI_CRM_SV_account__c = c1.svAccount;
        b.ASI_CRM_Mobile_Brand_and_System_Version__c = c1.mobileBrandAndSystemVersion;
        b.ASI_CRM_PRQR_Account__c = c1.prqrAccount;
        b.ASI_CRM_Outlet_s_Address__c = c1.outletAddress;
        b.ASI_CRM_Region__c = c1.region;
        
        if(c1.QRCodeSticker1 == Null)
            b.ASI_CRM_QR_Code1__c = FALSE;
        else
        	b.ASI_CRM_QR_Code1__c = c1.QRCodeSticker1;
        
        if(c1.QRCodeSticker2 == Null)
            b.ASI_CRM_QR_Code2__c = FALSE;
        else
        	b.ASI_CRM_QR_Code2__c = c1.QRCodeSticker2;
        
        if(c1.QRCodeSticker3 == Null)
        	b.ASI_CRM_QR_Code3__c = FALSE;
        else
            b.ASI_CRM_QR_Code3__c = c1.QRCodeSticker3;
        
        //--------20150826
        b.ASI_CRM_Brand__c = c1.brand;
        b.ASI_CRM_Bottle_Size_CL__c = c1.bottleSizeCL;
        b.ASI_CRM_Where_did_the_bottle_seen__c = c1.whereDidTheBottleSeen;
        b.ASI_CRM_How_did_you_arrive_this_figure__c = c1.howDidYouArriveThisFiqure;
        b.ASI_CRM_Estimated_Qty__c = c1.estimatedQty;
        b.ASI_CRM_Codes1__c = c1.code1;
        b.ASI_CRM_Codes2__c = c1.code2;
        b.ASI_CRM_Codes3__c = c1.code3;
        b.ASI_CRM_Look_Alike_Name1__c = c1.lookAlikeName1;
        b.ASI_CRM_Look_Alike_Name2__c = c1.lookAlikeName2;
        b.ASI_CRM_Look_Alike_Name3__c = c1.lookAlikeName3;
        
        //20151005
        b.ASI_CRM_Bottle_Size_CL2__c = c1.bottleSizeCL2;
        b.ASI_CRM_Bottle_Size_CL3__c = c1.bottleSizeCL3;
        
        //20150828
        b.ASI_CRM_Alcohol_Volume__c = c1.alcoholVolume;
        
        a.add(b);
    } 
        upsert a;
        
        return 'success';
    }
     global with sharing class IssueStructure{
         
         //-----20151005 Start
         global String bottleSizeCL2{set;get;}
         global String bottleSizeCL3{set;get;}
         //-----20151005 End
         
         //-----20150826 Start
         global String brand{set;get;}
         global String bottleSizeCL{set;get;}
         global String whereDidTheBottleSeen{set;get;}
         global String howDidYouArriveThisFiqure{set;get;}
         global Decimal estimatedQty{set;get;}
         global String code1{set;get;}
         global String code2{set;get;}
         global String code3{set;get;}
         global String lookAlikeName1{set;get;}
         global String lookAlikeName2{set;get;}
         global String lookAlikeName3{set;get;}
         //-----20150826 End
         
         //-----20150828 Start
         global Decimal alcoholVolume{set;get;}
         //-----20150828 End
         global string Bottle_Sight_1{set;get;}
         global string Bottle_Sight_2{set;get;}
         global string Bottle_Sight_3{set;get;}
         global string Bottle_Sight_4{set;get;}
         global string Bottle_Sight_5{set;get;}
         global string Bottle_Sight_6{set;get;}
         global string Product2{set;get;}
         global string Product3{set;get;}
         global string CityID{set;get;}
         global string Consumer_Name{set;get;}
         global string Date_Of_Purchase{set;get;}
         global string Detail{set;get;}
         global string Discussion_With_Seller{set;get;}
         global string IOM_Detail{set;get;}
         global string Expectation{set;get;}
         global string How_Complaint_Learnt{set;get;}
         global string Location{set;get;}
         global string Lot_Code{set;get;}
         global string Manufacturing_Date{set;get;}
         //2015-09-09
         global string Manufacturing_Date2{set;get;}
         global string Manufacturing_Date3{set;get;}
         //2015-09-09 End
         global string Lookalike_Detail{set;get;}
         global string Origin_Of_GMA{set;get;}
         global string Origin_Of_GMA2{set;get;}
         global string OutletID{set;get;}
         global string Packing_Specification{set;get;}
         global string Description{set;get;}
         global Decimal Price1{set;get;}
         global Decimal Price2{set;get;}
         global Decimal Price3{set;get;}
         global string Product{set;get;}
         global string Reason_For_Complaint{set;get;}
         global Decimal Referred_BTL{set;get;}
         global string Remarks{set;get;}
         global string Traceability_Detail{set;get;}
         global string Sub_brandID{set;get;}
         global string Tel_No{set;get;}
         global string Distributor_Contact_Info{set;get;}
         global string Distributor_Contact_Person{set;get;}
         global string AccountID{set;get;}
         global string RecordType{set;get;}
         global string RecordID{set;get;}
         global string Local_Update_Time{set;get;}
         global string WeChatID{set;get;}
         global string qrCodeStickerIssueCategory{set;get;}
         global string canYouLogInPRCQRCodeWebsite{set;get;}
         global string whatsTheWebsiteContent{set;get;}
         global string svAccount{set;get;}
         global string mobileBrandAndSystemVersion{set;get;}
         global string prqrAccount{set;get;}
         global String outletAddress{set;get;}
         global String region{set;get;}
         global Boolean QRCodeSticker1{set;get;}
         global Boolean QRCodeSticker2{set;get;}
         global Boolean QRCodeSticker3{set;get;}
     
         public void replaceNull() {
         
             if(How_Complaint_Learnt==null) How_Complaint_Learnt= '';   
             if(OutletID==null) OutletID= ''; 
             if(Product==null) Product=''; 
             if(CityID==null) CityID= ''; 
             if(AccountID==null) AccountID= ''; 
             if(Sub_brandID==null) Sub_brandID= ''; 
             if(qrCodeStickerIssueCategory==null) qrCodeStickerIssueCategory= '';
             if(canYouLogInPRCQRCodeWebsite==null) canYouLogInPRCQRCodeWebsite= ''; 
             if(whatsTheWebsiteContent==null) whatsTheWebsiteContent= ''; 
             if(svAccount==null) svAccount= ''; 
             if(mobileBrandAndSystemVersion==null) mobileBrandAndSystemVersion= ''; 
             if(prqrAccount==null) prqrAccount= ''; 
             if(WeChatID==null) WeChatID= ''; 
             if(outletAddress == Null) outletAddress = '';
             if(region == Null) region = '';
             if(QRCodeSticker1 == Null) QRCodeSticker1 = FALSE;
             if(QRCodeSticker2 == Null) QRCodeSticker2 = FALSE;
             if(QRCodeSticker3 == Null) QRCodeSticker3 = FALSE;
         }
     }
 }