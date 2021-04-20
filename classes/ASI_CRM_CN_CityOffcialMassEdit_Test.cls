@isTest
public class ASI_CRM_CN_CityOffcialMassEdit_Test{

    static testMethod void ASI_CRM_CN_CityOffcialMassEditCtrl_Test(){
        Group g = [SELECT Id,Name FROM Group WHERE group.name = 'ASI CRM CN Admin'];     
        list<User> users= [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 2];
        User CNAdmin= users[0];
        User CityManager= users[1];
        CityManager.CompanyName='Pernod Ricard China';
        list <ASI_CRM_Region__c> regionlst = new list <ASI_CRM_Region__c>();        
        regionlst.add(new ASI_CRM_Region__c (Name='TEST',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region')));     
        regionlst.add(new ASI_CRM_Region__c (Name='TEST1',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region')));
        insert regionlst;
        
        list <ASI_CRM_Division__c> divisionlst = new list <ASI_CRM_Division__c>();
        divisionlst.add(new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=regionlst[0].Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Division__cASI_CRM_CN_Region')));
        divisionlst.add(new ASI_CRM_Division__c(Name='TEST1', ASI_CRM_Region__c=regionlst[1].Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Division__cASI_CRM_CN_Region')));
        insert divisionlst;
        
        list <ASI_CRM_CN_Area__c> arealst = new list <ASI_CRM_CN_Area__c>();
        arealst.add(new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=divisionlst[0].Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Area__cASI_CRM_CN_Area')));
        arealst.add(new ASI_CRM_CN_Area__c(Name='TEST1', ASI_CRM_English_Name__c='TEST1', ASI_CRM_Division__c=divisionlst[1].Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Area__cASI_CRM_CN_Area')));
        insert arealst;
        
        list <ASI_CRM_City__c> citylst = new list <ASI_CRM_City__c>();
        citylst.add(new ASI_CRM_City__c(Name='TEST',ASI_CRM_CN_City_Code__c='TESTCITY', ASI_CRM_CN_Area__c=arealst[0].Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City'),ASI_CRM_CN_City_Manager__c=CNAdmin.id));
        citylst.add(new ASI_CRM_City__c(Name='TEST1',ASI_CRM_CN_City_Code__c='TESTCITY1', ASI_CRM_CN_Area__c=arealst[1].Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City'),ASI_CRM_CN_City_Manager__c=CityManager.id));
        insert citylst;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_CN_Brand'),ASI_CRM_CN_Competitor__c=true);
        insert brand; 
            
        ASI_MFM_Sub_brand__c subBrand=new ASI_MFM_Sub_brand__c(Name='subBrand1',ASI_MFM_Brand__c=brand.id,ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'));
        insert subBrand;
        
        list <ASI_MFM_Item_Group__c> itemGrouplst=new list <ASI_MFM_Item_Group__c>();
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name='Test1',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP1',ASI_CRM_CN_Sequence_C__c=1.00,ASI_CRM_CN_Eng_Name__c='TESTENG1',ASI_MFM_Sub_brand__c=subBrand.id));
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name='Test2',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP2',ASI_CRM_CN_Sequence_C__c=22.00,ASI_CRM_CN_Eng_Name__c='TESTENG2',ASI_MFM_Sub_brand__c=subBrand.id));
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name='Test3',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP3',ASI_CRM_CN_Sequence_C__c=333.00,ASI_CRM_CN_Eng_Name__c='TESTENG3',ASI_MFM_Sub_brand__c=subBrand.id));
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name=null,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP4',ASI_CRM_CN_Sequence_C__c=4444.00,ASI_CRM_CN_Eng_Name__c=null,ASI_CRM_CN_Chinese_Name__c=null,ASI_MFM_Sub_brand__c=subBrand.id));
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name='Test5',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP5',ASI_CRM_CN_Sequence_C__c=55555.00,ASI_CRM_CN_Chinese_Name__c='t',ASI_CRM_CN_Eng_Name__c=null,ASI_MFM_Sub_brand__c=subBrand.id));
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name='Test6',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP6',ASI_CRM_CN_Sequence_C__c=666666.00,ASI_CRM_CN_Eng_Name__c='TESTENG6',ASI_CRM_CN_Chinese_Name__c=null,ASI_MFM_Sub_brand__c=subBrand.id));
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name='Test7',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP7',ASI_CRM_CN_Sequence_C__c=777777.00,ASI_CRM_CN_Eng_Name__c=null,ASI_CRM_CN_Chinese_Name__c=null,ASI_MFM_Sub_brand__c=subBrand.id));
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name=null,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP8',ASI_CRM_CN_Sequence_C__c=8888888.00,ASI_CRM_CN_Eng_Name__c='TESTENG8',ASI_MFM_Sub_brand__c=subBrand.id));
        itemGrouplst.add(new ASI_MFM_Item_Group__c(Name='Test9',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),ASI_CRM_CN_City_Official_Input__c=true,ASI_MFM_Item_Group_Code__c='TESTITEMGROUP9',ASI_CRM_CN_Sequence_C__c=null,ASI_CRM_CN_Eng_Name__c='TESTENG9',ASI_CRM_CN_Chinese_Name__c='ABC', ASI_MFM_Sub_brand__c=subBrand.id));
        insert itemGrouplst;
        
        Date today=date.today();
        Integer year =today.year();
        Integer month=today.month();
        Date Datevalue=Date.newInstance(year,month-1,1);
        
        List <ASI_CRM_City_Official__c> lstCityOfficial=new list<ASI_CRM_City_Official__c>();
        lstCityOfficial.add(new ASI_CRM_City_Official__c(ASI_CRM_Item_Group__c=itemGrouplst[0].id,RecordTypeId =Global_RecordTypeCache.getRtId('ASI_CRM_City_Official__cASI_CRM_CN_City_Official'),ASI_CRM_Depletion_Date__c=Datevalue,ASI_CRM_City__c=citylst[0].id,ASI_CRM_Official_Data__c=100));     
        lstCityOfficial.add(new ASI_CRM_City_Official__c(ASI_CRM_Item_Group__c=itemGrouplst[1].id,RecordTypeId =Global_RecordTypeCache.getRtId('ASI_CRM_City_Official__cASI_CRM_CN_City_Official'),ASI_CRM_Depletion_Date__c=Datevalue,ASI_CRM_City__c=citylst[0].id));
        insert lstCityOfficial;
        
        List <ASI_CRM_City_Official__c> lstCityOfficial1=new list<ASI_CRM_City_Official__c>();
        lstCityOfficial1.add(new ASI_CRM_City_Official__c(ASI_CRM_Item_Group__c=itemGrouplst[2].id,RecordTypeId =Global_RecordTypeCache.getRtId('ASI_CRM_City_Official__cASI_CRM_CN_City_Official'),ASI_CRM_Depletion_Date__c=Datevalue,ASI_CRM_City__c=citylst[1].id,ASI_CRM_Official_Data__c=100));     
        lstCityOfficial1.add(new ASI_CRM_City_Official__c(ASI_CRM_Item_Group__c=itemGrouplst[3].id,RecordTypeId =Global_RecordTypeCache.getRtId('ASI_CRM_City_Official__cASI_CRM_CN_City_Official'),ASI_CRM_Depletion_Date__c=Datevalue,ASI_CRM_City__c=citylst[1].id));
        insert lstCityOfficial1;
        
        ASI_CRM_City_Official__c cityOfficial1= new ASI_CRM_City_Official__c(ASI_CRM_Item_Group__c=itemGrouplst[5].id,ASI_CRM_Official_Data__c=99,RecordTypeId =Global_RecordTypeCache.getRtId('ASI_CRM_City_Official__cASI_CRM_CN_City_Official'),ASI_CRM_Depletion_Date__c=Datevalue);        
      
        ASI_CRM_CN_CustomSetting__c customSettingCN = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_PRCCityOfficialReportID__c ='123');
        insert customSettingCN;
        
        system.runAs(CNAdmin){ 
            /*Condition-Showbutton=true*/
            List<GroupMember>listGroupMember =new List<GroupMember>(); 
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = CNAdmin.id;
            listGroupMember.add(gm); 
            insert listGroupMember;
                                   
            ASI_CRM_CN_CityOffcialMassEditCtrl con = new ASI_CRM_CN_CityOffcialMassEditCtrl();
            con.Search();
            con.save();        
            con.confirm();
            con.unlock();
            con.redirectToReport();
        }
         system.runAs(CityManager){ 
            /*Condition-Showbutton=false*/
            ASI_CRM_CN_CityOffcialMassEditCtrl con = new ASI_CRM_CN_CityOffcialMassEditCtrl();
            con.Search();
            con.save();        
            con.confirm();
            con.unlock();
            con.redirectToReport();
        }
    }
}