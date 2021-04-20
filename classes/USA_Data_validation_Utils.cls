/****************************************************
* Name: USA_Data_validation_Utils.cls
* Author: Zachary Huang
* CreateDate: 2018-5-28
* Description: Methods for data validation
****************************************************/
public with sharing class USA_Data_validation_Utils {

    public static List<String> statusList = new List<String>{
        'error','fixed','good'
    };

    //1.Data integrity check  2. Data format check
    public static Map<String,String> Datacheck(Data_validation_Obj obj,String value){
        String filedName = obj.fieldName;
        Map<String,String> rebackMap = new Map<String,String>();

            if(obj.formatType == 1 || obj.formatType == 2 ){
                rebackMap = Data_Check_With_Comma_OR_Semicolon(obj,value,obj.formatType);
            }
            if(obj.formatType == 3 || obj.formatType == 4){
                rebackMap = Data_Check_With_Comma_Combine_Semicolon(obj,value,obj.formatType);
            }
            
        return rebackMap;
    }

    /** for comma or semicolon check 
        param： obj    custom class to store information of field
                value  field value
                type   format type (comma or semicolon)

        Format                              Action                  Description                         
        name,name,name(,/;)                 fix                     at the end of the string is a comma or semilocon    
        name,name,( )name                   fix                     have a whitespace at the start or end of a element  
        name,(),name                        addError                hava a blank element when divided by comma  
        Id,(wrongID),Id                     addError                have a wrong Id type( through compare length and prefix with Id demo)
        name(;)name,name                    fix                     wrong format    
    **/
    public static Map<String,String> Data_Check_With_Comma_OR_Semicolon(Data_validation_Obj obj,String value,Integer type){
        String fix='';  // fixed value
        String mark=''; // comma for type = 1;semicolon for type = 2
        Boolean needFix = false;
        Boolean canfix = obj.canfix;
        String fieldName = obj.fieldName;
        Map<String,String> resultMap = new Map<String,String>();
        List<String> semiList = new List<String>();
        if(type == 1){
            mark = ',';
            semiList = value.split(';');
        }
        if(type == 2){
            mark = ';';
            semiList = value.split(',');
        }
        
        List<String> divideList = value.split('[,;]');
        List<String> checkList = new List<String>();// for comma or semicolon (single mark delimited), trim each part before check Id format
        for(String str:divideList){
            if(string.isBlank(str)){
                resultMap.put(statusList.get(0),system.label.USA_Empty_Error +'【 FieldName:'+fieldName+'】' );
                return resultMap;
            }

            if(str.startsWith(' ')|| str.endsWith(' ')){
                needFix = true;
            }
            checkList.add(str.trim());
        }

        // check the ID length and prefix if necessary
        if(obj.hasId){
            resultMap = checkIdFormat(obj,checkList,false);
            if(resultMap.size()>0){
                return resultMap;
            }
        }
        //check error：Mistaken input ',' to ';' and endwith';'or ','
        if(semiList.size()>1 || value.endswith(';') || value.endsWith(',')){
            needFix=true;
        }
        //fix data
        if(needFix){
            if(canfix){
                for(Integer i=0;i<divideList.size();i++){
                    if(i == divideList.size()-1){
                        fix+=divideList[i].trim();
                    }else{
                        fix+=divideList[i].trim()+mark;
                    }
                }
            }else{
                resultMap.put(statusList.get(0),system.label.USA_Format_Error +'【 FieldName:'+fieldName+'】' );
                return resultMap;
            }            
        }

        if(String.isNotEmpty(fix)){
            resultMap.put(statusList.get(1), fix);
            return resultMap;
        }

        resultMap.put(statusList.get(2), value);
        return resultMap;
    }


   
    /** for Comma & Semicolon check
        param： obj    custom class to store information of field
                value  field value
                type   combination type(comma_semicolon or semicolon_comma)

        Format                              Action                  Description                         
        name(;)Id;name,Id;name,Id           addError                wrong format(',' mistakenly write to ';')
        name,Id(,)name,Id;name,Id           addError                wrong format(';' mistakenly write to ',')   
        name,Id;name,Id;name,Id('/;)        addError                at the end of the string is a comma or semilocon    
        name();name,Id;name,id              addError                lost element
        name,(wrongId);name,Id;name,Id      adderror                have a wrong Id type( through compare length and prefix with Id demo)
        Id,Id;name,Id;name,Id               adderror                wrong name(only for mistakenly write 'name' to 'Id')
        name,Id;( )name,Id;name,Id          addError                have a whitespace at the start or end of a element

    **/
    public static Map<String,String> Data_Check_With_Comma_Combine_Semicolon(Data_validation_Obj obj,String value,Integer type){
        Integer count = obj.subListSize;
        Integer index = obj.IdIndex;
        String fieldName = obj.fieldName;

        String mark =''; // sublist delimit mark; e.g  for (,;) type, mark is ','.
        Map<String,String> resultMap = new Map<String,String>();
        List<String> semiList = new List<String>();

        if(type == 3){
            mark=',';
            semiList = value.split(';');
        }
        if(type == 4){
            mark=';';
            semiList = value.split(',');
        }
        List<String> singleList = value.split('[,;]');
        //system.debug('singleList='+singleList);
        //check the values: name,Id;name,Id
        List<String> idList = new List<String>();
        List<String> nameList = new List<String>();
        if(math.mod(singleList.size(),count)<>0){
            resultMap.put(statusList.get(0), system.label.USA_Data_Integrity_Error+'【 FieldName:'+fieldName+'】');
            return resultMap;
        }
        if(value.endswith(';') || value.endsWith(',')){
            resultMap.put(statusList.get(0), system.label.USA_Format_Error+'【 FieldName:'+fieldName+'】');
            return resultMap;
        }

        for(Integer i=1;i<=singleList.size();i++){
            if (singleList[i-1].startsWith(' ')||singleList[i-1].endswith(' ')||String.isBlank(singleList[i-1])) {
                resultMap.put(statusList.get(0), system.label.USA_Empty_Error+'【 FieldName:'+fieldName+' value:'+singleList[i-1]+'】');
                return resultMap;
            }
        }
    
        system.debug('idlist='+idlist+'--nameList:'+nameList);
        if(obj.hasId){
            for(Integer i=1;i<=singleList.size();i++){
                if(math.mod(i-index,count)==0){
                    idList.add(singleList[i-1]);
                }else{
                    nameList.add(singleList[i-1]);
                }           
            }
            resultMap = checkIdFormat(obj,nameList,true);
            system.debug('resultMap:'+resultMap);   
            if(resultMap.size()>0){
                return resultMap;
            }else{
                resultMap = checkIdFormat(obj,idList,false);
                if(resultMap.size()>0){
                    return resultMap;
                }
            }
        }

        for(String valList: semiList){
            List<String> commaList = valList.split(mark);
            system.debug('commaList.size():'+commaList.size());
            if(commaList.size()<>count){
                resultMap.put(statusList.get(0),system.label.USA_Format_Error+' 【 fieldName:'+fieldName+' value:'+valList+' 】');
                return resultMap;
            }      
        }   
        resultMap.put(statusList.get(2),value);
        return resultMap;
    }
 

    /** check ID/Name
    * 1.Id length   2. Id prefix
    **/
    public static Map<String,String> checkIdFormat(Data_validation_Obj obj,List<String> idList,Boolean isNameCheck){
        String demoStr = obj.IdFormat;
        String fieldName = obj.fieldName;
        Map<String,String> returnMap = new Map<String,String>();
        for(String val: idList){
            system.debug('val.length='+val.length()+'--demo.lenth='+demoStr.length()+'val.prefix='+val.substring(0,3)+'demo.prefix='+demoStr.substring(0,3));
            // system.debug(!(val.length() == demoStr.length() && val.substring(0,3) == demoStr.subString(0,3)) || isNameCheck);
            if(!isNameCheck){
                if(!(val.length() == demoStr.length() && val.substring(0,3) == demoStr.subString(0,3))){
                    returnMap.put(statusList.get(0), system.label.USA_Data_Integrity_Error+ '【 FieldName='+fieldName+' ID='+val+' 】');
                    return returnMap;
                }
            }else{
                if((val.length() == demoStr.length() && val.substring(0,3) == demoStr.subString(0,3))){
                    returnMap.put(statusList.get(0), system.label.USA_Data_Integrity_Error+ '【 FieldName='+fieldName+' Name='+val+' 】');
                    return returnMap;
                }
            }           
        }
        return returnMap;
    }

    /**
    * handle the check result in trigger
    * 1. adderror to the object
    * 2. fix some bad data
    **/

    public static void data_handle(SObject obj,String fieldName,Map<String,Map<String,String>> resultMap){

        String status = new List<String>(resultMap.get(fieldName).keySet())[0];
        if(status == USA_Data_validation_Utils.statusList[0]){
            obj.addError(resultMap.get(fieldName).get(status));
        }
        if(status == USA_Data_validation_Utils.statusList[1]){
            obj.put(fieldName,resultMap.get(fieldName).get(status));
        }   
    }

    
    public static Map<String,Map<String,String>> dataMapCreate(sobject obj,Map<String,Data_validation_Obj> fieldMap){
        Map<String,Map<String,String>> resultMap = new Map<String,Map<String,String>>();
        for(String filed: fieldMap.keySet()){
            if(String.isNotBlank((String)obj.get(filed))){
                resultMap.put(filed,USA_Data_validation_Utils.Datacheck(fieldMap.get(filed), (String)obj.get(filed)));
            }
        }

        return resultMap;
    }


    public class Data_validation_Obj{
        /**
        ** formatType:
        * '1' stand for ','
        * '2' stand for ';'
        * '3' stand for ',&;'
        * '4' stand for ';&,'
        *
        * hasId: true for the string contains Id, otherwise not
        * IdIndex: index of ID in the pair of data. e.g  name1,Id1;name2,Id2, index = 2
        * subListSize: e.g: name1,Id1;name2,Id2  subListSize = 2
        * IdFormat: Id demo
        * canfix: whether this field can be fixed, generally,if the format isn't complex, 'canfix' will be true, otherwise,be false
        * formatType '1' and  '2' need fix,canfix = true,otherwise 'canfix' = false for formatType '3' and '4'  
        */
        public string fieldName{get;set;}
        public Integer formatType{get;set;}
        public Boolean hasId{get;set;}
        public Integer subListSize {get;set;}
        public Integer IdIndex{get;set;}
        public string IdFormat{get;set;}
        public Boolean canfix{get;set;}
    }

}