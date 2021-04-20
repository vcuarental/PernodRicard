/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* NAME: CustomerReturn.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                               DATE: 14/01/2013 
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. 
*******************************************************************************/
global class CustomerReturn {
   webService static Integer ETL_SF_ClientLoad(Integer country, String customer_AN8, String customer_Group, String cod_Warehouse, String cod_Salesman, String cod_Currency, String cod_ProgAdjust) {
     Integer res = -1;
     
    Set< Id > setRecTypeAcc = new Set< Id >();
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
    setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
        
     if (customer_AN8!=null && cod_Salesman!=null){
        List<User> arrayUser = null; 
        List<Account> arrayAccount = null;        
        User user = null;      
        Account account; 
        arrayUser = [Select Id  from User  where C_digo_JDE__c=:cod_Salesman limit 1];
        if (arrayUser!=null && arrayUser.size()>0){        
          user = arrayUser[0];          
          arrayAccount = [ SELECT Client_code_AN8__c,Price_Group__c,Business_Unit__c,OwnerId 
            FROM Account WHERE Client_code_AN8__c =: customer_AN8 AND RecordTypeId =: setRecTypeAcc ];
          if ((arrayAccount!=null) && (arrayAccount.size()>0)){
            account = arrayAccount[0];
            account.Client_code_AN8__c=customer_AN8;
            account.Price_Group__c=customer_Group;
            //account.Business_Unit__c=cod_Warehouse;
            account.OwnerId=user.Id;
            update account;
          }          
          
          if (account!=null && account.Id!=null) res=0;        
        }else  res = 2;
     }else  res = 1;
     return res; 
    }
}