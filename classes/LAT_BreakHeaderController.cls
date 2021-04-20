/******************************************************************************
*   Company:Valuenet       Developers:Waldemar Mayo        Date:18/02/2014    *
*******************************************************************************/

public with sharing class LAT_BreakHeaderController{
     
    public String paramValue {get;set;}
    public String paramBreaks {get;set;}
     
    public List<String> getListTitleText(){
        List<String> listTitleText = new List<String>();
        if(paramValue.split(' ').size() > 1){
            try{
                if(paramBreaks.equalsIgnoreCase('All')){
                    listTitleText = paramValue.split(' ');
                }else if(paramBreaks.equalsIgnoreCase('Auto')){
                    List<List<String>> listCombination = new List<List<String>>();
                    String firstStr = '';
                    for(Integer i=0; i<paramValue.split(' ').size(); i++){
                        firstStr += (firstStr=='') ? (paramValue.split(' ')[i]) : (' '+paramValue.split(' ')[i]);
                        String secondStr = ''; 
                        for(Integer e=0; e<paramValue.split(' ').size(); e++){
                            if(e > i){
                                secondStr += secondStr=='' ? paramValue.split(' ')[e] : (' '+paramValue.split(' ')[e]);
                            }
                        }
                        if(firstStr.length() == secondStr.length()){
                            return new list<String>{firstStr, secondStr};
                        }
                        listCombination.add(new list<String>{firstStr, secondStr});
                    }
                    Integer minIndex = 0;
                    Integer minComb = null;
                    for(integer i=0; i<listCombination.size(); i++){
                        Integer diff = listCombination[i][0].length() - listCombination[i][1].length();
                        if((minComb == null || minComb > Math.abs(diff)) && (diff != 0)){
                            minComb = Math.abs(diff);
                            minIndex = i;
                        }
                    }
                    listTitleText = listCombination[minIndex];
                }else{
                    set<String> breaks = new set<String>();
                    for(String br: paramBreaks.split(',')){
                        breaks.add(br.trim());
                    }
                    Integer countSpace = 1;
                    while(paramValue.indexOf(' ') != -1){
                        if(breaks.contains(String.ValueOf(countSpace))){
                            paramValue = paramValue.replaceFirst(' ', '<br/>');
                        }else{
                            paramValue = paramValue.replaceFirst(' ', '(nbsp)');
                        }
                        countSpace++;
                    }
                    paramValue = paramValue.replace('(nbsp)', ' ');
                    listTitleText = paramValue.split('<br/>');
                }
            }catch(Exception e){}
        }
         
        if(listTitleText.isEmpty()){
            listTitleText.add(paramValue);
        }
         
        return listTitleText;
    }
}