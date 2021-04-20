//Test class :  ; charset=UTF-16;
public class ASI_CRM_KR_SITCSVCtrl {
    public String  Yearstr {set; get;} {Yearstr = '';} 
    public String  Monthstr {set; get;} {Yearstr = '';} 
    //public string FileName {set; get;} {Yearstr = '0';} 
    public limitWrapper[] thousandBlocks {set; get;}  {thousandBlocks= new limitWrapper[]{};}
    //https://pernod-ricard--shsb1full--c.visualforce.com/apex/ASI_CRM_KR_SITCSVPage?Year=2020&Month=Jan     
    public ASI_CRM_KR_SITCSVCtrl(){
        
    }
    
    public void init(){
        integer listLimit = 999;
        
        Yearstr = String.valueOf(ApexPages.currentPage().getParameters().get('Year'));
        Monthstr = String.valueOf(ApexPages.currentPage().getParameters().get('Month'));
        
        Monthstr = Monthstr.substring(0, 3);

        List<ASI_KOR_Item_Group__c> ItemGroupList = [select id,Name,ASI_KOR_Item_Group_Name__c,ASI_CRM_Fixed_Conversion_Rate__c,ASI_KOR_Item_Group_Code__c from ASI_KOR_Item_Group__c where  ASI_CRM_KR_StockInTradeSIT__c = true];
        List<Account> AccountList = [select id,Name,NameLocal,ASI_KOR_Customer_Code__c from account where ASI_LUX_Le_Cercle_Member__c = true and ASI_KOR_Venue_Status__c='Active' and OwnerId =: UserInfo.getUserId()];
        
        integer counter = 0;
        integer loopCount = 0;
        List<rowObject> tempList = new List<rowObject>();
        for(Account acc:AccountList){
            for(ASI_KOR_Item_Group__c itemGroup: ItemGroupList){
                
                if(counter < listLimit){
                    tempList.add(new rowObject(acc,itemGroup));
                    counter++;
                }else{
                    loopCount++;
                    thousandBlocks.add(new limitWrapper(tempList,loopCount));
                    tempList = new List<rowObject>();
                    tempList.add(new rowObject(acc,itemGroup));
                    counter = 0;
                }
                //rowObject temp = new rowObject(acc,itemGroup);
                //rowList.add(temp);
            }
        }
        if(tempList.size() > 0)  {
            loopCount++;
            thousandBlocks.add(new limitWrapper(tempList,loopCount));
        }
        
        /*
        User u = [select id,ASI_CRM_MY_Customer_Category_Code_2__c from user where id = :UserInfo.getUserId()];
        
        if(u.ASI_CRM_MY_Customer_Category_Code_2__c!=null && u.ASI_CRM_MY_Customer_Category_Code_2__c.contains(';') ){
            List<String> parts = u.ASI_CRM_MY_Customer_Category_Code_2__c.split(';');
            if(parts.size()>1){
                system.debug('size :  ' + parts.size());
                Integer num = Integer.valueOf(parts[1]);
                num++;
                FileName = string.valueOf(num);
                if(parts[0] == Monthstr){
                    u.ASI_CRM_MY_Customer_Category_Code_2__c= parts[0] +';'+ string.valueOf(num);
                }else{
                    u.ASI_CRM_MY_Customer_Category_Code_2__c= Monthstr+';'+ string.valueOf(num);
                }
            }else{
               FileName='1';
            }
        }else{
            u.ASI_CRM_MY_Customer_Category_Code_2__c= 'May;1';
            FileName='1';
        }
        
        update u;
*/
        //return new PageReference('/apex/ASI_CRM_KR_ItemUploadPage');                                  
    }
    
    public class limitWrapper{
        public rowObject [] rowObjectList {get;set;}
        public integer blockNumber {get;set;}
        public limitWrapper(rowObject[] templist, integer i){
            this.rowObjectList = templist;
            this.blockNumber = i;
        }
        
    }
    
    
    public class rowObject {
        public String AccountCode  {set;get;} {AccountCode='';}
        public String AccountName  {set;get;} {AccountName='';}
        public String ItemGroupCode  {set;get;} {ItemGroupCode='';}
        public String ItemGroupName  {set;get;} {ItemGroupName='';}

        
        public rowObject(Account acc, ASI_KOR_Item_Group__c itemGroup){
            this.AccountCode = acc.ASI_KOR_Customer_Code__c.replace(',', '');
            this.AccountName = acc.Name.replace(',', '');//NameLocal
            this.ItemGroupCode = itemGroup.ASI_KOR_Item_Group_Code__c.replace(',', '');
            this.ItemGroupName = itemGroup.ASI_KOR_Item_Group_Name__c.replace(',', '');
        }
    }
    
}