@isTest
public class ASI_KOR_KeymanAllocationCtrlTest {
    
    @testSetup 
    public static void setupData(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ){
            Profile p = [SELECT Id 
                         FROM profile WHERE name = 'ASI KOR Standard Platform User'];
            
            User adminUser= new User(
                username = 'testqwe12390@test123.com.pernod-ricard.laputaA',
                Email = 'testUser@test123.com',
                lastName = 'adminUser',
                firstName = 'test',
                alias  = 'yougohA',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                emailEncodingKey = 'UTF-8',
                timeZoneSidKey = 'America/Los_Angeles',
                profileId = p.id
                
            );
            
            insert adminUser;
            
            User testUser= new User(
                username = 'testqwe12390@test123.com.pernod-ricard.laputa',
                Email = 'testUser@test123.com',
                lastName = 'keyman',
                firstName = 'test',
                alias  = 'yougohoo',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                emailEncodingKey = 'UTF-8',
                timeZoneSidKey = 'America/Los_Angeles',
                profileId = p.id,
                ASI_KOR_User_Branch_Code__c = '550',
                ASI_KOR_User_Branch_Name__c ='Testing',
                ASI_KOR_User_Region_Code__c = 'R01',
                ASI_KOR_User_Region_Name__c = 'test',
                ASI_KOR_Salesman_Code__c = 'B56'
                
            );
            
            insert testUser;
            
            User branchManager = new User(
                username = 'testqwe12390bm@test123.com.pernod-ricard.laputa',
                Email = 'test1234bm@test123.com',
                lastName = 'bmbm',
                firstName = 'bbm',
                alias  = 'bm123',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                emailEncodingKey = 'UTF-8',
                timeZoneSidKey = 'America/Los_Angeles',
                profileId = p.id,
                ASI_KOR_User_Region_Name__c = 'test Region'
            );
            
            insert branchManager;
            
            group g = [select id from group where DeveloperName = 'ASI_KOR_IT_Admin' limit 1];
            
            groupMember gm = new groupMember(
                groupID = g.id, 
                userOrGroupID = adminUser.id
            );
            insert gm;
        }
        
        User branchManager = [select Id from User where lastname = 'bmbm'];
        User testUser = [select Id from User where lastname = 'keyman'];
        
        RecordType  rType = [select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account'];
        Account venue1 = new Account(
            Name = 'Test Account',
            ASI_KOR_Customer_Code__c = '41352626', 
            ASI_KOR_Postal_Code__c='1234',
            recordtypeid = rType.id,
            ASI_KOR_Grade__c='A',
            ASI_KOR_Venue_Channel__c='TOT', 
            ASI_KOR_Venue_Pillar__c='W-TOT', 
            ASI_KOR_Contract_Type__c='non-Contracted',
            ASI_KOR_Venue_Status__c ='Active',
            OwnerId = testUser.Id
        );
        venue1.ownerid = testUser.id;
        insert venue1;
        
        Contact keyman = new Contact(
            ASI_KOR_Keyman_Code__c = '00001',
            LastName = 'TestContact',
            AccountId = venue1.Id,
            ownerId = testUser.Id    
        );
        
        insert keyman;
        
        ASI_KOR_Brand__c brand = new ASI_KOR_Brand__c(
            Name = 'Test Brand', 
            ASI_KOR_Brand_Code__c = 'BC0001'
            
        );
        
        insert brand;
        
        ASI_KOR_Sub_Brand__c subBrand = new ASI_KOR_Sub_Brand__c (
            Name =  'Test Sub-Brand', 
            ASI_KOR_Brand_Code__c = 'SBC', 
            ASI_KOR_Sub_Brand_Code__c = 'SBC', 
            ASI_KOR_Brand__c = brand.Id
        );
        
        insert subBrand;
        
        ASI_KOR_Item_Group__c itemGroup = new ASI_KOR_Item_Group__c(
            Name = 'IMNE45',
            ASI_KOR_Item_Group_Code__c = 'IMNE45',
            ASI_KOR_Item_Group_Name__c = 'BIS Imperial Neon 45cl',
            ASI_KOR_VMS_Item_Group_Code__c = 'IMNE_450',
            ASI_KOR_Standard_Bottle_Size__c = 450,
            ASI_KOR_Sub_Brand__c = subBrand.Id,
            ASI_KOR_Active__c = true
            
        );
        insert itemGroup;
        
        
        List<ASI_KOR_VMS_Interface_File__c> vmsList = new List<ASI_KOR_VMS_Interface_File__c>();
        
        for (integer i=0; i<=12 ;i++){            
            ASI_KOR_VMS_Interface_File__c vms1 = new ASI_KOR_VMS_Interface_File__c(
                ASI_KOR_Venue__c = venue1.Id,
                //ASI_KOR_Keyman_Original__c = venue1.Id,
                ASI_KOR_Keyman__c = keyman.Id,
                ASI_KOR_Item_Group__c = itemGroup.Id,
                ASI_KOR_Promotion_Month__c = ''+i,
                ASI_KOR_Promotion_Year__c = '2018',
                ASI_KOR_Actual_Volume__c = 4,
                ASI_KOR_Quantity_Case__c = 4,
                ASI_KOR_Final_VI__c = 10,
                ASI_KOR_UOM__c = 'C'          
            );             
            vmsList.add(vms1);            
        }
        
        insert vmsList;
        
        List<ASI_KOR_Branches__c> branchList = new List<ASI_KOR_Branches__c>(); 
        ASI_KOR_Branches__c branch = new ASI_KOR_Branches__c(
            Name = 'Test Branch',
            ASI_KOR_Branch_Code__c = '550',
            ASI_KOR_Region_Code__c = 'R01',
            ASI_KOR_Branch_Manager__c = branchManager.Id 
        );
        
        ASI_KOR_Branches__c branch2 = new ASI_KOR_Branches__c(
            Name = 'Test Branch 2',
            ASI_KOR_Branch_Code__c = '551',
            ASI_KOR_Region_Code__c = 'R02',
            ASI_KOR_Branch_Manager__c = branchManager.Id 
        );
        branchList.add(branch);
        branchList.add(branch2);
        
        insert branchList;
        
        
        List<ASI_KOR_Regions__c> regionList = new List<ASI_KOR_Regions__c>();
        ASI_KOR_Regions__c region= new ASI_KOR_Regions__c(
            Name = 'OFF Trade',
            ASI_KOR_Region_Code__c = 'R03',
            ASI_KOR_Regional_Sales_Director__c = branchManager.id  
        );
        ASI_KOR_Regions__c region2 = new ASI_KOR_Regions__c(
            Name = 'Central Region',
            ASI_KOR_Region_Code__c = 'R04',
            ASI_KOR_Regional_Sales_Director__c = branchManager.id
            
        );
        
        regionList.add(region);
        regionList.add(region2);
        
        insert regionList;
		
		ASI_KOR_NSD_Payment_Settlement_Header__c nsdPaymentSettlementHeader = new
         ASI_KOR_NSD_Payment_Settlement_Header__c();
         nsdPaymentSettlementHeader.ASI_KOR_Month__c = string.valueOf(Date.today().month());
         nsdPaymentSettlementHeader.ASI_KOR_Year__c = string.valueOf(Date.today().year());
         nsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
         nsdPaymentSettlementHeader.ASI_KOR_SYS_Cut_off_Date__c =Date.today();
         insert nsdPaymentSettlementHeader;
         
         ASI_KOR_RSD_Payment_Settlement_Header__c rsdPaymentSettlementHeader = new
         ASI_KOR_RSD_Payment_Settlement_Header__c();
         rsdPaymentSettlementHeader.ASI_KOR_Month__c = string.valueOf(Date.today().month());
         rsdPaymentSettlementHeader.ASI_KOR_Year__c = string.valueOf(Date.today().year());
         rsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Approved by NSD';
         rsdPaymentSettlementHeader.ASI_KOR_NSD_Payment_Settlement__c = nsdPaymentSettlementHeader.Id;
         rsdPaymentSettlementHeader.ASI_KOR_SYS_Cut_off_Date__c =Date.today();
     rsdPaymentSettlementHeader.ownerid = testUser.id;
         insert rsdPaymentSettlementHeader;
        
    }
    
