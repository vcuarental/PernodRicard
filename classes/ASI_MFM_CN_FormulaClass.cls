public without sharing class ASI_MFM_CN_FormulaClass {
    
    Public Static String generateACCode(String BUPrefix, String BUSuffix, String departmentCode, String ACCode, String subbrandCode){
        
        Return BUPrefix + departmentCode + subbrandCode + BUSuffix + '.' + ACCode;
    }
    
    Public static decimal stringToValue(String formulaString, Map<String, Schema.SObjectField> schemaMap, Set<String> relationShipFieldSet, sObject obj){
        
        List<String> fields = new List<String>();
        List<String> combination = new List<String>();
        
        formulaString = formulaString.replaceAll( '\\s+', '');
        
        fields = formulaString.split('[\\p{Punct}&&[^_.]]');
        combination = combinationOfBracket(formulaString);
        combination.add(formulaString);
        
        Map<String, decimal> fieldValueMap = fieldValue(fields, schemaMap, relationShipFieldSet, obj);
        decimal result = calculateValue(fieldValueMap, combination, formulaString);
        
        system.debug('Final Result.     ' + result);
        
        return result;
    }
    
    Private Static decimal calculateValue(Map<String, decimal> fieldValueMap, List<String> combination, String formula){
        
        Map<String, String> elementValue = new Map<String, String>();
        
        for(String s : combination){
            
            List<decimal> value = new List<decimal>();
            Integer position = null;
            String f = s;
            
            system.debug('original fields : ' + f);
            
            for(String k : elementValue.keySet()){
                
                if(f.indexOfIgnoreCase(k) > -1){
                    
                    system.debug('elementValue.get(k) ' + elementValue.get(k));
                    system.debug('s, formula ' + s + '     k, Formula.     ' + k);
                    
                    f = f.replace(k, String.valueOf(elementValue.get(k)));
                    
                    system.debug('20171030hbsdkjansd     ' + elementValue.containsKey(k));
                    system.debug('s.replace(k, String.valueOf(elementValue.get(k))).     ' + f);
                }
            }
            
            for(String v : fieldValueMap.keySet()){
                
                if(f.indexOfIgnoreCase(v) > -1 && !v.remove('.').isNumeric()){
                    
                    system.debug('fieldValue.get(v) ' + fieldValueMap.get(v));
                    
                    f = f.replace(v, String.valueOf(fieldValueMap.get(v)));
                }
            }
            
            system.debug('converted fields : ' + f);
            
            elementValue.put(s, String.valueOf(calculation(f)));
        }
        
        return decimal.valueOf(elementValue.get(formula));
    }
    
    Private Static decimal calculation(String formula){
        
        decimal returnValue;
        String editFormula = '';
        
        formula = formula.replaceAll('[\\p{Punct}&&[^*/+-.]]', '').replaceAll('\\-\\-', '\\+').replaceAll('\\+\\+', '\\+').replaceAll('\\+\\-', '\\-').replaceAll('\\-\\+', '\\-');
        editFormula = formula;
        
        system.debug('formula split  ' + formula);
        
        formula = formula.replaceAll('(\\*\\-)', '@');
        formula = formula.replaceAll('(\\/\\-)', '#');
        
        for(String s : formula.split('[\\+\\-]')){//20180419 Introv Added &&^[(*\\-)(/\\-)] //[\\+\\-&&[^(*\\-)(/\\-)]]'
            
            s = s.replaceAll('@', '*-');
            s = s.replaceAll('#', '/-');
            
            if(s.contains('*') || s.contains('/') ){
                
                returnValue = operation(s, '*', '/');
                system.debug('formula */.      ' + s + '          returnValue.   ' + returnValue);
                
                if(editFormula.indexOfIgnoreCase(s) > -1){
                    
                    editFormula = editFormula.replace(s, String.valueOf(returnValue));
                }
            }
        }
        
        if(editFormula.contains('+') || editFormula.contains('-') ){
            
            returnValue = operation(editFormula, '+', '-');
            system.debug('formula +-.      ' + editFormula + '          returnValue.   ' + returnValue);
        }
        
        system.debug('formulaAAAAAAAAA.      ' + editFormula);
        
        system.debug('returnValue.      ' + returnValue);
        
        if(returnValue == Null && formula.remove('.').isNumeric())
            returnValue = decimal.valueOf(formula);
        
        return returnValue;
    }
    
    Private Static decimal operation(String formula, String symbol_A, String symbol_B){
		
        Integer j = 0;
        Integer k = 0;
        decimal total = 0;
        List<Integer> ordering = new List<Integer>();
        List<Integer> symbol_A_List = new List<Integer>();
        List<Integer> symbol_B_List = new List<Integer>();
        Map<Integer, String> mapSymbol = new Map<Integer, String>();
        
        while(j != -1 || k != -1){
            
            if(j != -1){
                
                if(symbol_A_List.size() > 0 && symbol_A_List[symbol_A_List.size() - 1] == j - 1)
                    continue;
                
                j = formula.indexOf(symbol_A, j + 1);
                
                if(j != -1){
                    mapSymbol.put(j, symbol_A);
                    ordering.add(j);
                    symbol_A_List.add(j);
                }
            }
            
            if(k != -1){
                
                k = formula.indexOf(symbol_B, k + 1);
                
                if(k != -1){
                    
                    if(symbol_B_List.size() > 0 && symbol_B_List[symbol_B_List.size() - 1] == k - 1)
                        continue;
                    
                    mapSymbol.put(k, symbol_B);
                    ordering.add(k);
                    symbol_B_List.add(k);
                }
            }
            
            system.debug('formula   ' + formula);
            system.debug('j.  ' + j + '     k.   ' + k);
        }
        
        ordering.sort();
        
        for(Integer o = 0; o < ordering.size(); o++ ){
            
            if(o == 0){
                total = decimal.valueOf(formula.substring(0, ordering[o]));
            }
            
            if(o + 1 < ordering.size()){
                
                if(mapSymbol.get(ordering[o]) == symbol_A){
                    
                    total = identification(total, decimal.valueOf(formula.substring(ordering[o] + 1, ordering[o + 1])), symbol_A);
                }else{
                    
                    total = identification(total, decimal.valueOf(formula.substring(ordering[o] + 1, ordering[o + 1])), symbol_B);
                }
            }else{
                
                if(mapSymbol.get(ordering[o]) == symbol_A){
                    
                    total = identification(total, decimal.valueOf(formula.substring(ordering[o] + 1)), symbol_A);
                }else{
                    
                    total = identification(total, decimal.valueOf(formula.substring(ordering[o] + 1)), symbol_B);
                }
            }
        }
        
        Return total;
    }
    
    Private Static Map<String, decimal> fieldValue(List<String> fields, Map<String, Schema.SObjectField> schemaMap, Set<String> relationShipFieldSet, sObject obj){
        
        Map<String, decimal> mapValue = new Map<String, decimal>();
        
        for(String f : fields){
            if(f != '' && f != null && (schemaMap.containsKey(f) || relationShipFieldSet.contains(f.toLowerCase()))){
                
                decimal value;
                
                if(f.contains('.')){
                    
                    List<String> splitStr = f.split('\\.');
                    sObject obj2 = obj;
                    
                    for(integer i = 0; i < splitStr.size(); i++){
                        if(i + 1 != splitStr.size()){
                            
                            obj2 = obj2.getSobject(splitStr[i]);
                        }else{
                            
                            value = obj2.get(splitStr[i]) != Null ? (decimal)obj2.get(splitStr[i]) : 0;
                        }
                    }    
                }else{
                    
                    value = obj.get(f) != Null ? (decimal)obj.get(f) : 0;
                }
                
                mapValue.put(f, value);
            }
        }
        
        return mapValue;
    }
    
    Private Static decimal identification(decimal a, decimal b, String symbol){
        
        if(symbol == '+')
            return (a + b).setScale(6);
        else if(symbol == '-')
            return (a - b).setScale(6);
        else if(symbol == '*')
            return (a * b).setScale(6);
        else
            return (a / b).setScale(6);
    }
    
    Private Static List<String> combinationOfBracket(String formula){
        
        List<String> combination = new List<String>();
        Set<Integer> splittedIndex = new Set<Integer>();
        Integer startBracket = null;
        Integer endBracket = null;
        Integer i = 0;
        
        while(i < formula.length()){
            
            if(formula.subString(i, i + 1) == '('){
                
                if(!splittedIndex.contains(i)){
                    startBracket = i;
                }
            }
            
            if(formula.subString(i, i + 1) == ')'){
                
                if(!splittedIndex.contains(i)){
                    
                    endBracket = i;
                    
                    combination.add(formula.substring(startBracket, endBracket + 1));
                    splittedIndex.add(startBracket);
                    splittedIndex.add(endBracket);
                    i = 0;
                    continue;
                }
            }
            
            i++;
        }
        
        return combination;
    }
}