    @isTest 
    public static void testKeymanPage(){
        User currentUser = [select Id from User where lastname = 'keyman'];
        ASI_KOR_Brand__c currentBrand = [select Id from ASI_KOR_Brand__c where Name = 'Test Brand'];
        List<ASI_KOR_VMS_Interface_File__c> vmsFileList = [select Id, ASI_KOR_Final_VI__c, ASI_KOR_CA_Amount__c, ASI_KOR_Actual_Volume__c 
                                                           from ASI_KOR_VMS_Interface_File__c 
                                                           where ASI_KOR_Promotion_Month__c!= null AND ASI_KOR_Promotion_Year__c!=null];
        
        system.runAs(currentUser){
            Test.setCurrentPage(Page.ASI_KOR_KeymanAllocation);
            ASI_KOR_KeymanAllocationCtrl controller = new ASI_KOR_KeymanAllocationCtrl();
            controller.doSave();
            controller.finalizedRecord();
            //controller.getReportLink();
            controller.getYear();
            controller.getMonth();
            controller.getBranch();
            controller.vmsClone();
            controller.vmsDelete();
            ASI_KOR_KeymanAllocationCtrl.wrapper_keymanDetail wrapperClass = new ASI_KOR_KeymanAllocationCtrl.wrapper_keymanDetail('Test Brand',vmsFileList);
            wrapperClass.getVI_approved();
            wrapperClass.getVI_allocated();
            wrapperClass.getActualVolume();
            
        }
        
    }
    
    @isTest 
    public static void testVMSflagTrigger(){
        User currentUser = [select Id from User where lastname = 'adminUser'];
        List<ASI_KOR_VMS_Interface_File__c> vmsFileList = [select Id, ASI_KOR_Final_VI__c, ASI_KOR_CA_Amount__c, ASI_KOR_Actual_Volume__c 
                                                           from ASI_KOR_VMS_Interface_File__c 
                                                           where ASI_KOR_Promotion_Month__c!= null AND ASI_KOR_Promotion_Year__c!=null];
        
        for(ASI_KOR_VMS_Interface_File__c vms : vmsFileList){
            vms.ASI_KOR_VMS_Sync__c = true;
        }
        update vmsFileList;
        for(ASI_KOR_VMS_Interface_File__c vms : vmsFileList){
            vms.ASI_KOR_VMS_Sync__c = false;
        }
        update vmsFileList;
        
        
    }
}